;;; dashboard-setup.el --- Dashboard configuration -*- lexical-binding: t; -*-
;; use-package with package.el:
(use-package nerd-icons
  :ensure t)

(use-package dashboard
  :ensure t
  :after nerd-icons
  :init
  (setq dashboard-banner-logo-title nil
        dashboard-startup-banner 'ascii
        dashboard-banner-ascii
        "  ____                    _      _____
 / ___|___  ___ _ __ ___ (_) ___| ____|_ __ ___   __ _  ___ ___
| |   / _ \\/ __| '_ ` _ \\| |/ __|  _| | '_ ` _ \\ / _` |/ __/ __|
| |__| (_) \\__ \\ | | | | | | (__| |___| | | | | | (_| | (__\\__ \\
 \\____\\___/|___/_| |_| |_|_|\\___|_____|_| |_| |_|\\__,_|\\___|___/")
  (setq dashboard-image-banner-max-height 200)
  (setq dashboard-image-banner-max-width 200)
  (setq dashboard-center-content t)
  (setq dashboard-vertically-center-content t)
  (setq dashboard-show-shortcuts nil)
  :config
  (setq dashboard-display-icons-p t)     ; display icons on both GUI and terminal
  (setq dashboard-icon-type 'nerd-icons) ; use `nerd-icons' package
  (setq dashboard-set-heading-icons t)   ; enable heading icons
  (setq dashboard-set-file-icons t)      ; enable file icons

  ;; Dashboard items to show
  (setq dashboard-items '((recents   . 5)
                          (bookmarks . 5)
                          (projects  . 5)
                          (agenda    . 5)))

  ;; Set navigator buttons below the banner
  (setq dashboard-navigator-buttons
        `(((,(nerd-icons-faicon "nf-fa-book" :height 1.1 :v-adjust 0.0)
            "Keybindings"
            "Open keybindings cheatsheet"
            (lambda (&rest _) (find-file ,(expand-file-name "KEYBINDINGS.md" user-emacs-directory))))
           (,(nerd-icons-faicon "nf-fa-cog" :height 1.1 :v-adjust 0.0)
            "Settings"
            "Open Emacs config"
            (lambda (&rest _) (find-file ,(expand-file-name "init.el" user-emacs-directory)))))))

  ;; Bookmarks
  (setq dashboard-bookmarks
        `(("Keybindings Cheatsheet" . ,(expand-file-name "KEYBINDINGS.md" user-emacs-directory))
          ("Emacs Config" . ,(expand-file-name "init.el" user-emacs-directory))
          ("LSP Config" . ,(expand-file-name "lisp/lsp.el" user-emacs-directory))
          ("Helpers" . ,(expand-file-name "lisp/helpers.el" user-emacs-directory))))

  (setq dashboard-startupify-list '(dashboard-insert-banner
                                    dashboard-insert-newline
                                    dashboard-insert-banner-title 
                                    dashboard-insert-newline
                                    dashboard-insert-navigator
                                    dashboard-insert-newline
                                    dashboard-insert-items
                                    dashboard-insert-newline
                                    dashboard-insert-footer))  

  ;; For emacsclient - show dashboard when connecting without a file
  (add-hook 'server-after-make-frame-hook
            (lambda ()
              (when (and (not (buffer-file-name))
                         (member (buffer-name) '("*scratch*" " *server*")))
                (dashboard-refresh-buffer)
                (switch-to-buffer dashboard-buffer-name))))

  ;; For regular Emacs startup
  (add-hook 'emacs-startup-hook
            (lambda ()
              (when (< (length command-line-args) 2)
                (dashboard-refresh-buffer)
                (switch-to-buffer dashboard-buffer-name)))))

(provide 'dashboard-setup)
