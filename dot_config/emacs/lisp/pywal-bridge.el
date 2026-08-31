;;; pywal-bridge.el --- Bridge between pywal and theme system -*- lexical-binding: t; -*-
;; I have no clue how this works, stolen from random github page, with touchups by Claude.

(require 'themes)
(require 'pywal)

;; Enhanced pywal integration for theme system
(defvar pywal-bridge--original-pywal-apply nil
  "Store original pywal-apply-colors function.")

(defvar pywal-bridge--original-reload-pywal nil
  "Store original reload-pywal function.")

(defun pywal-bridge--enhanced-apply ()
  "Enhanced pywal application that integrates with theme system."
  (message "[pywal-bridge] Enhanced apply called - current theme: %s" themes--current-theme)
  ;; Only apply pywal colors if current theme is pywal or no theme is set
  (if (or (not themes--current-theme) (eq themes--current-theme 'pywal))
      (progn
        (message "[pywal-bridge] ALLOWING pywal colors (current theme: %s)" themes--current-theme)
        (let* ((data (pywal--read-colors))
               (spec (pywal--alist-get* data "special"))
               (colors (pywal--alist-get* data "colors")))
          (when (and data spec colors)
            (let ((theme-colors
                   `((bg . ,(or (pywal--alist-get* spec "background")
                                (pywal--alist-get* colors "color0")))
                     (fg . ,(or (pywal--alist-get* spec "foreground")
                                (pywal--alist-get* colors "color7")))
                     (accent . ,(or (pywal--alist-get* colors "color4")
                                    (pywal--alist-get* colors "color2")))
                     (highlight . ,(or (pywal--alist-get* colors "color8")
                                       (pywal--alist-get* spec "background")))
                     (selection . ,(or (pywal--alist-get* colors "color8")
                                       (pywal--alist-get* colors "color0")))
                     (comment . ,(or (pywal--alist-get* colors "color8")
                                     (pywal--alist-get* colors "color3")))
                     (string . ,(or (pywal--alist-get* colors "color2")
                                    (pywal--alist-get* colors "color10")))
                     (keyword . ,(or (pywal--alist-get* colors "color5")
                                     (pywal--alist-get* colors "color13")))
                     (warning . ,(or (pywal--alist-get* colors "color3")
                                     (pywal--alist-get* colors "color11")))
                     (error . ,(or (pywal--alist-get* colors "color1")
                                   (pywal--alist-get* colors "color9")))
                     (success . ,(or (pywal--alist-get* colors "color2")
                                     (pywal--alist-get* colors "color10"))))))
              
              ;; Update the pywal theme definition with current colors
              (let ((pywal-theme (themes-get 'pywal)))
                (when pywal-theme
                  (setf (theme-def-colors pywal-theme) theme-colors)))
              
              ;; Apply using the theme system
              (themes--apply-colors theme-colors)
              
              ;; Call original pywal function for any additional face customizations
              (when pywal-bridge--original-pywal-apply
                (funcall pywal-bridge--original-pywal-apply))))))
    (message "[pywal-bridge] BLOCKING pywal colors (current theme: %s)" themes--current-theme)))

(defun pywal-bridge--enhanced-reload ()
  "Enhanced pywal reload that respects theme system."
  (message "[pywal-bridge] Reload pywal requested (current theme: %s)" themes--current-theme)
  (if (or (not themes--current-theme) (eq themes--current-theme 'pywal))
      (progn
        (message "[pywal-bridge] Proceeding with pywal reload")
        ;; Cancel any pending timer first
        (when (and (boundp 'pywal--reload-timer) (timerp pywal--reload-timer))
          (cancel-timer pywal--reload-timer)
          (setq pywal--reload-timer nil))
        ;; Apply pywal colors
        (pywal-bridge--enhanced-apply)
        (message "[pywal-bridge] Pywal colors reloaded."))
    (message "[pywal-bridge] Ignoring pywal reload - current theme is %s" themes--current-theme)))

(defun pywal-bridge-setup ()
  "Set up pywal bridge integration."
  (interactive)
  ;; Store original functions
  (unless pywal-bridge--original-pywal-apply
    (setq pywal-bridge--original-pywal-apply (symbol-function 'pywal-apply-colors)))
  (unless pywal-bridge--original-reload-pywal
    (setq pywal-bridge--original-reload-pywal (symbol-function 'reload-pywal)))
  
  ;; Replace functions with enhanced versions
  (fset 'pywal-apply-colors 'pywal-bridge--enhanced-apply)
  (fset 'reload-pywal 'pywal-bridge--enhanced-reload)
  
  ;; Add hook to update pywal theme when theme system changes
  (themes-add-hook 'pywal-bridge--on-theme-change)
  
  (message "Pywal bridge activated"))

(defun pywal-bridge-teardown ()
  "Tear down pywal bridge integration."
  (interactive)
  ;; Restore original functions
  (when pywal-bridge--original-pywal-apply
    (fset 'pywal-apply-colors pywal-bridge--original-pywal-apply)
    (setq pywal-bridge--original-pywal-apply nil))
  (when pywal-bridge--original-reload-pywal
    (fset 'reload-pywal pywal-bridge--original-reload-pywal)
    (setq pywal-bridge--original-reload-pywal nil))
  
  ;; Remove hook
  (themes-remove-hook 'pywal-bridge--on-theme-change)
  
  (message "Pywal bridge deactivated"))

(defun pywal-bridge--on-theme-change ()
  "Handle theme changes for pywal integration."
  (message "[pywal-bridge] Theme change hook triggered, current theme: %s" themes--current-theme)
  (cond
   ;; Switching TO pywal theme
   ((eq themes--current-theme 'pywal)
    (message "[pywal-bridge] Switching TO pywal theme")
    (when themes-enable-pywal-integration
      (pywal-start-watching))
    ;; Apply current pywal colors
    (pywal-bridge--enhanced-apply))
   
   ;; Switching AWAY from pywal theme 
   ((and (not (eq themes--current-theme 'pywal))
         themes-enable-pywal-integration)
    (message "[pywal-bridge] Switching AWAY from pywal theme to %s" themes--current-theme)
    ;; Stop watching to prevent interference
    (pywal-stop-watching)
    ;; Cancel any pending timers
    (when (and (boundp 'pywal--reload-timer) (timerp pywal--reload-timer))
      (cancel-timer pywal--reload-timer)
      (setq pywal--reload-timer nil)
      (message "[pywal-bridge] Cancelled pywal reload timer")))))

;; Dynamic pywal theme creation from current colors
(defun pywal-bridge-create-static-theme (name)
  "Create a static theme from current pywal colors."
  (interactive "sTheme name: ")
  (let* ((data (pywal--read-colors))
         (spec (pywal--alist-get* data "special"))
         (colors (pywal--alist-get* data "colors")))
    (unless (and data spec colors)
      (error "Could not read pywal colors"))
    
    (let ((theme-colors
           `((bg . ,(or (pywal--alist-get* spec "background")
                        (pywal--alist-get* colors "color0")))
             (fg . ,(or (pywal--alist-get* spec "foreground")
                        (pywal--alist-get* colors "color7")))
             (accent . ,(or (pywal--alist-get* colors "color4")
                            (pywal--alist-get* colors "color2")))
             (highlight . ,(or (pywal--alist-get* colors "color8")
                               (pywal--alist-get* spec "background")))
             (selection . ,(or (pywal--alist-get* colors "color8")
                               (pywal--alist-get* colors "color0")))
             (comment . ,(or (pywal--alist-get* colors "color8")
                             (pywal--alist-get* colors "color3")))
             (string . ,(or (pywal--alist-get* colors "color2")
                            (pywal--alist-get* colors "color10")))
             (keyword . ,(or (pywal--alist-get* colors "color5")
                             (pywal--alist-get* colors "color13")))
             (warning . ,(or (pywal--alist-get* colors "color3")
                             (pywal--alist-get* colors "color11")))
             (error . ,(or (pywal--alist-get* colors "color1")
                           (pywal--alist-get* colors "color9")))
             (success . ,(or (pywal--alist-get* colors "color2")
                             (pywal--alist-get* colors "color10"))))))
      
      (themes-register
       (make-theme-def
        :name (intern name)
        :display-name (format "Pywal Snapshot: %s" name)
        :description (format "Static theme created from pywal colors on %s" 
                             (format-time-string "%Y-%m-%d %H:%M"))
        :type 'static
        :colors theme-colors))
      
      (message "Created static theme '%s' from current pywal colors" name))))

;; Integration with compositor/picom (if needed)
(defun pywal-bridge-sync-compositor ()
  "Sync theme changes with compositor if available."
  (interactive)
  ;; This function can be extended to trigger picom config reloads
  ;; or other compositor integrations when themes change
  (when (executable-find "picom")
    ;; Example: reload picom with new colors
    ;; You can customize this based on your picom setup
    (message "Compositor sync not implemented yet - extend as needed")))

;; Initialize bridge on load
(defun pywal-bridge-init ()
  "Initialize pywal bridge integration."
  (message "[pywal-bridge] Initializing bridge...")
  (when (featurep 'pywal)
    (message "[pywal-bridge] Pywal feature found, setting up bridge")
    (pywal-bridge-setup))
  (unless (featurep 'pywal)
    (message "[pywal-bridge] Pywal feature not found yet")))

;; Hook into theme system - run earlier than pywal's emacs-startup-hook
(add-hook 'after-init-hook 'pywal-bridge-init)

;; Also try to set up immediately when this file loads (if pywal is already loaded)
(when (featurep 'pywal)
  (pywal-bridge-init))

(provide 'pywal-bridge)
;;; pywal-bridge.el ends here
