(load-library "iso-transl")

(add-to-list 'load-path "~/.emacs.d/vendor/org-mode/lisp")
(add-to-list 'load-path "~/.emacs.d/vendor/org-mode/contrib/lisp")

(add-to-list 'load-path "~/.emacs.d/vendor")
(progn (cd "~/.emacs.d/vendor")
       (normal-top-level-add-subdirs-to-load-path))

(setq load-path (cons "~/.emacs.d/vendor/rinari/util" load-path))
(setq load-path (cons "~/.emacs.d/vendor/rinari/util/jump" load-path))
;(add-to-list 'load-path "~/.emacs.d/vendor/org-mode/lisp")
;(add-to-list 'load-path "~/.emacs.d/vendor/org-mode/contrib/lisp")
;(setq load-path (cons "~/.emacs.d/vendor/org-mode/lisp" load-path))
;(setq load-path (cons "~/.emacs.d/vendor/org-mode/contrib/lisp" load-path))

(defconst emacs-config-dir "~/.emacs.d/configs/" "")
(setq load-path (cons "~/.emacs.d" load-path))
(defun load-cfg-files (filelist)
  (dolist (file filelist)
    (load (expand-file-name
           (concat emacs-config-dir file)))
    (message "Loaded config file: %s" file)
    ))


(add-to-list 'load-path "/usr/share/emacs/site-lisp/w3m")
;(if window-system
;   (require 'w3m-load))
;(require 'org-mac-protocol)

(load-cfg-files '("browse_kill_ring"
                  "custom"
                  "git"
                  "gnus"
                  "highlight_line"
                  "ido"
                  "javascript"
                  "lorem"
                  "main"
                  "org"
                  "python"
                  "ruby"
                  "shell"
;                  "slime"
                  "smex"
                  "textmate"
                  "theme"
                  "yasnippet"))

(setq custom-file "~/.emacs.d/configs/custom.el")

(require 'dpaste)
(require 'font-lock)
(require 'gist)
(require 'grep-o-matic)
(require 'growl)
(require 'nav)
(require 'saveplace)
(require 'textile-mode)
(require 'vernacular-time)
(require 'pymacs)
(require 'auto-complete)
(require 'rst)
;(require 'flyspell)

(setq confirm-kill-emacs
      (lambda (e)
        (y-or-n-p-with-timeout
         "Really exit Emacs (automatically exits in 5 secs)? " 5 t)))