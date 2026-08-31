;;; wordcount.el --- Mode-line word count -*- lexical-binding: t; -*-
(require 'cl-lib)
(defun my-buffer-word-count ()
  (how-many "\\w+\\(?:[-'’]\\w+\\)*" (point-min) (point-max)))
(defvar my/mode-line-wordcount '(:eval (format " %dW" (my-buffer-word-count))))
(defun my/ensure-single-wordcount ()
  (setq global-mode-string
        (cl-remove-if
         (lambda (elt)
           (and (consp elt) (eq (car elt) :eval)
                (string-match-p "my-buffer-word-count" (format "%S" elt))))
         global-mode-string))
  (add-to-list 'global-mode-string my/mode-line-wordcount t)
  (force-mode-line-update))
(with-eval-after-load 'powerline-evil (my/ensure-single-wordcount))
(provide 'wordcount)
