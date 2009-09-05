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
(autoload 'pymacs-apply "pymacs")
(autoload 'pymacs-call "pymacs")
(autoload 'pymacs-eval "pymacs" nil t)
(autoload 'pymacs-exec "pymacs" nil t)
(autoload 'pymacs-load "pymacs" nil t)

(pymacs-load "ropemacs" "rope-")
(setq ropemacs-enable-autoimport t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                                         
;;; Auto-completion                                                                                            
;;;  Integrates:                                                                                               
;;;   1) Rope                                                                                                  
;;;   2) Yasnippet                                                                                             
;;;   all with AutoComplete.el                                                                                 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                                         
(defun prefix-list-elements (list prefix)
  (let (value)
    (nreverse
     (dolist (element list value)
      (setq value (cons (format "%s%s" prefix element) value))))))
(defvar ac-source-rope
  '((candidates
     . (lambda ()
         (prefix-list-elements (rope-completions) ac-target))))
  "Source for Rope")
(defun ac-python-find ()
  "Python `ac-find-function'."
  (require 'thingatpt)
  (let ((symbol (car-safe (bounds-of-thing-at-point 'symbol))))
    (if (null symbol)
        (if (string= "." (buffer-substring (- (point) 1) (point)))
            (point)
          nil)
      symbol)))
(defun ac-python-candidate ()
  "Python `ac-candidates-function'"
  (let (candidates)
    (dolist (source ac-sources)
      (if (symbolp source)
          (setq source (symbol-value source)))
      (let* ((ac-limit (or (cdr-safe (assq 'limit source)) ac-limit))
             (requires (cdr-safe (assq 'requires source)))
             cand)
        (if (or (null requires)
                (>= (length ac-target) requires))
            (setq cand
                  (delq nil
                        (mapcar (lambda (candidate)
                                  (propertize candidate 'source source))
                                (funcall (cdr (assq 'candidates source)))))))
        (if (and (> ac-limit 1)
                 (> (length cand) ac-limit))
            (setcdr (nthcdr (1- ac-limit) cand) nil))
        (setq candidates (append candidates cand))))
    (delete-dups candidates)))

;; (defun python-auto-fill-comments-only ()
;;   (auto-fill-mode 1)
;;   (set (make-local-variable 'fill-nobreak-predicate)
;;        (lambda ()
;;          (not (python-in-string/comment)))))
(add-hook 'python-mode-hook
          (lambda ()
                 (auto-complete-mode 1)
                 (set (make-local-variable 'ac-sources)
                      (append ac-sources '(ac-source-rope) '(ac-source-yasnippet)))
                 (set (make-local-variable 'ac-find-function) 'ac-python-find)
                 (set (make-local-variable 'ac-candidate-function) 'ac-python-candidate)
                 (set (make-local-variable 'ac-auto-start) nil)))
 
;;Ryan's python specific tab completion
(defun ryan-python-tab ()
  ; Try the following:                 
  ; 1) Do a yasnippet expansion        
  ; 2) Do a Rope code completion
  ; 3) Do an indent
  (interactive)
  (if (eql (ac-start) 0)
      (indent-for-tab-command)))
 
(defadvice ac-start (before advice-turn-on-auto-start activate)
  (set (make-local-variable 'ac-auto-start) t))
(defadvice ac-cleanup (after advice-turn-off-auto-start activate)
  (set (make-local-variable 'ac-auto-start) nil))

(define-key python-mode-map (kbd "TAB") 'ryan-python-tab)
(global-set-key (kbd "ESC M-p") 'rope-open-project)

;; RST and an attempt at turning on RST in proper docstrings
;(autoload 'rst-mode "rst" nil t)

;(mmm-add-classes
; '(
;   (rst-python
;    :submode rst-mode
;    :face mmm-declaration-submode-face
;    :front "\\(\"\"\"\\)\\|\\(\'\'\'\\)"
;    :front-offset -1
;    :save-matches t 
;    :back "~1" 
;    :back-offset 1
;    :end-not-begin t
    
    ;; Define a skeleton for entering new docstrings.
;    :insert ((?d docstring nil @ "\"\"" @ "\"" \n
;                   _ \n "\"" @ "\"\"" @)))
;   (doctest-python
;    :submode nil
;    :face mmm-code-submode-face
;    :front "^[ \t]*>>>" 
;    :include-front t
;    :back "\n$"
;    :insert ((?e doctest-example nil
;		 @ @ "    >>> " _ "\n\n" @ @)))))

;;(add-to-list 'mmm-mode-ext-classes-alist '(python-mode "\\.py'" doctest-python))
;(add-to-list 'mmm-mode-ext-classes-alist '(python-mode nil rst-python))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; End Auto Completion                                       
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

(setq ipython-command "/usr/local/bin/ipython")
(require 'ipython)


(setq auto-mode-alist
      (append '(("\\.txt$" . rst-mode)
                ("\\.rst$" . rst-mode)
                ("\\.rest$" . rst-mode)) auto-mode-alist))


(defun fix-django-templates ()
  "This will fix django templates that have improper whitespace"
  (interactive
   (progn
     (beginning-of-buffer
      (query-replace-regexp "{{\\([\\w\\\"]\\)" "{{ \\1"))
     (beginning-of-buffer
      (query-replace-regexp "\\([\\w\\\"]\\)}}" "\\1 }}")))))