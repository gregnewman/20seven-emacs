;; Other configuration;; no splash screen(setq inhibit-startup-message t);; use UTF-8(prefer-coding-system 'utf-8);; make pretty(global-font-lock-mode 1) ;; shows current selected region(setq-default transient-mark-mode t);; indent via spaces not tabs(setq-default indent-tabs-mode nil);; titlebar = buffer unless filename(setq frame-title-format '(buffer-file-name "%f" ("%b")));; show paired parenthasis(show-paren-mode 1) ;(set-default-font "-adobe-courier-bold-o-normal--18-180-75-75-m-110-iso8859-13");; TAB => 4*'\b'(setq default-tab-width 4);; turn off tool bar, and menu bar(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1));; Make sure we have font-lock to start with(require 'font-lock);; log the time of the things I have done(setq-default org-log-done t) ;; get rid of yes-or-no questions - y or n is enough(defalias 'yes-or-no-p 'y-or-n-p) (require 'uniquify)(setq uniquify-buffer-name-style 'reverse)(setq uniquify-separator "/")(setq uniquify-after-kill-buffer-p t) ; rename after killing uniquified(setq uniquify-ignore-buffers-re "^\\*") ; don't muck with special buffers;; See http://www.delorie.com/gnu/docs/elisp-manual-21/elisp_620.html;; and http://www.gnu.org/software/emacs/manual/elisp.pdf;; disable line wrap(setq default-truncate-lines nil);; make side by side buffers function the same as the main window(setq truncate-partial-width-windows nil);; Add F12 to toggle line wrap;(global-set-key [f8] 'toggle-truncate-lines)(custom-set-faces  ;; custom-set-faces was added by Custom.  ;; If you edit it by hand, you could mess it up, so be careful.  ;; Your init file should contain only one such instance.  ;; If there is more than one, they won't work right. '(default ((t (:stipple nil :background "#1e1e27" :foreground "#cfbfad" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight semi-light :height 140 :width normal :family "apple-inconsolata-medium")))) '(highlight-current-line-face ((t (:background "black")))));; When things go wrong, turn this on(toggle-debug-on-error t)