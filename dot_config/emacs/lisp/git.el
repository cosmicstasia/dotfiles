;;; git.el --- magit, diff-hl and leader keys -*- lexical-binding: t; -*-
(unless (package-installed-p 'magit)
  (package-refresh-contents))

(use-package magit
  :ensure t
  :commands (magit-status magit-get-current-branch)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (text-mode . diff-hl-mode))
  :config
  (diff-hl-flydiff-mode 1)
  (setq diff-hl-draw-borders nil)
  (unless (display-graphic-p) (diff-hl-margin-mode 1)))

(with-eval-after-load 'diff-hl
  (when (fboundp 'load-pywal-colors) (load-pywal-colors)))

(provide 'git)
