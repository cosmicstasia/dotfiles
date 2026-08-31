;;; server-init.el --- Start the Emacs server -*- lexical-binding: t; -*-
(require 'server)
(unless (server-running-p) (server-start))
(global-set-key (kbd "<f5>") (lambda () (interactive) (load-file user-init-file)))
(provide 'server-init)
