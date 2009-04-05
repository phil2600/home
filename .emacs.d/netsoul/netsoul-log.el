;;; netsoul-log.el --- Logging facilities for Emacs netsoul
;; $Id: netsoul-log.el 28 2005-07-16 18:07:03Z cadilh_m $
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

(defgroup netsoul-log-details nil
  "Log related settings."
  :group 'netsoul)

(defcustom netsoul-log t
  "Define if messages have to be logged."
  :group 'netsoul-log-details
  :type '(boolean))

(defcustom netsoul-log-path "~/.emacs.d/netsoul/logs"
  "Log file path."
  :group 'netsoul-log-details
  :type '(string))

;;; Functions:

;;;###autoload
(defun netsoul-log-message (login nickname message)
  "Save (LOGIN,NICKNAME)'s MESSAGE in a log file.
See `netsoul-log' and `netsoul-log-path' for more customization."
  (when netsoul-log
    (let ((netsoul-log-path (expand-file-name netsoul-log-path)))
      (if (file-directory-p netsoul-log-path)
	  (unless (file-accessible-directory-p netsoul-log-path)
	    (error "Directory %s is not accesible" netsoul-log-path))
	(make-directory netsoul-log-path t))
      (let ((coding-system-for-write 'raw-text))
	(write-region (concat "(" (format-time-string "%Y-%m-%d - %Hh%M") ") "
			      nickname ": " message "\n")
		      nil (concat netsoul-log-path "/" login) t 'silent))
      (message ""))))

(provide 'netsoul-log)

;;; arch-tag: 5d4f9b2f-fd44-44e8-b036-38821bc40af7
;;; netsoul-log.el ends here
