;;; netsoul-chat.el --- Chat management for Emacs netsoul
;; $Id: netsoul-chat.el 56 2005-09-12 12:19:08Z cadilh_m $
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

(defgroup netsoul-chat-details nil
  "Chat buffers settings."
  :group 'netsoul)

(defgroup netsoul-photo-details nil
  "Photo related settings."
  :group 'netsoul-chat-details)

(defcustom netsoul-photo-path "~/.emacs.d/netsoul/photo/"
  "Photos path."
  :group 'netsoul-photo-details
  :type '(string))

(defcustom netsoul-photo t
  "Display photo."
  :group 'netsoul-photo-details
  :type '(boolean))

(defcustom netsoul-photo-url
  "http://michael.cadilhac.name/photo.php?login=%s"
  "Url for photo retrieving, %s will be replaced with the login.
Note that the photo is not resized in Emacs."
  :group 'netsoul-photo-details
  :type '(string))

;;;###autoload
(defcustom netsoul-ignore-logins nil
  "List of logins to ignore messages from.
The messages are still logged."
  :group 'netsoul-chat-details
  :type '(repeat (string :tag "Login")))

(defcustom netsoul-no-auto-reply-logins nil
  "List of logins that should not receive an auto reply."
  :group 'netsoul-chat-details
  :type '(repeat (string :tag "Login")))

(defcustom netsoul-no-auto-reply-groups '("bocal")
  "List of groups that should not receive an auto reply."
  :group 'netsoul-chat-details
  :type '(repeat (string :tag "Group")))

(defcustom netsoul-chat-mode-hook nil
  "Chat mode hook."
  :group 'netsoul-chat-details
  :type 'hook)

(defcustom netsoul-receive-message-hook nil
  "Message receiving hook.
Each function will receive three parameters: the login and nickname of the
sender, and the message itself."
  :group 'netsoul-chat-details
  :type 'hook)

;;;###autoload
(defcustom netsoul-smiley t
  "Display smileys."
  :group 'netsoul-chat-details
  :type '(boolean))

(defcustom netsoul-msg-warn-time 1
  "Seconds to block the user to warn that a message has been received.
Could be 0."
  :group 'netsoul-chat-details
  :type '(integer))

(defcustom netsoul-beep-on-message t
  "Beeping on new message."
  :group 'netsoul-chat-details
  :type '(boolean))

;;;###autoload
(defcustom netsoul-self-name "You"
  "Your name, will be written as <name> your text."
  :group 'netsoul-chat-details
  :type '(string))

(defcustom netsoul-display-time "%Hh%M"
  "Time displayed in the chat buffer.
See `format-time-string' for the syntax of this variable."
  :group 'netsoul-chat-details
  :type '(string))

(defcustom netsoul-message-patterns
  '(("/me +" . ("%s %s" t))
    ("/beat +" . ("%s is beating %s against the wall" t))
    ("/insist +" . ("Really, I do mean that %s" nil)))
  "Pattern to match messages against before inserting them in chat buffers."
  :group 'netsoul-chat-details
  :type '(repeat (list (string :tag "Pattern to match")
		       (string :tag "Replaced by")
		       (boolean :tag "Nickname also treated"))))

;;;###autoload
(defcustom netsoul-cut-method 'fill
  "Method to cut the text in a chat buffer.
'fill means use `fill' like method, so break at words (default),
'cut means cut at point, so break at chars (Emacs default for buffers)."
  :group 'netsoul-chat-details
  :type '(choice (symbol :tag "fill" 'fill)
		 (symbol :tag "cut" 'cut)))

(defface netsoul-from
  '((((class color))
     (:foreground "red3")))
  "Face used for displaying the <from> field."
  :group 'netsoul-chat-details)

(defface netsoul-you
  '((((class color))
     (:foreground "green")))
  "Face used for displaying the <you> field."
  :group 'netsoul-chat-details)

;;; Internal variables:

;;;###autoload
(defvar netsoul-user-id nil
  "Netsoul user id of the destination.")

;;;###autoload
(defvar netsoul-user-connected nil
  "Set to t if the destination is connected.")

;;;###autoload
(defvar netsoul-user-login nil
  "Current netsoul login of the destination.")

;;;###autoload
(defvar netsoul-unread nil
  "Read/unread flag for the last messages received.")

;;;###autoload
(defvar netsoul-away-sent nil
  "Sent/not sent flag for the away message.")
(make-variable-buffer-local 'netsoul-user-id)
(make-variable-buffer-local 'netsoul-user-connected)
(make-variable-buffer-local 'netsoul-user-login)
(make-variable-buffer-local 'netsoul-unread)
(make-variable-buffer-local 'netsoul-away-sent)

;; On Windows systems, photo-path needs to be set as
;; `untranslated' for LF not to be converted to CRLF.
(call-if-exists '(add-untranslated-filesystem
		  (let ((netsoul-photo-path (expand-file-name netsoul-photo-path)))
		    (unless (file-directory-p netsoul-photo-path)
		      (make-directory netsoul-photo-path t))
		    netsoul-photo-path)))

;; In graphic mode, `url' is used for photo downloading, and
;; `smiley' for emoticons displaying.
(condition-case nil (require 'url)
  (error nil))
(condition-case nil (require 'smiley)
  (error nil))
(call-if-exists '(url-do-setup))

;;; Mode definition:

(defvar netsoul-chat-mode-map nil
  "Keymap for chat mode.")

;;;###autoload
(defun netsoul-chat-mode ()
  "Mode for netsoul chat buffers."
  (interactive)
  (kill-all-local-variables)
  (netsoul-chat-mode-map)
  (setq major-mode 'netsoul-chat-mode)
  (setq mode-name "Netsoul Chat")
  (use-local-map netsoul-chat-mode-map)
  (run-hooks 'netsoul-chat-mode-hook)
  (setq buffer-read-only t))

(defun netsoul-chat-mode-map ()
  "Keymap for netsoul chat buffers."
  (unless netsoul-chat-mode-map
    (setq netsoul-chat-mode-map (make-sparse-keymap))
    (define-key netsoul-chat-mode-map "\C-i" 'other-window)
    (define-key netsoul-chat-mode-map [(tab)] 'other-window)
    (define-key netsoul-chat-mode-map "\C-cn" 'netsoul-next-chat-buffer)
    (define-key netsoul-chat-mode-map "\C-xb" 'netsoul-next-chat-buffer)
    (define-key netsoul-chat-mode-map "n" 'netsoul-next-chat-buffer)
    ;; Fixme: A buffer list should be implemented.
    (define-key netsoul-chat-mode-map "\C-ck" 'netsoul-chat-kill)
    (define-key netsoul-chat-mode-map "\C-xk" 'netsoul-chat-kill)
    (define-key netsoul-chat-mode-map "k" 'netsoul-chat-kill)
    (define-key netsoul-chat-mode-map "\C-ch" 'netsoul-show)
    (define-key netsoul-chat-mode-map "\C-cq" 'netsoul-show)
    (define-key netsoul-chat-mode-map "h" 'netsoul-show)
    (define-key netsoul-chat-mode-map "q" 'netsoul-show)
    (define-key netsoul-chat-mode-map "\C-c\C-c" 'netsoul-clear-chat-buffer)
    (define-key netsoul-chat-mode-map "C" 'netsoul-clear-chat-buffer)
    (define-key netsoul-chat-mode-map "\C-cm" 'netsoul-send-message)
    (define-key netsoul-chat-mode-map "m" 'netsoul-send-message)))

;;; Functions:

;;;###autoload
(defun netsoul-current-chat-buffer ()
  "Return the current chat buffer."
  (save-excursion
    (let ((window-list (window-list))
	  (cur-buffer nil)
	  (buffer-result nil))
      (while (and (car window-list) (not buffer-result))
	(set-buffer (setq cur-buffer (window-buffer (car window-list))))
	(when netsoul-user-id
	  (setq buffer-result cur-buffer))
	(setq window-list (cdr window-list)))
      buffer-result)))

(defun netsoul-chat-kill ()
  "Kill the current chat window."
  (interactive)
  (let ((chat-buffer (netsoul-current-chat-buffer)))
    (when chat-buffer
      (netsoul-next-chat-buffer t)
      (kill-buffer chat-buffer))))

(defun netsoul-chat-create-set-photo (state buffer &optional login)
  "Insert in BUFFER the photo of LOGIN after its download.
STATE is the state of the download.
Called on the creation of a chat buffer."
  ;; Prevent the use of old-fashioned url-retrieve.
  (unless login
    (setq login buffer
	  buffer state))
  (when (and (bufferp buffer) (buffer-live-p buffer))
    (save-excursion
      (goto-char (point-min))
      (when (search-forward "g\n" nil t)
	(goto-char (point-min))
	(let* ((data (substring (buffer-string) (search-forward "g\n" nil t)))
	       (netsoul-photo-path (expand-file-name netsoul-photo-path))
	       (filename (concat netsoul-photo-path "/" login ".jpg")))
	  (if (file-directory-p netsoul-photo-path)
	      (unless (file-accessible-directory-p netsoul-photo-path)
		(error "Directory %s is not accesible" netsoul-photo-path))
	    (make-directory netsoul-photo-path t))
	  (erase-buffer)
	  (setq buffer-file-coding-system 'binary)
	  (insert data)
	  (append-to-file (point-min) (point-max) filename)
	  (kill-buffer (current-buffer))
	  (with-current-buffer buffer
	    (let ((buffer-read-only nil)
		  (iconimage (create-image filename)))
	      (save-excursion
		(if (not iconimage)
		    (delete-file filename)
		  (goto-char (point-min))
		  (forward-line 1)
		  (insert-image iconimage "123456789012345" nil)
		  (insert "\n")
		  (forward-line -1)
		  (center-line))))))))))

;;;###autoload
(defun netsoul-chat-create-buffer (id login host)
  "Create a chat buffer for ID LOGIN HOST.
It inserts a photo if we are in graphic mode."
  (when (not login)
    (error "Connection ID no longer exists"))
  (save-excursion
    (let ((buffer (get-buffer (concat " *" host "*")))
	  (fill-size (/ (* (frame-width) netsoul-chat-width) 100))
	  (photo-filename (concat (expand-file-name netsoul-photo-path)
				  "/" login ".jpg")))
      (if buffer
	  (progn
	    (set-buffer buffer)
	    (let ((buffer-read-only nil))
	      (unless netsoul-user-connected
		(goto-char (point-max))
		(insert "Starting chat with " login "\n")
		(goto-char (point-max)))
	      (when (eq netsoul-cut-method 'fill)
		(fill-simple  (1- fill-size))))
	    (setq netsoul-user-id id
		  netsoul-user-connected t
		  netsoul-user-login login
		  netsoul-away-sent nil)
	    buffer)
	(setq buffer (get-buffer-create (concat " *" host "*")))
	(set-buffer buffer)
	(netsoul-chat-mode)
	(let ((buffer-read-only nil))
	  (make-local-variable 'truncate-partial-width-windows)
	  (setq truncate-partial-width-windows nil
		fill-column fill-size
		netsoul-user-id id
		netsoul-user-connected t
		netsoul-user-login login
		netsoul-unread nil
		netsoul-away-sent nil
		truncate-lines nil)
	  (insert (buffer-name))
	  (center-line)
	  (insert "\n")
	  (when (and (display-graphic-p) (functionp 'url-retrieve)
		     netsoul-photo)
	    (if (not (file-readable-p photo-filename))
		(call-if-exists
		 '(url-retrieve (format netsoul-photo-url login)
				'netsoul-chat-create-set-photo `(,buffer ,login)))
	      (let ((iconimage (create-image photo-filename)))
		(if (not iconimage)
		    (delete-file photo-filename)
		  (insert-image iconimage "123456789012345" nil)
		  (center-line)
		  (insert "\n")))))
	  (insert "Starting chat with " login "\n")
	  buffer)))))

(defun netsoul-clear-chat-buffer ()
  "Clear a chat buffer for all its infos, photo included."
  (interactive)
  (save-excursion
    (unless netsoul-user-login
      (let ((chat-buffer (netsoul-current-chat-buffer)))
	(when (not chat-buffer)
	  (error "Not a chat-buffer, no chat-buffer found"))
	(set-buffer chat-buffer)))
    (let ((buffer-read-only nil))
      (erase-buffer))))

;;;###autoload
(defun netsoul-ignore-contact (login)
  "Add LOGIN to the ignore list."
  (interactive (list (let ((default (or (netsoul-get-contact-property 'login)
					(thing-at-point 'symbol))))
		       (if default
			   (read-string (concat "Ignore login (default: "
						default "): ") nil nil default)
			 (read-string "Ignore login: ")))))
  (if (not (string-match netsoul-login-pattern login))
      (error "Login doesn't match login pattern")
    (add-to-list 'netsoul-ignore-logins login)
    (customize-save-variable 'netsoul-ignore-logins
			     netsoul-ignore-logins)
    (netsoul-update-contact-list)))

;;;###autoload
(defun netsoul-unignore-contact (login)
  "Remove LOGIN from the ignore list."
  (interactive (list (if (not netsoul-ignore-logins)
			 (error "Ignore list is empty")
		       (let ((default (or (netsoul-get-contact-property 'login)
					  (thing-at-point 'symbol)))
			     (completions (mapcar (lambda (e) (list e e))
						  netsoul-ignore-logins)))
			 (if (and default (member default netsoul-ignore-logins))
			     (completing-read (concat "Unignore login (default: "
						      default "): ")
					      completions nil t nil nil default)
			   (completing-read "Unignore login: " completions nil t))))))
  (setq netsoul-ignore-logins (remove login netsoul-ignore-logins))
  (customize-save-variable 'netsoul-ignore-logins
			   netsoul-ignore-logins)
  (netsoul-update-contact-list))


;;;###autoload
(defun netsoul-receive-message (id login group host message)
  "The user ID LOGIN HOST from group GROUP has send MESSAGE."
  (let* ((nickname (netsoul-login-to-nick login))
	 (host (url-decode host))
	 (chat-buffer (unless (member login netsoul-ignore-logins)
			(or (netsoul-id-to-buffer id)
			    (netsoul-chat-create-buffer id login
							(concat nickname "@" host)))))
	 (message (url-decode message))
	 (msg (concat "New message from " nickname)))
    ;; Logging.
    (netsoul-log-message login nickname message)
    ;; The sequel shouldn't be called if LOGIN is ignored.
    (when chat-buffer
      (run-hook-with-args 'netsoul-receive-message-hook login nickname message)
      ;; Insert in the buffer
      (netsoul-message-insert-in-buffer
       chat-buffer nickname message 'netsoul-from)
      ;; Warn the user
      (when netsoul-beep-on-message
	(beep t))
      (with-temp-message msg
	(sleep-for netsoul-msg-warn-time))
      (message "%s" msg)
      ;; Add the `new msg' flag
      (with-current-buffer chat-buffer
	(setq netsoul-unread t))
      ;; If chat-buffer is the current chat buffer, say it's seen
      ;; FIXME: If frame is not selected, wait for it but WITHOUT
      ;;        blocking message receiving.
      (if (eq chat-buffer (netsoul-current-chat-buffer))
	  (netsoul-see-chat chat-buffer)
	(netsoul-update-contact-list))
      ;; For all window displaying chat-buffer, set the point down
      (let ((window-list (get-buffer-window-list chat-buffer))
	    (buffer-size (+ 1 (buffer-size chat-buffer))))
	(mapcar (lambda (window)
		  (set-window-point window buffer-size)) window-list))
      ;; Auto reply
      (when (and (not (string= netsoul-state "actif"))
		 netsoul-away-message
		 (not (member login netsoul-no-auto-reply-logins))
		 (not (member group netsoul-no-auto-reply-groups)))
	(unless (or (string= netsoul-away-message "")
		    (with-current-buffer chat-buffer netsoul-away-sent))
	  (netsoul-commit-message id netsoul-away-message chat-buffer)
	  (with-current-buffer chat-buffer (setq netsoul-away-sent t))))
      ;; Warn the user one more time
      (message "%s" msg))))

;;;###autoload
(defun netsoul-message-insert-in-buffer (chat-buffer nickname message face)
  "Insert in CHAT-BUFFER NICKNAME's MESSAGE.
The sender is colored with FACE."
  (let ((hard-message nil)
	(time (format-time-string netsoul-display-time)))
    (unless (string= time "")
      (setq time (concat time " ")))
    (dolist (token netsoul-message-patterns)
      (when (string-match (format "^%s\\(.*\\)$" (car token)) message)
	(if (nth 2 token)
	    (setq hard-message (format (car (cdr token)) nickname
				       (substring message (match-beginning 1)
						  (match-end 1))))
	  (setq message (format (car (cdr token))
				(substring message (match-beginning 1)
					   (match-end 1)))))))
    (if hard-message
	(insert-in-buffer (concat time "**" hard-message "\n") chat-buffer)
      (insert-in-buffer (concat time
				"<" nickname  "> " message "\n")
			chat-buffer nil face (+ 1 (length time))
			(+ 2 (length nickname))))))

;;;###autoload
(defun netsoul-receive-typing (id login host typing)
  "ID LOGIN HOST has sent a typing event.
TYPING is either `start' or `stop'."
  (let ((chat-buffer (netsoul-id-to-buffer id))
	(nickname (netsoul-login-to-nick login)))
    (let ((buffer-n (concat " *" (concat nickname "@" (url-decode host))
			    (if (string= "start" typing) " Typing" "") "*")))
      (when chat-buffer
	(let ((buffer-new (get-buffer buffer-n)))
	  (when (and buffer-new (not (eq buffer-new chat-buffer)))
	    (kill-buffer buffer-new)))
	(with-current-buffer chat-buffer
	  (rename-buffer buffer-n))))))

(provide 'netsoul-chat)

;;; arch-tag: d7b0e447-d112-414b-b4cf-f717a3260db1
;;; netsoul-chat.el ends here
