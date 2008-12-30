;;; vernacular-time.el --- Convert Emacs time to vernacular

;; Copyright (C) 2008 Yoni Rabkin
;;
;; Author: Yoni Rabkin <yonirabkin@member.fsf.org>
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3 of
;; the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public
;; License along with this program; if not, write to the Free
;; Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
;; MA 02111-1307, USA.

;;; Commentary:
;;
;; vernacular-time.el will place overlays over date-time strings in a
;; buffer to convert a date like "2008-08-10" to "Thursday" or
;; "yesterday".
;;
;; To automatically convert the `ls' times in a dired buffer, do:
;;
;; (add-hook 'dired-after-readin-hook 'vernacular-time-dired-display)
;;
;; You can manually do this by interactively invoking
;; `vernacular-time-dired-display' in a dired buffer.
;;
;; You can remove all of the overlays by interactively invoking
;; `vernacular-time-remove-all'.

;;; History:
;;
;; Initially written in August of '08.

;;; Code:

(condition-case nil
    (require 'overlay)
  (error nil))

(defvar vernacular-time-dired-date-regexp
  "[[:digit:]]\\{4\\}\\(-[[:digit:]]\\{2\\}\\)\\{2\\} [[:digit:]]\\{2\\}:[[:digit:]]\\{2\\}")

(defun date-to-vernacular (then-date)
  "Return the time in vernacular based on THEN-DATE."
  (let ((delta (days-between then-date (current-time-string)))
	(then-time (date-to-time then-date)))
    (cond ((= delta 1)
	   (format-time-string "tomorrow, %R" then-time t))
	  ((= delta 0)
	   (format-time-string "today, %R" then-time t))
	  ((= delta -1)
	   (format-time-string "yesterday, %R" then-time t))
	  ((and (< delta 0)
		(<= -7 delta))
	   (format-time-string "%a, %Y-%m-%d" then-time t))
	  (t then-date))))

(defun vernacular-time-overlay-common (overlay)
  "Common actions for placing OVERLAYs."
  (overlay-put overlay 'vernacular-time t))

(defun vernacular-time-overlay-put (overlay prop value)
  "Wrapper for common actions when placing OVERLAYs.
Argument PROP property.
Argument VALUE value of property."
  (overlay-put overlay prop value)
  (overlay-put overlay 'vernacular-time t))

(defun vernacular-time-remove-vernacular-overlays (start end)
  "Remove all vernacular-time overlays between START and END."
  (remove-overlays start end 'vernacular-time t))

(defun vernacular-time-remove-all ()
  "Remove all vernacular-time overlays in the current buffer."
  (interactive)
  (vernacular-time-remove-vernacular-overlays (point-min) (point-max)))

;;; --------------------------------------------------------
;;; Dired
;;; --------------------------------------------------------

(defun vernacular-dired-convert (dired-time-string)
  "Convert DIRED-TIME-STRING to a format Emacs groks."
  (format-time-string "%Y-%m-%dT%T%z"
		      (apply #'encode-time
			     (parse-time-string dired-time-string))))

(defun date-to-vernacular-dired (dired-time-string)
  "Convert and return DIRED-TIME-STRING in the vernacular."
  (date-to-vernacular
   (vernacular-dired-convert dired-time-string)))

(defun date-to-vernacular-dired-change-p (dired-time-string)
  "Return t if there is any need to change DIRED-TIME-STRING."
  (< -8
     (days-between
      (vernacular-dired-convert dired-time-string)
      (current-time-string))))

(defun vernacular-time-dired (type)
  "Convert the times in the current buffer to TYPE of overlays."
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward vernacular-time-dired-date-regexp (point-max) t)
      (let ((inhibit-read-only t)
	    (start (match-beginning 0))
	    (end (match-end 0))
	    (dired-time-string (match-string 0)))
	(when (date-to-vernacular-dired-change-p dired-time-string)
	  (cond ((eq type 'echo)
		 (vernacular-time-overlay-put
		  (make-overlay start end) 'help-echo
		  (date-to-vernacular-dired dired-time-string)))
		((eq type 'display)
		 (vernacular-time-overlay-put
		  (make-overlay start end) 'display
		  (format "%16s"
			  (date-to-vernacular-dired dired-time-string))))
		(t (error "unknown type"))))
	(forward-line)))))

(defun vernacular-time-dired-display ()
  "Display time overlays in the current dired buffer."
  (interactive)
  (vernacular-time-dired 'display))

(provide 'vernacular-time)

;;; vernacular-time.el ends here