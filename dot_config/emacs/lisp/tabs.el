;;; tabs.el --- vim-tab-bar setup with file type icons -*- lexical-binding: t; -*-
;; This is a convoluted mess. Mostly created by AI. 

(eval-when-compile (require 'use-package))

(defun my/enable-vim-tab-bar (&rest _)
  "Turn on tab-bar and vim-tab-bar with my defaults."
  (tab-bar-mode 1)
  (when (fboundp 'vim-tab-bar-mode) (vim-tab-bar-mode 1))
  (when (boundp 'vim-tab-bar-show-groups) (setq vim-tab-bar-show-groups t))
  (force-mode-line-update t)
  (redraw-display))

;; Create tab, give it an icon
;; if you need to add an icon or change an icon, this is where you'd start.
(defun my/tab-bar-tab-name-with-icon ()
  "Generate tab name with file type icon using nerd-icons."
  (let* ((buffer (window-buffer (minibuffer-selected-window)))
         (buffer-name (buffer-name buffer))
         (file-name (buffer-file-name buffer))
         (icon (if (and file-name (fboundp 'nerd-icons-icon-for-file))
                   (nerd-icons-icon-for-file file-name)
                 (if (fboundp 'nerd-icons-icon-for-mode)
                     (nerd-icons-icon-for-mode (buffer-local-value 'major-mode buffer))
                   (cond
                    ((string-match-p "\\.md\\'" buffer-name) "")      ; markdown
                    ((string-match-p "\\.el\\'" buffer-name) "")      ; emacs lisp
                    ((string-match-p "\\.py\\'" buffer-name) "")      ; python
                    ((string-match-p "\\.js\\'" buffer-name) "")      ; javascript
                    ((string-match-p "\\.rs\\'" buffer-name) "")      ; rust
                    ((string-match-p "\\.c\\'" buffer-name) "")       ; c
                    ((string-match-p "\\.cpp\\'" buffer-name) "")     ; cpp
                    ((string-match-p "\\.nix\\'" buffer-name) "")     ; nix
                    ((string-match-p "\\.sh\\'" buffer-name) "")      ; shell
                    ((string-match-p "\\.json\\'" buffer-name) "")    ; json
                    ((string-match-p "\\.yml?\\'" buffer-name) "")    ; yaml
                    ((string-match-p "\\.html?\\'" buffer-name) "")   ; html
                    ((string-match-p "\\.css\\'" buffer-name) "")     ; css
                    (t "")))))                                        ; default file
         (short-name (if file-name
                        (file-name-nondirectory file-name)
                      buffer-name)))
    (if (and icon (not (string-empty-p icon)))
        (format "%s %s" icon short-name)
      short-name)))

;; fallback if you don't have nerdfonts.
(defun my/tab-bar-tab-name-with-simple-icon ()
  "Generate tab name with simple file type icons (fallback version)."
  (let* ((buffer (window-buffer (minibuffer-selected-window)))
         (buffer-name (buffer-name buffer))
         (file-name (buffer-file-name buffer))
         (icon (cond
                ((and file-name (string-match-p "\\.md\\'" file-name)) "")
                ((and file-name (string-match-p "\\.el\\'" file-name)) "")
                ((and file-name (string-match-p "\\.py\\'" file-name)) "")
                ((and file-name (string-match-p "\\.js\\'" file-name)) "")
                ((and file-name (string-match-p "\\.rs\\'" file-name)) "")
                ((and file-name (string-match-p "\\.c\\(pp\\)?\\'" file-name)) "")
                ((and file-name (string-match-p "\\.nix\\'" file-name)) "")
                ((and file-name (string-match-p "\\.sh\\'" file-name)) "")
                ((and file-name (string-match-p "\\.json\\'" file-name)) "")
                ((and file-name (string-match-p "\\.ya?ml\\'" file-name)) "")
                ((and file-name (string-match-p "\\.html?\\'" file-name)) "")
                ((and file-name (string-match-p "\\.css\\'" file-name)) "")
                ((derived-mode-p 'dired-mode) "")
                ((derived-mode-p 'vterm-mode) "")
                ((string-match-p "\\*.*\\*" buffer-name) "")  ; special buffers
                (file-name "")                                 ; generic file
                (t "")))                                       ; fallback
         (short-name (if file-name
                        (file-name-nondirectory file-name)
                      buffer-name)))
    (format "%s %s" icon short-name)))

(use-package vim-tab-bar
  :commands (vim-tab-bar-mode)
  :init
  (add-hook 'window-setup-hook #'my/enable-vim-tab-bar)
  (when (boundp 'enable-theme-functions)
    (add-hook 'enable-theme-functions #'my/enable-vim-tab-bar))
  :config
  (setq tab-bar-tab-name-function #'my/tab-bar-tab-name-with-icon)
  
  ;; Fallback to simple icons if nerd-icons functions aren't working
  (unless (and (fboundp 'nerd-icons-icon-for-file)
               (fboundp 'nerd-icons-icon-for-mode))
    (setq tab-bar-tab-name-function #'my/tab-bar-tab-name-with-simple-icon))
  
  (add-hook 'after-make-frame-functions
            (lambda (f) (with-selected-frame f (my/enable-vim-tab-bar)))))

(provide 'tabs)
