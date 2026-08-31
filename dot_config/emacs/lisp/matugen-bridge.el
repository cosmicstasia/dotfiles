;;; matugen-bridge.el --- Bridge between matugen and theme system -*- lexical-binding: t; -*-

;; This module integrates matugen (Material You color generator) with the theme system.
;; It loads colors from the active Emacs config directory and provides them to themes.

(require 'themes)

;; Path to matugen-generated colors file
(defvar matugen-bridge-colors-file
  (expand-file-name "matugen-colors.el" user-emacs-directory)
  "Path to the matugen-generated colors file.")

(defvar matugen-bridge--cached-colors nil
  "Cached colors from the last matugen load.")

(defun matugen-bridge--read-colors ()
  "Read colors from the matugen-generated file."
  (let ((colors-file (expand-file-name matugen-bridge-colors-file)))
    (when (file-exists-p colors-file)
      (condition-case err
          (progn
            ;; Load the file to get matugen-colors variable
            (load colors-file nil t t)
            (when (boundp 'matugen-colors)
              matugen-colors))
        (error
         (message "[matugen-bridge] Error reading colors: %s" err)
         nil)))))

(defun matugen-bridge--apply-colors ()
  "Apply matugen colors to Emacs."
  (let ((colors (matugen-bridge--read-colors)))
    (when colors
      (setq matugen-bridge--cached-colors colors)

      ;; Update the matugen theme definition with current colors
      (let ((matugen-theme (themes-get 'matugen)))
        (when matugen-theme
          (setf (theme-def-colors matugen-theme) colors)))

      ;; Apply using the theme system
      (themes--apply-colors colors)
      (message "[matugen-bridge] Applied matugen colors"))))

(defun matugen-reload-colors ()
  "Reload and apply matugen colors. Called by matugen post-hook."
  (interactive)
  (message "[matugen-bridge] Reloading matugen colors...")
  (let ((colors (matugen-bridge--read-colors)))
    (when colors
      (setq matugen-bridge--cached-colors colors)
      ;; Always update the theme definition with fresh colors
      (let ((matugen-theme (themes-get 'matugen)))
        (when matugen-theme
          (setf (theme-def-colors matugen-theme) colors)))
      ;; Only apply immediately if matugen theme is active
      (if (eq themes--current-theme 'matugen)
          (progn
            (themes--apply-colors colors)
            ;; Force redisplay on all frames (needed for daemon/emacsclient)
            (dolist (frame (frame-list))
              (redraw-frame frame))
            (message "[matugen-bridge] Matugen colors applied."))
        (message "[matugen-bridge] Colors cached - will apply when matugen theme is loaded.")))))

(defun matugen-bridge-setup ()
  "Set up matugen bridge integration."
  (interactive)
  ;; Add hook to update matugen theme when theme system changes
  (themes-add-hook 'matugen-bridge--on-theme-change)
  (message "Matugen bridge activated"))

(defun matugen-bridge-teardown ()
  "Tear down matugen bridge integration."
  (interactive)
  ;; Remove hook
  (themes-remove-hook 'matugen-bridge--on-theme-change)
  (message "Matugen bridge deactivated"))

(defun matugen-bridge--on-theme-change ()
  "Handle theme changes for matugen integration."
  (message "[matugen-bridge] Theme change hook triggered, current theme: %s" themes--current-theme)
  (when (eq themes--current-theme 'matugen)
    (message "[matugen-bridge] Switching TO matugen theme")
    (matugen-bridge--apply-colors)))

(defun matugen-bridge-apply-colors ()
  "Apply matugen colors. Called from theme setup function."
  (interactive)
  ;; Use cached colors if available, otherwise read from file
  (let ((colors (or matugen-bridge--cached-colors (matugen-bridge--read-colors))))
    (when colors
      (setq matugen-bridge--cached-colors colors)
      ;; Update the matugen theme definition with current colors
      (let ((matugen-theme (themes-get 'matugen)))
        (when matugen-theme
          (setf (theme-def-colors matugen-theme) colors)))
      ;; Apply using the theme system
      (themes--apply-colors colors)
      ;; Force redisplay on all frames (needed for daemon/emacsclient)
      (dolist (frame (frame-list))
        (redraw-frame frame))
      (message "[matugen-bridge] Applied matugen colors"))))

;; Initialize bridge on load
(defun matugen-bridge-init ()
  "Initialize matugen bridge integration."
  (message "[matugen-bridge] Initializing bridge...")
  (matugen-bridge-setup))

;; Hook into after-init
(add-hook 'after-init-hook 'matugen-bridge-init)

(provide 'matugen-bridge)
;;; matugen-bridge.el ends here
