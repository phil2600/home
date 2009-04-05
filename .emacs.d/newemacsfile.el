;;; Global file configuration for Emacs.

;;; This is an example file with some essential but also some gadget
;;; tweaking. It is meant to be in ~/.emacs.d/init.el, the ``new''
;;; .emacs place. Please read this file attentively.

;;; Use local site-lisp, and turn on PIE specific conf.
(eval-when-compile
  (require 'cl))
(add-to-list 'load-path "/usr/pkg/share/emacs/site-lisp")

(ignore-errors
 (require 'std-comment "std_comment.el")
 (require 'std "std.el")

 (defadvice std-get (around std-get-is-dirty activate)
   "Fix a little bit `std' dirtiness."
   (let ((mode-name (cond ((eq major-mode 'c-mode) "C")
			  ((eq major-mode 'c++-mode) "C++")
			  (t mode-name))))
     ad-do-it)))


;;; Don't put customization in this file.
(setq custom-file "~/.emacs.d/custom.el")


;;; Setup some modes.

;; Turn on interactive do (ido, i.e. iswitchb++).
(require 'ido)
(ido-mode 1)
(add-to-list 'ido-ignore-files ":\\'") ; Fix a bug in IDO.

;; Remove useless decorations.
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(blink-cursor-mode -1)

;; Other modes.
(partial-completion-mode 1) ; Partial completion is a killer feature. M-x p-c-m RET
(normal-erase-is-backspace-mode 1)
(show-paren-mode 1) ; This is useful blinking !
(savehist-mode 1) ; Save my histories.
(display-time)
(column-number-mode 1)


;;; Variable configuration.
(setq user-full-name "Your Name"
      user-mail-address "Your Mail"
      font-lock-maximum-decoration t
      mouse-autoselect-window t
      shell-file-name "/bin/bash"
      kill-read-only-ok t
      ;; Input method, see C-h f set-input-method.
      ;; This replaces iso-accents-mode. You may prefer `prefix'.
      default-input-method "french-postfix"
      inhibit-startup-message t		    ; I know you, Emacs.
      frame-title-format '("%b" (buffer-file-name ": %f"))

      ;; Let Gnus not be bordélique by storing its data in another place.
      gnus-init-file "~/.emacs.d/gnus/.gnus"
      gnus-home-directory "~/.emacs.d/gnus/"
      message-directory "~/.emacs.d/gnus/Mail")


;;; Kind of expert mode.
(fset 'yes-or-no-p 'y-or-n-p)


;;; Face configuration.
;; Don't forget to use gnuclient(1) !!
(set-face-foreground 'default "white")
(set-face-background 'default "#333333")
(set-face-background 'cursor "white")
(set-face-foreground 'mode-line "white")
(set-face-background 'mode-line "black")
(setq default-frame-alist
      '((cursor-color . "white")
        (background-color . "#333333")
        (foreground-color . "white")
        (vertical-scroll-bars . nil)
        (tool-bar-lines . 0)
        (menu-bar-lines . 0)
        (reverse . nil)))
(when (display-graphic-p)
  (let ((font "-misc-fixed-medium-r-normal--13-120-75-75-c-80-iso8859-1"))
    (set-default-font font)
    (add-to-list 'default-frame-alist `(font . ,font))))


;;; C indentation.
(require 'cc-mode)
(add-to-list
 'c-style-alist
 '("GoodStyle"
   (c-basic-offset             . 2)
   (c-comment-only-line-offset . 0)
   (c-hanging-braces-alist     . ((substatement-open before after)))
   (c-offsets-alist
    . ((topmost-intro          . 0)
       ;; Align if starts with *
       (c . (lambda (of)
              (save-excursion
                (forward-line 0)
                (if (looking-at "[[:space:]]*[|`]") 0 1))))
       ;; /*- comments stay in place.
       (comment-intro . (lambda (of)
                          (save-excursion
                            (forward-line 0)
                            (skip-chars-forward "[:space:]" (point-at-eol))
                            (when (looking-at "/\\*-")
                                (vector (current-column))))))
       (substatement         . +)
       (substatement-open    . 0)
       (case-label           . +)
       (access-label         . -)
       (inclass              . ++)
       (inline-open          . 0)))))

(setq c-default-style "GoodStyle")


;;; Hooks (for example).
(add-hook 'text-mode-hook (lambda ()
			    (activate-input-method default-input-method)
			    (flyspell-mode 1)))

(add-hook 'write-file-hook
	  (lambda ()
	    (unless (memq major-mode '(message-mode gnus-article-mode))
	      (delete-trailing-whitespace)
	      (whitespace-cleanup))))


;;; Load customization file.
(load custom-file t)

;;; init.el ends here.

