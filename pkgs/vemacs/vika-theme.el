;;; vika-theme.el --- a theme that a certain girl named Vika likes -*- lexical-binding: t; -*-
(deftheme vika
  "Theme that Vika likes. Simple, maybe a bit low-contrast, but good.")

(let ((fg "#111111")
      (alt-fg "#222222")
      (bg "#f8f8f0")
      (lighter-bg "#b8b8b0")
      (even-lighter-bg "#606060")
      )
  (custom-theme-set-faces
   'vika
   ;; Here will be defined faces. The face name comes first,
   ;; after it comes the face description (see defface for info)
   `(default ((t (:background ,bg :foreground ,fg))))
   `(font-lock-keyword-face ((t (:weight bold :foreground ,fg))))
   `(font-lock-comment-face ((t (:weight bold :slant italic :foreground ,fg))))
   `(font-lock-string-face ((t (:slant italic :foreground ,alt-fg))))
   ;; TODO
   ;; `(font-lock-variable-name-face ((t ())))
   ;; `(font-lock-builtin-face ((t ())))

   ;; Modeline
   ;; TODO Modeline for terminals with 16 colors
   `(mode-line ((t (:background ,lighter-bg :foreground ,fg))))
   `(powerline-active1 ((t (:background ,even-lighter-bg))))

   ;; Org mode
   `(org-document-title ((t (:foreground ,fg :weight bold :slant italic :height 2.0))))
   `(org-headline-done ((t (:foreground ,alt-fg :slant italic))))
   `(org-document-info ((t (:foreground ,alt-fg :slant italic))))
   `(org-block ((t (:foreground ,alt-fg :inherit fixed-pitch))))
   `(org-block-begin-line ((t (:weight bold :inherit fixed-pitch))))
   `(org-block-end-line ((t (:weight bold :inherit fixed-pitch))))
   `(org-drawer ((t (:weight bold :foreground ,fg))))
   `(org-todo ((t (:weight bold :foreground "red"))))
   `(org-done ((((min-colors 16777216)) (:weight bold :foreground "#00A000")) (t (:weight bold :foreground "green"))))
   `(org-checkbox ((t (:weight bold :inherit fixed-pitch))))
   ;; Org agenda
   `(org-agenda-done ((((min-colors 16777216)) (:foreground "#00A000")) (t (:foreground "green"))))
   `(org-scheduled ((t (:foreground ,alt-fg))))
   `(org-scheduled-today ((t (:weight bold))))
   `(org-agenda-date ((default (:foreground "blue"))))
   ;; TODO make it distinguishable
   `(org-agenda-date-today ((default (:weight bold :slant italic :inherit org-agenda-date))))
   `(org-agenda-date-weekend ((default (:weight bold :inherit org-agenda-date))))
   `(org-agenda-structure ((default (:foreground ,alt-fg :weight bold))))
   ;; Outline mode (basically a restricted subset of Org-mode at this point, but Org uses its faces)
   `(outline-1 ((t (:foreground ,alt-fg :weight bold :height 1.33))))
   `(outline-2 ((t (:foreground ,alt-fg :weight bold :height 1.33))))
   `(outline-3 ((t (:foreground ,alt-fg :weight bold :height 1.33))))
   `(outline-4 ((t (:foreground ,alt-fg :weight bold :height 1.33))))
   `(outline-5 ((t (:foreground ,alt-fg :weight bold :height 1.33))))
   `(outline-6 ((t (:foreground ,alt-fg :weight bold :height 1.33))))
   `(outline-7 ((t (:foreground ,alt-fg :weight bold :height 1.33))))
   `(outline-8 ((t (:foreground ,alt-fg :weight bold :height 1.33))))
   )
  )

;;;###autoload
(when (and (boundp 'custom-theme-load-path) load-file-name)
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

(provide-theme 'vika)
(provide 'vika-theme)

;; Use the following to load the dev version of this theme:
;; (press C-x C-e (M-x eval-last-sexp RET) at the end - if already loaded, will reload from scratch)
;;
;; (prog2 (save-buffer) (load-file "/home/vika/Projects/nix-flake/emacs/vika-theme.el") (mapcar #'disable-theme custom-enabled-themes) (enable-theme 'vika) (spaceline-compile))

;;; vika-theme.el ends here
