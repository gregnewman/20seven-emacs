(load-library "iso-transl")

(add-to-list 'load-path "~/.emacs.d/vendor")
(progn (cd "~/.emacs.d/vendor")
       (normal-top-level-add-subdirs-to-load-path))

(setq load-path (cons "~/.emacs.d/vendor/rinari/util" load-path))
(setq load-path (cons "~/.emacs.d/vendor/rinari/util/jump" load-path))
(setq load-path (cons "~/.emacs.d/vendor/org-mode/lisp" load-path))
(setq load-path (cons "~/.emacs.d/vendor/org-mode/contrib/lisp" load-path))

(defconst emacs-config-dir "~/.emacs.d/configs/" "")
(setq load-path (cons "~/.emacs.d" load-path))
(defun load-cfg-files (filelist)
  (dolist (file filelist)
    (load (expand-file-name
           (concat emacs-config-dir file)))
    (message "Loaded config file: %s" file)
    ))
 
(load-cfg-files '("anything"
                  "browse_kill_ring"
                  "custom"
                  "dired"
                  "git"
                  "highlight_line"
                  "ido"
                  "javascript"
                  "lorem"
                  "main"
                  "org"
                  "python"
                  "ruby"
                  "shell"
                  "slime"
                  "smex"
                  "textmate"
                  "theme"
                  "yasnippet"))

(setq custom-file "~/.emacs.d/configs/custom.el")

(require 'cl)
(require 'cheat)
(require 'dpaste)
(require 'font-lock)
(require 'gist)
(require 'grep-o-matic)
(require 'growl)
(require 'nav)
(require 'vernacular-time)