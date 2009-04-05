;;; netsoul-configuration.el --- Configuration management for Emacs netsoul
;; $Id: netsoul-conf.el 71 2005-11-03 18:19:24Z cadilh_m $
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

(defgroup netsoul-user-details nil
  "User's informations."
  :group 'netsoul)

(defgroup netsoul-connection-details nil
  "Connection details."
  :group 'netsoul)

(defcustom netsoul-contacts-file "~/.emacs.d/netsoul/contacts"
  "Contact file."
  :group 'netsoul-user-details
  :type '(string))

;;;###autoload
(defcustom netsoul-location (system-name)
  "Location of the user."
  :group 'netsoul-user-details
  :type '(string))

;;;###autoload
(defcustom netsoul-login nil
  "User's login."
  :group 'netsoul-user-details
  :type '(string))

;;;###autoload
(defcustom netsoul-pass nil
  "User's password (use nil to be asked password on connect)."
  :group 'netsoul-user-details
  :type '(radio (const :tag "Prompt for password" "")
		(string :tag "Save password in .emacs")))

;;;###autoload
(defcustom netsoul-user-data (concat "Using Emacs-" emacs-version " ("
				     system-configuration  ")" )
  "User's informations."
  :group 'netsoul-user-details
  :type '(string))

;;;###autoload
(defcustom netsoul-host "ns-server.epita.fr"
  "Netsoul server."
  :group 'netsoul-connection-details
  :type '(string))

;;;###autoload
(defcustom netsoul-port 4242
  "Netsoul server port."
  :group 'netsoul-connection-details
  :type '(integer))

;;; Functions:

;;;###autoload
(defun netsoul-load-configuration (&optional location)
  "Netsoul configuration loading, using LOCATION as the user's location."
  (let ((netsoul-contacts-file (expand-file-name netsoul-contacts-file)))
    (unless (and (file-regular-p netsoul-contacts-file)
		 netsoul-login netsoul-port netsoul-host netsoul-user-data)
      (with-temp-message "Configuration has to be made, please answer some questions."
	(sleep-for 2))
      (netsoul-create-configuration))
    (unless (file-readable-p netsoul-contacts-file)
      (error (concat netsoul-contacts-file " is not readable")))
    (load-file netsoul-contacts-file)
    (unless (getenv "NS_USER_LINK")
      (if (not location)
	  (let ((location (read-string (format "Your location (default: %s): "
					       netsoul-location)
				       "" nil netsoul-location)))
	    (unless (string= location netsoul-location)
	      (setq netsoul-location location)
	      (customize-save-variable 'netsoul-location netsoul-location)))
	(setq netsoul-location location)
	(customize-save-variable 'netsoul-location netsoul-location)))))

(defun netsoul-create-configuration ()
  "Ask for essential informations about the user."
  (interactive)
  (if (getenv "NS_USER_LINK")
      (setq netsoul-login (getenv "USER")
	    netsoul-pass nil)
    (setq netsoul-login (read-string "Your login: "))
    (while (not (and netsoul-login
		     (string-match netsoul-login-pattern netsoul-login)))
      (with-temp-message "You really need a login !"
	(sleep-for 2))
      (setq netsoul-login (read-string "Your login: ")))
    (setq netsoul-pass
	  (read-passwd "Your password (if nothing, you'll be asked every time you connect): ")))
  (setq netsoul-user-data
	(read-string "Your user's data (default: Emacs version): " "" nil
		     (concat "Using Emacs-" emacs-version " (" system-configuration  ")" )))
  (unless (getenv "NS_USER_LINK")
    (setq netsoul-host
	  (read-string "Netsoul server's name (default: ns-server.epita.fr): "
		       "" nil "ns-server.epita.fr")
	  netsoul-port
	  (string-to-number
	   (read-string "Netsoul server's port (default: 4242): " "" nil
			"4242"))))
  (customize-save-variable 'netsoul-login netsoul-login)
  (customize-save-variable 'netsoul-pass netsoul-pass)
  (customize-save-variable 'netsoul-host netsoul-host)
  (customize-save-variable 'netsoul-port netsoul-port)
  (customize-save-variable 'netsoul-user-data netsoul-user-data)
  (unless netsoul-contacts-hash
    (setq netsoul-contacts-hash (make-hash-table :test 'equal)))
  (netsoul-add-contacts)
  (with-temp-message "Configuration saved. Please edit your preferences with M-x netsoul-customize."
    (sleep-for 4)))

;;;###autoload
(defun netsoul-write-contacts ()
  "Write the contacts file."
  (let ((netsoul-contacts-file (expand-file-name netsoul-contacts-file)))
    (when (file-exists-p netsoul-contacts-file)
      (delete-file netsoul-contacts-file))
    (let ((file-data
	   (concat ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\n"
		   ";;     Emacs Netsoul contacts file. Edit at your own risk    ;;\n"
		   ";; Do not add your code here. This file is frequently erased ;;\n"
		   ";;        To customize, please use M-x netsoul-customize     ;;\n"
		   ";;        To add contacts, use M-x netsoul-add-contacts      ;;\n"
		   ";;     To remove contacts, use M-x netsoul-delete-contact    ;;\n"
		   ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\n\n"
		   "\n"
		   "(setq netsoul-contacts-hash (make-hash-table :test 'equal))\n")))
      (maphash (lambda (login data)
		 (setq file-data
		       (concat file-data "(puthash \"" login "\" (list \"" (nth 0 data)
			       "\" (make-hash-table)) netsoul-contacts-hash)\n")))
	       netsoul-contacts-hash)
      (let ((directory (file-name-directory netsoul-contacts-file)))
	(unless (file-directory-p directory)
	  (make-directory directory t)))
      (append-to-file file-data nil netsoul-contacts-file))))


;;;###autoload
(defun netsoul-customize ()
  "Customization of the `netsoul' group."
  (interactive)
  (customize-group 'netsoul))


(provide 'netsoul-configuration)

;;; arch-tag: 688fa523-0a5e-4df8-a10d-5d96a25e2829
;;; netsoul-configuration.el ends here
