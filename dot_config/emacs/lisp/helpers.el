;;; helpers.el --- General helpers -*- lexical-binding: t; -*-

(eval-when-compile (require 'use-package))

(use-package which-key
  :demand t
  :config
  (which-key-mode 1)
  (setq which-key-idle-delay 0.5
        which-key-sort-order 'which-key-prefix-then-key-order
        which-key-sort-uppercase-first nil
        which-key-add-column-padding 1
        which-key-max-display-columns nil
        which-key-min-display-lines 6
        which-key-side-window-slot -10
        which-key-show-remaining-keys t
        which-key-show-docstrings t
        which-key-enable-extended-define-key t)
  ;; Show which-key faster for leader key
  (setq which-key-show-early-on-C-h t
        which-key-idle-secondary-delay 0.05))

(use-package diminish :demand t)

;; Hydra for creating command menus
(use-package hydra
  :demand t)

(use-package general
  :demand t
  :config
  (when (boundp 'general-override-mode-map)
    (define-key general-override-mode-map (kbd "SPC") nil))

  ;; Tab switching with M-1 through M-9 (Alt+number)
  (dotimes (i 9)
    (let ((tab-num (1+ i)))
      (global-set-key (kbd (format "M-%d" tab-num))
        `(lambda () (interactive) (tab-bar-select-tab ,tab-num)))))

  (my/leader-keys
    "?"  '((lambda () (interactive)
             (find-file (expand-file-name "KEYBINDINGS.md" user-emacs-directory)))
           :which-key "Cheatsheet")
    "f"  '(find-file                      :which-key "Find File")
    "b"  '(consult-buffer                 :which-key "Switch Buffer")
    "c"  '(tab-new                        :which-key "New Tab")
    "vo" '(tab-bar-switch-to-next-tab     :which-key "Next Tab")
    "vO" '(tab-bar-switch-to-prev-tab     :which-key "Prev Tab")
    "vb" '(switch-to-buffer-other-tab     :which-key "Buffer→Tab")
    "vf" '(find-file-other-tab            :which-key "File→Tab")
    "t"  '(vterm-toggle                   :which-key "Vterm")
    "n"  '(dired-sidebar-toggle-sidebar   :which-key "File Tree")
    "w"  '(:ignore t :which-key "Windows")
    "ww" '(hydra-window/body  :which-key "Window Hydra")
    "wv" '(split-window-right :which-key "Vertical split")
    "wh" '(split-window-below :which-key "Horizontal split")
    "wd" '(delete-window      :which-key "Delete window")
    "wo" '(delete-other-windows :which-key "Delete other windows")
    "r"  '(reload-pywal                   :which-key "Reload Pywal"))

  ;; Theme group
  (my/leader-keys
    "h"  '(:ignore t :which-key "Themes")
    "ht" '(themes-load            :which-key "Load Theme")
    "hr" '(themes-reload          :which-key "Reload Current")
    "hp" '(themes-toggle-previous :which-key "Previous Theme")
    "hc" '(themes-cycle           :which-key "Cycle Themes")
    "hi" '(themes-info            :which-key "Theme Info")
    "hs" '(pywal-bridge-create-static-theme :which-key "Save Pywal as Static")
    "hd" '(themes-debug           :which-key "Debug Theme System")
    "hD" '(pywal-debug-colors     :which-key "Debug Pywal Colors")
    "hS" '(themes-config-save-current :which-key "Manual Save Theme"))

  ;; Git group
  (my/leader-keys
    "g"  '(:ignore t :which-key "Git")
    "gs" '(magit-status          :which-key "Status")
    "gh" '(hydra-git/body        :which-key "Git Hydra")
    "gd" '(magit-diff-unstaged   :which-key "Diff unstaged")
    "gc" '(magit-branch-or-checkout :which-key "Branch/Checkout")
    "gl" '(magit-log-oneline     :which-key "Log")
    "gp" '(magit-push            :which-key "Push")
    "gP" '(magit-pull            :which-key "Pull")
    "gf" '(magit-fetch           :which-key "Fetch")
    "gF" '(magit-fetch-all       :which-key "Fetch all")
    "gr" '(magit-rebase          :which-key "Rebase")
    "gn" '(diff-hl-next-hunk     :which-key "Next hunk")
    "go" '(diff-hl-previous-hunk :which-key "Prev hunk")
    "gR" '(diff-hl-revert-hunk   :which-key "Revert hunk")
    "gS" '(diff-hl-show-hunk     :which-key "Show hunk"))

  ;; Window management Hydra
  (defhydra hydra-window (:hint nil :color pink)
    "
^Split^           ^Switch^        ^Resize^         ^Delete^
^─────^───────────^──────^────────^──────^─────────^──────^──────
_v_: Vertical     _h_: ← Left     _H_: ← Shrink    _d_: Delete
_s_: Horizontal   _j_: ↓ Down     _J_: ↓ Shrink    _o_: Only this
^ ^               _k_: ↑ Up       _K_: ↑ Grow      ^ ^
^ ^               _l_: → Right    _L_: → Grow      ^ ^
"
    ("v" split-window-right)
    ("s" split-window-below)
    ("h" windmove-left)
    ("j" windmove-down)
    ("k" windmove-up)
    ("l" windmove-right)
    ("H" shrink-window-horizontally)
    ("J" shrink-window)
    ("K" enlarge-window)
    ("L" enlarge-window-horizontally)
    ("d" delete-window)
    ("o" delete-other-windows :exit t)
    ("q" nil "quit"))

  ;; Git Hydra for visual command menu
  (defhydra hydra-git (:exit t :hint nil :color blue)
    "
^Magit^            ^Hunks^           ^Remote^
^─────^────────────^─────^───────────^──────^────────
_s_: Status        _n_: Next hunk    _p_: Push
_d_: Diff          _o_: Prev hunk    _P_: Pull
_c_: Branch        _R_: Revert hunk  _f_: Fetch
_l_: Log           _S_: Show hunk    _F_: Fetch all
_b_: Blame         ^ ^               _r_: Rebase
"
    ("s" magit-status)
    ("d" magit-diff-unstaged)
    ("c" magit-branch-or-checkout)
    ("l" magit-log-oneline)
    ("b" magit-blame)
    ("n" diff-hl-next-hunk)
    ("o" diff-hl-previous-hunk)
    ("R" diff-hl-revert-hunk)
    ("S" diff-hl-show-hunk)
    ("p" magit-push)
    ("P" magit-pull)
    ("f" magit-fetch)
    ("F" magit-fetch-all)
    ("r" magit-rebase)
    ("q" nil "quit"))

  ;; Jump to directories group
  (my/leader-keys
    "j"  '(:ignore t :which-key "Jump to Dir")
    "jd" '(my/jump-to-documents :which-key "Documents")))

;; Jump to directory functions
(defun my/jump-to-documents ()
  "Jump to Documents directory."
  (interactive)
  (dired (expand-file-name "Documents" "~")))

(defun my/smart-ctrl-t ()
  "Context-aware C-t: xref-go-back in xref buffers, tab-new elsewhere."
  (interactive)
  (cond
   ((and (fboundp 'xref--marker-ring)
         (not (ring-empty-p (xref--marker-ring))))
    (call-interactively 'xref-go-back))
   (t (call-interactively 'tab-new))))

(add-hook 'after-init-hook
          (lambda ()
            (global-set-key (kbd "C-t") 'my/smart-ctrl-t)))

(with-eval-after-load 'evil
  (define-key evil-normal-state-map (kbd "C-t") 'my/smart-ctrl-t)
  (define-key evil-insert-state-map (kbd "C-t") 'my/smart-ctrl-t)
  (define-key evil-visual-state-map (kbd "C-t") 'my/smart-ctrl-t)
  (define-key evil-emacs-state-map (kbd "C-t") 'my/smart-ctrl-t))

;; Ctrl+hjkl for moving between splits 
(add-hook 'after-init-hook
          (lambda ()
            (global-set-key (kbd "C-h") 'windmove-left)
            (global-set-key (kbd "C-j") 'windmove-down)
            (global-set-key (kbd "C-k") 'windmove-up)
            (global-set-key (kbd "C-l") 'windmove-right)))

;; Make sure it works in evil mode.
(with-eval-after-load 'evil
  (define-key evil-normal-state-map (kbd "C-h") 'windmove-left)
  (define-key evil-normal-state-map (kbd "C-j") 'windmove-down)
  (define-key evil-normal-state-map (kbd "C-k") 'windmove-up)
  (define-key evil-normal-state-map (kbd "C-l") 'windmove-right)
  (define-key evil-insert-state-map (kbd "C-h") 'windmove-left)
  (define-key evil-insert-state-map (kbd "C-j") 'windmove-down)
  (define-key evil-insert-state-map (kbd "C-k") 'windmove-up)
  (define-key evil-insert-state-map (kbd "C-l") 'windmove-right)
  (define-key evil-visual-state-map (kbd "C-h") 'windmove-left)
  (define-key evil-visual-state-map (kbd "C-j") 'windmove-down)
  (define-key evil-visual-state-map (kbd "C-k") 'windmove-up)
  (define-key evil-visual-state-map (kbd "C-l") 'windmove-right))

;; Additional markdown bindings (main bindings are in markdown-setup.el)
(with-eval-after-load 'markdown-mode
  (my/leader-keys
    :keymaps 'markdown-mode-map
    "mi" '(markdown-toggle-inline-images  :which-key "Toggle images")))

(with-eval-after-load 'which-key       (diminish 'which-key-mode))
(with-eval-after-load 'company         (diminish 'company-mode))
(with-eval-after-load 'eldoc           (diminish 'eldoc-mode))
(with-eval-after-load 'flymake         (diminish 'flymake-mode))
(with-eval-after-load 'evil-snipe      (diminish 'evil-snipe-local-mode) (diminish 'evil-snipe-override-local-mode))
(with-eval-after-load 'evil-commentary (diminish 'evil-commentary-mode))
(with-eval-after-load 'evil-visualstar (diminish 'evil-visualstar-mode))
(with-eval-after-load 'evil-surround   (diminish 'evil-surround-mode))
(with-eval-after-load 'vim-tab-bar     (diminish 'vim-tab-bar-mode))
(with-eval-after-load 'evil-collection-unimpaired (diminish 'evil-collection-unimpaired-mode))
(with-eval-after-load 'markdown-setup  (diminish 'md/markdown-conceal-mode) (diminish 'md/markdown-list-pretty-mode))
(with-eval-after-load 'counsel         (diminish 'counsel-mode))
(with-eval-after-load 'ivy             (diminish 'ivy-mode))
(with-eval-after-load 'ivy-avy         (diminish 'ivy-avy-mode))
(diminish 'visual-line-mode)

(dolist (pair '((minibuffer-local-map              . exit-minibuffer)
                (minibuffer-local-ns-map           . exit-minibuffer)
                (minibuffer-local-completion-map   . minibuffer-complete-and-exit)
                (minibuffer-local-must-match-map   . minibuffer-complete-and-exit)))
  (when (boundp (car pair))
    (define-key (symbol-value (car pair)) (kbd "RET") (cdr pair))
    (define-key (symbol-value (car pair)) (kbd "C-m") (cdr pair))))

(with-eval-after-load 'ivy
  (define-key ivy-minibuffer-map (kbd "RET") 'ivy-alt-done)
  (define-key ivy-minibuffer-map (kbd "C-m") 'ivy-alt-done))

(defun my/insert-timestamp ()
  "Insert current timestamp at cursor position. In Evil normal mode, enter insert mode after."
  (interactive)
  (insert (format-time-string "%I:%M %p"))
  (when (and (bound-and-true-p evil-mode)
             (eq evil-state 'normal))
    (evil-insert-state)))

(add-hook 'after-init-hook
          (lambda ()
            (global-set-key (kbd "C-c t") 'my/insert-timestamp)))

(with-eval-after-load 'evil
  (define-key evil-normal-state-map (kbd "C-c t") 'my/insert-timestamp)
  (define-key evil-insert-state-map (kbd "C-c t") 'my/insert-timestamp)
  (define-key evil-visual-state-map (kbd "C-c t") 'my/insert-timestamp)
  (define-key evil-emacs-state-map (kbd "C-c t") 'my/insert-timestamp))

(defun my/insert-youtube-shortcode ()
  "Insert Hugo YouTube shortcode and prompt for video ID/URL. In Evil normal mode, enter insert mode after."
  (interactive)
  (let ((video-input (read-string "YouTube video ID or URL: "
                                  (when (and (fboundp 'evil-paste-from-register)
                                             (not (string-empty-p (or (current-kill 0 t) ""))))
                                    (current-kill 0 t)))))
    (insert (format "{{< youtube \"%s\" >}}" video-input)))
  (when (and (bound-and-true-p evil-mode)
             (eq evil-state 'normal))
    (evil-insert-state)))

(add-hook 'after-init-hook
          (lambda ()
            (global-set-key (kbd "C-c y") 'my/insert-youtube-shortcode)))

(with-eval-after-load 'evil
  (define-key evil-normal-state-map (kbd "C-c y") 'my/insert-youtube-shortcode)
  (define-key evil-insert-state-map (kbd "C-c y") 'my/insert-youtube-shortcode)
  (define-key evil-visual-state-map (kbd "C-c y") 'my/insert-youtube-shortcode)
  (define-key evil-emacs-state-map (kbd "C-c y") 'my/insert-youtube-shortcode))

;; Hugo shortcode definitions with their parameters
(defvar my/hugo-shortcodes
  '(("wrap" . (("src" . "Image path (e.g., /assets/image.jpg)")
               ("alt" . "Alt text")
               ("float" . "Float (left/right/center/none)")
               ("width" . "Width (e.g., 200px, 50%)")
               ("max-width" . "Max width (optional)")
               ("caption" . "Caption text (optional)")
               ("margin" . "Custom margin (optional)")))
    ("image" . (("src" . "Image path")
                ("alt" . "Alt text")
                ("width" . "Width (optional)")
                ("height" . "Height (optional)")))
    ("figure" . (("src" . "Image path")
                 ("alt" . "Alt text")
                 ("caption" . "Caption text (optional)")
                 ("captionPosition" . "Caption position (optional)")))
    ("youtube" . (("id" . "YouTube video ID or URL")))
    ("collapse" . (("summary" . "Summary text")
                   ("content" . "Content to collapse")))
    ("code" . (("language" . "Programming language")
               ("file" . "File path (optional)"))))
  "Alist of Hugo shortcodes and their parameters.")

(defun my/insert-hugo-shortcode ()
  "Interactive Hugo shortcode inserter with parameter prompts."
  (interactive)
  (let* ((shortcode-names (mapcar #'car my/hugo-shortcodes))
         (selected (completing-read "Select shortcode: " shortcode-names nil t))
         (params (cdr (assoc selected my/hugo-shortcodes)))
         (param-values '())
         (shortcode-str ""))

    ;; Collect parameter values
    (dolist (param params)
      (let* ((param-name (car param))
             (param-desc (cdr param))
             (is-optional (string-match-p "(optional)" param-desc))
             (prompt (format "%s: " param-desc))
             (value (read-string prompt)))
        (when (and value (not (string-empty-p value)))
          (push (cons param-name value) param-values))))

    ;; Build shortcode string
    (setq param-values (nreverse param-values))
    (setq shortcode-str (format "{{< %s" selected))
    (dolist (pv param-values)
      (setq shortcode-str
            (concat shortcode-str
                    (format " %s=\"%s\"" (car pv) (cdr pv)))))
    (setq shortcode-str (concat shortcode-str " >}}"))

    ;; Insert shortcode
    (insert shortcode-str)

    ;; Enter insert mode if in Evil normal mode
    (when (and (bound-and-true-p evil-mode)
               (eq evil-state 'normal))
      (evil-insert-state))))

;; Keybindings for shortcode inserter
(add-hook 'after-init-hook
          (lambda ()
            (global-set-key (kbd "C-c s") 'my/insert-hugo-shortcode)))

(with-eval-after-load 'evil
  (define-key evil-normal-state-map (kbd "C-c s") 'my/insert-hugo-shortcode)
  (define-key evil-insert-state-map (kbd "C-c s") 'my/insert-hugo-shortcode)
  (define-key evil-visual-state-map (kbd "C-c s") 'my/insert-hugo-shortcode)
  (define-key evil-emacs-state-map (kbd "C-c s") 'my/insert-hugo-shortcode))


(provide 'helpers)
