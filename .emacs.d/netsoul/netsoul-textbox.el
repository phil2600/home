;;; netsoul-textbox.el --- Textbox management for Emacs netsoul
;; $Id: netsoul-textbox.el 28 2005-07-16 18:07:03Z cadilh_m $
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

;;; Users variables:

(defgroup netsoul-textbox-details nil
  "Textbox related settings."
  :group 'netsoul)

(defcustom netsoul-chat-textbox-mode-hook nil
  "Chat textbox mode hook."
  :type 'hook
  :group 'netsoul-textbox-details)

;;; Internal variables:

(defvar netsoul-textbox-buffer nil
  "Textbox's buffer.")

;;; Mode definition:

(defvar netsoul-chat-textbox-mode-map nil
  "Keymap for textbox chat mode.")

(defun netsoul-chat-textbox-mode ()
  "Mode for the textbox chat buffer."
  (interactive)
  (kill-all-local-variables)
  (netsoul-chat-textbox-mode-map)
  (setq major-mode 'netsoul-chat-textbox-mode)
  (setq mode-name "Netsoul Textbox"
	buffer-undo-list nil)
  (use-local-map netsoul-chat-textbox-mode-map)
  (make-local-variable 'after-change-functions)
  (add-hook 'after-change-functions
	    'netsoul-textbox-change)
  (run-hooks 'netsoul-chat-textbox-mode-hook))

(defun netsoul-chat-textbox-mode-map ()
  "Keymap for the textbox chat buffer."
  (unless netsoul-chat-textbox-mode-map
    (setq netsoul-chat-textbox-mode-map (make-sparse-keymap))
    (define-key netsoul-chat-textbox-mode-map [(control m)] 'netsoul-send-textbox)
    (define-key netsoul-chat-textbox-mode-map "\C-c\C-c" 'netsoul-clear-chat-buffer)
    (define-key netsoul-chat-textbox-mode-map "\C-ck" 'netsoul-chat-kill)
    (define-key netsoul-chat-textbox-mode-map "\C-cq" 'netsoul-show)
    (define-key netsoul-chat-textbox-mode-map "\C-ch" 'netsoul-show)
    (define-key netsoul-chat-textbox-mode-map "\C-cm" 'netsoul-send-message)
    (define-key netsoul-chat-textbox-mode-map "\C-i" 'other-window)
    (define-key netsoul-chat-textbox-mode-map [(tab)] 'other-window)
    (define-key netsoul-chat-textbox-mode-map "\C-xb" 'netsoul-next-chat-buffer)
    (define-key netsoul-chat-textbox-mode-map "\C-cn" 'netsoul-next-chat-buffer))) ;; Temporary

;;; Functions:

;;;###autoload
(defun netsoul-textbox-buffer ()
  "Return the Netsoul Textbox buffer, if it exists."
  (unless (buffer-live-p netsoul-textbox-buffer)
    (save-window-excursion
      (setq netsoul-textbox-buffer (get-buffer-create " *Netsoul Textbox*"))
      (set-buffer netsoul-textbox-buffer)
      (netsoul-chat-textbox-mode)))
  netsoul-textbox-buffer)

(defun netsoul-send-textbox ()
  "Send a message from the textbox."
  (interactive)
  (if (not (string= " *Netsoul Textbox*" (buffer-name)))
      (error "Not in the netsoul textbox")
    (let ((chat-buffer (netsoul-current-chat-buffer))
          (message (buffer-string)))
      (if (not (and chat-buffer
		    (with-current-buffer chat-buffer netsoul-user-connected)))
          (error "No active chat-buffer found")
        (erase-buffer)
        (netsoul-commit-message (with-current-buffer chat-buffer netsoul-user-id)
				message chat-buffer)))))

;;;###autoload
(defun netsoul-commit-message (id message chat-buffer)
  "Commit to ID a MESSAGE, writting the message in CHAT-BUFFER."
  (when (numberp id)
    (netsoul-message-insert-in-buffer chat-buffer netsoul-self-name message
				      'netsoul-you)
  (let ((window-list (get-buffer-window-list chat-buffer))
	(buffer-size (+ 1 (buffer-size chat-buffer))))
    (mapcar (lambda (window)
	      (set-window-point window buffer-size)) window-list))
  (let ((login (with-current-buffer chat-buffer
		 netsoul-user-login)))
    (when login
      (netsoul-log-message login netsoul-self-name message)))
  (netsoul-send-message id message)))


;;;###autoload
(defun netsoul-send-message (id message)
  "Send to ID a MESSAGE.
If ID is a string, use it as a login.  Otherwise, use it as an NS-ID."
  (interactive (list (let ((default (or (netsoul-get-contact-property 'login)
					(thing-at-point 'symbol))))
		       (if default
			   (read-string (concat "Send message to (default: "
						default "): ") nil nil default)
			 (read-string "Send message to: ")))
		     (read-string "Message: " nil nil nil t)))
  (when (not (string= "" message))
    (when (and (stringp id) (not (string-match netsoul-login-pattern id)))
      (error "Login doesn't match login pattern"))
    (netsoul-send-server (concat "msg_user " (if (stringp id) id
					       (concat ":" (number-to-string id)))
				 " msg " (url-encode message)) t)))

(defun netsoul-textbox-change (be en le)
  "Called when the texbox has changed.
See `after-change-functions' for details on BE EN and LE."
  (if (string= "" (buffer-string))
      (netsoul-send-typing nil)
    (when (and (= be 1) (not (= en 1)))
      (netsoul-send-typing t))))

;;;###autoload
(defun netsoul-send-typing (start)
  "Send the typing message to the current chat buffer.
If START is t, send a start, a stop otherwise."
  (let ((chat-buffer (netsoul-current-chat-buffer)))
    (when chat-buffer
      (with-current-buffer chat-buffer
	(when netsoul-user-connected
	  (netsoul-send-server
	   (concat "msg_user :"
		   (number-to-string netsoul-user-id)
		   " dotnetSoul_User" (if start "" "Cancelled")
		   "Typing") t))))))

(provide 'netsoul-textbox)


;;; arch-tag: fa0fc123-dc91-4b26-aeb4-0c3c62938805
;;; netsoul-textbox.el ends here
