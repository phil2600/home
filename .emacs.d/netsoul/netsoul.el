;;; netsoul.el --- Emacs netsoul main file
;; $Id: netsoul.el 28 2005-07-16 18:07:03Z cadilh_m $
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

;;; Commentary:

;; This messenger is to be use with the netsoul network, a Big Brother
;; protocol for the Cersti schools.

;; To use it, either within the schools with the `ACU version' of Emacs
;; or elsewhere, add the path you installed these `.elc' files to the
;; load path and load Emacs netsoul.

;; (add-to-list load-path "~/path/to/emacs/netsoul")
;; (require 'netsoul)

;; Optionally, you could compile these files for a quicker loading.

;;; Code:

(load "netsoul-loaddefs.el")

(defgroup netsoul nil
  "An Emacs-Lisp implementation of the Netsoul Protocol."
  :group  'applications
  :prefix "netsoul-")

;;;###autoload
(defconst netsoul-version "0.6.2")

;;;###autoload
(defconst netsoul-version-name "SoLong")

(unless (file-directory-p (expand-file-name "~/.emacs.d"))
  (make-directory (expand-file-name "~/.emacs.d")))

;;; User variables:

(defcustom netsoul-connect-hook nil
  "List of functions called when the connection is established."
  :type 'hook
  :group 'netsoul)

(defcustom netsoul-quit-hook nil
  "List of functions called when the connection is closed.
Each function will receive an argument that would be t if the user
was disconnected or nil if the user ask for disconnection"
  :type 'hook
  :group 'netsoul)

;;; Functions:

;;;###autoload
(defalias 'netsoul-start 'netsoul)

;;;###autoload
(defun netsoul (&optional location)
  "Launch Emacs Netsoul, setting user's location to LOCATION."
  (interactive)
  (when (and (getenv "NS_USER_LINK")
	     (not (functionp 'make-network-process)))
    (error "Local Netsoul only works with network-process enabled Emacsen, try ACU's Emacs"))
  (when netsoul-connection-state
    (error "Netsoul already started, please use netsoul-quit before"))
  (netsoul-load-configuration location)
  (netsoul-connect))

;;;###autoload
(defun netsoul-quit ()
  "End Netsoul process."
  (interactive)
  (when netsoul-connection-state
    (when netsoul-process
      (set-process-sentinel netsoul-process nil))
    (netsoul-warn-chats)
    (when netsoul-away-timer
      (cancel-timer netsoul-away-timer))
    (when netsoul-ping-timer
      (cancel-timer netsoul-ping-timer))
    (when (eq netsoul-connection-state 'authentified)
      (insert-in-buffer "*CONNECTION CLOSED*\n" (netsoul-contacts-buffer) nil
			'netsoul-warning-face 1 19)
      (run-hook-with-args 'netsoul-quit-hook (not (interactive-p))))
    (setq netsoul-ping-timer nil
	  netsoul-away-timer nil
	  netsoul-connection-state nil)
    (if (and (processp netsoul-process)
	     (equal 'open (process-status (process-name netsoul-process))))
	(delete-process (process-name netsoul-process)))))

(provide 'netsoul)

;;; arch-tag: 27120678-8ae7-43e9-8799-d3d4835f57bf
;;; netsoul.el ends here
