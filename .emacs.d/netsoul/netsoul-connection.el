;;; netsoul-connection.el --- Connection management for Emacs netsoul
;; $Id: netsoul-connection.el 56 2005-09-12 12:19:08Z cadilh_m $
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

;;; Internal variables:

;; Think only geeks will change that.
(defconst netsoul-ping-messages
  '("Pommade" "APWAL" "Corde" "Ketum" "Baobab"
    "Abitbol ! L'homme le plus classe du monde"
    "Le lisp c'est fun" "Bonjours" "fabecc ? Racluuure !"
    "Emacs, c'est frais" "c2c en a une toute petite"
    "Georges Abitbol s'était loin d'être un pérave."
    "Hooo les beaux jours au parc Pinel !")
  "Messages to send as ping.")

(defconst netsoul-ping-delay 30
  "Delay between pings.")

(defvar netsoul-command-prefix nil
  "Prefix to commands.")

;;;###autoload
(defvar netsoul-process nil
  "Netsoul connection.")

;;;###autoload
(defvar netsoul-connection-state nil
  "Connection state, could be nil, 'connecting, 'connected or 'authentified.")

(defvar netsoul-session-pass nil
  "Session password.")

;;;###autoload
(defvar netsoul-delta 0
  "Time difference between local time and server one.")

(defvar netsoul-untreated-input nil
  "Part of a message not treated.")

;;;###autoload
(defvar netsoul-ping-timer nil
  "Ping timer.")

(defvar netsoul-events-buffer nil
  "Buffer for event logging.")

;;; Functions:

;;;###autoload
(defun netsoul-events-buffer ()
  "Return the Netsoul Events buffer, if it exists."
  (unless (buffer-live-p netsoul-events-buffer)
    (save-window-excursion
      (setq netsoul-events-buffer (get-buffer-create "*Netsoul Events*"))
      (set-buffer netsoul-events-buffer)
      (setq buffer-read-only t)))
  netsoul-events-buffer)

;;;###autoload
(defun netsoul-send-server (str &optional with-prefix)
  "Send STR to the netsoul server.
If WITH-PREFIX is set, add the command prefix to STR."
  (when with-prefix
    (setq str (concat netsoul-command-prefix " " str)))
  (netsoul-event-message (concat "Raw to server: " str))
  (process-send-string netsoul-process (concat str "\n")))

(defun netsoul-whole-user-data ()
  "Return the whole user data, with ENetsoul propaganda."
  (url-encode (concat "ENetsoul - " netsoul-version-name " ("
		      netsoul-version ") ["
		      netsoul-user-data "]")))

(defun netsoul-send-user-data (&optional user-data)
  "Send to the server the new USER-DATA."
  (interactive (list (read-string "User data: ")))
  (when user-data
    (setq netsoul-user-data user-data))
  (netsoul-send-server (concat "user_data " (netsoul-whole-user-data)) t))

