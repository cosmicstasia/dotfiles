;;; minibuffer.el --- Minibuffer quirks -*- lexical-binding: t; -*-
(with-eval-after-load 'vertico
  (define-key vertico-map (kbd "y") #'self-insert-command))

(dolist (map '(minibuffer-local-map
               minibuffer-local-completion-map
               minibuffer-local-must-match-map
               minibuffer-inactive-mode-map))
  (when (boundp map)
    (define-key (symbol-value map) (kbd "y") #'self-insert-command)
    (define-key (symbol-value map) (kbd "Y") #'self-insert-command)))

(provide 'minibuffer)
