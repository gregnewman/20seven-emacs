;; Copyright 2009 Google Inc. All Rights Reserved.
;;
;; Author: issactrotts@google.com
;;
;; M-x eval-buffer to run the tests in this file.
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


(load-file "nav.el")


(setq nav-test-functions '())


(defmacro nav-assert (expression)
  "Throws an exception if an expression does not evaluate to non-nil."
  `(if (not ,expression)
       (throw 'nav-assertion-failed ',expression)))


(defmacro nav-deftest (name-of-tested-thing &rest body)
  "Defines a test."
  `(push (cons ,name-of-tested-thing (lambda () ,@body))
         nav-test-functions))


;;; Unit tests

(nav-deftest "nav-filter"
  (nav-assert (equal '() (nav-filter '() 'stringp)))
  (nav-assert (equal '("a" "b") (nav-filter '("a" "b") 'stringp)))
  (nav-assert (equal '() (nav-filter '(1) 'stringp))))


(nav-deftest "nav-join"
  (nav-assert (string= "" (nav-join "" '())))
  (nav-assert (string= "" (nav-join "--" '())))
  (nav-assert (string= "a" (nav-join "--" '("a"))))
  (nav-assert (string= "aye--bee" (nav-join "--" '("aye" "bee")))))


(nav-deftest "nav-filter-out-boring-filenames"
  (nav-assert (equal '() (nav-filter-out-boring-filenames '() '())))
  (nav-assert (equal '("a" "b.foo") (nav-filter-out-boring-filenames '("a" "b.foo") '())))
  (nav-assert (equal '("a") (nav-filter-out-boring-filenames '("a" "b.foo") '("\\.foo$")))))


(nav-deftest "nav-dir-files-or-nil"
  (nav-assert (eq nil (nav-dir-files-or-nil "$")))
  (nav-assert (nav-dir-files-or-nil "."))
  (nav-assert (nav-dir-files-or-nil ".."))
  (nav-assert (nav-dir-files-or-nil "/")))


(nav-deftest "nav-dir-suffix"
  (nav-assert (string= "qux" (nav-dir-suffix "/qux/")))
  (nav-assert (string= "qux" (nav-dir-suffix "qux/")))
  (nav-assert (string= "bar" (nav-dir-suffix "/foo/bar/")))
  (nav-assert (string= "bar" (nav-dir-suffix "/foo/bar"))))


(nav-deftest "nav-make-grep-list-cmd"
  (nav-assert (string= "" (nav-make-grep-list-cmd "pat" '())))
  (nav-assert (string= "grep -il 'pat' file1 file2"
                       (nav-make-grep-list-cmd "pat" '("file1" "file2")))))


;;; Tests involving some file IO.

(defun make-test-file (filename contents)
  (let ((prev-file (buffer-file-name)))
    (find-file filename)
    (insert contents)
    (save-buffer)
    (find-file prev-file)))


(defun set-up ()
  (make-directory "d1/d11/" t)
  (make-directory "d1/d12/" t)
  (make-directory "emptydir/" t)
  (make-test-file "d1/a" "things in a")
  (make-test-file "d1/b" "a little bee")
  (make-test-file "d1/d12/c" "let me see"))


(nav-deftest "getting all paths in an empty directory tree"
             (let ((found-paths (nav-get-paths "emptydir/"))
                   (expected (list "emptydir/")))
               (nav-assert (equal expected found-paths))))


(nav-deftest "getting all paths in a non-empty directory tree"
             (let ((found-paths (nav-get-paths "d1/"))
                   (expected '("d1/"
                               "d1/a"
                               "d1/b"
                               "d1/d11/"
                               "d1/d12/"
                               "d1/d12/c")))
               (nav-assert (equal expected found-paths))))


(defun tear-down ()
  (delete-file "d1/a")
  (delete-file "d1/b")
  (delete-file "d1/d12/c")
  (delete-directory "d1/d11/")
  (delete-directory "d1/d12/")
  (delete-directory "d1/")
  (delete-directory "emptydir/"))


(defun nav-run-tests ()
  (pop-to-buffer "*nav-tests*")
  (erase-buffer)
  (let ((num-failures 0)
        (num-tests (length nav-test-functions)))
    (dolist (name-and-test nav-test-functions)
      (let ((name (car name-and-test))
            (test (cdr name-and-test)))
        (insert (format "Testing %s\n" name))
        (condition-case err
            (funcall test)
          ((error err)
           (insert (format "...Failed: %s\n" (error-message-string err)))
           (setq num-failures (+ 1 num-failures))))))
    (let ((num-passed (- num-tests num-failures)))
      (insert (format "\n%i out of %i tests passed, %i failed.\n"
                      num-passed num-tests num-failures)))))


;; If we add tests that modify the directory tree, we'll have to call
;; set-up and tear-down before and after each test.
(set-up)
(nav-run-tests)
(tear-down)

