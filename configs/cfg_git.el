;; Add in git version control hooks
(require 'vc-git)
(when (featurep 'vcgit) (add-to-list 'vc-handled-backends 'git))
(require 'git)
(autoload 'git-blame-mode "git-blame"
  "Minor mode for incremental blame for git" t)