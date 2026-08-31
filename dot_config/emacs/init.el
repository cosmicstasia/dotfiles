;;; init.el --- Personal Emacs configuration -*- lexical-binding: t; -*-

(setq load-prefer-newer t)
(setq warning-suppress-types '((bytecomp))
      warning-inhibit-types '((files missing-lexbind-cookie)))
(setq native-comp-async-report-warnings-errors 'silent)
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(when (eq system-type 'darwin)
  ;; GUI Emacs does not inherit Homebrew's shell PATH.
  (dolist (directory '("/opt/homebrew/bin" "/usr/local/bin"))
    (when (file-directory-p directory)
      (setq exec-path (cons directory (delete directory exec-path)))
      (unless (member directory (split-string (or (getenv "PATH") "") path-separator t))
        (setenv "PATH" (concat directory path-separator (getenv "PATH"))))))
  (setq find-program "/usr/bin/find"))

(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file 'noerror 'nomessage)

(defun my/leader-keys (&rest args)
  (if (fboundp 'general-define-key)
      (apply #'general-define-key
             :states '(normal visual emacs) :prefix "SPC" :global-prefix "C-SPC" args)
    (let ((a args))
      (with-eval-after-load 'general
        (apply #'general-define-key
               :states '(normal visual emacs) :prefix "SPC" :global-prefix "C-SPC" a)))))

(require 'package)
(setq package-enable-at-startup nil
      package-archives '(("gnu"          . "https://elpa.gnu.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")
                         ("melpa"        . "https://melpa.org/packages/")))
(package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents) (package-install 'use-package))
(eval-when-compile (require 'use-package))
(setq use-package-always-ensure t)

;; Get all the modules from lisp directory
(require 'helpers)
(dolist (m '(ui fonts themes theme-definitions pywal-bridge matugen-bridge themes-config
                external-theme-integration evil-setup minibuffer completion markdown-setup
                wiki-links lsp powerline-setup tabs git pywal dashboard-setup vterm-setup pairing
                scrolling wordcount clipboard-tty cache-management spell server-init dired-setup
                claude-code-setup))
  (require m nil t))

(global-set-key (kbd "<f5>") (lambda () (interactive) (load-file user-init-file)))
(setq make-backup-files nil
      auto-save-default nil)

;; Initialize theme system
(add-hook 'after-init-hook
          (lambda ()
            (unless (and (featurep 'themes-config) 
                         (fboundp 'themes-config-load-saved)
                         (themes-config-load-saved))
              (themes-load themes-default-theme t)
              (message "Theme system initialized with default theme: %s" themes-default-theme))))

(provide 'init)
