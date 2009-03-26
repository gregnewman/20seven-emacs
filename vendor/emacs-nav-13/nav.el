;; Copyright 2009 Google Inc. All Rights Reserved.
;;
;; Author: issactrotts@google.com
;;
;; GETTING STARTED
;; To use this file, put something like the following in your
;; ~/.emacs:
;;
;; (add-to-list 'load-path "/directory/containing/nav/")
;; (require 'nav)
;;
;; Type M-x nav to open the navigation window. It should show up as a
;; 30-character wide column on the left, showing the contents of the
;; current directory. If there are multiple windows open, all but one
;; will be closed to make sure the nav window shows up correctly.
;;
;; KEY BINDINGS
;;   Enter/Return: Open file or directory under cursor
;;
;;   1: Open file under cursor in 1st other window
;;   2: Open file under cursor in 2nd other window
;;
;;   c: Copy file or directory under cursor
;;   d: Delete file or directory under cursor (asks to confirm first)
;;   e: Edit current directory in dired
;;   f: Recursively find files whose names or contents match some regexp
;;   g: Recursively grep for some regexp
;;   j: Jump to another directory
;;   m: Move or rename file or directory
;;   n: Make new directory
;;   p: Pop directory stack to go back to the directory where you just were
;;   q: Quit nav
;;   r: Refresh
;;   s: Start a shell in an emacs window in the current directory
;;   t: Start a terminal in an emacs window in the current directory.
;;      This allows programs like vi and less to be run.
;;   u: Go up to parent directory
;;   !: Run shell command
;;   [: Rotate non-nav windows counter clockwise
;;   ]: Rotate non-nav windows clockwise
;;
;;   :: Go into debug mode (should only be needed if you are hacking nav.el)
;;
;; BUGS:
;; - If you go to a directory, then leave it, then delete it, it still remains in
;;   the stack, leading to confusion.
;; - Running the 'g' and 'f' commands doesn't work well in directory
;;   trees containing filenames with spaces.
;;
;; TODO:
;; - Add automated tests of system calls.
;; - Optionally show a bit more depth of the directory tree.
;; - Toggle showing and hiding directory contents when user hits enter on them.
;;
;; LICENSE
;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;      http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.


(defgroup nav nil
  "A lightweight file/directory navigator."
  :group 'applications)

(defcustom nav-width 30
  "*How many columns to make the nav window."
  :type 'integer
  :group 'nav)

(defcustom nav-boring-file-regexps (list "\\.pyc$" "\\.o$" "~$" "\\.bak$" "^\\." "/\\.")
  "*Nav ignores filenames that match any regular expression in this list."
  :type '(repeat string)
  :group 'nav)

(defvar nav-dir-stack '())

(defconst nav-shell-buffer-name "*nav-shell*"
  "Name of the buffer used for the command line shell spawned by nav on the 's' key.")

(defconst nav-buffer-name "*nav*"
  "Name of the buffer where nav shows directory contents.")

(defconst nav-buffer-name-for-find-results "*nav-find*"
  "Name of the buffer where nav shows results of its find command (f key).")


(defun nav-filter (ls pred)
  "Returns a new list containing all elements that satisfy the given predicate."
  (let ((result '()))
    (dolist (x ls)
      (if (funcall pred x)
          (push x result)))
    (reverse result)))


(defun nav-join (sep string-list)
  (mapconcat 'identity string-list sep))


(defun nav-filter-out-boring-filenames (filenames boring-regexps)
  (let ((result '()))
    (dolist (filename filenames)
      (let ((filename-is-boring nil))
        (dolist (rx boring-regexps)
          (if (string-match rx filename)
              (setq filename-is-boring t)))
        (if (not filename-is-boring)
            (push filename result))))
    (reverse result)))


(defun nav-make-pipe-filter-against-boring-files ()
  (mapconcat (lambda (rx) (concat "grep -v \"" rx "\"")) nav-boring-file-regexps " | "))


(defun nav-make-non-boring-find-command ()
  ;; The sed command strips away ./ prefixes.
  (concat "find . -name \\* | sed 's/^.\\///' | "
          (nav-make-pipe-filter-against-boring-files)))


(defun nav-get-non-boring-filenames-recursively ()
  (let ((command (nav-make-non-boring-find-command)))
    (split-string (shell-command-to-string command))))


(defun nav-kill-buffer-if-exists (bufname)
  (condition-case err
      (kill-buffer bufname)
    (error nil)))


(defun nav-dir-files-or-nil (dirname)
  "Returns a list of files in a directory, or nil if it is not a
directory or is not accessible."
  (condition-case err
      (directory-files dirname)
    (file-error nil)))


;; Changes to a different directory and pushes it onto the stack.
(defun nav-cd (dirname)
  (let ((dirname (file-name-as-directory (file-truename dirname))))
    (setq default-directory dirname)
    (nav-show-dir dirname)
    (nav-assert (nav-dir-files-or-nil default-directory))))


(defun nav-open-file (filename)
  (interactive "sFilename:")
  (if (file-directory-p filename)
      (nav-push-dir filename)
    (if (file-exists-p filename)
        (find-file-other-window filename))))


(defun nav-open-file-under-cursor ()
  (interactive)
  (let ((filename (get-cur-line-str)))
    (nav-open-file filename)))


(defun nav-go-up-one-dir ()
  (interactive)
  (nav-push-dir ".."))


(defun nav-push-dir (dirname)
  (push (file-truename dirname) nav-dir-stack)
  (nav-cd dirname))


(defun nav-pop-dir ()
  (interactive)
  (let ((dir (if (> (length nav-dir-stack) 1)
                 (progn
                   (pop nav-dir-stack)
                   (car nav-dir-stack))
               ".")))
    (message "Changing to %s\n" dir)
    (nav-cd dir)))


(defun get-cur-line-str ()
  (buffer-substring-no-properties (point-at-bol)
                                  (point-at-eol)))


(defun nav-non-boring-directory-files (dir)
  (nav-filter-out-boring-filenames (directory-files dir) nav-boring-file-regexps))


(defun nav-dir-suffix (dir)
  (replace-regexp-in-string ".*/" "" (directory-file-name dir)))


(defun nav-line-number-at-pos (p)
  (let ((line-num 1))
    (dotimes (i p line-num)
      (if (eq ?\n (char-after i))
          (setq line-num (+ line-num 1))))))


(defun nav-replace-buffer-contents (new-contents should-make-filenames-clickable)
  (let ((saved-line-number (nav-line-number-at-pos (point))))
    (setq buffer-read-only nil)
    (erase-buffer)
    (insert new-contents)
    (font-lock-fontify-buffer)
    (if should-make-filenames-clickable
        (nav-make-filenames-clickable))
    (setq buffer-read-only t)
    (goto-line saved-line-number)))


(defun nav-make-filenames-clickable ()
  (condition-case err
      (dotimes (i (count-lines 1 (point-max)))
        (let ((line-num (+ i 1)))
          (goto-line line-num)
          (let ((start (line-beginning-position))
                (end (line-end-position)))
            (make-button start end
                         'action (lambda (button)
                                   (nav-open-file (button-label button)))
                         'follow-link t
                         'help-echo ""))))
    (error 
     ;; This can happen for versions of emacs that don't have
     ;; make-button defined.
     'failed)))


(defun nav-show-dir (dir)
  (let ((new-contents '("../")))
    (dolist (filename (nav-non-boring-directory-files dir))
      (let ((line (concat "\n" filename
                          (if (file-directory-p filename)
                              "/"
                            ""))))
        (push line new-contents)))
    (let ((new-contents (nav-join "" (reverse new-contents))))
      (nav-replace-buffer-contents new-contents t))
    (setq mode-line-format (concat "nav: " (nav-dir-suffix (file-truename dir)) "/"))
    (force-mode-line-update)))


(defun nav-set-window-width (n)
  (if (> (window-width) n)
    (shrink-window-horizontally (- (window-width) n)))
  (if (< (window-width) n)
    (enlarge-window-horizontally (- n (window-width)))))


(defun nav-set-window-height (n)
  (if (> (window-height) n)
    (shrink-window (- (window-height) n)))
  (if (< (window-height) n)
    (enlarge-window (- n (window-height)))))


(defun nav-get-working-dir ()
  (file-name-as-directory (file-truename default-directory)))


(defun nav-invoke-dired ()
  "Invokes dired on the current directory so the user can rename
and delete files, etc."
  (interactive)
  (other-window 1)
  (dired (nav-get-working-dir)))


(defun nav-open-file-other-window (k)
  (let ((filename (get-cur-line-str))
        (dirname (nav-get-working-dir)))
    (other-window k)
    (find-file (concat dirname "/" filename))))


(defun nav-open-file-other-window-1 ()
  (interactive)
  (nav-open-file-other-window 1))


(defun nav-open-file-other-window-2 ()
  (interactive)
  (if (= 2 (length (window-list)))
      (progn
        (other-window 1)
        (split-window-horizontally)
        (select-window (nav-get-window))))
  (nav-open-file-other-window 2))


(defun nav-get-window ()
  (let ((nav-win nil))
    (dolist (w (window-list))
      (if (string= "*nav*" (buffer-name (window-buffer w)))
          (setq nav-win w)))
    nav-win))


(defun nav-refresh ()
  (interactive)
  (nav-set-window-width nav-width)
  (nav-show-dir "."))


(defun nav-turn-off-keys-and-be-writable ()
  (interactive)
  (use-local-map (make-sparse-keymap))
  (setq buffer-read-only nil))


(defun nav-turn-on-keys-and-be-read-only ()
  (interactive)
  (use-local-map (nav-make-key-bindings))
  (setq buffer-read-only t))


(defun nav-quit ()
  (interactive)
  (let ((window	(get-buffer-window "*nav*")))
    (if	window
        (delete-window window)))
  (kill-buffer nav-buffer-name))


(defun nav-toggle ()
  (interactive)
  (if (nav-get-window)
      (nav-quit)
    (nav)))


(defun nav-make-recursive-grep-command (pattern)
  (concat (nav-make-non-boring-find-command) " | xargs grep -inH '" pattern "'"))


(defun nav-recursive-grep (pattern)
  (interactive "sPattern to recursively grep for: ")
  (grep (nav-make-recursive-grep-command pattern))
  (other-window 1))


(defun nav-jump-to-dir (dirname)
  (interactive "fDirectory: ")
  (nav-push-dir dirname))


(defun nav-this-is-a-microsoft-os ()
  (or (string= system-type "windows-nt")
      (string= system-type "ms-dos")))


(defun nav-make-remove-dir-command (dirname)
  (if (nav-this-is-a-microsoft-os)
      (format "rmdir /S /Q \"%s\"" dirname)
    (format "rm -rf '%s'" dirname)))


(defun nav-delete-file-or-dir ()
  (interactive)
  (let ((filename (get-cur-line-str)))
    (if (file-directory-p filename)
        (if (yes-or-no-p (format "Really delete directory %s ?" filename))
            (progn
	      (shell-command (nav-make-remove-dir-command filename))
              (nav-refresh)))
      (if (y-or-n-p (format "Really delete file %s ? " filename))
          (progn
            (delete-file filename)
            (nav-refresh))))))


(defun nav-ok-to-overwrite (target-name)
  "Returns true if the target doesn't exist, is a directory, or if the user says it's ok."
  (or (not (file-exists-p target-name))
      (file-directory-p target-name)
      (y-or-n-p (format "Really overwrite %s ? " target-name))))


(defun nav-copy-file-or-dir (target-name)
  (interactive "sCopy to: ")
  (let ((filename (get-cur-line-str)))
    (if (nav-this-is-a-microsoft-os)
	(copy-file filename target-name)
      (if (nav-ok-to-overwrite target-name)
	  (let ((maybe-dash-r (if (file-directory-p filename) "-r" "")))
	    (shell-command (format "cp %s '%s' '%s'" maybe-dash-r filename target-name))))))
  (nav-refresh))


(defun nav-move-file (new-name)
  (interactive "sNew name or directory: ")
  (let ((old-name (get-cur-line-str)))
    (if (nav-this-is-a-microsoft-os)
	(rename-file old-name new-name)
      (if (nav-ok-to-overwrite new-name)
	  (shell-command (format "mv %s %s" old-name new-name)))))
  (nav-refresh))


(defun nav-make-grep-list-cmd (pattern filenames)
  (if (not filenames)
      ""
    (format "grep -il '%s' %s" pattern (nav-join " " filenames))))


(defun nav-append-slashes-to-dir-names (names)
  (mapcar (lambda (name)
            (if (file-directory-p name)
                (concat name "/")
              name))
          names))


(defun nav-find-files (pattern)
  (interactive "sPattern: ")
  (let* ((filenames (nav-get-non-boring-filenames-recursively))
         (names-matching-pattern
          (nav-filter filenames (lambda (name) (string-match pattern name))))
         (names-matching-pattern
          (nav-append-slashes-to-dir-names names-matching-pattern)))
    (pop-to-buffer nav-buffer-name-for-find-results nil)
    (if names-matching-pattern
        (nav-show-find-results names-matching-pattern)
        (nav-replace-buffer-contents
         "No matching files found."
         nil))))


(defun nav-show-find-results (paths)
  (nav-replace-buffer-contents
   (nav-join "\n" names-matching-pattern)
   t)
  ;; Enable nav keyboard shortcuts, mainly so hitting enter will open
  ;; files.
  (use-local-map nav-mode-map))


(defun nav-make-new-directory (name)
  (interactive "sMake directory: ")
  (make-directory name)
  (nav-refresh))


(defun nav-shell ()
  "Starts up a shell on the current nav directory."
  (interactive)
  (nav-kill-buffer-if-exists nav-shell-buffer-name)
  (shell nav-shell-buffer-name))


(defun nav-term ()
  "Starts up a term on the current nav directory, unless there is already a
*terminal* buffer in which case it is reused."
  (interactive)
  (let ((dirname (file-truename ".")))
    (other-window 1)
    ;; Invoke dired on current directory so term will start there.
    ;; TODO(issactrotts): Do something other than this hack, to prevent
    ;; cluttering up with a dired buffer.
    (dired dirname))
  (term "/bin/bash"))


(defun nav-get-other-windows ()
  (let* ((nav-window (get-buffer-window nav-buffer-name))
         (cur-window (next-window nav-window))
         (result '()))
    (while (not (eq cur-window nav-window))
      (push cur-window result)
      (setq cur-window (next-window cur-window)))
    (reverse result)))


(defun nav-rotate-windows-cw ()
  "Cyclically permutes the windows other than the nav window, clockwise."
  (interactive)
  (nav-rotate-windows (lambda (i) (mod (+ i 1) n))))


(defun nav-rotate-windows-ccw ()
  "Cyclically permutes the windows other than the nav window, counter-clockwise."
  (interactive)
  (nav-rotate-windows (lambda (i) (mod (+ i n -1) n))))


(defun nav-rotate-windows (next-i)
  "Cyclically permutes the windows other than the nav window, either clockwise
or counter-clockwise depending on the passed-in function next-i."
  (let* ((win-list (nav-get-other-windows))
         (win-vec (apply 'vector win-list))
         (buf-list (mapcar 'window-buffer win-list))
         (buf-vec (apply 'vector buf-list))
         (n (length win-vec)))
    (dotimes (i n)
      (set-window-buffer (aref win-vec (funcall next-i i))
                         (buffer-name (aref buf-vec i))))))


(defun nav-get-paths (dir-path)
  "Recursively finds all paths starting with a given directory name."
  (let ((paths (list dir-path)))
    (dolist (file-name (directory-files dir-path))
      (if (not (or (string= "." file-name)
                   (string= ".." file-name)))
          (progn
            (let ((file-path (format "%s%s" dir-path file-name)))
              (if (file-directory-p file-path)
                  (let ((more-paths (nav-get-paths (format "%s/" file-path))))
                    (setq paths (append (reverse more-paths) paths)))
                (push file-path paths))))))
    (reverse paths)))


(defun nav-set-up-highlighting ()
  (turn-on-font-lock)
  (font-lock-add-keywords 'nav-mode '(("^.*/$" . font-lock-type-face))))


(define-derived-mode nav-mode fundamental-mode 
  "Nav-mode is for IDE-like navigation of directories.

 It's more IDEish than dired, not as heavy weight as speedbar."
  (nav-set-window-width nav-width)
  (setq major-mode 'nav-mode)
  (setq mode-name "Navigation")
  (use-local-map nav-mode-map)
  (nav-set-up-highlighting)
  (nav-refresh))  


(defun nav-set-key-bindings (bindings)
  (define-key bindings "\n" 'nav-open-file-under-cursor) ; enter key
  (define-key bindings "\r" 'nav-open-file-under-cursor) ; return key for Macs
  (define-key bindings "1" 'nav-open-file-other-window-1)
  (define-key bindings "2" 'nav-open-file-other-window-2)
  (define-key bindings "c" 'nav-copy-file-or-dir)
  (define-key bindings "d" 'nav-delete-file-or-dir)
  (define-key bindings "e" 'nav-invoke-dired)
  (define-key bindings "f" 'nav-find-files)
  (define-key bindings "g" 'nav-recursive-grep)
  (define-key bindings "j" 'nav-jump-to-dir)
  (define-key bindings "m" 'nav-move-file)
  (define-key bindings "n" 'nav-make-new-directory)
  (define-key bindings "p" 'nav-pop-dir)
  (define-key bindings "q" 'nav-quit)
  (define-key bindings "r" 'nav-refresh)
  (define-key bindings "s" 'nav-shell)
  (define-key bindings "t" 'nav-term)
  (define-key bindings "u" 'nav-go-up-one-dir)
  (define-key bindings "[" 'nav-rotate-windows-ccw)
  (define-key bindings "]" 'nav-rotate-windows-cw)
  (define-key bindings "!" 'shell-command)
  (define-key bindings ":" 'nav-turn-off-keys-and-be-writable)
  (define-key bindings "\C-x\C-f" 'find-file-other-window))

(nav-set-key-bindings nav-mode-map)


(defun nav ()
  "Run nav-mode in a narrow window on the left side."
  (interactive)
  (delete-other-windows)
  (split-window-horizontally)
  (other-window 1)
  (nav-kill-buffer-if-exists nav-buffer-name)
  (pop-to-buffer nav-buffer-name nil)
  (set-window-dedicated-p (selected-window) t)
  (nav-mode))


(provide 'nav)
