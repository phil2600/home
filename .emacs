;;
;; .emacs for conf in /usr/school/.env
;;
;; Made by Charlie Root
;; Login   <root@epita.fr>
;;
;; Started on  Thu Aug 23 22:13:42 2007 Charlie Root
;; Last update Mon Nov 12 18:58:43 2007 Phil
;;

					; I love rockyluke !

(defconst xemacs (string-match "XEmacs" emacs-version)
  "non-nil iff XEmacs, nil otherwise")

;(if (not xemacs)
;    (load "std_comment.el"))

;(if (not xemacs)
;    (load "std.el"))

(if (file-exists-p "~/.myemacs")
    (load-file "~/.myemacs"))

;(custom-set-variables
; ;; custom-set-variables was added by Custom.
; ;; If you edit it by hand, you could mess it up, so be careful.
; ;; Your init file should contain only one such instance.
; ;; If there is more than one, they won't work right.
; '(ecb-compile-window-width (quote edit-window))
; '(ecb-layout-name "left15")
; '(ecb-options-version "2.32")
; '(ecb-primary-secondary-mouse-buttons (quote mouse-1--mouse-2))
; '(ecb-tip-of-the-day nil)
; '(ecb-tree-buffer-style (quote image)))
;(custom-set-faces
; ;; custom-set-faces was added by Custom.
; ;; If you edit it by hand, you could mess it up, so be careful.
; ;; Your init file should contain only one such instance.
; ;; If there is more than one, they won't work right.
; '(background "blue")
; '(font-lock-builtin-face ((((class color) (background dark)) (:foreground "Turquoise"))))
; '(font-lock-comment-face ((t (:foreground "MediumAquamarine"))))
; '(font-lock-constant-face ((((class color) (background dark)) (:bold t :foreground "DarkOrchid"))))
; '(font-lock-doc-string-face ((t (:foreground "green2"))))
; '(font-lock-function-name-face ((t (:foreground "SkyBlue"))))
; '(font-lock-keyword-face ((t (:bold t :foreground "CornflowerBlue"))))
; '(font-lock-preprocessor-face ((t (:italic nil :foreground "CornFlowerBlue"))))
; '(font-lock-reference-face ((t (:foreground "DodgerBlue"))))
; '(font-lock-string-face ((t (:foreground "LimeGreen"))))
; '(font-lock-type-face ((t (:foreground "#9290ff"))))
; '(font-lock-variable-name-face ((t (:foreground "PaleGreen"))))
; '(font-lock-warning-face ((((class color) (background dark)) (:foreground "yellow" :background "red"))))
; '(highlight ((t (:background "CornflowerBlue"))))
; '(list-mode-item-selected ((t (:background "gold"))))
; '(makefile-space-face ((t (:background "wheat"))))
; '(mode-line ((t (:background "Navy"))))
; '(paren-match ((t (:background "darkseagreen4"))))
; '(region ((t (:background "DarkSlateBlue"))))
; '(show-paren-match ((t (:foreground "black" :background "wheat"))))
; '(show-paren-mismatch ((((class color)) (:foreground "white" :background "red"))))
; '(speedbar-button-face ((((class color) (background dark)) (:foreground "green4"))))
; '(speedbar-directory-face ((((class color) (background dark)) (:foreground "khaki"))))
; '(speedbar-file-face ((((class color) (background dark)) (:foreground "cyan"))))
; '(speedbar-tag-face ((((class color) (background dark)) (:foreground "Springgreen"))))
; '(vhdl-speedbar-architecture-selected-face ((((class color) (background dark)) (:underline t :foreground "Blue"))))
; '(vhdl-speedbar-entity-face ((((class color) (background dark)) (:foreground "darkGreen"))))
; '(vhdl-speedbar-entity-selected-face ((((class color) (background dark)) (:underline t :foreground "darkGreen"))))
; '(vhdl-speedbar-package-face ((((class color) (background dark)) (:foreground "black"))))
; '(vhdl-speedbar-package-selected-face ((((class color) (background dark)) (:underline t :foreground "black"))))
; '(widget-field ((((class grayscale color) (background light)) (:background "DarkBlue"))))


(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(safe-local-variable-values (quote ((todo-categories "Todo" "Todo" "Todo" "YAKA")))))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )
