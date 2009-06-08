;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Python mode customizations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'python)
(autoload 'python-mode "python-mode" "Python Mode." t)
(add-to-list 'auto-mode-alist '("\\.py\\'" . python-mode))
(add-to-list 'interpreter-mode-alist '("python" . python-mode))
(setq interpreter-mode-alist
      (cons '("python" . python-mode)
            interpreter-mode-alist)
      python-mode-hook
      '(lambda () (progn
		    (set-variable 'py-indent-offset 4)
		    (set-variable 'py-smart-indentation nil)
		    (set-variable 'indent-tabs-mode nil) 
		    ;;(highlight-beyond-fill-column)
            (define-key python-mode-map "\C-m" 'newline-and-indent)
		    ;;(pabbrev-mode)
		    (abbrev-mode)
            )
      )
)


;; pymacs
;(autoload 'pymacs-apply "pymacs")
;(autoload 'pymacs-call "pymacs")
;(autoload 'pymacs-eval "pymacs" nil t)
;(autoload 'pymacs-exec "pymacs" nil t)
;(autoload 'pymacs-load "pymacs" nil t)


;(require 'pysmell)
;(add-hook 'python-mode-hook (lambda () (pysmell-mode 1)))


;(pymacs-load "ropemacs" "rope-")
;(setq ropemacs-enable-autoimport t)

(require 'django-html-mode)
(require 'django-mode)


(defun my-compile ()
  "Use compile to run python programs"
  (interactive)
  (compile (concat "python " (buffer-name))))
(setq compilation-scroll-output t)


(local-set-key "\C-c\C-p" 'my-compile)


(require 'comint)
(define-key comint-mode-map [(meta p)]
   'comint-previous-matching-input-from-input)
(define-key comint-mode-map [(meta n)]
   'comint-next-matching-input-from-input)
(define-key comint-mode-map [(control meta n)]
    'comint-next-input)
(define-key comint-mode-map [(control meta p)]
    'comint-previous-input)


(setq py-python-command-args '("-pylab" "-colors" "Linux"))

(defadvice py-execute-buffer (around python-keep-focus activate)
   (let ((remember-window (selected-window))
         (remember-point (point)))
     ad-do-it
     (select-window remember-window)
     (goto-char remember-point)))

 (defun rgr/python-execute()
   (interactive)
   (if mark-active
       (py-execute-string (buffer-substring-no-properties (region-beginning) (region-end)))
     (py-execute-buffer)))
(global-set-key (kbd "C-c C-e") 'rgr/python-execute)

(setq ipython-command "/opt/local/Library/Frameworks/Python.framework/Versions/2.5/bin/ipython")
(require 'ipython)
