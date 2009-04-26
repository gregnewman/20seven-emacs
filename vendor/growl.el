;;; growl.el --- Send message to Growl(include clones and network).

;; Copyright (C) 2008  Takeru Naito

;; Author: Takeru Naito <takeru.naito@gmail.com>
;; Keywords: growl

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; * Description
;;
;; growl.el Send message to Growl(include clones and network).
;;
;; * Usage
;;
;; Just put the code like below into your .emacs:
;;
;; (require 'growl)
;;
;; and...
;;
;; (growl "Hello World.")
;;

;;; Change Log:

;; 2008-12-27:
;;  * Added mumbles-send support.
;;
;; 2008-12-23:
;;  * Initial import.

;;; Code:

(require 'bindat)
(or (require 'hmac-md5 nil t)
    (and (require 'hex-util nil t)
         (defun md5-binary (string)
           (decode-hex-string (md5 string)))))
;; vars
(defconst growl-udp-port 9887)
(defconst growl-protocol-version 1)
(defconst growl-type-registration 0)
(defconst growl-type-notification 1)

(defvar growl-application-name "Emacs")
(defvar growl-default-title "Emacs")
(defvar growl-udp-all-notifes (list "Emacs Notification"))
(defvar growl-udp-default-notifies growl-udp-all-notifes)
(defvar growl-udp-registered-p nil)
(defvar growl-udp-registration-before-wait 1)
(defvar growl-udp-registration-after-wait 1)
(defvar growl-udp-password nil)
(defvar growl-udp-process nil)

(defvar growl-notify-function
  (cond
   ((executable-find "growlnotify")   'growl-growlnotify)
   ((executable-find "mumbles-send")  'growl-mumbles-send)
   ((executable-find "whinesend")     'growl-whinesend)
   (t                                 'growl-udp-send-generic)))

;; UDP packet definitions
(defun growl-udp-registration-packet ()
  (let*
      ((growl-network-registration-format
        '((:version u8)
          (:type u8)
          (:app-name-length u16)
          (:num-all-notifications u8)
          (:num-default-notifications u8)))

       (packet
        (concat
         (bindat-pack
          growl-network-registration-format
          `((:version . ,growl-protocol-version)
            (:type .  ,growl-type-registration)
            (:app-name-length . ,(length growl-application-name))
            (:num-all-notifications . ,(length growl-udp-all-notifes))
            (:num-default-notifications . ,(length growl-udp-default-notifies))))
         growl-application-name

         (mapconcat (lambda (notify)
                      (concat (bindat-pack
                               '((:length u16))
                               `((:length . ,(length notify))))
                              notify))
                    growl-udp-all-notifes nil)

         (mapconcat (lambda (notify)
                      (when (member notify growl-udp-all-notifes)
                        (bindat-pack
                         '((:length u8))
                         `((:length . ,(- (length growl-udp-all-notifes)
                                          (length (member notify growl-udp-all-notifes))))))))
                    growl-udp-default-notifies nil)))

       (checksum (md5-binary (concat packet growl-udp-password))))

    (concat packet checksum)))

(defun growl-udp-notification-packet (name title description &optional priority sticky)
  (let*
      ((growl-network-notification-format
        '((:version u8)
          (:type u8)
          (:flags u16)
          (:name-length u16)
          (:title-length u16)
          (:description-length u16)
          (:app-name-length u16)))

       (priority (or priority 0))
       (flags (logior 0 (lsh 1 (logand #x7 priority))))

       (packet
        (concat
         (bindat-pack
          growl-network-notification-format
          `((:version . ,growl-protocol-version)
            (:type .  ,growl-type-notification)
            (:flags . ,(if sticky (logior 1 flags) flags))
            (:name-length . ,(length name))
            (:title-length . ,(length title))
            (:description-length . ,(length description))
            (:app-name-length . ,(length growl-application-name))))
         name
         title
         description
         growl-application-name))

       (checksum (md5-binary (concat packet growl-udp-password))))

    (concat packet checksum)))

(defun growl-udp-make-network-process ()
  (make-network-process
   :name growl-application-name
   :host 'local
   :type 'datagram
   :service growl-udp-port))

(defun growl-udp-make-netcat-process ()
  (condition-case nil
      (let ((process-connection-type nil))
        (start-process "growl-nc" " *growl-netcat*"
                       "nc" "-u" "localhost"
                       (int-to-string growl-udp-port)))
    (error "No usable send program")))

(defun growl-udp-get-or-create-process ()
  (unless (memq growl-udp-process (process-list))
    (setq growl-udp-process
          (cond
           ((eq growl-notify-function 'growl-udp-send-udp)
            (growl-udp-make-network-process))
           ((eq growl-notify-function 'growl-udp-send-netcat)
            (growl-udp-make-netcat-process))
           ((eq growl-notify-function 'growl-udp-send-generic)
            (condition-case nil
                (growl-udp-make-network-process)
              ((error "Unsupported connection type")
               (growl-udp-make-netcat-process)))))))
    growl-udp-process)

(defun growl-udp-send (str)
  (let
      ((process-connection-type nil)
       (conn (growl-udp-get-or-create-process)))
    (process-send-string conn str)))

(defun growl-udp-registration ()
  (growl-udp-send (growl-udp-registration-packet)))

;; External client settings.
(defun growl-growlnotify (message)
  (start-process "growlnotify" " *growlnotify*"
                 "growlnotify"
                 "--name" "Emacs"
                 "--appIcon" "Emacs"
                 "--message" message))

(defun growl-mumbles-send (message)
  (start-process "mumbles-send" " *mumbles-send*"
                 "mumbles-send"
                 growl-default-title
                 message))

(defun growl-whinesend (message)
  (start-process "whinesend" " *whinesend*"
                 "whinesend"
                 "-t" growl-default-title
                 "-i" (car command-line-args)
                 "-m" message))

;; UDP client settings.
(defun growl-udp-send-generic (message)
  (unless growl-udp-registered-p
    (sit-for growl-udp-registration-before-wait)
    (growl-udp-registration)
    (sit-for growl-udp-registration-after-wait)
    (setq growl-udp-registered-p t))
  (growl-udp-send
   (growl-udp-notification-packet (car growl-udp-all-notifes)
                                  growl-default-title
                                  message)))

(defalias 'growl-udp-send-udp 'growl-udp-send-generic)
(defalias 'growl-udp-send-netcat 'growl-udp-send-generic)

;; main
(defun growl (message)
  (funcall growl-notify-function message))

(provide 'growl)

;;; growl.el ends here

;; Local Variables:
;; mode: emacs-lisp
;; coding: utf-8-unix
;; indent-tabs-mode: nil
;; End:
