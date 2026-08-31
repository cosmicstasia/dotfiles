;;; clipboard-tty.el --- Clipboard helpers for TTY -*- lexical-binding: t; -*-
(use-package xclip
  :if (and (not (display-graphic-p)) (getenv "DISPLAY"))
  :config (xclip-mode 1))

(when (and (not (display-graphic-p)) (getenv "WAYLAND_DISPLAY")
           (executable-find "wl-copy") (executable-find "wl-paste"))
  (defun my/wl-copy (text &optional _push)
    (let ((p (make-process :name "wl-copy" :buffer nil
                           :command '("wl-copy" "--type" "text/plain;charset=utf-8")
                           :connection-type 'pipe)))
      (when text (process-send-string p text) (process-send-eof p))))
  (defun my/wl-paste ()
    (let ((text (shell-command-to-string "wl-paste --no-newline --type text/plain")))
      (unless (string= text "") text)))
  (setq interprogram-cut-function   #'my/wl-copy
        interprogram-paste-function #'my/wl-paste))

(provide 'clipboard-tty)
