;; load paths
(setq load-path (cons "~/emacs" load-path))
(setq load-path (cons "~/emacs/python-mode" load-path))
(setq load-path (cons "~/emacs/configs" load-path))
(setq load-path (cons "~/emacs" load-path))
(setq load-path (cons "~/emacs/cedet/common" load-path))
(setq load-path (cons "~/emacs/cedet/semantic" load-path))
(setq load-path (cons "~/emacs/cedet/eieio" load-path))
(setq load-path (cons "~/emacs/cedet/ede" load-path))
(setq load-path (cons "~/emacs/cedet/speedbar" load-path))
(setq load-path (cons "~/emacs/ecb" load-path))
(setq load-path (cons "~/emacs/mmm-mode" load-path))
(setq load-path (cons "~/emacs/color-theme" load-path))
(setq load-path (cons "/Applications/Emacs.app/Contents/Resources/site-lisp" load-path))
(setq load-path (cons "/Applications/Emacs.app/Contents/Resources/lisp" load-path))

(defconst emacs-config-dir "~/emacs/configs/" "")
 
(defun load-cfg-files (filelist)
  (dolist (file filelist)
    (load (expand-file-name
           (concat emacs-config-dir file)))
    (message "Loaded config file: %s" file)
    ))
 
(load-cfg-files '("cfg_main"
                  "cfg_linum"
                  "cfg_mmm_mode"
                  "cfg_python"
                  "cfg_theme"
                  "cfg_ido"
                  "cfg_cedet"
                  "cfg_ecb"
                  "cfg_git"
;                  "cfg_keybindings"
;                  "cfg_css-mode"
;                  "cfg_javascript"
                  "cfg_highlight_line"))
