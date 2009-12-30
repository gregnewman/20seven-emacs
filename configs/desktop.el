;;; desktop-autosave.el begins here
(provide 'desktop-autosave)
(eval-when-compile
  (require 'cl))
(require 'desktop)
;(setq desktop-dirname (expand-file-name "~/.emacs.d/desktop"))
(desktop-save-mode 1) ;; Switch on desktop.el
(defun desktop-autosave-save ()
  (desktop-save-in-desktop-dir))
  (add-hook 'auto-save-hook
            (lambda ()
            (desktop-autosave-save)))
;;; desktop-autosave.el ends here