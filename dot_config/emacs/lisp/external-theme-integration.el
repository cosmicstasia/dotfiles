;;; external-theme-integration.el --- External theme integration for scripts -*- lexical-binding: t; -*-
;; I have no clue how this works, stolen from random github page, with touchups by Claude.

(require 'themes)

;; Map external theme names to Emacs theme names
(defvar external-theme-mapping
  '(("catppuccin" . catppuccin)
    ("ayu" . ayu)
    ("nerd_ayu" . ayu)
    ("dracula" . dracula)
    ("nerd_dracula" . dracula)
    ("everforest" . everforest)
    ("nerd_everforest" . everforest)
    ("rosepine" . rose-pine)
    ("nerd_rosepine" . rose-pine)
    ("oceanic" . oceanic)
    ("nerd_oceanic" . oceanic)
    ("gruvbox" . gruvbox)
    ("modern_gruvbox" . gruvbox)
    ("nerd_gruvbox" . gruvbox)
    ("nerd_gruv_chad" . gruvbox)
    ("nerd_gruvbox_dwm" . gruvbox)
    ("oxocarbon" . oxocarbon)
    ("oxo_chad" . oxocarbon)
    ("nerd_oxocarbon" . oxocarbon)
    ("nerd_oxo_chad" . oxocarbon)
    ("gruv_chad" . gruvbox)
    ("gruv_boxes" . gruvbox)
    ("nerd" . gruvbox)  ; Default nerd theme uses gruvbox
    ("nerd_mocha" . catppuccin)
    ("nerd_hyprspike" . catppuccin)
    ("dwm" . everforest)  ; Default to everforest for dwm
    ("pywal" . pywal)
    ("pywal2" . pywal)
    ("pywal_dwm" . pywal)
    ("arrows" . rose-pine)  ; Arrows uses rosepine colors
    ("hyprspike" . catppuccin)  ; Hyprspike uses catppuccin colors
    ("flat" . doom-one)  ; Default for flat
    ("nord" . nord)
    ("tokyo-night" . tokyo-night)
    ("tokyonight" . tokyo-night)
    ;; Matugen themes (Material You)
    ("matugen" . matugen)
    ("matugen_chadwm" . matugen)
    ("matugen_slants" . matugen)
    ("matugen_shapes" . matugen)
    ("matugen_icons" . matugen)
    ("matugen_colorful" . matugen))
  "Mapping from external theme script names to Emacs theme names.")

(defun external-theme-change (theme-name)
  "Change Emacs theme based on external THEME-NAME."
  (let ((emacs-theme (alist-get theme-name external-theme-mapping nil nil #'string=)))
    (if emacs-theme
        (progn
          (themes-load emacs-theme t)
          (message "External theme change: %s -> %s" theme-name emacs-theme))
      (message "Unknown external theme: %s" theme-name))))

(defun external-theme-change-from-args ()
  "Change theme based on command line arguments."
  (when command-line-args-left
    (let ((theme-name (car command-line-args-left)))
      (external-theme-change theme-name)
      (setq command-line-args-left (cdr command-line-args-left)))))

;; Function to be called from external scripts via emacsclient
(defun external-set-theme (theme-name)
  "Set Emacs theme from external script via emacsclient."
  (interactive "sTheme name: ")
  (external-theme-change theme-name))

;; Create a command-line interface
(defun themes-cli-handler ()
  "Handle theme changes from command line."
  (when (member "--theme" command-line-args)
    (let ((theme-pos (cl-position "--theme" command-line-args :test #'string=)))
      (when (and theme-pos (< (1+ theme-pos) (length command-line-args)))
        (let ((theme-name (nth (1+ theme-pos) command-line-args)))
          (external-theme-change theme-name))))))

;; Add to startup hook
(add-hook 'after-init-hook 'themes-cli-handler)

(provide 'external-theme-integration)
;;; external-theme-integration.el ends here
