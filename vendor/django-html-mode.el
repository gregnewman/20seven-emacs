;; This django-html-mode is mainly derived from html mode
(require 'sgml-mode)

(defvar django-html-mode-hook nil)

(defvar django-html-mode-map
  (let ((django-html-mode-map (make-keymap)))
    (define-key django-html-mode-map "\C-j" 'newline-and-indent)
    django-html-mode-map)
  "Keymap for Django major mode")

;; if : if, if not, if A or B, if not A or B, if not A and B
;; for : for a in alist reversed
  ;; forloop.counter 	The current iteration of the loop (1-indexed)
  ;; forloop.counter0 	The current iteration of the loop (0-indexed)
  ;; forloop.revcounter 	The number of iterations from the end of the loop (1-indexed)
  ;; forloop.revcounter0 	The number of iterations from the end of the loop (0-indexed)
  ;; forloop.first 	True if this is the first time through the loop
  ;; forloop.last 	True if this is the last time through the loop
  ;; forloop.parentloop 	For nested loops, this is the loop "above" the current one

;; ifequal : ifequal A B
;; comment : {% This is comment %}
;; filter : {{ name | lower }}

;; keyword-end : if, for, ifequal, block, ifnotequal, spaceless
;; keyword-3 : regroup
;; keyword-2 : for, ifequal
;; keyword-1 : if, block, extends, include, ifchanged, load, now, ssi, withratio
;; keyword-0 : else, spaceless

;; start and end keyword for block/comment/variable
(defconst django-html-open-block     "{%")
(defconst django-html-close-block    "%}")
(defconst django-html-open-comment   "{#")
(defconst django-html-close-comment  "#}")
(defconst django-html-open-variable  "{{")
(defconst django-html-close-variable "}}")

(defconst django-html-font-lock-keywords-1
  (append
   ;; html-mode keyword
   sgml-font-lock-keywords-1)

  "First level keyword highlighting")

(defconst django-html-font-lock-keywords-2
  (append
   django-html-font-lock-keywords-1
   sgml-font-lock-keywords-2))

(defconst django-html-font-lock-keywords-3
  (append
   django-html-font-lock-keywords-1
   django-html-font-lock-keywords-2

      `(;; comment
     (,(rx (eval django-html-open-comment)
           (1+ space)
           (0+ (not (any "#")))
           (1+ space)
           (eval django-html-close-comment))
      . font-lock-comment-face)

     ;; variable font lock
     (,(rx (eval django-html-open-variable)
           (1+ space)
           (group (0+ (not (any "}"))))
           (1+ space)
           (eval django-html-close-variable))
      (1 font-lock-variable-name-face))

     ;; start, end keyword font lock
     (,(rx (group (or (eval django-html-open-block)
                      (eval django-html-close-block)
                      (eval django-html-open-comment)
                      (eval django-html-close-comment)
                      (eval django-html-open-variable)
                      (eval django-html-close-variable))))
      (1 font-lock-builtin-face))

     ;; end prefix keyword font lock
     (,(rx (eval django-html-open-block)
           (1+ space)
           (group (and "end"
                        ;; end prefix keywords
                       (or "autoescape" "block" "blocktrans" "cache" "comment" "filter" "for"
                           "if" "ifchanged" "ifequal" "ifnotequal" "spaceless" "trans" "with")))
           (1+ space)
           (eval django-html-close-block))
      (1 font-lock-keyword-face))

     ;; more words after keyword
     (,(rx (eval django-html-open-block)
           (1+ space)
           (group (or "autoescape" "block" "blocktrans" "cache" "comment" "cycle"
                      "debug" "else" "extends" "filter" "firstof" "for"
                      "if" "ifchanged" "ifequal" "ifnotequal" "include"
                      "load" "now" "regroup" "spaceless" "ssi" "templatetag"
                      "trans" "url" "widthratio" "with"))

           ;; TODO: is there a more beautiful way?
           (0+ (not (any "}")))

           (1+ space)
           (eval django-html-close-block))
      (1 font-lock-keyword-face))

     ;; TODO: if specific cases for supporting "or", "not", and "and"

     ;; for sepcific cases for supporting in
     (,(rx (eval django-html-open-block)
           (1+ space)
           "for"
           (1+ space)

           (group (1+ (or word ?_ ?.)))

           (1+ space)
           (group "in")
           (1+ space)

           (group (1+ (or word ?_ ?.)))

           (group (? (1+ space) "reverse"))

           (1+ space)
           (eval django-html-close-block))
      (1 font-lock-variable-name-face) (2 font-lock-keyword-face)
      (3 font-lock-variable-name-face) (4 font-lock-keyword-face)))))

(defvar django-html-font-lock-keywords
  django-html-font-lock-keywords-1)

(defvar django-html-mode-syntax-table
  (let ((django-html-mode-syntax-table (make-syntax-table)))
    django-html-mode-syntax-table)
  "Syntax table for django-html-mode")

;;;###autoload
(define-derived-mode django-html-mode html-mode  "django-html"
  "Major mode for editing django html files(.djhtml)"
  :group 'django-html

  ;; it mainly from sgml-mode font lock setting
  (set (make-local-variable 'font-lock-defaults)
       '((django-html-font-lock-keywords
          django-html-font-lock-keywords-1
          django-html-font-lock-keywords-2
          django-html-font-lock-keywords-3)
         nil t nil nil
         (font-lock-syntactic-keywords
          . sgml-font-lock-syntactic-keywords))))

(add-to-list 'auto-mode-alist '("\\.djhtml$'" . django-html-mode))

(provide 'django-html-mode)


;;;  Auto-close tags
(defvar django-closable-tags
  '("autoescape" "blocktrans" "block" "cache"
    "comment" "filter" "for" "ifchanged"
    "ifequal" "ifnotequal" "if" "spaceless"
    "with"))

(defvar django-tag-re
  (concat "{%\\s *\\(end\\)?\\("
          (mapconcat 'identity django-closable-tags "\\|")
          "\\)[^%]*%}"))

(defun django-find-open-tag ()
  (if (search-backward-regexp django-tag-re nil t)
      (if (match-string 1) ; If it's an end tag
          (if (not (string= (match-string 2) (django-find-open-tag)))
              (error "Unmatched Django tag")
            (django-find-open-tag))
        (match-string 2)) ; Otherwise, return the match
    nil))

(defun django-close-tag ()
  (interactive)
  (let ((open-tag (save-excursion (django-find-open-tag))))
    (if open-tag
        (insert "{% end" open-tag " %}")
      (error "Nothing to close"))))


(define-key html-mode-map "\C-c]" 'django-close-tag)
