;;; netsoul-ergonomic.el --- Ergonomic management for Emacs netsoul
;; $Id: netsoul-ergo.el 72 2005-11-03 18:21:18Z cadilh_m $
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

;;; User variables:

(defgroup netsoul-ergonomic-details nil
  "Ergonomic details."
  :group 'netsoul)

(defface netsoul-warning-face
  '((((class color))
     (:foreground "red3" :weight bold)))
  "Face used when wanting to warn the user of something."
  :group 'netsoul-ergonomic-details)

;;;###autoload
(defcustom netsoul-chat-width 66
  "Width of the chat window, in percent of full screen."
  :type '(integer)
  :group 'netsoul-ergonomic-details)

;;;###autoload
(defcustom netsoul-chat-height 83
  "Height of the chat window, in percent of full height."
  :type '(integer)
  :group 'netsoul-ergonomic-details)

(defcustom netsoul-read-message-hook nil
  "Read message hook.
Two argument are passed to functions in this hook:
  - The login of the person the message is read,
  - Her nickname."
  :type 'hook
  :group 'netsoul-ergonomic-details)

;;; Internal variables:

(defvar netsoul-previous-chat-buffer nil
  "Previous chat buffer.")

(defvar netsoul-previous-win-conf nil
  "Previous windows configuration.")

;;; Functions:

(defun netsoul-one-chat ()
  "Search for a chat window, first in the buffer list."
  (if (and (bufferp netsoul-previous-chat-buffer)
	   (buffer-live-p netsoul-previous-chat-buffer))
      (progn
	(netsoul-see-chat netsoul-previous-chat-buffer)
	netsoul-previous-chat-buffer)
    (save-excursion
      (let ((buffer-list (buffer-list))
	    (buffer-result nil))
	(while (and (car buffer-list) (not buffer-result))
	  (set-buffer (car buffer-list))
	  (when netsoul-user-login
	    (setq buffer-result (current-buffer)))
	  (setq buffer-list (cdr buffer-list)))
	(if buffer-result
	    (progn (netsoul-see-chat buffer-result)
		   buffer-result)
	  (set-buffer (get-buffer-create " *No Conversation*"))
	  (netsoul-chat-mode)
	  (current-buffer))))))

(defun netsoul-is-shown ()
  "Return t if netsoul is currently shown, nil otherwise."
  (if (not netsoul-previous-win-conf)
      nil
    (let ((correct t)
	  (chat nil)
	  (contact nil)
	  (textbox nil)
	  (win-lst (window-list)))
      (while (and win-lst correct)
	(let ((buffer (window-buffer (car win-lst))))
	  (cond ((eq buffer (netsoul-contacts-buffer))
		 (setq contact t))
		((eq buffer (netsoul-textbox-buffer))
		 (setq textbox t))
		(t (if (or (with-current-buffer buffer
			     netsoul-user-login)
			   (string= (buffer-name buffer) " *No Conversation*"))
		       (setq chat t)
		     (setq correct nil)))))
	(setq win-lst (cdr win-lst)))
      (and correct (and chat (and contact textbox))))))

;;;###autoload
(defun netsoul-show ()
  "Show/Hide netsoul's interface."
  (interactive)
  (if (netsoul-is-shown)
      (progn
	(setq netsoul-previous-chat-buffer (netsoul-current-chat-buffer))
	(netsoul-restore-windows))
    (unless netsoul-connection-state
      (with-temp-message "You should launch netsoul (M-x netsoul)"
	(sleep-for 1)))
    (setq netsoul-previous-win-conf (current-window-configuration))
    (delete-other-windows)
    (let ((we (window-edges))
	  (w1 (selected-window)))
      (let ((w2 (split-window w1 (/ (* (nth 2 we) netsoul-chat-width) 100) t)))
	(let ((w3 (split-window w1 (/ (* (nth 3 we) netsoul-chat-height) 100))))
	  (set-window-buffer w1 (netsoul-one-chat))
	  (set-window-buffer w2 (netsoul-contacts-buffer))
	  (set-window-buffer w3 (netsoul-textbox-buffer))
	  (select-window w3))))))


(defun netsoul-restore-windows ()
  "Hide the netsoul interface."
  (if netsoul-previous-win-conf
      (progn
        (set-window-configuration netsoul-previous-win-conf)
        (setq netsoul-previous-win-conf nil))
    (error "No previous window configuration saved")))

(defun netsoul-other-chat-buffer (from-buffer)
  "Give the next window in the uid order of FROM-BUFFER.
FROM-BUFFER is in most cases a chat window."
  (let ((buffer-next nil)
	(buffer-first nil)
	(n-min-uid 31415926)
	(n-next-uid 31415926)
	(n-start-uid 0)
	(buffer-list (buffer-list)))
    (save-window-excursion
      (set-buffer from-buffer)
      (when netsoul-user-id
	(setq n-start-uid netsoul-user-id))
      (while (car buffer-list)
	(set-buffer (car buffer-list))
	(when (and netsoul-user-id (not (= netsoul-user-id n-start-uid)))
	  (when (> n-min-uid netsoul-user-id)
	    (setq n-min-uid netsoul-user-id
		  buffer-first (car buffer-list)))
	  (when (and (> n-next-uid netsoul-user-id) (> netsoul-user-id n-start-uid))
	    (setq n-next-uid netsoul-user-id
		  buffer-next (car buffer-list))))
	(setq buffer-list (cdr buffer-list)))
      (if buffer-next
	  buffer-next
	buffer-first))))

;;;###autoload
(defun netsoul-next-chat-buffer (&optional not-same)
  "Return the next chat buffer in the uid order.
If NOT-SAME is set, create a buffer when there's only one chat buffer."
  (interactive)
  (save-excursion
    (let ((cur-window (netsoul-current-chat-window)))
      (when cur-window
	(netsoul-send-typing nil)
	(let ((next-chat (netsoul-other-chat-buffer
			  (window-buffer cur-window))))
	  (if next-chat
	      (set-window-buffer cur-window next-chat)
	    (when not-same
	      (set-window-buffer
	       cur-window
	       (with-current-buffer (get-buffer-create " *No Conversation*")
		 (netsoul-chat-mode)
		 (current-buffer)))))
	  (if next-chat
	      (netsoul-see-chat next-chat)))
	(with-current-buffer (netsoul-textbox-buffer)
	  (unless (string= "" (buffer-string))
	    (netsoul-send-typing t)))))))

;;;###autoload
(defun netsoul-warn-chats ()
  "Say that chats are closed."
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (when netsoul-user-connected
	(let ((buffer-read-only nil))
	  (goto-char (point-max))
	  (insert "Chat closed\n")
	  (setq netsoul-user-connected nil))))))

;;;###autoload
(defun netsoul-see-chat (buffer)
  "User switched to buffer BUFFER, so she had read the message."
  (with-current-buffer buffer
    (when (and netsoul-user-login netsoul-unread)
      (run-hook-with-args 'netsoul-read-message-hook netsoul-user-login
			  (netsoul-login-to-nick netsoul-user-login))
      (setq netsoul-unread nil)
      (netsoul-update-contact-list))))

(defun netsoul-try-x-urgency (set-p)
  "Try to set (according to SET-P) the X urgency hint to the current frame.
ARGS are ignored."
  (when (eq (framep-on-display) 'x)
    (with-temp-buffer
      (shell-command
       (concat "urgent " (unless set-p "-")
	       (cdr (assq 'outer-window-id (frame-parameters)))) t))))

(add-hook 'netsoul-receive-message-hook
	  (lambda (&rest args) (netsoul-try-x-urgency t)))

;; Some window managers don't remove the hint by themselves. They suck.
(add-hook 'netsoul-read-message-hook
	  (lambda (&rest args) (netsoul-try-x-urgency nil)))

(provide 'netsoul-ergonomic)

;;; arch-tag: 46a4704b-1002-414e-9285-55cef6f563c9
;;; netsoul-ergonomic.el ends here
