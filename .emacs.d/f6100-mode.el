;;; f6100-mode.el --- mode for editing f6100 code.

;; Copyright (C)  2005 - 2008 ACU - Epita.

;; Maintainer: ACU
;; Keywords: f6100, corewar

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this file ; see the file COPYING. If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.


;;; Commentary:

;; The major mode for editing f6100 code.
;; This assembly language is to be used in the Corewar project.


;;; History:

;; 2008: Updated by Laurent Le Brun:
;;              - Add mode-map (electric keys)
;; 2006: Updated by Laurent Le Brun:
;;		- Adapt to corewar assignement.
;;		- Add indentation and fixed some regexps.
;; 2005: First code by Jean Chalard.


;;; Code:
(defcustom f6100-indent-width default-tab-width
  "Width of the indentation.")

(defcustom f6100-comment-column 40
  "Position of comments")

(defvar f6100-mode-syntax-table
  (let ((f6100-mode-syntax-table (make-syntax-table)))
    (modify-syntax-entry ?, "." f6100-mode-syntax-table)
    (modify-syntax-entry ?( "(" f6100-mode-syntax-table)
    (modify-syntax-entry ?) ")" f6100-mode-syntax-table)
    (modify-syntax-entry ?[ "(" f6100-mode-syntax-table)
    (modify-syntax-entry ?] ")" f6100-mode-syntax-table)
    (modify-syntax-entry ?_ "_" f6100-mode-syntax-table)
    (modify-syntax-entry ?# "<" f6100-mode-syntax-table)
    (modify-syntax-entry ?\n ">" f6100-mode-syntax-table)
    (modify-syntax-entry ?- "'" f6100-mode-syntax-table)
    f6100-mode-syntax-table)
  "Syntax table for `f6100-mode'.")

(defconst f6100-font-lock-keywords-1
  `(("\".*\"" . f6100-constant-face)
    ("\#.*" . f6100-comment-face)
    ("[a-zA-Z][a-zA-Z0-9_]*[a-zA-Z0-9]:" . f6100-label-face)
    ("[a-zA-Z]:" . f6100-label-face)
    ("0x[0-9A-Fa-f]+" . f6100-constant-face)
    ,`(,(concat "\\<\\(crash\\|nop\\|and\\|or\\|xor\\|not\\|rol\\|asr\\|add\\|sub"
		"\\|cmp\\|neg\\|mov\\|ldr\\|str\\|ldb\\|stb\\|lc\\|ll\\|swp\\|addi"
		"\\|cmpi\\|bz\\|bnz\\|bs\\|b\\|stat\\|check\\|mode\\|fork\\|write"
		"\\)\\>") . f6100-keyword-face)
    ,`(,(concat "\\(feisar\\|goteki45\\|agsystems\\|auricom\\|assegai\\|piranha\\|"
		"qirex\\|icaras\\|mines\\|rocket\\|missile\\|plasma\\|miniplasma\\)")
       . f6100-keyword-face)
   ("\\.[a-z]*" . f6100-keyword-face)
   ("r\\(1[0-5]\\|[0-9]\\)" . f6100-register-face)
   ("\\(\\[\\|\\]\\)" . f6100-symbol-face)
   ("[a-zA-Z][a-zA-Z0-9_]*[a-zA-Z0-9]" . f6100-ident-face)
   ("[a-zA-Z]" . f6100-ident-face)
   ("\\<0[0-7]+" . f6100-constant-face)
   ("[0-9_]+" . f6100-constant-face))
  "Syntax highlighting for `f6100-mode'.")


;; Faces:

(defface f6100-constant-face
  '((t :inherit font-lock-constant-face))
  "Face used to highlight f6100 constant expressions.")
(defvar f6100-constant-face 'f6100-constant-face)

(defface f6100-label-face
  '((t :inherit font-lock-builtin-face))
  "Face used to highlight f6100 labels.")
(defvar f6100-label-face 'f6100-label-face)

(defface f6100-ident-face
  '((t :inherit font-lock-variable-name-face))
  "Face used to highlight f6100 identifiers.")
(defvar f6100-ident-face 'f6100-ident-face)

(defface f6100-register-face
  '((t :inherit font-lock-variable-name-face))
  "Face used to highlight f6100 registers.")
(defvar f6100-register-face 'f6100-register-face)

(defface f6100-symbol-face
  '((t :inherit font-lock-preprocessor-face))
  "Face used to highlight f6100 symbols : [ ].")
(defvar f6100-symbol-face 'f6100-symbol-face)

(defface f6100-keyword-face
  '((t :inherit font-lock-keyword-face))
  "Face used to highlight f6100 keywords : o, c, s.")
(defvar f6100-keyword-face 'f6100-keyword-face)

(defface f6100-comment-face
  '((t :inherit font-lock-comment-face))
  "Face used to highlight f6100 commented lines.")
(defvar f6100-comment-face 'f6100-comment-face)

(defvar f6100-font-lock-keywords f6100-font-lock-keywords-1
  "Default highlighting for f6100 code.")


;; Functions:

(defvar f6100-mode-map ()
  "Keymap used in 'F6100-mode'")
(if f6100-mode-map
    nil
  (setq f6100-mode-map (make-sparse-keymap))
  (define-key f6100-mode-map "." 'f6100-electric-char)
  (define-key f6100-mode-map ":" 'f6100-electric-char)
  (define-key f6100-mode-map "#" 'f6100-electric-comment)
  (define-key f6100-mode-map "\C-m" 'newline-and-indent))

(defun f6100-electric-comment (arg)
  "Insert comment"
  (interactive "*P")
  (comment-indent)
  (if (looking-at "$")
      (insert " ")))

(defun f6100-electric-char (arg)
  "Insert char and indent line"
  (interactive "*P")
  (self-insert-command (prefix-numeric-value arg))
  (f6100-indent-line))

(define-derived-mode f6100-mode fundamental-mode "F6100"
  "Major mode for editing f6100 code."
  (set (make-local-variable 'font-lock-defaults) '(f6100-font-lock-keywords))
  (set (make-local-variable 'indent-line-function) 'f6100-indent-line)

  (set (make-local-variable 'comment-start) "#")
  (set (make-local-variable 'comment-end) "")
  (setq comment-column f6100-comment-column)
  (use-local-map f6100-mode-map)
  (f6100-indent-line))

(defun f6100-indent-line ()
  "Indent the current line as f6100 code."
  (interactive)
  (save-excursion
    (beginning-of-line)
    (if (or (looking-at "[ \t]*\\.") (looking-at "^[ \t]*[a-zA-Z0-9_]*:"))
	(indent-line-to 0)
      (if (looking-at "[ \t]*#")
          (indent-line-to f6100-comment-column)
        (indent-line-to f6100-indent-width))))
  (when (looking-back "^[ \t]*")
    (skip-chars-forward " \t")))

(provide 'f6100-mode)
