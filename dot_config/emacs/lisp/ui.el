;;; ui.el --- Basic UI setup -*- lexical-binding: t; -*-
(when (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(setq inhibit-startup-screen t)
(global-display-line-numbers-mode 1)
(when (boundp 'mode-line-compact) (setq mode-line-compact 'long))
(global-visual-line-mode t)
;; Disable the damn beep
(setq visible-bell t)
(setq ring-bell-function 'ignore)

(provide 'ui)
