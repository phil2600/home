;;; netsoul-generic.el --- Generic functions for Emacs netsoul
;; $Id: netsoul-generic.el 60 2005-09-17 07:13:43Z cadilh_m $
;;
;; Copyright (C) 2004, 2005, 2006 Michaël Cadilhac

;; Author: Michaël Cadilhac <michael.cadilhac@lrde.org>
;; Keywords: netsoul, chat, instant messenger

;; This file is part of Emacs Netsoul.

;; Emacs Netsoul is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or (at
;; your option) any later version.

;; Emacs Netsoul is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with Emacs Netsoul; see the file COPYING. If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.

;;; Code:

;;; Functions:

;;;###autoload
(defmacro call-if-exists (func)
  "Call FUNC if its car is an existing function."
  `(funcall (if (functionp (car ,func))
		(list 'lambda nil ,func)
	      (lambda nil))))

(defun string-replace-regexp (from to string)
  "Replace FROM with TO in STRING.
FROM is a regexp."
  (save-match-data
    (let ((pos 0)
	  (len-to (length to)))
      (while (setq pos (string-match from string pos))
	(setq string (concat (substring string 0 pos) to
			     (substring string (match-end 0)))
	      pos (+ len-to pos)))
      string)))

;;;###autoload
(defun url-encode (string)
  "URL-Encode STRING."
  (mapconcat
   (lambda (c)
     (format (if (string-match "[a-zA-Z0-9]" (char-to-string c))
                 "%c" "%%%02x") c))
   (encode-coding-string string 'iso-latin-1) ""))

;;;###autoload
(defun url-decode (string)
  "URL-Decode STRING."
  (save-match-data
    (let ((pos 0))
      (while (setq pos (string-match "%\\([a-fA-F0-9][a-fA-F0-9]\\)" string pos))
	(setq string (concat (substring string 0 pos)
			     (format "%c" (string-to-number (match-string 1 string) 16))
			     (substring string (match-end 0)))
	      pos (+ 1 pos)))
      string))
  (string-replace-regexp "\\\\n" "\n" string))

;;;###autoload
(defun netsoul-event-message (text)
  "Print TEXT to the netsoul-events buffer."
  (with-current-buffer (netsoul-events-buffer)
    (save-excursion
      (let ((buffer-read-only nil))
	(goto-char (point-max))
	(insert (concat (format-time-string "[%H:%M] ") text "\n"))))))

;;;###autoload
(defun fill-simple (&optional at beg end)
  "Fill adding \\n's every AT chars, trying to not break words."
  (interactive "P\nr")
  (unless at
    (setq at fill-column))
  (save-excursion
    (goto-char (point-min))
    (while (not (eq (point) (point-max)))
      (let ((pab (point-at-bol)))
	(goto-char (+ pab at))
	(when (eq pab (point-at-bol))
	  (if (looking-at "$")
	      (forward-line 1)
	    (if (or (memq (char-after) '(? ?\t))
		    (memq (char-before) '(? ?\t)))
		(newline)
	      (let ((old-point (point)))
		(forward-word -1)
		(if (or (eq (point) pab)
			(not (eq (point-at-bol) pab)))
		    (progn
		      (goto-char old-point)
		      (newline))
		  (newline))))))))))

;;;###autoload
(defun insert-in-buffer (text buffer &optional clear-before wface wfrom wlen)
  "Insert TEXT in BUFFER.
CLEAR-BEFORE means clear the buffer before inserting text.
WFACE is a face that will be set for text from WFROM of len WLEN."
  (with-current-buffer buffer
    (let ((buffer-read-only nil))
      (when clear-before
	(erase-buffer))
      (goto-char (point-max))
      (insert (with-temp-buffer
		(insert text)
		(when wface
		  (put-text-property wfrom (+ wfrom wlen) 'face wface))
		(goto-char (point-max))
		(insert " ")
		(when (and netsoul-smiley (functionp 'smiley-buffer))
		  (call-if-exists '(smiley-buffer (current-buffer))))
		(delete-backward-char 1)
		(when (eq netsoul-cut-method 'fill)
		  (fill-simple (- (/ (* (frame-width) netsoul-chat-width) 100) 2)))
		(buffer-string))))))

;;;###autoload
(defun netsoul-get-time ()
  "Get time with delta."
  (nth 0 (split-string (number-to-string (+ (float-time) netsoul-delta)) "\\.")))

;;;###autoload
(defun netsoul-send-to-buffer-id (id message &optional destroy)
  "Insert in chat buffer which `netsoul-user-id' is ID a MESSAGE.
If DESTROY is t, set the buffer to a disconnected state."
  (let ((chat-buffer (netsoul-id-to-buffer id)))
    (when chat-buffer
      (insert-in-buffer message chat-buffer)
      (when destroy
	(with-current-buffer chat-buffer
	  (setq netsoul-user-connected nil))))))

