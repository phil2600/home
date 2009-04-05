(defvar f6100-mode-hook nil)

(defvar f6100-mode-map
  (let ((f6100-mode-map (make-sparse-keymap))) ; Or make-sparse-keymap
;;     (define-key toyunda-mode-map "\C-co" 'toyunda-add-position)
    f6100-mode-map)
  "Keymap for f6100 major mode")

(add-to-list 'auto-mode-alist '("\\.s\\'" . f6100-mode))

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
  "Syntax table for f6100-mode")

(defconst f6100-font-lock-keywords-1
  (list
   '("\\(crash\\|nop\\|and\\|or\\|xor\\|not\\|rol\\|asr\\|add\\|sub\\|cmp\\|neg\\|mov\\|ldr\\|str\\|ldb\\|stb\\|lc\\|ll\\|swp\\|addi\\|cmpi\\|bz\\|bnz\\|bs\\|b\\|stat\\|check\\|mode\\|fork\\|write\\)" . 'f6100-keyword-face)
   '("\\(feisar\\|goteki45\\|agsystems\\|auricom\\|assegai\\|piranha\\|qirex\\|icaras\\|mines\\|rocket\\|missile\\|plasma\\)" . 'f6100-keyword-face)
   '("r[0-9][0-5]?" . 'f6100-register-face)
   '("\\(\\[\\|\\]\\)" . 'f6100-symbol-face)
   '("0x[0-9A-Fa-f]+" . 'f6100-constant-face)
   '("0[0-7]+" . 'f6100-constant-face)
   '("[0-9]+" . 'f6100-constant-face)
   '("[a-zA-Z][a-zA-Z_]*:" . 'f6100-constant-face)
   )
  "Syntax highlighting for f6100-mode")

(defface f6100-constant-face
  '((t :inherit font-lock-constant-face))
  "Face used to highlight f6100 constant expressions.")
(defvar f6100-constant-face 'f6100-constant-face)

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
  "Default highlighting for f6100-mode")

(define-derived-mode f6100-mode fundamental-mode "F6100"
  "Major mode for editing f6100 ships."
  (set (make-local-variable 'font-lock-defaults) '(f6100-font-lock-keywords))
;  (set (make-local-variable 'indent-line-function) 'toyunda-indent-line)
)

(setq comment-start "# ")

(provide 'f6100-mode)