(defun netsoul-launch ()
  "Setup after connection is established."
  (netsoul-send-user-data)
  (netsoul-set-state "actif")
  (netsoul-away-timer)
  (netsoul-update-contacts)
  (netsoul-watch-log)
  (run-hooks 'netsoul-connect-hook))

;;;###autoload
(defun netsoul-connect ()
  "External/internal connection to the netsoul server."
  (setq netsoul-session-pass (or netsoul-pass ""))
  (let ((user-link (getenv "NS_USER_LINK")))
    (if user-link
        (progn
          (setq netsoul-command-prefix "cmd"
                netsoul-process (call-if-exists
				 '(make-network-process
				   :name "netsoul-server"
				   :family 'local
				   :buffer nil
				   :service (expand-file-name (concat "~/.ns/" user-link))))
                netsoul-delta 0
		netsoul-connection-state 'authentified)
	  (set-process-sentinel netsoul-process 'netsoul-connection-sentinel)
          (set-process-filter netsoul-process 'netsoul-receive-from-server)
	  (netsoul-launch))
      (when (equal netsoul-session-pass "")
	(setq netsoul-session-pass (read-passwd
				    (concat netsoul-login "'s password: "))))
      (setq netsoul-command-prefix "user_cmd")
      (if (functionp 'make-network-process)
	  (setq netsoul-process (call-if-exists
				 '(make-network-process
				   :name "netsoul-server"
				   :host netsoul-host
				   :buffer nil
				   :service netsoul-port))
		netsoul-connection-state 'connecting)
	(setq netsoul-process
	      (open-network-stream
	       "netsoul-server" nil netsoul-host netsoul-port)))
      (set-process-sentinel netsoul-process 'netsoul-connection-sentinel)
      (set-process-filter netsoul-process 'netsoul-receive-from-server))))

(defun netsoul-receive-from-server (proc message)
  "In authentified mode, receive and treat PROC's MESSAGE."
  (when netsoul-untreated-input
    (setq message (concat netsoul-untreated-input message)
	  netsoul-untreated-input nil))
  (let ((list (split-string message "\n")))
    (if (string-match "\n" message (- (length message) 1))
	(mapcar 'netsoul-treat-message list)
      (setq netsoul-untreated-input (car (last list)))
      (mapcar 'netsoul-treat-message (butlast list)))))

(defun netsoul-receive-login-hello (message)
  "Parse the `salut' handshaking MESSAGE and store data."
  (netsoul-event-message "Trying to connect...")
  (let ((items (split-string message)))
    (if (= (length items) 6)
	(let ((myid (nth 1 items))
	      (challenge (nth 2 items))
	      (peerip (nth 3 items))
	      (peerport (nth 4 items))
	      (time (string-to-number (nth 5 items))))
	  (setq netsoul-delta (truncate (- time (float-time))))
	  (netsoul-event-message "Trying to authentificate...")
	  (netsoul-send-server "auth_ag ext_user none none")
	  (netsoul-send-server
	   (concat "ext_user_log "  netsoul-login " "
		   (md5 (concat challenge "-"
				peerip "/" peerport netsoul-session-pass))
		   " " (url-encode netsoul-location) " " (netsoul-whole-user-data)))
	  (setq netsoul-session-pass nil))
      (error "Probably not a Netsoul server"))))

(defun netsoul-receive-login-reply (reply)
  "Parse the login reply REPLY."
  (let ((items (split-string reply)))
    (if (string-match "^002" (nth 1 items))
	(if (eq netsoul-connection-state 'connected)
	    (setq netsoul-connection-state 'authentified)
	  (setq netsoul-connection-state 'connected))
      (netsoul-event-message "Authentification failed !")
      (netsoul-quit)
      (error "Authentification failed !"))
    (when (eq netsoul-connection-state 'authentified)
      (netsoul-event-message "Successfuly connected !")
      (message "Netsoul connection established.")
      (setq netsoul-ping-timer (run-at-time t netsoul-ping-delay 'netsoul-ping))
      (netsoul-launch))))

(defun netsoul-ping ()
  "Ping the server with a random message."
  (netsoul-send-server
   (concat "pong "(nth (random (length netsoul-ping-messages))
		       netsoul-ping-messages))))

(defun netsoul-treat-message (message)
  "Treat a netsoul-server MESSAGE."
  (unless (string= message "")
    (netsoul-event-message (concat "Raw from server: " message))
    (if (eq netsoul-connection-state 'authentified)
	;; Parse the header of the message.
	(if (string-match (concat "^user_cmd \\([0-9.]+\\):[^:]+:[^:]+:"
				  "\\([^@]+\\)@[^:]*:[^:]*:\\([^:]*\\):"
				  "\\([^ ]*\\) \\( *| *\\)")
			  message)
	    (let ((id (string-to-number (match-string 1 message)))
		  (login (match-string 2 message))
		  (host (match-string 3 message))
		  (group (match-string 4 message)))
	      (setq message (substring message (match-end 5)))
	      (cond
	       ((string-match "^who" message)
		(netsoul-who-result message))
	       ((string-match "^logout" message)
		(netsoul-contact-disconnected id login))
	       ((string-match "^login" message)
		(netsoul-contact-connected id login))
	       ((string-match "^state \\([^ ]+\\):\\([0-9]+\\)" message)
		(netsoul-contact-state id login group (match-string 1 message)
				       (string-to-number (match-string 2 message))))
	       ((string-match "^msg \\([^ ]+\\) +dst=" message)
		(netsoul-receive-message id login group host (match-string 1 message)))
	       ((string-match "^typing_\\([^ ]+\\) +dst=" message)
		(netsoul-receive-typing id login host (match-string 1 message)))
	       ((string-match "^dotnetSoul_UserTyping" message)
		(netsoul-receive-typing id login host "start"))
	       ((string-match "^dotnetSoul_UserCancelledTyping" message)
		(netsoul-receive-typing id login host "end"))
	       ((string-match "^new_mail -f \\([^ ]*\\) %28\\(.*\\)%29$" message)
		(netsoul-receive-mail (match-string 1 message)
				      (match-string 2 message)))
	       ((string-match "^rep" message) t)
	       (t (netsoul-event-message "Message not treated."))))
	  (unless (string-match "^rep" message)
	    (netsoul-event-message "Incorrect message header.")))
      (cond ((string-match "^salut " message) (netsoul-receive-login-hello message))
	    ((string-match "^rep " message) (netsoul-receive-login-reply message))
	    (t (netsoul-quit) (error "Unexpected answer from the server"))))))

(defun netsoul-connection-sentinel (proc state)
  "Called when the netsoul connection PROC is interupted.
See sentinel related functions for the STATE parameter."
  (netsoul-quit)
  (insert-in-buffer "*WARNING: Netsoul connection closed*" (netsoul-textbox-buffer)
		    nil 'netsoul-warning-face 1 36)
  (error "Netsoul connection closed"))


(provide 'netsoul-connection)

;;; arch-tag: 22e4cb60-38eb-4f88-99f6-fd40e4a36701
;;; netsoul-connection.el ends here
