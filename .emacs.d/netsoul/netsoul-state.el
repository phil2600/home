;;; netsoul-state.el --- Users status management for Emacs netsoul
;; $Id: netsoul-state.el 28 2005-07-16 18:07:03Z cadilh_m $
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

(defgroup netsoul-state-details nil
  "User's state details."
  :group 'netsoul)

(defcustom netsoul-away-timeout 300
  "Seconds to switch state to away."
  :group 'netsoul-state-details
  :type '(integer))

;;;###autoload
(defcustom netsoul-away-message
  "Auto: I'm away. Use Emacs' Netsoul, that's the future"
  "Auto away message. nil for nothing."
  :group 'netsoul-state-details
  :type '(string))

;;; Internal variables:

;;;###autoload
(defvar netsoul-away-timer nil
  "Timer used to away the user.")

;;;###autoload
(defvar netsoul-state nil
  "Current state.")

(defvar netsoul-possible-states
  '("away" "idle" "actif" "lock")
  "States in which the user can be.")

;;; Functions:

;;;###autoload
(defun netsoul-set-state (state)
  "Change your state to STATE."
  (interactive (list (completing-read "Your state: "
				      (mapcar (lambda (e) (list e e))
					      netsoul-possible-states))))
  (setq netsoul-state state)
  (netsoul-send-server (concat "state " (url-encode state) ":" (netsoul-get-time)))
  (when (string= state "actif")
    (dolist (buffer (buffer-list))
      (with-current-buffer buffer
	(when netsoul-user-id
	  (setq netsoul-away-sent nil))))))

;;;###autoload
(defun netsoul-contact-disconnected (id login)
  "A contact (ID LOGIN) has disconnected."
  (let ((connections (netsoul-login-to-connections login)))
    (remhash id connections)
    (let ((message (concat login " got disconnected"
			   (when (> (hash-table-count connections) 0)
			     " but is still online from another location"))))
      (netsoul-send-to-buffer-id id (concat (format-time-string "%Hh%M ")
					    message "\n") t)
      (netsoul-event-message message))
    (netsoul-update-contact-list)))

;;;###autoload
(defun netsoul-contact-connected (id login)
  "A contact (ID LOGIN) has connected."
  (let ((connections (netsoul-login-to-connections login))
	(format-time (format-time-string "%Hh%M ")))
    (netsoul-send-to-buffer-id id (concat format-time login " connected\n"))
    (netsoul-event-message (concat login " connected"
				   (when (> (hash-table-count connections) 0)
				     " from another location")))
    (netsoul-who-list (concat "{" login "}"))))

;;;###autoload
(defun netsoul-contact-state (id login group state time)
  "A contact (ID LOGIN GROUP) changed his state to STATE since TIME.
This change is not taken into account if GROUP is `exam'."
  (unless (string= group "exam")
    (let ((connections (netsoul-login-to-connections login)))
      (let ((connection (gethash id connections nil)))
	(when (and connection (not (string= (url-decode state)
					    (nth 1 connection))))
	  (puthash id (list
		       (nth 0 connection)
		       (url-decode state)
		       time
		       (nth 3 connection)
		       (nth 4 connection)
		       (nth 5 connection)
		       (nth 6 connection)
		       (nth 7 connection))
		   connections)
	  (netsoul-update-contact-list)
	  (let ((message (concat login " is now " (url-decode state))))
	    (netsoul-send-to-buffer-id id (concat (format-time-string "%Hh%M ")
						  message "\n"))
	    (netsoul-event-message message)))))))

(defun netsoul-away-wait ()
  "Wait for an input to set the state back to actif."
  (when (string= netsoul-state "actif")
    (netsoul-event-message "Going to away state")
    (netsoul-set-state "away")
    (while (sit-for 120)
      (netsoul-event-message "Still away..."))
    (netsoul-event-message "Going back to actif state")
    (netsoul-set-state "actif")))

;;;###autoload
(defun netsoul-away-timer ()
  "Set the away timer."
  (when (timerp netsoul-away-timer)
    (cancel-timer netsoul-away-timer))
  (setq netsoul-away-timer nil)
  (or (<= netsoul-away-timeout 0)
      (setq netsoul-away-timer (run-with-idle-timer netsoul-away-timeout
						    t 'netsoul-away-wait))))

(defun netsoul-set-away-message (away-message)
  "Set the away message of the user to AWAY-MESSAGE.
Just an easier way than to do it with `customize'."
  (interactive "sSet away message (`Auto:' will be added, empty means no message): ")
  (if (string= away-message "")
      (setq netsoul-away-message "")
    (setq netsoul-away-message (concat "Auto: " away-message)))
  (customize-save-variable 'netsoul-away-message netsoul-away-message))

(provide 'netsoul-state)

;;; arch-tag: a6818ae6-fb9e-4cf9-8a53-60a21aa62e2d
;;; netsoul-state.el ends here
