;;; dpastede.el --- Emacs integration for dpaste.de

;; Copyright (C) 2008, 2009 Greg Newman <20seven.org>

;; Version: 0.1
;; Keywords: paste pastie pastebin dpaste python
;; Created: 18 Dec 2009
;; Author: Greg Newman <grep@20seven.org>
;; Guilherme Gondim <semente@taurinus.org>
;; Maintainer: Greg Newman <greg@20seven.org>

;; This file is NOT part of GNU Emacs.

;; This is free software; you can redistribute it and/or modify it under
;; the terms of the GNU General Public License as published by the Free
;; Software Foundation; either version 2, or (at your option) any later
;; version.
;;
;; This is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
;; for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
;; MA 02111-1307, USA.

;;; Commentary:

;; dpastede.el provides functions to post a region or buffer to
;; <http://dpaste.de> and put the paste URL into the kill-ring.

;; Installation and setup:

;; Put this file in a directory where Emacs can find it. On GNU/Linux
;; it's usually /usr/local/share/emacs/site-lisp/ and on Windows it's
;; something like "C:\Program Files\Emacs<version>\site-lisp". Then
;; add the follow instructions in your .emacs.el:

;;     (require 'dpastede nil)
;;     (global-set-key (kbd "C-c p") 'dpastede-region-or-buffer)
;;     (setq dpastede-poster "Guido van Rossum")

;; Then with C-c p you can run `dpastede-region-or-buffer'. With a prefix
;; argument (C-u C-c p), your paste will use the hold option.

;; Todo:

;; - Use emacs lisp code to post paste instead curl (version 0.3)

;;; Code:
(defvar dpastede-poster "dpastede.el"
  "Paste author name or e-mail. Don't put more than 30 characters here.")

(defvar dpastede-supported-modes-alist '((css-mode . "CSS")
                                       (diff-mode . "Diff")
                                       (html-mode . "Django/Jinja")
                                       (javascript-mode . "JavaScript")
                                       (js2-mode . "JavaScript")
                                       (python-mode . "Python")
                                       (inferior-python-mode . "Python console session")
                                       (sql-mode . "SQL")
                                       (sh-mode . "Bash")))


;;;###autoload
(defun dpastede-region (begin end title &optional arg)
  "Post the current region or buffer to dpaste.de and yank the
url to the kill-ring.

With a prefix argument, use hold option."
  (interactive "r\nsPaste title: \nP")
  (let* ((file (or (buffer-file-name) (buffer-name)))
         (name (file-name-nondirectory file))
         (lang (or (cdr (assoc major-mode dpastede-supported-modes-alist))
                  ""))
         (hold (if arg "on" "off"))
         (output (generate-new-buffer "*dpastede*")))
    (shell-command-on-region begin end
			     (concat "curl -si"
                                     " -F 'content=<-'"
;                                     " -F 'lexer=" lang "'"
;                                     " -F 'title=" title "'"
;                                     " -F 'poster=" dpastede-poster "'"
;                                     " -F 'expire_options=2592000'"
                                     " http://dpaste.de/api/")
			     output)
    (with-current-buffer output
;      (search-forward-regexp "^Location: \\(http://dpaste\\.de/\\(hold/\\)?[0-9]+/\\)")
;      (message "Paste created: %s (yanked)" (match-string 1))
      (message "Paste created")
      (kill-new (match-string 1)))
    (kill-buffer output)))

;;;###autoload
(defun dpastede-buffer (title &optional arg)
  "Post the current buffer to dpaste.com and yank the url to the
kill-ring.

With a prefix argument, use hold option."
  (interactive "sPaste title: \nP")
  (dpastede-region (point-min) (point-max) title arg))

;;;###autoload
(defun dpastede-region-or-buffer (title &optional arg)
  "Post the current region or buffer to dpaste.com and yank the
url to the kill-ring.

With a prefix argument, use hold option."
  (interactive "sPaste title: \nP")
  (condition-case nil
      (dpastede-region (point) (mark) title arg)
    (mark-inactive (dpaste-buffer title arg))))


(provide 'dpastede)
;;; dpastede.el ends here.
