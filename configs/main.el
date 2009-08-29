;; no splash screen
(setq inhibit-startup-message t)

;; use UTF-8
(prefer-coding-system 'utf-8)

; Lines shouldn't be longer than 79 chars
(setq fill-column 72)

;; allow remote editing through transmit
(setq backup-by-copying t) 

;; make pretty
(global-font-lock-mode 1)

;; remove the beeping, it drives me nuts
(setq ring-bell-function 'ignore)
 
;; shows current selected region
(setq-default transient-mark-mode t)

;; indent via spaces not tabs
(setq-default indent-tabs-mode nil)

;; titlebar = buffer unless filename
(setq frame-title-format '(buffer-file-name "%f" ("%b")))

;; show paired parenthasis
(show-paren-mode 1)
 
;(set-default-font "-adobe-courier-bold-o-normal--18-180-75-75-m-110-iso8859-13")

;; TAB => 4*'\b'
(setq default-tab-width 4)

;; line numbers
(global-linum-mode 1)
(setq column-number-mode  t)

;; turn off tool bar, and menu bar
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;; log the time of the things I have done
(setq-default org-log-done t) 

;; get rid of yes-or-no questions - y or n is enough
(defalias 'yes-or-no-p 'y-or-n-p)
 
(require 'uniquify)
(setq uniquify-buffer-name-style 'reverse)
(setq uniquify-separator "|")
(setq uniquify-after-kill-buffer-p t) ; rename after killing uniquified
(setq uniquify-ignore-buffers-re "^\\*") ; don't muck with special buffers

;; disable line wrap
(setq default-truncate-lines nil)

;; make side by side buffers function the same as the main window
(setq truncate-partial-width-windows nil)

;; full screen toggle using command+[RET]
(defun toggle-fullscreen () 
  (interactive) 
  (set-frame-parameter nil 'fullscreen (if (frame-parameter nil 'fullscreen) 
                                           nil 
                                           'fullboth)))

;;; NOT USING SINCE EMACS 23 DOESN'T SUPPORT FULL SCREEN IN MAC BUILDS YET
;(global-set-key [(meta return)] 'toggle-fullscreen) 
(global-set-key (kbd "C-,") 'toggle-fullscreen)

;; bury the buffer
(global-set-key [f8] 'bury-buffer)

;; ibuffer key
(global-set-key (kbd "C-;") 'ibuffer)

;; windmove bindings
(when (fboundp 'windmove-default-keybindings)
      (windmove-default-keybindings))

;; Place Backup Files in Specific Directory
;; Enable backup files.
(setq make-backup-files t)

;; Enable versioning with default values (keep five last versions, I think!)
(setq version-control t)

;; Save all backup file in this directory.
(setq backup-directory-alist (quote ((".*" . "~/.emacs_backups/"))))

; stolen from http://github.com/febuiles/dotemacs/tree/master/temp_files.el
(defvar user-temporary-file-directory
  (concat temporary-file-directory user-login-name "/"))
(make-directory user-temporary-file-directory t)
(setq backup-by-copying t)
(setq backup-directory-alist
      `(("." . ,user-temporary-file-directory)
        (,tramp-file-name-regexp nil)))
(setq auto-save-list-file-prefix
      (concat user-temporary-file-directory ".auto-saves-"))
(setq auto-save-file-name-transforms
      `((".*" ,user-temporary-file-directory t)))

(add-to-list 'load-path "/usr/local/share/emacs/site-lisp")

(setq delete-old-versions t)

(pc-selection-mode)

(server-start)

(setq initial-frame-alist '((top . 1) 
                            (left . 1) 
                            (width . 100) 
                            (height . 45)))

;; clean out buffers except shell, agenda and org
(defun restart ()
  (interactive)
  (let ((list (buffer-list)))
    (while list
      (let* ((buffer (car list))
             (name (buffer-name buffer)))
        (and (not (string-equal name "*shell*"))
             (not (string-equal name "*Org Agenda*"))
             (not (string-equal name "greg.org"))
             (kill-buffer buffer)))
      (setq list (cdr list)))))


;; SavePlace
(setq save-place-file "~/saveplace") ;; keep my ~/ clean
(setq-default save-place t)                   ;; activate it for all buffers