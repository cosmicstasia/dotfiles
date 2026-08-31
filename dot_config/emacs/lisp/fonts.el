;;; fonts.el --- Font configuration -*- lexical-binding: t; -*-

(defun my/apply-fonts (&optional frame)
  "Apply font settings to FRAME (or current frame if nil)."
  (let ((target-frame (or frame (selected-frame))))
    (when (display-graphic-p target-frame)
      (set-face-attribute 'default target-frame :font "JetBrainsMono Nerd Font" :height 130)
      (set-face-attribute 'fixed-pitch target-frame :family "JetBrainsMono Nerd Font" :height 130)
      (set-face-attribute 'variable-pitch target-frame :family "JetBrainsMono Nerd Font" :height 130)
      ;; Set emoji font for Unicode emoji range
      (set-fontset-font t 'unicode "Noto Color Emoji" target-frame 'prepend)
      ;; Also try Symbola as fallback
      (set-fontset-font t 'unicode "Symbola" target-frame 'append))))

;; Apply to default (future frames)
(set-face-attribute 'default         nil :font "JetBrainsMono Nerd Font" :height 130)
(set-face-attribute 'fixed-pitch     nil :family "JetBrainsMono Nerd Font" :height 130)
(set-face-attribute 'variable-pitch  nil :family "JetBrainsMono Nerd Font" :height 130)

;; Configure emoji fonts globally
(set-fontset-font t 'unicode "Noto Color Emoji" nil 'prepend)
(set-fontset-font t 'unicode "Symbola" nil 'append)

;; Apply to existing frames
(mapc #'my/apply-fonts (frame-list))

;; Apply to new frames
(add-hook 'after-make-frame-functions #'my/apply-fonts)

;; Re-apply fonts after theme changes (if themes system is available)
(when (featurep 'themes)
  (themes-add-hook 'my/apply-fonts))

(provide 'fonts)
