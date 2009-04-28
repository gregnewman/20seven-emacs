(load-library "iso-transl")

(add-to-list 'load-path "~/.emacs.d/vendor")
(progn (cd "~/.emacs.d/vendor")
       (normal-top-level-add-subdirs-to-load-path))

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
 
(load-cfg-files '("cfg_main"
                  "cfg_org"
                  "cfg_yasnippet"
                  "cfg_browse_kill_ring"
                  "cfg_python"
                  "cfg_ruby"
                  "cfg_theme"
                  "cfg_ido"
                  "cfg_anything"
                  "cfg_dired"
                  "cfg_git"
                  "cfg_slime"
                  "cfg_highlight_line"
                  "custom"))

(setq custom-file "~/.emacs.d/configs/custom.el")
