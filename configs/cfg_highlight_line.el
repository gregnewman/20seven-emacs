(require 'highlight-current-line)
 
(custom-set-variables
 '(highlight-current-line-globally t nil (highlight-current-line)))
 
(custom-set-faces
 '(highlight-current-line-face ((t (:background "#eeeeee")))))
 
                                        ; good: 4f2f42
                                        ; midnight blue
                                        ; saddle brown
(cond (window-system
       (custom-set-faces
        '(highlight-current-line-face ((t (:background "#eeeeee")))))))