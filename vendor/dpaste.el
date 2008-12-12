;;; dpaste.el --- Emacs integration for dpaste.com

;; Copyright (C) 2008 Greg Newman <20seven.org>
     
;; Version: 0.1.1
;; Keywords: paste pastie pastebin dpaste python
;; Created: 01 Dec 2008
;; Author: Greg Newman <20seven.org>
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
;;  dpaste.el will post a region or if no region is selected, the buffer to http://dpaste.com and
;;  and put the url into the kill-ring 
;;  current api usage example: curl -si -F 'content=<-' http://dpaste.com/api/v1/ | grep ^Location: | colrm 1 10

;;  Thanks to Paul Bissex (http://news.e-scribe.com) for a great paste service
;;  Inspired by gist.el


;;  TODO: add additional fields for title and poster

;;; Code:

(defvar dpaste-supported-modes-alist '((css-mode . "Css")
                                     (diff-mode . "Diff")
                                     (haskell-mode . "Haskell")
                                     (html-mode . "DjangoTemplate")
                                     (javascript-mode . "JScript")
                                     (js2-mode . "JScript")
                                     (python-mode . "Python")
                                     (ruby-mode . "Ruby")
                                     (text-mode . "Plain")
                                     (sql-mode . "Sql")
                                     (sh-mode . "Bash")
                                     (xml-mode . "Xml")))

;;;###autoload
(defun dpaste-region (begin end)
  "post the current region or buffer to dpaste.com and yank the url to the kill-ring"
  (interactive "r")
  (let* ((file (or (buffer-file-name) (buffer-name)))
         (name (file-name-nondirectory file))
         (ext (or (cdr (assoc major-mode dpaste-supported-modes-alist))
                  (file-name-extension file)
                  "txt"))
         (output (generate-new-buffer " *dpaste*")))
    (shell-command-on-region
     begin end
     (format (concat "curl -si "
                     "-F 'language=%s' "
                     "-F 'content=<-' "
                     "http://dpaste.com/api/v1/")ext name)
     output)
    (with-current-buffer output
      (search-backward-regexp "^Location: \\([A-Za-z0-9]+.*\\)")
      (message "dpaste created: %s" (match-string 1))
      (kill-new (match-string 1)))
   (kill-buffer output)))

;;;###autoload
(defun dpaste-buffer ()
  "post the current buffer to dpaste.com and yank the url to the kill-ring"
  (interactive)
  (dpaste-region (point-min) (point-max)))

;;;###autoload
(defun dpaste-region-or-buffer ()
  "post the current region or buffer to dpaste.com and yank the url to the kill-ring"
  (interactive)
  (condition-case nil
      (dpaste-region (point) (mark))
      (mark-inactive (dpaste-buffer))))


(provide 'dpaste)
;;; dpaste.el ends here.