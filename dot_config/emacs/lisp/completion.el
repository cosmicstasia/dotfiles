;;; completion.el --- Completion stacks -*- lexical-binding: t; -*-

(use-package vertico :init (vertico-mode))
(use-package orderless
  :init
  (setq completion-styles '(orderless)
        completion-category-defaults nil
        completion-category-overrides '((file (styles . (partial-completion))))))
(use-package consult)

(use-package ivy
  :demand t
  :init
  (setq ivy-use-virtual-buffers t
        ivy-count-format "(%d/%d) "
        ivy-initial-inputs-alist nil
        ivy-re-builders-alist '((t . ivy--regex-ignore-order)))
  :config
  (ivy-mode 1)
  (when (bound-and-true-p vertico-mode) (vertico-mode -1))
  (define-key ivy-minibuffer-map (kbd "y") #'self-insert-command)
  (define-key ivy-minibuffer-map (kbd "Y") #'self-insert-command)
  (define-key ivy-minibuffer-map (kbd "C-j") #'ivy-next-line)
  (define-key ivy-minibuffer-map (kbd "C-k") #'ivy-previous-line))

(use-package counsel :after ivy :config (counsel-mode 1))
(use-package swiper  :after ivy)

(provide 'completion)
