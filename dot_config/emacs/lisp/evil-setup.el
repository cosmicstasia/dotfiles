;;; evil-setup.el --- Evil and friends -*- lexical-binding: t; -*-

;; Evil 1.15 declares this legacy variable without initializing it.
(defvar evil-mode-buffers nil)

(use-package evil
  :init
  (setq evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-want-Y-yank-to-eol t
        evil-want-fine-undo t
        evil-want-minibuffer nil
        evil-default-register ?+
        evil-undo-system (if (fboundp 'undo-redo) 'undo-redo 'undo-fu)
        select-enable-clipboard t)
  :config
  (evil-mode 1)
  (dolist (state '(motion operator visual))
    (evil-global-set-key state "j" 'evil-next-visual-line)
    (evil-global-set-key state "k" 'evil-previous-visual-line))
  (define-key evil-insert-state-map (kbd "SPC") #'self-insert-command)
  
  (if (eq evil-undo-system 'undo-redo)
      (progn
        (define-key evil-normal-state-map (kbd "u")   #'undo-only)
        (define-key evil-normal-state-map (kbd "C-r") #'undo-redo))
    (use-package undo-fu)
    (define-key evil-normal-state-map (kbd "u")   #'undo-fu-only-undo)
    (define-key evil-normal-state-map (kbd "C-r") #'undo-fu-only-redo))
  
  (define-key evil-normal-state-map (kbd "y") #'evil-yank)
  (define-key evil-visual-state-map (kbd "y") #'evil-yank)
  (define-key evil-normal-state-map (kbd "Y") #'evil-yank-line)
  (define-key evil-normal-state-map (kbd "p") (lambda () (interactive) (evil-paste-after 1)))
  (define-key evil-normal-state-map (kbd "P") (lambda () (interactive) (evil-paste-before 1)))
  
  (define-key evil-insert-state-map (kbd "y") #'self-insert-command)
  (define-key evil-insert-state-map (kbd "Y") #'self-insert-command)
  (define-key evil-insert-state-map (kbd "C-S-v") #'yank)

  ;; Smart buffer close functions
  (defun my/smart-close-buffer (&optional bang)
    "Close buffer intelligently - close window if splits, close tab if multiple tabs, otherwise quit."
    (interactive)
    (cond
     ;; Multiple windows (splits): use evil-quit to close just this window
     ((> (length (window-list)) 1)
      (evil-quit bang))
     ;; Single window but multiple tabs: close the tab
     ((> (length (tab-bar-tabs)) 1)
      (tab-bar-close-tab))
     ;; Last window and last tab: quit
     (t
      (evil-quit bang))))

  (defun my/smart-save-and-close (&optional bang)
    "Save and close buffer intelligently - save, then close window/tab as appropriate."
    (interactive)
    (cond
     ;; Multiple windows (splits): use evil-save-and-close to save and close just this window
     ((> (length (window-list)) 1)
      (evil-save-and-close bang))
     ;; Single window but multiple tabs: save then close the tab
     ((> (length (tab-bar-tabs)) 1)
      (when (buffer-file-name)
        (save-buffer))
      (tab-bar-close-tab))
     ;; Last window and last tab: save and quit
     (t
      (evil-save-and-close bang))))

  ;; Rebind ZZ, ZQ
  (define-key evil-normal-state-map (kbd "Z Z") #'my/smart-save-and-close)
  (define-key evil-normal-state-map (kbd "Z Q") #'my/smart-close-buffer)

  ;; Override :wq and :q ex commands
  (evil-ex-define-cmd "q[uit]" #'my/smart-close-buffer)
  (evil-ex-define-cmd "wq" #'my/smart-save-and-close))

(with-eval-after-load 'general
  (when (and (boundp 'general-override-mode-map)
             (keymapp general-override-mode-map))
    (define-key general-override-mode-map (kbd "y") nil)
    (define-key general-override-mode-map (kbd "Y") nil)
    (define-key general-override-mode-map (kbd "p") nil)
    (define-key general-override-mode-map (kbd "P") nil)))

(use-package evil-collection :after evil
  :init (setq evil-collection-setup-minibuffer nil)
  :config (evil-collection-init))
(use-package evil-surround   :after evil :config (global-evil-surround-mode 1))
(use-package evil-commentary :after (evil org) :config (evil-commentary-mode 1))
(use-package evil-visualstar :after evil :config (global-evil-visualstar-mode 1))
(use-package evil-snipe      :after evil :config (evil-snipe-mode 1) (evil-snipe-override-mode 1))

(add-hook 'minibuffer-setup-hook
          (lambda () (when (boundp 'evil-local-mode) (ignore-errors (evil-emacs-state)))))

(provide 'evil-setup)
