;;; netsoul-mail.el --- Mail info management for Emacs netsoul
;; $Id: netsoul-mail.el 28 2005-07-16 18:07:03Z cadilh_m $
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

(defgroup netsoul-mail-details nil
  "Mail settings."
  :group 'netsoul)


(defcustom netsoul-receive-mail-hook nil
  "Hook for mail receiving."
  :type 'hook
  :group 'netsoul-mail-details)

;;; Functions:

;;;###autoload
(defun netsoul-receive-mail (from subject)
  "A mail from FROM titled SUBJECT has been received."
  (let ((from (url-decode from))
	(subject (url-decode subject)))
    (message (concat "New mail from " from " (subject: " subject ")"))
    (run-hook-with-args 'netsoul-receive-mail-hook from subject)))

(provide 'netsoul-mail)

;;; arch-tag: e66a9cdc-1691-4d6d-baed-71c9fad262e8
;;; netsoul-mail.el ends here
