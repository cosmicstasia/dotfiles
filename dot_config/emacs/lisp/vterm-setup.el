;;; vterm-setup.el --- vterm + toggle -*- lexical-binding: t; -*-

(eval-when-compile
  (require 'project nil t)
  (declare-function project-root "project" (project)))

(use-package project 
  :demand t
  :ensure t)

(use-package vterm
  :commands (vterm)
  :config
  (define-key vterm-mode-map [(control return)] #'vterm-toggle-insert-cd)

  (setq vterm-kill-buffer-on-exit t)

  (defun my/vterm-setup-no-query ()
    "Set up vterm buffer to not query on exit."
    (setq-local confirm-kill-processes nil)
    (when-let ((proc (get-buffer-process (current-buffer))))
      (set-process-query-on-exit-flag proc nil)))

  (add-hook 'vterm-mode-hook #'my/vterm-setup-no-query)

  (advice-add 'vterm--internal :after
              (lambda (&rest _)
                (when-let ((proc (get-buffer-process (current-buffer))))
                  (set-process-query-on-exit-flag proc nil)))))

(use-package vterm-toggle
  :after (vterm project)
  :commands (vterm-toggle vterm-toggle-insert-cd)
  :config
  (require 'project))

(setq confirm-kill-processes nil)

(provide 'vterm-setup)