;;;###autoload
(defun netsoul-id-to-buffer (id)
  "Get the active buffer corresponding to ID."
  (save-excursion
    (let ((buffer-list (buffer-list))
	  (buffer-result nil))
      (while (and (car buffer-list) (not buffer-result))
	(set-buffer (car buffer-list))
	(when (and netsoul-user-id (= netsoul-user-id id) netsoul-user-connected)
	  (setq buffer-result (car buffer-list)))
	(setq buffer-list (cdr buffer-list)))
      buffer-result)))

;;;###autoload
(defun netsoul-current-chat-window ()
  "Get the current chat window."
  (save-excursion
    (let ((window-list (window-list))
	  (window-result nil)
	  (window-other-result nil))
      (while (and (car window-list) (not window-result))
	(set-buffer (window-buffer (car window-list)))
	(when netsoul-user-id
	  (setq window-result (car window-list)))
	(when (not (or (string= (buffer-name) " *Netsoul Textbox*")
		       (string= (buffer-name) " *Netsoul Contacts*")))
	  (setq window-other-result (car window-list)))
	(setq window-list (cdr window-list)))
      (if window-result
	  window-result
	window-other-result))))

;;;###autoload
(defun netsoul-puthash-after (prev-key new-key new-data hash)
  "Insert after PREV-KEY the pair (NEW-KEY, NEW-DATA) in HASH.
HASH is a symbol.
If PREV-KEY is nil the pair is inserted at the beginning.
If PREV-KEY is not found in HASH, the pair is inserted
at the end of the hash table."
  (let ((new-hash (make-hash-table :test 'equal))
	put)
    (setq put nil)
    (unless prev-key
      (puthash new-key new-data new-hash)
      (setq put t))
    (maphash (lambda (key data)
	       (puthash key data new-hash)
	       (when (equal key prev-key)
		 (puthash new-key new-data new-hash)
		 (setq put t)))
	     (symbol-value hash))
    (unless put
      (puthash new-key new-data (symbol-value hash)))
    (set hash new-hash)))

;; If the macro `with-selected-window' doesn't exist,
;; use the definition of `subr'.
;;;###autoload
(defmacro with-selected-window (window &rest body)
  "Taken from `subr' in case of not defined (Emacs ~< 21.3).
See the original doc for WINDOW and BODY."
  `(let ((save-selected-window-window (selected-window))
	 (save-selected-window-alist
	  (mapcar (lambda (frame) (list frame (frame-selected-window frame)))
		  (frame-list))))
     (unwind-protect
	 (progn (select-window ,window)
		,@body)
       (dolist (elt save-selected-window-alist)
	 (and (frame-live-p (car elt))
	      (window-live-p (cadr elt))
	      (set-frame-selected-window (car elt) (cadr elt))))
       (if (window-live-p save-selected-window-window)
	   (select-window save-selected-window-window)))))

(provide 'netsoul-generic)

;;; arch-tag: b70db842-18c1-4bff-99eb-1688937e54a7
;;; netsoul-generic.el ends here
