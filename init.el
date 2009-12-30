(load-library "iso-transl")
(add-to-list 'load-path "/usr/local/share/emacs/site-lisp")
(add-to-list 'load-path "~/.emacs.d/vendor/org-mode/lisp")
(add-to-list 'load-path "~/.emacs.d/vendor/org-mode/contrib/lisp")

(add-to-list 'load-path "~/.emacs.d/vendor")
(progn (cd "~/.emacs.d/vendor")
       (normal-top-level-add-subdirs-to-load-path))

(defconst emacs-config-dir "~/.emacs.d/configs/" "")
(setq load-path (cons "~/.emacs.d" load-path))
(defun load-cfg-files (filelist)
  (dolist (file filelist)
    (load (expand-file-name
           (concat emacs-config-dir file)))
    (message "Loaded config file: %s" file)
    ))

(load-cfg-files '("browse_kill_ring"
                  "custom"
                  "git"
                  "highlight_line"
                  "ido"
                  "javascript"
                  "lorem"
                  "main"
                  "org"
                  "python"
                  "ruby"
                  "rst"
                  "shell"
                  "slime"
                  "smex"
                  "theme"
                  "yasnippet"))

(setq custom-file "~/.emacs.d/configs/custom.el")

(require 'dpaste)
(require 'flymake)
(require 'dpastede)
(require 'font-lock)
(require 'gist)
(require 'growl)
(require 'nav)
(require 'saveplace)
(require 'textile-mode)
(require 'vernacular-time)
;(require 'pymacs)
(require 'auto-complete)
(require 'rst)
(require 'mercurial)
;(require 'flyspell)
(require 'todochiku)
;(require 'desktop)
(require 'uniquify)

(setq confirm-kill-emacs
      (lambda (e)
        (y-or-n-p-with-timeout
         "Really exit Emacs (automatically exits in 5 secs)? " 5 t)))

(server-start)