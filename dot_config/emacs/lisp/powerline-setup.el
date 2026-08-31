;;; powerline-setup.el --- Powerline status bar -*- lexical-binding: t; -*-

;; powerline-evil 20190603 accidentally makes this face inherit from itself.
(defface powerline-evil-operator-face
  '((t (:background "cyan" :inherit powerline-evil-base-face)))
  "Powerline face for Evil's operator state."
  :group 'powerline)

(require 'powerline-evil)
(use-package powerline :config (powerline-center-evil-theme))
(use-package powerline-evil :after (evil powerline) :config (powerline-evil-vim-color-theme))
(defun my/powerline-setup ()
  (setq powerline-default-separator (if (char-displayable-p #xE0B0) 'utf-8 'arrow)
        powerline-utf-8-separator-left        #xE0B0
        powerline-utf-8-separator-right       #xE0B2
        powerline-utf-8-separator-left-thin   #xE0B1
        powerline-utf-8-separator-right-thin  #xE0B3)
  (powerline-reset)
  (powerline-center-evil-theme))
(add-hook 'after-init-hook #'my/powerline-setup)
(provide 'powerline-setup)
