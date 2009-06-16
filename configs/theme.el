;; color theme
(require 'color-theme)
(color-theme-initialize)

;(color-theme-charcoal-black)
;(color-theme-blippblopp)
;(color-theme-billw)
;(color-theme-inkpot)
;(load-file "~/.emacs.d/vendor/color-theme/color-theme-tango-2.el")
;(color-theme-tango-2)
;(load-file "~/.emacs.d/vendor/color-theme/twilight-emacs/color-theme-twilight.el")
;(color-theme-twilight)
;(color-theme-montz)
(load-file "~/.emacs.d/vendor/color-theme/zenburn.el")
(color-theme-zenburn)
;(load-file "~/.emacs.d/vendor/color-theme/color-theme-blackboard.el")
;(color-theme-blackboard)
;(load-file "~/.emacs.d/vendor/color-theme/color-theme-hober2.el")
;(color-theme-hober2)

;(load-file "~/.emacs.d/vendor/color-theme/color-theme-github/color-theme-github.el")
;(color-theme-github)

;(load-file "~/.emacs.d/vendor/color-theme/color-theme-merbivore/color-theme-merbivore.el")
;(color-theme-merbivore)





;; ;; Function to set my color theme
;; (defun color-theme-newman ()
;;   (interactive)
;;   (custom-set-faces
;;    ;; Outline Mode and Org-Mode
;;    '(outline-1 ((t (:foreground "#D6B163" :bold t))))
;;    '(outline-2 ((t (:foreground "#A5F26E" :bold nil))))
;;    '(outline-3 ((t (:foreground "#B150E7" :bold nil))))
;;    '(outline-4 ((t (:foreground "#529DB0" :bold nil))))
;;    '(outline-5 ((t (:foreground "#CC7832" :bold nil))))
;;    '(org-level-1 ((t (:inherit outline-1))))
;;    '(org-level-2 ((t (:inherit outline-2))))
;;    '(org-level-3 ((t (:inherit outline-3))))
;;    '(org-level-4 ((t (:inherit outline-4))))
;;    '(org-level-5 ((t (:inherit outline-5))))
;;    '(org-agenda-date ((t (:inherit font-lock-type-face))))
;;    '(org-agenda-date-weekend ((t (:inherit org-agenda-date))))
;;    '(org-scheduled-today ((t (:foreground "#ff6ab9" :italic t))))
;;    '(org-scheduled-previously ((t (:foreground "#d74b4b"))))
;;    '(org-upcoming-deadline ((t (:foreground "#d6ff9c"))))
;;    '(org-warning ((t (:foreground "#8f6aff" :italic t))))
;;    '(org-date ((t (:inherit font-lock-constant-face))))
;;    '(org-tag ((t (:inherit font-lock-comment-delimiter-face))))
;;    '(org-hide ((t (:foreground "#191919"))))
;; ;   '(org-todo ((t (:background "DarkRed" :foreground "white" :box (:line-width 1 :style released-button)))))
;; ;   '(org-done ((t (:background "DarkGreen" :foreground "white" :box (:line-width 1 :style released-button)))))
;;    '(org-column ((t (:background "#222222"))))
;;    '(org-column-title ((t (:background "DarkGreen" :foreground "white" :bold t :box (:line-width 1 :style released-button)))))
;; ;   '(pmade-org-next-face ((t (:background "#4f97e9" :foreground "white" :box (:line-width 1 :style released-button)))))
;; ;   '(pmade-org-pending-face ((t (:background "#d85b00" :foreground "white" :box (:line-width 1 :style released-button)))))
;;    '(pmade-org-reading-face ((t (:background "#68527a" :foreground "white" :box (:line-width 1 :style released-button))))))
;; )

;; (defun color-theme-newman-gui ()
;;   (color-theme-newman))
;; ;  (custom-set-faces
;; ;   '(default ((t (:background "#191919" :foreground "#FFFFFF"))))))

;;  ;; Load color-theme
;; (color-theme-newman-gui)