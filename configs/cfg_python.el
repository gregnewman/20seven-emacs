;;; python-mode site-lisp configuration
(setq load-path (cons "/Users/greg/emacs/python-mode" load-path))
(setq auto-mode-alist
      (cons '("\\.py$" . python-mode) auto-mode-alist))
(add-to-list 'auto-mode-alist '("\\.doctest$" . doctest-mode))
(setq interpreter-mode-alist
      (cons '("python" . python-mode)
            interpreter-mode-alist))
(autoload 'python-mode "python-mode" "Python editing mode." t)
(autoload 'doctest-mode "doctest-mode" "Editing mode for Python Doctest examples." t)
(require 'pycomplete)

; pymacs & rope
;(require 'pymacs)
;(pymacs-load "ropemacs" "rope-")
(autoload 'pymacs-apply "pymacs")
(autoload 'pymacs-call "pymacs")
(autoload 'pymacs-eval "pymacs" nil t)
(autoload 'pymacs-exec "pymacs" nil t)
(autoload 'pymacs-load "pymacs" nil t)
;;(eval-after-load "pymacs"
;;  '(add-to-list 'pymacs-load-path YOUR-PYMACS-DIRECTORY"))

; django
;(define-skeleton django-trans
;   	  "django translate template tag"
;   	  nil
;   	  "{% trans '" _ "' %}")
;(define-key global-map  "\C-xt"         'django-trans)

; python doc search
(defun py-doc-search (w)
  "Launch PyDOC on the Word at Point"
  (interactive
   (list (let* ((word (thing-at-point 'word))
                (input (read-string 
                        (format "pydoc entry%s: " 
                                (if (not word) "" (format " (default %s)" word))))))
           (if (string= input "") 
               (if (not word) (error "No pydoc args given")
                 word)                  ;sinon word
             input))))                  ;sinon input
  (shell-command (concat py-python-command " -c \"from pydoc import help;help(\'" w "\')\"") "*PYDOCS*")
  (view-buffer-other-window "*PYDOCS*" t 'kill-buffer-and-window))

;; bind doc search to ^c^f
(add-hook 'python-mode-hook (lambda () (local-set-key (kbd "C-c C-f") 'py-doc-search)))

;; pdb
(defadvice pdb (before gud-query-cmdline activate)
  "Provide a better default command line when called interacively."
  (interactive
   (list (gud-query-cmdline '/System/Library/Frameworks/Python.framework/Versions/2.5/lib/python2.5/pdb.py
                            (file-name-nondirectory buffer-file-name)))))