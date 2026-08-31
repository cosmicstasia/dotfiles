;;; themes.el --- Doom Emacs-style theme management system -*- lexical-binding: t; -*-

(require 'cl-lib)

;; Theme system variables
(defvar themes--current-theme nil
  "Currently active theme name.")

(defvar themes--available-themes '()
  "List of available theme definitions.")

(defvar themes--theme-history '()
  "History of previously loaded themes.")

(defvar themes--hooks '()
  "Hooks to run after theme changes.")

(defcustom themes-default-theme 'catppuccin
  "Default theme to load on startup."
  :type 'symbol
  :group 'themes)

(defcustom themes-enable-pywal-integration t
  "Whether to integrate with pywal for dynamic color updates."
  :type 'boolean
  :group 'themes)

;; Theme definition structure
(cl-defstruct theme-def
  name
  display-name
  description
  type ; 'static, 'pywal, 'custom
  colors
  faces
  setup-func
  teardown-func
  vars)

;; Color utilities
(defun themes--hex-to-rgb (hex)
  "Convert HEX color to RGB list."
  (when (string-match "^#?\\([0-9a-fA-F]\\{2\\}\\)\\([0-9a-fA-F]\\{2\\}\\)\\([0-9a-fA-F]\\{2\\}\\)$" hex)
    (list (string-to-number (match-string 1 hex) 16)
          (string-to-number (match-string 2 hex) 16)
          (string-to-number (match-string 3 hex) 16))))

(defun themes--lighten-color (color amount)
  "Lighten COLOR by AMOUNT (0.0-1.0)."
  (let* ((rgb (themes--hex-to-rgb color))
         (r (nth 0 rgb))
         (g (nth 1 rgb))
         (b (nth 2 rgb)))
    (format "#%02x%02x%02x"
            (min 255 (+ r (* amount (- 255 r))))
            (min 255 (+ g (* amount (- 255 g))))
            (min 255 (+ b (* amount (- 255 b)))))))

(defun themes--darken-color (color amount)
  "Darken COLOR by AMOUNT (0.0-1.0)."
  (let* ((rgb (themes--hex-to-rgb color))
         (r (nth 0 rgb))
         (g (nth 1 rgb))
         (b (nth 2 rgb)))
    (format "#%02x%02x%02x"
            (max 0 (- r (* amount r)))
            (max 0 (- g (* amount g)))
            (max 0 (- b (* amount b))))))

(defun themes--blend-colors (color1 color2 alpha)
  "Blend COLOR1 and COLOR2 with ALPHA (0.0-1.0, 0=color1, 1=color2)."
  (let* ((rgb1 (themes--hex-to-rgb color1))
         (rgb2 (themes--hex-to-rgb color2))
         (r1 (nth 0 rgb1)) (g1 (nth 1 rgb1)) (b1 (nth 2 rgb1))
         (r2 (nth 0 rgb2)) (g2 (nth 1 rgb2)) (b2 (nth 2 rgb2)))
    (format "#%02x%02x%02x"
            (round (+ (* (- 1 alpha) r1) (* alpha r2)))
            (round (+ (* (- 1 alpha) g1) (* alpha g2)))
            (round (+ (* (- 1 alpha) b1) (* alpha b2))))))

;; Theme registration and management
(defun themes-register (theme-def)
  "Register a theme definition."
  (let ((name (theme-def-name theme-def)))
    (setq themes--available-themes
          (cons theme-def (cl-remove-if (lambda (th) (eq (theme-def-name th) name))
                                        themes--available-themes)))
    theme-def))

(defun themes-get (name)
  "Get theme definition by NAME."
  (cl-find-if (lambda (th) (eq (theme-def-name th) name))
              themes--available-themes))

(defun themes-list ()
  "List all available themes."
  (mapcar #'theme-def-name themes--available-themes))

;; Core theme loading functionality
(defun themes--apply-colors (colors)
  "Apply COLORS alist to faces on all frames."
  (when colors
    (let ((bg (alist-get 'bg colors))
          (fg (alist-get 'fg colors))
          (accent (alist-get 'accent colors))
          (highlight (alist-get 'highlight colors))
          (selection (alist-get 'selection colors))
          (comment (alist-get 'comment colors))
          (string (alist-get 'string colors))
          (keyword (alist-get 'keyword colors))
          (warning (alist-get 'warning colors))
          (error (alist-get 'error colors))
          (success (alist-get 'success colors)))

      ;; Apply faces to ALL frames by iterating through each frame
      (dolist (frame (frame-list))
        ;; Core faces - in terminal mode, use 'unspecified' for bg to let terminal control it
        (when (and bg fg)
          (if (display-graphic-p frame)
              (set-face-attribute 'default frame :background bg :foreground fg)
            ;; In terminal mode, let the terminal control bg/fg colors
            (set-face-attribute 'default frame :background 'unspecified :foreground 'unspecified)))
        (when accent
          (set-face-attribute 'cursor frame :background accent))
        (when fg
          (set-frame-parameter frame 'mouse-color fg))

        ;; Selection and highlighting
        (when selection
          (set-face-attribute 'region frame :background selection :foreground 'unspecified))
        (when highlight
          (set-face-attribute 'highlight frame :background highlight :foreground fg))

        ;; Mode line
        (when accent
          (set-face-attribute 'mode-line frame :background accent :foreground (or bg fg) :box nil))
        (when bg
          (set-face-attribute 'mode-line-inactive frame :background (themes--darken-color bg 0.1) :foreground fg :box nil))

        ;; Syntax highlighting
        (when comment
          (set-face-attribute 'font-lock-comment-face frame :foreground comment :slant 'italic))
        (when string
          (set-face-attribute 'font-lock-string-face frame :foreground string))
        (when keyword
          (set-face-attribute 'font-lock-keyword-face frame :foreground keyword :weight 'bold))

        ;; Status colors
        (when warning
          (set-face-attribute 'font-lock-warning-face frame :foreground warning :weight 'bold))
        (when error
          (set-face-attribute 'error frame :foreground error :weight 'bold))
        (when success
          (set-face-attribute 'success frame :foreground success :weight 'bold))

        ;; Window dividers and fringe
        (when bg
          (set-face-attribute 'fringe frame :background bg :foreground (or comment fg))
          (set-face-attribute 'vertical-border frame :foreground (or comment fg)))
        (when (facep 'window-divider)
          (set-face-attribute 'window-divider frame :foreground (or comment fg)))
        (when (facep 'window-divider-first-pixel)
          (set-face-attribute 'window-divider-first-pixel frame :foreground (or comment fg)))
        (when (facep 'window-divider-last-pixel)
          (set-face-attribute 'window-divider-last-pixel frame :foreground (or comment fg))))

      ;; Also set for future frames (nil means default/new frames)
      ;; Only set explicit colors for GUI frames
      (when (and bg fg)
        ;; Set default face - will be overridden for terminal frames when they're created
        (set-face-attribute 'default nil :background bg :foreground fg)
        ;; Only add to default-frame-alist if we're in GUI mode
        ;; Terminal frames will use unspecified bg/fg
        (when (display-graphic-p)
          (setq default-frame-alist
                (cons (cons 'background-color bg)
                      (cons (cons 'foreground-color fg)
                            (cons (cons 'mouse-color fg)
                                  (assq-delete-all 'background-color
                                                   (assq-delete-all 'foreground-color
                                                                    (assq-delete-all 'mouse-color default-frame-alist)))))))))
      (when accent
        (set-face-attribute 'cursor nil :background accent))
      (when selection
        (set-face-attribute 'region nil :background selection :foreground 'unspecified))
      (when highlight
        (set-face-attribute 'highlight nil :background highlight :foreground fg))
      (when accent
        (set-face-attribute 'mode-line nil :background accent :foreground (or bg fg) :box nil))
      (when bg
        (set-face-attribute 'mode-line-inactive nil :background (themes--darken-color bg 0.1) :foreground fg :box nil))
      (when comment
        (set-face-attribute 'font-lock-comment-face nil :foreground comment :slant 'italic))
      (when string
        (set-face-attribute 'font-lock-string-face nil :foreground string))
      (when keyword
        (set-face-attribute 'font-lock-keyword-face nil :foreground keyword :weight 'bold))
      (when warning
        (set-face-attribute 'font-lock-warning-face nil :foreground warning :weight 'bold))
      (when error
        (set-face-attribute 'error nil :foreground error :weight 'bold))
      (when success
        (set-face-attribute 'success nil :foreground success :weight 'bold))

      ;; Window dividers and fringe for future frames
      (when bg
        (set-face-attribute 'fringe nil :background bg :foreground (or comment fg))
        (set-face-attribute 'vertical-border nil :foreground (or comment fg)))
      (when (facep 'window-divider)
        (set-face-attribute 'window-divider nil :foreground (or comment fg)))
      (when (facep 'window-divider-first-pixel)
        (set-face-attribute 'window-divider-first-pixel nil :foreground (or comment fg)))
      (when (facep 'window-divider-last-pixel)
        (set-face-attribute 'window-divider-last-pixel nil :foreground (or comment fg)))

      ;; Force redisplay on all frames - including daemon client frames
      (mapc (lambda (frame)
              (with-selected-frame frame
                (force-window-update)
                (redraw-display)))
            (if (daemonp)
                ;; In daemon mode, only update frames with clients
                (seq-filter (lambda (f) (frame-parameter f 'client)) (frame-list))
              ;; Not in daemon mode, update all frames
              (frame-list)))

      ;; Also explicitly update visible frames
      (when (fboundp 'visible-frame-list)
        (mapc (lambda (frame)
                (with-selected-frame frame
                  (force-window-update)
                  (redraw-display)))
              (visible-frame-list))))))

(defun themes--apply-faces (faces)
  "Apply custom FACES definitions."
  (dolist (face-spec faces)
    (let ((face (car face-spec))
          (attributes (cdr face-spec)))
      (when (facep face)
        (apply #'set-face-attribute face nil attributes)))))

(defun themes--apply-vars (vars)
  "Apply theme VARS (custom variables)."
  (dolist (var-spec vars)
    (let ((var (car var-spec))
          (value (cdr var-spec)))
      (when (boundp var)
        (set var value)))))

(defun themes-load (name &optional no-confirm)
  "Load theme by NAME. If NO-CONFIRM is non-nil, don't prompt for confirmation."
  (interactive (list (intern (completing-read "Theme: " 
                                               (mapcar #'symbol-name (themes-list))
                                               nil t))
                     t)) ; Always pass no-confirm=t for interactive use
  (let ((theme-def (themes-get name)))
    (unless theme-def
      (error "Theme not found: %s" name))
    
    ;; Skip confirmation by default (only confirm if explicitly requested)
    (when (and themes--current-theme 
               (not (eq themes--current-theme name))
               (not no-confirm)
               (not (y-or-n-p (format "Replace current theme '%s' with '%s'? " 
                                      themes--current-theme name))))
      (user-error "Theme loading cancelled"))
    
    ;; Run teardown for current theme
    (when themes--current-theme
      (themes--teardown-current))

    ;; Update state BEFORE applying (important for pywal bridge logic)
    (when themes--current-theme
      (push themes--current-theme themes--theme-history))
    (setq themes--current-theme name)

    ;; Apply colors
    (when (theme-def-colors theme-def)
      (themes--apply-colors (theme-def-colors theme-def)))

    ;; Apply faces
    (when (theme-def-faces theme-def)
      (themes--apply-faces (theme-def-faces theme-def)))
    
    ;; Apply variables
    (when (theme-def-vars theme-def)
      (themes--apply-vars (theme-def-vars theme-def)))
    
    ;; Run setup function
    (when (theme-def-setup-func theme-def)
      (funcall (theme-def-setup-func theme-def)))

    ;; Run hooks
    (dolist (hook themes--hooks)
      (when (functionp hook)
        (condition-case err
            (funcall hook)
          (error
           (message "[themes] Hook failed: %s" (error-message-string err))))))

    (message "Loaded theme: %s" (theme-def-display-name theme-def))))

(defun themes--teardown-current ()
  "Teardown the current theme."
  (when themes--current-theme
    (let ((theme-def (themes-get themes--current-theme)))
      (when (and theme-def (theme-def-teardown-func theme-def))
        (funcall (theme-def-teardown-func theme-def))))))

(defun themes-reload ()
  "Reload the current theme."
  (interactive)
  (when themes--current-theme
    (themes-load themes--current-theme t)))

(defun themes-toggle-previous ()
  "Toggle between current and previous theme."
  (interactive)
  (if themes--theme-history
      (themes-load (car themes--theme-history) t)
    (message "No previous theme to toggle to")))

(defun themes-cycle ()
  "Cycle through available themes."
  (interactive)
  (let* ((themes (themes-list))
         (current-idx (cl-position themes--current-theme themes))
         (next-idx (if current-idx 
                       (mod (1+ current-idx) (length themes))
                     0)))
    (themes-load (nth next-idx themes) t)))

;; Add hooks support
(defun themes-add-hook (func)
  "Add FUNC to theme change hooks."
  (add-to-list 'themes--hooks func))

(defun themes-remove-hook (func)
  "Remove FUNC from theme change hooks."
  (setq themes--hooks (remove func themes--hooks)))

;; Theme info and debugging
(defun themes-current ()
  "Return current theme name."
  themes--current-theme)

(defun themes-info (&optional name)
  "Show information about theme NAME (or current theme)."
  (interactive)
  (let* ((theme-name (or name themes--current-theme))
         (theme-def (themes-get theme-name)))
    (if theme-def
        (with-output-to-temp-buffer "*Theme Info*"
          (princ (format "Theme: %s\n" (theme-def-display-name theme-def)))
          (princ (format "Name: %s\n" (theme-def-name theme-def)))
          (princ (format "Type: %s\n" (theme-def-type theme-def)))
          (when (theme-def-description theme-def)
            (princ (format "Description: %s\n" (theme-def-description theme-def))))
          (when (theme-def-colors theme-def)
            (princ "\nColors:\n")
            (dolist (color (theme-def-colors theme-def))
              (princ (format "  %s: %s\n" (car color) (cdr color))))))
      (message "No theme information available for: %s" theme-name))))

(defun themes-debug ()
  "Show debug information about the theme system."
  (interactive)
  (with-output-to-temp-buffer "*Theme Debug*"
    (princ "=== Theme System Debug Info ===\n\n")
    (princ (format "Current theme: %s\n" (or themes--current-theme "None")))
    (princ (format "Available themes: %s\n" (themes-list)))
    (princ (format "Theme history: %s\n" themes--theme-history))
    (princ (format "Pywal integration enabled: %s\n" themes-enable-pywal-integration))
    (princ (format "Pywal watching: %s\n" (if (boundp 'pywal--watch-descriptor) 
                                               pywal--watch-descriptor "Not loaded")))
    (when (featurep 'pywal-bridge)
      (princ "\n=== Pywal Bridge Status ===\n")
      (princ (format "Bridge active: %s\n" (if pywal-bridge--original-pywal-apply "Yes" "No"))))
    (princ "\n=== Current Face Values ===\n")
    (dolist (face '(default cursor region mode-line font-lock-keyword-face))
      (when (facep face)
        (let ((bg (face-attribute face :background))
              (fg (face-attribute face :foreground)))
          (princ (format "%s: bg=%s fg=%s\n" face bg fg)))))))

;; Function to broadcast theme to all client frames
(defun themes-broadcast-to-clients ()
  "Broadcast current theme to all emacsclient frames."
  (interactive)
  (when themes--current-theme
    (let ((theme-def (themes-get themes--current-theme)))
      (when theme-def
        (message "[themes] Broadcasting theme %s to all frames..." themes--current-theme)
        ;; Reload the theme which will apply to all frames
        (themes-load themes--current-theme t)
        (message "[themes] Broadcast complete")))))

;; Hook to apply theme to new frames (important for emacsclient)
(defun themes--setup-new-frame (frame)
  "Apply current theme colors to a newly created FRAME."
  (when (and themes--current-theme (frame-live-p frame))
    (let ((theme-def (themes-get themes--current-theme)))
      (when theme-def
        ;; For pywal themes, let pywal handle frame setup
        (if (eq (theme-def-type theme-def) 'pywal)
            (progn
              ;; For pywal, apply fresh colors from file
              (when (featurep 'pywal)
                (with-selected-frame frame
                  (pywal-apply-colors)
                  (redraw-frame frame))))
          ;; For static themes, use cached colors
          (let ((colors (theme-def-colors theme-def)))
            (when colors
              (let ((bg (alist-get 'bg colors))
                    (fg (alist-get 'fg colors)))
                (when (and bg fg)
                  (with-selected-frame frame
                    ;; In terminal mode, use unspecified to let terminal control colors
                    (if (display-graphic-p frame)
                        (set-face-attribute 'default frame :background bg :foreground fg)
                      (set-face-attribute 'default frame :background 'unspecified :foreground 'unspecified))
                    (redraw-frame frame)))))))))))

(add-hook 'after-make-frame-functions 'themes--setup-new-frame)

;; Add focus hook to refresh theme when focusing frames
(defun themes--on-focus-in ()
  "Refresh theme when focusing a frame."
  (when (and themes--current-theme (frame-live-p (selected-frame)))
    (let ((theme-def (themes-get themes--current-theme)))
      ;; For pywal themes, don't reapply on focus - pywal handles its own updates
      ;; For other themes, refresh colors on focus
      (when (and theme-def (not (eq (theme-def-type theme-def) 'pywal)))
        (themes--setup-new-frame (selected-frame))))))

(add-hook 'focus-in-hook 'themes--on-focus-in)

(provide 'themes)
;;; themes.el ends here
