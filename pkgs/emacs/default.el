;; basic ui config
(setq inhibit-startup-message t)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 10)

(menu-bar-mode -1)

(column-number-mode)
(global-display-line-numbers-mode t)

(setq tab-width 2)
(setq-default indent-tabs-mode nil)
(setq inhibit-splash-screen t)
(setq initial-scratch-message nil)

(delete-selection-mode)

(let ((backup-dir (concat user-emacs-directory "backups")))
  (make-directory backup-dir t)
  (setq backup-directory-alist (list (cons "." backup-dir)))
  (setq message-auto-save-directory backup-dir))

;;; Display and create symbol pairs
(show-paren-mode t)
(electric-pair-mode t)


(dolist (mode '(org-mode-hook
		term-mode-hook
		shell-mode-hook
		eshell-mode-hook))
  (add-hook mode (lambda () (display-line-number-mode 0))))

;; theme
(use-package monokai-pro-theme
  :ensure t
  :demand t
  :config
  (load-theme 'monokai-pro t))

;; spaceline
(use-package spaceline
  :ensure t
  :init
  (spaceline-spacemacs-theme)
  (spaceline-helm-mode)
  :custom
  (powerline-height 24)
  (powerline-default-separator 'wave))

(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  :custom
  (dashboard-set-footer nil))

;; Ligatures
(use-package ligature
  :ensure t
  :init
  (global-ligature-mode 1)
  :config
  (ligature-set-ligatures 't '("www"))
  (ligature-set-ligatures 'variable-pitch-mode '("ff" "fi" "ffi"))
  ;; Uses ligatures from Cascadia Code, but Fira Code has most of them too
  (ligature-set-ligatures '(prog-mode text-mode)
                          '( "|||>" "<|||" "<==>" "<!--" "####" "~~>" "***" "||=" "||>"
                             ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!=="
                             "!!." ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<"
                             "<~~" "<~>" "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
                             "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###" "#_(" "..<"
                             "..." "+++" "/==" "///" "_|_" "www" "&&" "^=" "~~" "~@" "~="
                             "~>" "~-" "**" "*>" "*/" "||" "|}" "|]" "|=" "|>" "|-" "{|"
                             "[|" "]#" "::" ":=" ":>" ":<" "$>" "==" "=>" "!=" "!!" ">:" 
                             ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*" "<|" "<:"
                             "<$" "<=" "<>" "<-" "<<" "<+" "</" "#{" "#[" "#:" "#=" "#!"
                             "##" "#(" "#?" "#_" "%%" ".=" ".-" ".." ".?" "+>" "++" "?:"
                             "?=" "?." "??" ";;" "/*" "/=" "/>" "//" "__" "~~" "(*" "*)"
                             "\\\\" "://")))

(use-package diminish
  :ensure t)

;; counsel (completion)
(use-package counsel
  :ensure t
  :diminish counsel-mode
  :config  (counsel-mode 1))

(use-package company
  :ensure t
  :diminish company-mode
  :hook ((prog-mode text-mode) . company-mode))

;;; helpful
(use-package helpful
  :ensure t
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable))

;; editor config
(use-package editorconfig
  :ensure t
  :config
  (editorconfig-mode 1))

;; direnv mode
(use-package direnv
  :ensure t
  :config
  (direnv-mode))

;; eglot
(use-package eglot)

;; nix mode
(use-package nix-mode
  :ensure t
  :after (direnv eglot)q
  :mode "\\.nix$"
  :config
  (add-to-list 'eglot-server-programs '(nix-mode . ("nil"))))

(use-package nix-repl
  :ensure nix-mode
  :commands (nix-repl))
(use-package nix-flake
  :ensure nix-mode
  :config
  (setq nix-flake-add-to-registry nil))
(use-package helm-nixos-options
  :ensure t)

;; capntproto mode
(use-package protobuf-mode
  :ensure t
  :mode "\\.capnp$")

;; Project management (projectile)
(use-package projectile
  :ensure t
  :init
  (projectile-mode +1)
  (helm-projectile-on)
  :config
  (setq projectile-project-serach-path '(("~/Developer/" . 2))))

(use-package helm-projectile
  :ensure t
  :after (helm projectile)
  :init
  (helm-projectile-on))


;;;; Org Mode
(defun kloenk/org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "-UKWN-Monaspace Krypton Var-regular-normal-normal-*-13-*-*-*-*-0-iso10646-1" :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))

(defun kloenk/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(defvar kloenk/org-files-tasks "~/Documents/OrgFiles/Tasks.org")
(defvar kloenk/org-files-habits "~/Documents/OrgFiles/Habits.org")
(defvar kloenk/org-files-journal "~/Documents/OrgFiles/Journal.org")
(defvar kloenk/org-files-metrics "~/Documents/OrgFiles/Metrics.org")
(defvar kloenk/org-files-birthdays "~/Documents/OrgFiles/Birthdays.org")

(use-package org
  :ensure t
  :hook (org-mode . kloenk/org-mode-setup)
  :config
  (setq org-ellipsis " ▾")

  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)

  (setq org-agenda-files
        '(kloenk/org-files-tasks
          kloenk/org-files-habits
          kloenk/org-files-birthdays))

  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-graph-column 60)

  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
          (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))

  (setq org-refile-targets
        '(("Archive.org" :maxlevel . 1)
          ("Tasks.org" :maxlevel . 1)))

  ;; Save Org buffers after refiling!
  (advice-add 'org-refile :after 'org-save-all-org-buffers)

  (setq org-tag-alist
        '((:startgroup)
                                        ; Put mutually exclusive tags here
          (:endgroup)
          ("@errand" . ?E)
          ("@home" . ?H)
          ("@work" . ?W)
          ("agenda" . ?a)
          ("planning" . ?p)
          ("publish" . ?P)
          ("batch" . ?b)
          ("note" . ?n)
          ("idea" . ?i)))

  ;; Configure custom agenda views
  (setq org-agenda-custom-commands
        '(("d" "Dashboard"
           ((agenda "" ((org-deadline-warning-days 7)))
            (todo "NEXT"
                  ((org-agenda-overriding-header "Next Tasks")))
            (tags-todo "agenda/ACTIVE" ((org-agenda-overriding-header "Active Projects")))))

          ("n" "Next Tasks"
           ((todo "NEXT"
                  ((org-agenda-overriding-header "Next Tasks")))))

          ("W" "Work Tasks" tags-todo "+work-email")

          ;; Low-effort next actions
          ("e" tags-todo "+TODO=\"NEXT\"+Effort<15&+Effort>0"
           ((org-agenda-overriding-header "Low Effort Tasks")
            (org-agenda-max-todos 20)
            (org-agenda-files org-agenda-files)))

          ("w" "Workflow Status"
           ((todo "WAIT"
                  ((org-agenda-overriding-header "Waiting on External")
                   (org-agenda-files org-agenda-files)))
            (todo "REVIEW"
                  ((org-agenda-overriding-header "In Review")
                   (org-agenda-files org-agenda-files)))
            (todo "PLAN"
                  ((org-agenda-overriding-header "In Planning")
                   (org-agenda-todo-list-sublevels nil)
                   (org-agenda-files org-agenda-files)))
            (todo "BACKLOG"
                  ((org-agenda-overriding-header "Project Backlog")
                   (org-agenda-todo-list-sublevels nil)
                   (org-agenda-files org-agenda-files)))
            (todo "READY"
                  ((org-agenda-overriding-header "Ready for Work")
                   (org-agenda-files org-agenda-files)))
            (todo "ACTIVE"
                  ((org-agenda-overriding-header "Active Projects")
                   (org-agenda-files org-agenda-files)))
            (todo "COMPLETED"
                  ((org-agenda-overriding-header "Completed Projects")
                   (org-agenda-files org-agenda-files)))
            (todo "CANC"
                  ((org-agenda-overriding-header "Cancelled Projects")
                   (org-agenda-files org-agenda-files)))))))

  (setq org-capture-templates
        `(("t" "Tasks / Projects")
          ("tt" "Task" entry (file+olp kloenk/org-files-tasks "Inbox")
           "* TODO %?\n  %U\n  %a\n  %i" :empty-lines 1)

          ("j" "Journal Entries")
          ("jj" "Journal" entry
           (file+olp+datetree kloenk/org-files-journal)
           "\n* %<%I:%M %p> - Journal :journal:\n\n%?\n\n"
           ;; ,(dw/read-file-as-string "~/Notes/Templates/Daily.org")
           :clock-in :clock-resume
           :empty-lines 1)
          ("jm" "Meeting" entry
           (file+olp+datetree kloenk/org-files-journal)
           "* %<%I:%M %p> - %a :meetings:\n\n%?\n\n"
           :clock-in :clock-resume
           :empty-lines 1)

          ("w" "Workflows")
          ("we" "Checking Email" entry (file+olp+datetree kloenk/org-files-journal)
           "* Checking Email :email:\n\n%?" :clock-in :clock-resume :empty-lines 1)

          ("m" "Metrics Capture")
          ("mw" "Weight" table-line (file+headline kloenk/org-files-metrics "Weight")
           "| %U | %^{Weight} | %^{Notes} |" :kill-buffer t)))

  (define-key global-map (kbd "C-c j")
              (lambda () (interactive) (org-capture nil "jj")))

  (kloenk/org-font-setup))

(use-package org-bullets
  :ensure t
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

; (use-package org-tempo
  ; :ensure org-plus-contrib
  ; :after org
  ; :config
  ; (add-to-list 'org-structure-template-alist '("s" . "src"))
  ; (add-to-list 'org-structure-template-alist '("sh" . "src sh"))
  ; (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  ; (add-to-list 'org-structure-template-alist '("yaml" . "src yaml"))
  ; (add-to-list 'org-structure-template-alist '("json" . "src json"))
  ; (add-to-list 'org-structure-template-alist '("rs" . "src rust")))

(use-package org-make-toc
  :ensure t
  :after org
  :hook org-mode)

;;; Treemacs
(use-package treemacs
  :ensure t
  :defer t
  :config
  (treemacs-resize-icons 15)
  :bind
  (:map global-map
        ("M-0" . treemacs-select-window)))

(use-package treemacs-magit
  :ensure t
  :after (treemacs magit))

(use-package treemacs-projectile
  :ensure t
  :after (treemacs projectile))

;;; Magit
(use-package magit
  :ensure t)
