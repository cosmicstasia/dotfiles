;;; lsp.el --- Language tooling -*- lexical-binding: t; -*-
;;; Current languages supported: Nix, bash and sh, CSS, HTML, Rust, Python, Java, TypeScript, JavaScript, React.
;;; NOTE: LSP servers and dependencies are installed externally. Required LSP servers:
;;; - Rust: rust-analyzer
;;; - Bash: bash-language-server (npm install -g bash-language-server)
;;; - Nix: nil (nix profile install nixpkgs#nil) or nixd (nix profile install nixpkgs#nixd)
;;; - C/C++: clangd
;;; - Lua: lua-language-server
;;; - Python: pyright (brew install pyright)
;;; - Java: jdtls (brew install jdtls)
;;; - TypeScript/JavaScript: typescript-language-server (npm install -g typescript-language-server typescript)
;;; - JSON: vscode-json-languageserver (npm install -g vscode-langservers-extracted)
;;; - HTML/CSS: vscode-html-languageserver (npm install -g vscode-langservers-extracted) 

(use-package sh-script
  :ensure nil  ; Built into Emacs
  :mode (("\\.sh\\'" . sh-mode)
         ("\\.bash\\'" . sh-mode)
         ("\\.bashrc\\'" . sh-mode)
         ("\\.bash_profile\\'" . sh-mode)
         ("\\.bash_aliases\\'" . sh-mode)
         ("\\.zsh\\'" . sh-mode)
         ("\\.zshrc\\'" . sh-mode))
  :config
  (setq sh-basic-offset 2
        sh-indentation 2))

(use-package nix-mode
  :mode "\\.nix\\'"
  :config
  (setq nix-indent-function 'nix-indent-line))

(use-package c-mode
  :ensure nil  
  :mode (("\\.c\\'" . c-mode)
         ("\\.h\\'" . c-mode)))

(use-package cc-mode
  :ensure nil 
  :mode (("\\.cpp\\'" . c++-mode)
         ("\\.cxx\\'" . c++-mode)
         ("\\.c++\\'" . c++-mode)
         ("\\.cc\\'" . c++-mode)
         ("\\.hpp\\'" . c++-mode)
         ("\\.hxx\\'" . c++-mode)
         ("\\.h++\\'" . c++-mode)
         ("\\.hh\\'" . c++-mode)
         ("\\.java\\'" . java-mode))
  :config
  (setq c-default-style "linux"
        c-basic-offset 4))

(use-package lua-mode
  :mode "\\.lua\\'")

;; Python configuration
(use-package python
  :ensure nil  ; Built into Emacs
  :mode ("\\.py\\'" . python-mode)
  :config
  (setq python-indent-offset 4
        python-shell-interpreter "python3"
        python-indent-guess-indent-offset-verbose nil))

;; TypeScript mode
(use-package typescript-mode
  :mode (("\\.ts\\'" . typescript-mode)
         ("\\.tsx\\'" . tsx-ts-mode))
  :config
  (setq typescript-indent-level 2))

;; JavaScript configuration
(use-package js
  :ensure nil  ; Built into Emacs
  :mode (("\\.js\\'" . js-mode)
         ("\\.mjs\\'" . js-mode)
         ("\\.cjs\\'" . js-mode))
  :config
  (setq js-indent-level 2))

;; JSON mode
(use-package json-mode
  :mode "\\.json\\'")

;; Web mode for JSX and mixed content
(use-package web-mode
  :pin "melpa-stable"
  :mode (("\\.jsx\\'" . web-mode)
         ("\\.html\\'" . web-mode)
         ("\\.css\\'" . web-mode))
  :config
  (setq web-mode-markup-indent-offset 2
        web-mode-css-indent-offset 2
        web-mode-code-indent-offset 2
        web-mode-enable-auto-pairing t
        web-mode-enable-auto-closing t
        web-mode-enable-current-element-highlight t))

(use-package eglot
  :hook ((rust-mode . eglot-ensure)
         (sh-mode . eglot-ensure)
         (nix-mode . eglot-ensure)
         (c-mode . eglot-ensure)
         (c++-mode . eglot-ensure)
         (lua-mode . eglot-ensure)
         (python-mode . eglot-ensure)
         (java-mode . eglot-ensure)
         (typescript-mode . eglot-ensure)
         (tsx-ts-mode . eglot-ensure)
         (js-mode . eglot-ensure)
         (json-mode . eglot-ensure)
         (web-mode . eglot-ensure))
  :config
  (add-to-list 'eglot-server-programs '(rust-mode . ("rust-analyzer")))
  (add-to-list 'eglot-server-programs '((sh-mode) . ("bash-language-server" "start")))
  ;; Nix LSP - try nil first, then nixd as fallback
  (cond
   ((executable-find "nil")
    (add-to-list 'eglot-server-programs '(nix-mode . ("nil"))))
   ((executable-find "nixd")
    (add-to-list 'eglot-server-programs '(nix-mode . ("nixd"))))
   (t
    (message "Warning: No Nix LSP server found. Install with: nix profile install nixpkgs#nil")))
  (add-to-list 'eglot-server-programs '((c-mode c++-mode) . ("clangd")))
  (add-to-list 'eglot-server-programs '(lua-mode . ("lua-language-server")))
  (add-to-list 'eglot-server-programs '(python-mode . ("pyright-langserver" "--stdio")))
  (add-to-list 'eglot-server-programs '(java-mode . ("jdtls")))
  (add-to-list 'eglot-server-programs '((typescript-mode tsx-ts-mode) . ("typescript-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs '(js-mode . ("typescript-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs '(json-mode . ("vscode-json-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs '(web-mode . ("vscode-html-language-server" "--stdio")))

  (setq eglot-autoshutdown t
        eglot-confirm-server-initiated-edits nil)

  ;; LSP Hydra for easy command access
  (with-eval-after-load 'hydra
    (defhydra hydra-lsp (:exit t :hint nil)
      "
^Navigation^      ^Actions^         ^Refactor^       ^Info^
^──────────^──────^───────^─────────^────────^───────^────^──────
_d_: Definition   _a_: Code action  _r_: Rename      _D_: Doc buffer
_i_: Implementation _f_: Format     _o_: Organize    _h_: Signature
_t_: Type def     _x_: Execute     ^ ^              _e_: Errors
_R_: References   _=_: Format region ^ ^            _s_: Symbols
_._: Find symbol  ^ ^              ^ ^              ^ ^
"
      ("d" xref-find-definitions)
      ("i" eglot-find-implementation)
      ("t" eglot-find-typeDefinition)
      ("R" xref-find-references)
      ("." xref-find-apropos)
      ("a" eglot-code-actions)
      ("f" eglot-format)
      ("=" eglot-format)
      ("x" eglot-code-action-quickfix)
      ("r" eglot-rename)
      ("o" eglot-code-action-organize-imports)
      ("D" eldoc-doc-buffer)
      ("h" eldoc)
      ("e" flymake-show-buffer-diagnostics)
      ("s" consult-imenu)
      ("q" nil "quit" :exit t))

    ;; Bind hydra to C-c l SPC (so C-c l remains a prefix for other keys)
    (define-key eglot-mode-map (kbd "C-c l SPC") 'hydra-lsp/body))

  ;; Individual LSP keybindings
  (define-key eglot-mode-map (kbd "C-c l r") 'eglot-rename)
  (define-key eglot-mode-map (kbd "C-c l a") 'eglot-code-actions)
  (define-key eglot-mode-map (kbd "C-c l f") 'eglot-format)
  (define-key eglot-mode-map (kbd "C-c l d") 'eldoc-doc-buffer)
  (define-key eglot-mode-map (kbd "C-c l i") 'eglot-find-implementation)
  (define-key eglot-mode-map (kbd "C-c l t") 'eglot-find-typeDefinition)

  ;; Format on save for specific modes
  (defun my/eglot-format-on-save ()
    "Format buffer with eglot before saving."
    (when (and (bound-and-true-p eglot--managed-mode)
               (member major-mode '(rust-mode python-mode typescript-mode tsx-ts-mode js-mode)))
      (eglot-format-buffer)))

  (add-hook 'before-save-hook #'my/eglot-format-on-save))

(use-package rust-mode 
  :mode "\\.rs\\'" 
  :config (setq rust-format-on-save t))

;; Flymake configuration (eglot uses flymake by default)
(use-package flymake
  :ensure nil  ; Built into Emacs
  :hook ((prog-mode . flymake-mode))
  :config
  (setq flymake-no-changes-timeout 0.5
        flymake-start-on-flymake-mode t
        flymake-start-on-save-buffer t)

  ;; Keybindings for flymake
  (define-key flymake-mode-map (kbd "C-c ! n") 'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "C-c ! p") 'flymake-goto-prev-error)
  (define-key flymake-mode-map (kbd "C-c ! l") 'flymake-show-buffer-diagnostics)
  (define-key flymake-mode-map (kbd "C-c ! L") 'flymake-show-project-diagnostics))

(use-package company
  :hook (after-init . global-company-mode)
  :config
  (setq company-idle-delay 0.2
        company-minimum-prefix-length 1
        company-backends '(company-capf company-files company-keywords))

  ;; Better company integration with eglot
  (add-hook 'eglot-managed-mode-hook
            (lambda ()
              (setq-local company-backends '(company-capf)))))

;; Additional language-specific enhancements

;; Python: Virtual environment support
(use-package pyvenv
  :config
  (setq pyvenv-mode-line-indicator '(pyvenv-virtual-env-name ("[venv:" pyvenv-virtual-env-name "] "))))

;; Better imenu support for navigation
(use-package imenu
  :ensure nil
  :config
  (setq imenu-auto-rescan t
        imenu-max-item-length 100))

;; Eldoc for inline documentation
(use-package eldoc
  :ensure nil
  :hook (prog-mode . eldoc-mode)
  :config
  (setq eldoc-idle-delay 0.5
        eldoc-echo-area-use-multiline-p t))

;; Tree-sitter support for better syntax (Emacs 29+)
(when (and (fboundp 'treesit-available-p)
           (treesit-available-p))
  (setq treesit-font-lock-level 4)

  ;; Grammar sources for M-x treesit-install-language-grammar
  (setq treesit-language-source-alist
        '((tsx        "https://github.com/tree-sitter/tree-sitter-typescript" nil "tsx/src")
          (typescript "https://github.com/tree-sitter/tree-sitter-typescript" nil "typescript/src")
          (javascript "https://github.com/tree-sitter/tree-sitter-javascript")
          (python     "https://github.com/tree-sitter/tree-sitter-python")
          (json       "https://github.com/tree-sitter/tree-sitter-json")
          (css        "https://github.com/tree-sitter/tree-sitter-css")))

  ;; Auto-remap modes to treesit versions if available
  (setq major-mode-remap-alist
        '((python-mode . python-ts-mode)
          (javascript-mode . js-ts-mode)
          (typescript-mode . typescript-ts-mode)
          (json-mode . json-ts-mode)
          (css-mode . css-ts-mode))))

(provide 'lsp)
