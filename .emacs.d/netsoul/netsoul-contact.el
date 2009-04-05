;; $Id: netsoul-contact.el 60 2005-09-17 07:13:43Z cadilh_m $
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

(defgroup netsoul-contact-list-details nil
  "Contact list related settings."
  :group 'netsoul)

(defface netsoul-active-face
  '((((class color))
     (:foreground "green")))
  "Face used to display active people."
  :group 'netsoul-contact-list-details)

(defface netsoul-non-active-face
  '((((class color))
     (:foreground "red")))
  "Face used to display inactive people."
  :group 'netsoul-contact-list-details)

(defface netsoul-offline-face
  '((((class color))
     (:foreground "grey")))
  "Face used to display offline people."
  :group 'netsoul-contact-list-details)

(defcustom netsoul-show-offline-contacts nil
  "Offline contacts shown ?"
  :group 'netsoul-contact-list-details
  :type '(boolean))

(defcustom netsoul-considered-as-offline-states '("server")
  "States that are considered as offline.
For example, '(\"server\" \"exam\") is a good value."
  :group 'netsoul-contact-list-details
  :type '(repeat string))

(defcustom netsoul-contacts-mode-hook nil
  "Contact mode hook."
  :group 'netsoul-contact-list-details
  :type 'hook)

;;; User variables:

;;;###autoload
(defvar netsoul-contacts-hash nil
  "Hash table used for contacts storing.")

(defvar netsoul-contacts-buffer nil
  "Buffer for the contact list.")

;;;###autoload
(defvar netsoul-login-pattern
  "^\\([a-z-]+_[a-zA-Z0-9_-]\\{,25\\}\\|[a-z0-9-]\\{,25\\}\\)$"
  "Pattern for valid logins.")

;;; Mode definitions:

(defvar netsoul-contacts-mode-map nil
  "Keymap for the netsoul contacts mode.")

(defun netsoul-contacts-mode ()
  "Mode for the netsoul contact buffer."
  (interactive)
  (kill-all-local-variables)
  (netsoul-contacts-mode-map)
  (setq major-mode 'netsoul-contacts-mode)
  (setq mode-name "Netsoul Contacts")
  (use-local-map netsoul-contacts-mode-map)
  (run-hooks 'netsoul-contacts-mode-hook))

(defun netsoul-contacts-mode-map ()
  "Keymap for the netsoul contacts buffer."
  (unless netsoul-contacts-mode-map
    (setq netsoul-contacts-mode-map (make-sparse-keymap))
    (define-key netsoul-contacts-mode-map "\C-i" 'other-window)
    (define-key netsoul-contacts-mode-map [(tab)] 'other-window)
    (define-key netsoul-contacts-mode-map [(mouse-1)] 'netsoul-chat)
    (define-key netsoul-contacts-mode-map [(control m)] 'netsoul-chat)
    (define-key netsoul-contacts-mode-map "a" 'netsoul-add-contacts)
    (define-key netsoul-contacts-mode-map "\C-k" 'netsoul-kill-contact-at-point)
    (define-key netsoul-contacts-mode-map "\C-y" 'netsoul-yank-contact)
    (define-key netsoul-contacts-mode-map "\C-cn" 'netsoul-next-chat-buffer)
    ;; Fixme: A buffer list should be implemented.
    (define-key netsoul-contacts-mode-map "\C-xb" 'netsoul-next-chat-buffer)
    (define-key netsoul-contacts-mode-map "n" 'netsoul-next-chat-buffer)
    (define-key netsoul-contacts-mode-map "\C-ck" 'netsoul-chat-kill)
    (define-key netsoul-contacts-mode-map "\C-xk" 'netsoul-chat-kill)
    (define-key netsoul-contacts-mode-map "k" 'netsoul-chat-kill)
    (define-key netsoul-contacts-mode-map "\C-ch" 'netsoul-show)
    (define-key netsoul-contacts-mode-map "\C-cq" 'netsoul-show)
    (define-key netsoul-contacts-mode-map "h" 'netsoul-show)
    (define-key netsoul-contacts-mode-map "q" 'netsoul-show)
    (define-key netsoul-contacts-mode-map "\C-c\C-c" 'netsoul-clear-chat-buffer)
    (define-key netsoul-contacts-mode-map "C" 'netsoul-clear-chat-buffer)
    (define-key netsoul-contacts-mode-map "o" 'netsoul-toggle-offline-contacts)
    (define-key netsoul-contacts-mode-map "i" 'netsoul-info-at-point)
    (define-key netsoul-contacts-mode-map "I" 'netsoul-toggle-ignore-at-point)
    (define-key netsoul-contacts-mode-map "m" 'netsoul-send-message)))

;;; Functions:

;;;###autoload
(defun netsoul-contacts-buffer ()
  "Return the Netsoul Contact buffer, if it exists."
  (unless (buffer-live-p netsoul-contacts-buffer)
    (save-window-excursion
      (setq netsoul-contacts-buffer (get-buffer-create " *Netsoul Contacts*"))
      (set-buffer netsoul-contacts-buffer)
      (netsoul-contacts-mode)
      (setq buffer-read-only t)))
  netsoul-contacts-buffer)

(defun netsoul-insert-contact-at-point (login nick)
  "Insert the contact LOGIN - NICK at point in the contact list."
  (with-current-buffer (netsoul-contacts-buffer)
    (save-excursion
      (condition-case nil
	  (forward-line -1)
	(error nil))
      (let* ((prev-login (netsoul-get-contact-property 'login)))
	(netsoul-puthash-after
	 prev-login login
	 (list nick (make-hash-table)) 'netsoul-contacts-hash)))))

;;;###autoload
(defun netsoul-add-contacts ()
  "Add new contacts to the netsoul contact list."
  (interactive)
  (unless netsoul-contacts-hash
    (setq netsoul-contacts-hash (make-hash-table :test 'equal)))
  (let ((new-contact
	 (read-string "Enter new contact's login (or nothing to stop): ")))
    (while (not (string= new-contact ""))
      (if (not (string-match netsoul-login-pattern new-contact))
	  (with-temp-message "Login doesn't match login pattern"
	    (sleep-for 2))
	(if (gethash new-contact netsoul-contacts-hash)
	    (with-temp-message "Login already exists"
	      (sleep-for 2))
	  (let ((new-contact-nick
		 (read-string (concat new-contact "'s nickname (default is login): ")
			      "" nil new-contact))
		(connections (make-hash-table)))
	    (netsoul-insert-contact-at-point new-contact new-contact-nick))))
      (setq new-contact (read-string "Enter new contact's login (or nothing stop): ")))
    (netsoul-write-contacts)
    (when (eq netsoul-connection-state 'authentified)
      (netsoul-watch-log)
      (netsoul-update-contact-list)
      (netsoul-update-contacts))))

;;;###autoload
(defun netsoul-update-contacts ()
  "Check the state of every contact."
  (when (> (hash-table-count netsoul-contacts-hash) 0)
    (netsoul-who-list (netsoul-contact-string))))

;;;###autoload
(defun netsoul-who-list (list)
  "Send a who request of the user LIST formated as {login_x,login_y,...}."
  (netsoul-send-server (concat "who " list) t))

;;;###autoload
(defun netsoul-watch-log ()
  "Send a watch_log command to netsoul-server for all contacts."
  (when (> (hash-table-count netsoul-contacts-hash) 0)
    (netsoul-send-server
     (concat "watch_log_user " (netsoul-contact-string)) t)))

(defun netsoul-contact-string ()
  "Return {login_x,login_y,login_z,...} taken from the contact list."
  (let ((list-contact '()))
    (maphash (lambda (login data)
               (setq list-contact (cons "," (cons login list-contact))))
             netsoul-contacts-hash)
    (concat "{" (substring (apply 'concat list-contact) 1) "}")))

;;;###autoload
(defun netsoul-login-to-nick (login)
  "Return the nickname associated with LOGIN or nil."
  (let ((contact (gethash login netsoul-contacts-hash nil)))
    (if contact
        (nth 0 contact)
      login)))

(defun netsoul-id-to-login (id)
  "Return the login associated with ID or nil."
  (let ((login-result nil))
    (maphash (lambda (login data)
               (when (gethash id (nth 1 data) nil)
		 (setq login-result login))) netsoul-contacts-hash)
    login-result))

;;;###autoload
(defun netsoul-login-to-connections (login)
  "Return the connection list associated with LOGIN."
  (let ((contact (gethash login netsoul-contacts-hash nil)))
    (if contact
        (nth 1 contact)
      (make-hash-table))))

;;;###autoload
(defun netsoul-update-contact-list ()
  "Update the contact list buffer."
  (when (eq netsoul-connection-state 'authentified)
    (let ((window (get-buffer-window (netsoul-contacts-buffer)))
	  line char)
      (when window
	(with-selected-window window
	  (setq line (+ (count-lines (window-start) (point))
			(if (= (current-column) 0) 1 0))
		char (- (point) (point-at-bol)))))
      (with-current-buffer (netsoul-contacts-buffer)
	(let ((buffer-read-only nil))
	  (erase-buffer)
	  (insert (if netsoul-show-offline-contacts
		      "All contacts:\n\n"
		    "Online contacts:\n\n"))
	  (maphash 'netsoul-print-contact netsoul-contacts-hash)
	  (goto-char (point-min))))
      (when window
	(with-selected-window window
	  (condition-case nil
	      (progn (goto-line line)
		     (forward-char char))
	    (error nil)))))))

;;;###autoload
(defun netsoul-get-contact-property (property)
  "Get the property PROPERTY on the contact under the point."
  (condition-case nil
      (get-text-property (+ 2 (point-at-bol)) property)
    (error nil)))

(defun netsoul-print-contact (login data)
  "Print an entry for LOGIN in the contact list.
DATA is a hash element for LOGIN."
  (let ((nick (nth 0 data)))
    (if (> (hash-table-count (nth 1 data)) 0)
	(maphash
	 (lambda (id connection)
	   (unless (and (not netsoul-show-offline-contacts)
			(member (nth 1 connection) netsoul-considered-as-offline-states))
	     (let ((buffer (netsoul-id-to-buffer id))
		   (dot ". "))
	       (when (and buffer (with-current-buffer buffer netsoul-unread))
		 (setq dot "* "))
	       (when (member login netsoul-ignore-logins)
		 (setq dot "I "))
	       (let ((line (concat dot nick "@" (nth 0 connection)
				   (unless (string= (nth 1 connection) "actif")
				     (concat " (" (nth 1 connection) ")")) "\n")))
		 (put-text-property 2 (+ 2 (length nick)) 'face
				    (if (string= (nth 1 connection) "actif")
					'netsoul-active-face 'netsoul-non-active-face) line)
		 (put-text-property 2 (+ 2 (length nick)) 'host  (nth 0 connection) line)
		 (put-text-property 2 (+ 2 (length nick)) 'ip  (nth 3 connection) line)
		 (put-text-property 2 (+ 2 (length nick)) 'group  (nth 4 connection) line)
		 (put-text-property 2 (+ 2 (length nick)) 'userdata  (nth 5 connection) line)
		 (put-text-property 2 (+ 2 (length nick)) 'nick nick line)
		 (put-text-property 2 (+ 2 (length nick)) 'id id line)
		 (put-text-property 2 (+ 2 (length nick)) 'login login line)
		 (insert line)))))
	 (nth 1 data))
      (when netsoul-show-offline-contacts
	(let ((line (concat (if (member login netsoul-ignore-logins) "I " ". ")
			    nick "\n")))
	  (put-text-property 2 (+ 2 (length nick)) 'face 'netsoul-offline-face line)
	  (put-text-property 2 (+ 2 (length nick)) 'login login line)
	  (insert line))))))

;;;###autoload
(defun netsoul-who-result (string)
  "Parse STRING as a who message.
If the group is `exam', the state of the user will not be considered."
  (if (string-match "who \\([0-9]+\\) \\([0-9a-zA-Z_-]+\\) \
\\([0-9.]+\\) \\([0-9]+\\) \\([0-9]+\\) \\([0-9]\\) \\([0-9]+\\) \
\\([^ ]+\\) \\([^ ]+\\) \\([^ ]+\\) \\([^: ]+\\):?\\([^ ]*\\) \\([^ ]+\\)"
		    string)
      (let ((id (match-string 1 string))
	    (login (match-string 2 string))
	    (ip (match-string 3 string))
	    (contime (string-to-number (match-string 4 string)))
	    (nowtime (string-to-number (match-string 5 string)))
	    (authag (match-string 6 string))
	    (authuser (match-string 7 string))
	    (machtype (match-string 8 string))
	    (host (match-string 9 string))
	    (group (match-string 10 string))
	    (state (match-string 11 string))
	    (statetime (string-to-number (match-string 12 string)))
	    (userdata (match-string 13 string)))
	(when (string= group "exam")
	  (setq state "exam"))
	(let ((connections (netsoul-login-to-connections login)))
	  (puthash (string-to-number id) (list (url-decode host) state
					       statetime ip
					       group
					       (url-decode userdata) machtype
					       contime nil)
		   connections)
	  (netsoul-update-contact-list)))
    (netsoul-event-message "Who message badly formated.")))

(defun netsoul-chat ()
  "User pressed enter on a contact."
  (interactive)
  (when (eq netsoul-connection-state 'authentified)
    (let (buffer
	  (window-cur (netsoul-current-chat-window))
	  (window-textbox (get-buffer-window (netsoul-textbox-buffer)))
	  (id (netsoul-get-contact-property 'id))
	  (host (netsoul-get-contact-property 'host))
	  (nick (netsoul-get-contact-property 'nick)))
      (when id
	(netsoul-send-typing nil)
	(unless (setq buffer (netsoul-id-to-buffer id))
	  (setq buffer (netsoul-chat-create-buffer id (netsoul-id-to-login id)
						   (concat nick "@" host))))
	(netsoul-see-chat buffer)
	(set-window-buffer window-cur buffer)
	(select-window window-textbox)
	(unless (string= "" (buffer-string))
	  (netsoul-send-typing t))))))

(defun netsoul-yank-contact ()
  "Insert killed contact at point."
  (interactive)
  (let ((cur-kill (current-kill 0 t)))
    (when (and cur-kill
	       (string-match (concat (substring netsoul-login-pattern 0 -1)
				     "@\\(.*\\)") cur-kill))
      (current-kill 0 nil)
      (let* ((login (substring cur-kill (match-beginning 1) (match-end 1)))
	     (nick (substring cur-kill (match-beginning 2) (match-end 2))))
	(netsoul-insert-contact-at-point login nick)
	(netsoul-write-contacts)
	(when netsoul-connection-state
	  (netsoul-watch-log)
	  (netsoul-update-contacts))))))

(defun netsoul-toggle-ignore-at-point ()
  "Toggle ignore state of the contact at point"
  (interactive)
  (let ((login (netsoul-get-contact-property 'login)))
    (when login
      (if (member login netsoul-ignore-logins)
	  (netsoul-unignore-contact login)
	(netsoul-ignore-contact login)))))

(defun netsoul-info-at-point ()
  "Print some info for the current user."
  (interactive)
  (let ((login (netsoul-get-contact-property 'login))
	(ip (netsoul-get-contact-property 'ip))
	(userdata (netsoul-get-contact-property 'userdata))
	(group (netsoul-get-contact-property 'group)))
    (when login
      (if ip
	  (message "Login: %s, ip: %s, user-data: %s, group: %s"
		   login ip userdata group)
	(message "Login: %s" login)))))

(defun netsoul-kill-contact-at-point ()
  "Delete the contact currently at point in the contact list."
  (interactive)
  (let ((login (netsoul-get-contact-property 'login)))
    (when login
      (kill-new (concat login "@" (netsoul-login-to-nick login)))
      (netsoul-kill-contact login))))

(defalias 'netsoul-delete-contact 'netsoul-kill-contact)
(defalias 'netsoul-remove-contact 'netsoul-kill-contact)

(defun netsoul-kill-contact (login)
  "Remove LOGIN from the contact list."
  (interactive
   (list (completing-read
	  "Enter the login of the user you want to delete: "
	  (let ((list-contact '()))
	    (maphash (lambda (login data)
		       (setq list-contact (cons `(,login ,login) list-contact)))
		     netsoul-contacts-hash)
	    list-contact))))
  (unless (or (not login) (string= login ""))
    (remhash login netsoul-contacts-hash)
    (netsoul-write-contacts)
    (netsoul-update-contact-list)))

(defun netsoul-toggle-offline-contacts ()
  "Toggle offline contact showing."
  (interactive)
  (setq netsoul-show-offline-contacts (not netsoul-show-offline-contacts))
  (netsoul-update-contact-list))

(provide 'netsoul-contact)

;;; arch-tag: 22e61a46-0a44-45e6-8f54-4de3e51829ba
;;; netsoul-contact.el ends here
