;;; ui.el --- Basic UI setup -*- lexical-binding: t; -*-
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-screen t)
(global-display-line-numbers-mode 1)
(when (boundp 'mode-line-compact) (setq mode-line-compact 'long))
(global-visual-line-mode t)
;; Disable the damn beep
(setq visible-bell t)
(setq ring-bell-function 'ignore)

(provide 'ui)
