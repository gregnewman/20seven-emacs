;; ECB
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(default-frame-alist (quote ((left-fringe) (rigt-fringe) (menu-bar-lines . 1) (width . 110) (height . 40))))
 '(ecb-eshell-auto-activate nil)
 '(ecb-layout-name "left13")
 '(ecb-layout-nr 9)
 '(ecb-layout-window-sizes (quote (("left13" (0.22727272727272727 . 0.975)))))
 '(ecb-source-file-regexps (quote ((".*" ("\\(^\\(\\.\\|#\\)\\|\\(~$\\|\\.\\(pyc\\|elc\\|obj\\|o\\|class\\|lib\\|dll\\|a\\|so\\|cache\\)$\\)\\)") ("^\\.\\(emacs\\|gnus\\)$")))))
 '(ecb-non-semantic-parsing-function nil)
 '(ecb-options-version "2.32")
 '(ecb-other-window-behavior (quote edit-and-compile))
 '(ecb-other-window-jump-behavior (quote edit-and-compile))
 '(ecb-primary-secondary-mouse-buttons (quote mouse-1--C-mouse-1))
 '(ecb-select-edit-window-on-redraw t)
 '(ecb-source-path (quote ("~/Documents")))
 '(ecb-tip-of-the-day nil)
 '(ecb-tree-buffer-style (quote image))
 '(ecb-tree-image-icons-directories (quote ("~/.emacs.d/ecb/ecb-images/default/height-17" (ecb-directories-buffer-name . "~/.emacs.d/ecb/ecb-images/directories/height-17") (ecb-sources-buffer-name . "~/.emacs.d/ecb/ecb-images/sources/height-14_to_21") (ecb-methods-buffer-name . "~/.emacs.d/ecb/ecb-images/methods/height-14_to_21")))))

(require 'ecb)
;; Fire up ECB
(ecb-activate)
(ecb-toggle-ecb-windows)