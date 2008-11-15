;; anything
;(require 'AnythingConfiguration)
(require 'anything-config)
(require 'anything-c-yasnippet)



(defvar anything-sources `(((name . "Buffers")
                            (candidates . anything-buffer-list)
                            (action . (("Switch to Buffer" . switch-to-buffer)
                                       ("Kill Buffer" . kill-buffer))))

                           ((name . "File Name History")
                            (candidates . file-name-history)
                            (action . find-file)
                            (type . file))

                           ((name . "Files from Current Directory")
                            (init-func . (lambda ()
                                           (setq anything-default-directory
                                                 default-directory)))
                            (candidates . (lambda ()
                                            (directory-files
                                             anything-default-directory)))
                            (action . find-file)
                            (type . file))

                           ((name . "Manual Pages")
                            (candidates . ,(progn
                                             (require 'woman)
                                             (woman-file-name "")
                                             (sort (mapcar 'car
                                                           woman-topic-all-completions)
                                                   'string-lessp)))
                            (action . woman)
                            (requires-pattern . 2))

                           ((name . "Complex Command History")
                            (candidates . (lambda ()
                                            (mapcar 'prin1-to-string
                                                    command-history)))
                            (action . (lambda (c)
                                        (eval (read c))))
                            (delayed))))

;(setq anything-sources
;           '(anything-c-source-mac-spotlight
;             anything-c-source-google-suggest
;             anything-c-source-locate))

(global-set-key [?\C-;] 'anything)