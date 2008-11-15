(require 'dired-x) 
(setq dired-omit-files 
      (rx (or (seq bol (? ".") "#")         ;; emacs autosave files 
;              (seq bol "." (not (any "."))) ;; dot-files 
              (seq "~" eol)                 ;; backup-files 
              (seq bol "CVS" eol)           ;; CVS dirs 
              (seq ".pyc" eol)
              ))) 
(setq dired-omit-extensions 
      (append dired-latex-unclean-extensions 
              dired-bibtex-unclean-extensions 
              dired-texinfo-unclean-extensions)) 
(add-hook 'dired-mode-hook (lambda () (dired-omit-mode 1))) 