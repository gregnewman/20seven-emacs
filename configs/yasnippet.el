;; yasnippet for code completion
(require 'yasnippet) ;; not yasnippet-bundle
(add-to-list 'yas/extra-mode-hooks 'html-mode-hook)
(yas/initialize)
(yas/load-directory "~/.emacs.d/vendor/yasnippet/snippets/")