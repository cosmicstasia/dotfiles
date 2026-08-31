;;; themes-config.el --- Theme configuration -*- lexical-binding: t; -*-

(require 'themes)


;; Custom theme example
(themes-register
 (make-theme-def
  :name 'my-custom
  :display-name "My Custom Theme"
  :description "Personal customized theme"
  :type 'custom
  :colors '((bg . "#1c1c1c")
            (fg . "#f8f8f2")
            (accent . "#ff6347")  ; Tomato red accent
            (highlight . "#2d2d2d")
            (selection . "#404040")
            (comment . "#75715e")
            (string . "#e6db74")
            (keyword . "#f92672")
            (warning . "#fd971f")
            (error . "#f92672")
            (success . "#a6e22e"))
  :setup-func (lambda ()
                (message "Loading my custom theme...")
                (when (display-graphic-p)
                  (set-frame-parameter nil 'alpha-background 0.9)))
  :teardown-func (lambda ()
                   (when (display-graphic-p)
                     (set-frame-parameter nil 'alpha-background 1.0)))))

(defun themes-config-setup-hooks ()
  "Set up theme-specific hooks and customizations."
  
  (themes-add-hook
   (lambda ()
     (when (featurep 'org)
       (let ((theme-def (themes-get themes--current-theme)))
         (when theme-def
           (let ((accent (alist-get 'accent (theme-def-colors theme-def)))
                 (string (alist-get 'string (theme-def-colors theme-def))))
             (when accent
               (set-face-attribute 'org-link nil :foreground accent))
             (when string
               (set-face-attribute 'org-code nil :foreground string)))))))))

;; Initialize theme configuration
(add-hook 'after-init-hook 'themes-config-setup-hooks)

(defun themes-config-time-based-switching ()
  "Switch themes based on time of day."
  (let ((hour (string-to-number (format-time-string "%H"))))
    (cond
     ((< hour 6)   (themes-load 'tokyo-night t))    ; Night
     ((< hour 9)   (themes-load 'gruvbox t))        ; Early morning
     ((< hour 17)  (themes-load 'doom-one-light t)) ; Day
     ((< hour 20)  (themes-load 'nord t))           ; Evening
     (t            (themes-load 'dracula t)))))      ; Night

;; Example: Theme persistence
(defvar themes-config-file (expand-file-name "current-theme" user-emacs-directory)
  "File to store current theme for persistence across sessions.")

;; Debug the file path
(message "[themes-config] user-emacs-directory: %s" user-emacs-directory)
(message "[themes-config] themes-config-file: %s" themes-config-file)

(defun themes-config-save-current ()
  "Save current theme to config file."
  (message "[themes-config] Save hook called - current theme: %s" themes--current-theme)
  (when themes--current-theme
    (message "[themes-config] Saving theme %s to %s" themes--current-theme themes-config-file)
    (with-temp-file themes-config-file
      (prin1 themes--current-theme (current-buffer)))
    (message "[themes-config] Theme saved successfully")))

(defun themes-config-load-saved ()
  "Load saved theme from config file."
  (message "[themes-config] Attempting to load saved theme from %s" themes-config-file)
  (if (file-exists-p themes-config-file)
      (condition-case err
          (with-temp-buffer
            (insert-file-contents themes-config-file)
            (goto-char (point-min))
            (let ((saved-theme (read (current-buffer))))
              (message "[themes-config] Found saved theme: %s (type: %s)" saved-theme (type-of saved-theme))
              (when (and saved-theme (symbolp saved-theme))
                (if (themes-get saved-theme)
                    (progn
                      (message "[themes-config] Loading saved theme: %s" saved-theme)
                      (themes-load saved-theme t)
                      (message "[themes-config] Restored theme: %s" saved-theme)
                      t) ; Return t if theme was loaded
                  (progn
                    (message "[themes-config] Warning: Theme '%s' not found in registry" saved-theme)
                    nil)))))
        (error
         (message "[themes-config] Failed to load saved theme: %s" (error-message-string err))
         nil))
    (message "[themes-config] No saved theme file found")
    nil))

;; Enable theme persistence
(themes-add-hook 'themes-config-save-current)
(message "[themes-config] Added save hook to theme system")

;; For Debug purposes
(add-hook 'after-init-hook 
          (lambda ()
            (message "[themes-config] Theme hooks: %s" themes--hooks)))

(defun themes-config-sync-terminal-colors ()
  "Sync current theme colors with terminal/external programs."
  (when themes--current-theme
    (let ((theme-def (themes-get themes--current-theme)))
      (when theme-def
        (let ((colors (theme-def-colors theme-def)))
          (let ((colors-file (expand-file-name "~/.cache/emacs-theme-colors")))
            (with-temp-file colors-file
              (dolist (color colors)
                (insert (format "%s=%s\n" (car color) (cdr color))))))
          
          (when (and (getenv "TERM") (display-graphic-p))
            (condition-case nil
                (send-string-to-terminal 
                 (format "\033]0;Emacs - %s\007" 
                         (theme-def-display-name theme-def)))
              (error nil))))))))

(themes-add-hook 'themes-config-sync-terminal-colors)

(provide 'themes-config)
