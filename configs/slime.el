(setq inferior-lisp-program "/usr/local/bin/sbcl") ; your Lisp system
(add-to-list 'load-path "~/.emacs.d/vendor/slime/")  ; your SLIME directory
;(require 'slime)
(require 'slime-autoloads)
(slime-setup)