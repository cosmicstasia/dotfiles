;;; claude-code-setup.el --- claude-code.el integration -*- lexical-binding: t; -*-

(use-package inheritenv
  :vc (:url "https://github.com/purcell/inheritenv" :rev :newest))

(use-package claude-code
  :vc (:url "https://github.com/stevemolitor/claude-code.el" :rev :newest)
  :config
  (setq claude-code-terminal-backend 'vterm)
  (claude-code-mode)
  :bind-keymap ("C-c c" . claude-code-command-map))

(with-eval-after-load 'general
  (my/leader-keys
    "a"   '(:ignore t :which-key "AI")
    "a c" '(claude-code :which-key "claude start")
    "a t" '(claude-code-toggle :which-key "toggle window")
    "a s" '(claude-code-send-command :which-key "send command")))

(provide 'claude-code-setup)
