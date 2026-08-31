;;; pywal.el --- Load & watch Pywal colors (debounced) -*- lexical-binding: t; -*-
;;; Created with stolen stuff from Github, gitlab, with fixing from Claude and ChatGPT
;;; Therefore janky af, use at your own risk.

(require 'json)
(require 'cl-lib)
(require 'filenotify)

(defvar pywal-cache-dir
  (or (getenv "XDG_CACHE_HOME")
      (expand-file-name "~/.cache"))
  "Where Pywal writes its cache.")

(defvar pywal-colors-json
  (expand-file-name "wal/colors.json" pywal-cache-dir)
  "Full path to Pywal's colors.json.")

(defvar pywal--watch-descriptor nil
  "File-notify watch descriptor for `pywal-colors-json`.")

(defvar pywal--reload-timer nil
  "Pending debounce timer for reloading Pywal colors.")

(defvar pywal-reload-delay 0.25
  "Seconds to debounce Pywal reloads after a file change.")

;; ---------- helpers ----------

(defun pywal--read-colors ()
  "Return parsed colors.json as an alist, or nil on failure."
  (when (file-readable-p pywal-colors-json)
    (condition-case err
        (with-temp-buffer
          (insert-file-contents pywal-colors-json)
          (let ((json-object-type 'alist)
                (json-key-type 'string)
                (json-array-type 'list))
            (json-read)))
      (error
       (message "[pywal] Failed to read JSON: %s" (error-message-string err))
       nil))))

(defun pywal--alist-get* (alist &rest keys)
  "Get nested KEYS from ALIST of string keys."
  (let ((cur alist))
    (while (and cur keys)
      (setq cur (alist-get (pop keys) cur nil nil #'string=)))
    cur))

;; ---------- apply ----------

(defun pywal-apply-colors ()
  "Apply Pywal colors to comprehensive set of faces."
  (interactive)
  (condition-case err
      (let* ((data   (pywal--read-colors))
             (spec   (pywal--alist-get* data "special"))
             (colors (pywal--alist-get* data "colors"))
             ;; Extract colors
             (bg     (or (pywal--alist-get* spec "background")
                         (pywal--alist-get* colors "color0")))
             (fg     (or (pywal--alist-get* spec "foreground")
                         (pywal--alist-get* colors "color7")))
             (cursor (or (pywal--alist-get* spec "cursor")
                         (pywal--alist-get* colors "color1")))
             ;; Color palette
             (color1 (pywal--alist-get* colors "color1"))  ; red
             (color2 (pywal--alist-get* colors "color2"))  ; green
             (color3 (pywal--alist-get* colors "color3"))  ; yellow
             (color4 (pywal--alist-get* colors "color4"))  ; blue
             (color5 (pywal--alist-get* colors "color5"))  ; magenta
             (color6 (pywal--alist-get* colors "color6"))  ; cyan
             (color8 (pywal--alist-get* colors "color8"))  ; bright black
             (color9 (pywal--alist-get* colors "color9"))  ; bright red
             (color10 (pywal--alist-get* colors "color10")) ; bright green
             (color11 (pywal--alist-get* colors "color11")) ; bright yellow
             (color12 (pywal--alist-get* colors "color12")) ; bright blue
             (color13 (pywal--alist-get* colors "color13")) ; bright magenta
             (color14 (pywal--alist-get* colors "color14")) ; bright cyan
             (color15 (pywal--alist-get* colors "color15")) ; bright white
             ;; Derived colors
             (accent (or color4 color2))
             (highlight-bg (or color8 accent))
             (region-bg (or color8 accent))
             (comment-fg (or color8 color3)))

        (when (and bg fg)
          ;; Core faces - apply to all frames
          (dolist (frame (frame-list))
            (set-face-attribute 'default frame :background bg :foreground fg)
            (set-face-attribute 'cursor frame :background (or cursor accent fg)))
          ;; Also set for new/future frames
          (set-face-attribute 'default nil :background bg :foreground fg)
          (set-face-attribute 'cursor nil :background (or cursor accent fg))
          
          ;; Selection and highlighting
          (set-face-attribute 'region nil :background region-bg :foreground nil)
          (set-face-attribute 'secondary-selection nil :background (or color8 color1))
          (set-face-attribute 'highlight nil :background highlight-bg :foreground bg)
          (set-face-attribute 'lazy-highlight nil :background (or color3 color11) :foreground bg)
          
          ;; Search
          (when (facep 'isearch)
            (set-face-attribute 'isearch nil :background (or color3 color11) :foreground bg :weight 'bold))
          (when (facep 'isearch-fail)
            (set-face-attribute 'isearch-fail nil :background (or color1 color9) :foreground fg))
          
          ;; Mode line
          (set-face-attribute 'mode-line nil :background accent :foreground (or bg fg) :box nil)
          (set-face-attribute 'mode-line-inactive nil :background (or color8 bg) :foreground fg :box nil)
          
          ;; Minibuffer
          (when (facep 'minibuffer-prompt)
            (set-face-attribute 'minibuffer-prompt nil :foreground (or color4 color12 accent) :weight 'bold))
          
          ;; Links
          (set-face-attribute 'link nil :foreground (or color4 color12) :underline t)
          (set-face-attribute 'link-visited nil :foreground (or color5 color13))
          
          ;; Font lock (syntax highlighting)
          (when (facep 'font-lock-comment-face)
            (set-face-attribute 'font-lock-comment-face nil :foreground comment-fg :slant 'italic))
          (when (facep 'font-lock-comment-delimiter-face)
            (set-face-attribute 'font-lock-comment-delimiter-face nil :foreground comment-fg))
          (when (facep 'font-lock-string-face)
            (set-face-attribute 'font-lock-string-face nil :foreground (or color2 color10)))
          (when (facep 'font-lock-keyword-face)
            (set-face-attribute 'font-lock-keyword-face nil :foreground (or color5 color13) :weight 'bold))
          (when (facep 'font-lock-builtin-face)
            (set-face-attribute 'font-lock-builtin-face nil :foreground (or color4 color12)))
          (when (facep 'font-lock-function-name-face)
            (set-face-attribute 'font-lock-function-name-face nil :foreground (or color4 color12) :weight 'bold))
          (when (facep 'font-lock-variable-name-face)
            (set-face-attribute 'font-lock-variable-name-face nil :foreground (or color3 color11)))
          (when (facep 'font-lock-type-face)
            (set-face-attribute 'font-lock-type-face nil :foreground (or color6 color14)))
          (when (facep 'font-lock-constant-face)
            (set-face-attribute 'font-lock-constant-face nil :foreground (or color1 color9)))
          (when (facep 'font-lock-warning-face)
            (set-face-attribute 'font-lock-warning-face nil :foreground (or color1 color9) :weight 'bold))
          
          ;; Line numbers (if using display-line-numbers-mode)
          (when (facep 'line-number)
            (set-face-attribute 'line-number nil :foreground (or color8 comment-fg) :background bg))
          (when (facep 'line-number-current-line)
            (set-face-attribute 'line-number-current-line nil :foreground fg :background bg :weight 'bold))
          
          ;; Fringe and window dividers
          (set-face-attribute 'fringe nil :background bg :foreground (or color8 comment-fg))
          (set-face-attribute 'vertical-border nil :foreground (or color8 comment-fg))
          (when (facep 'window-divider)
            (set-face-attribute 'window-divider nil :foreground (or color8 comment-fg)))
          (when (facep 'window-divider-first-pixel)
            (set-face-attribute 'window-divider-first-pixel nil :foreground (or color8 comment-fg)))
          (when (facep 'window-divider-last-pixel)
            (set-face-attribute 'window-divider-last-pixel nil :foreground (or color8 comment-fg)))

          ;; Tab bar (works with vim-tab-bar wrapper)
          (when (facep 'tab-bar)
            (set-face-attribute 'tab-bar nil :background bg :foreground fg :box nil))
          (when (facep 'tab-bar-tab)
            (set-face-attribute 'tab-bar-tab nil :background accent :foreground bg :weight 'bold :box nil))
          (when (facep 'tab-bar-tab-inactive)
            (set-face-attribute 'tab-bar-tab-inactive nil :background bg :foreground fg :box nil))
          
          ;; Completions
          (when (facep 'completions-annotations)
            (set-face-attribute 'completions-annotations nil :foreground (or color8 comment-fg)))
          (when (facep 'completions-common-part)
            (set-face-attribute 'completions-common-part nil :foreground (or color4 color12) :weight 'bold))
          (when (facep 'completions-first-difference)
            (set-face-attribute 'completions-first-difference nil :foreground (or color3 color11) :weight 'bold))
          
          ;; Show paren mode
          (when (facep 'show-paren-match)
            (set-face-attribute 'show-paren-match nil :background (or color2 color10) :foreground bg :weight 'bold))
          (when (facep 'show-paren-mismatch)
            (set-face-attribute 'show-paren-mismatch nil :background (or color1 color9) :foreground bg :weight 'bold))
          
          ;; Org mode basics (if loaded)
          (when (facep 'org-level-1)
            (set-face-attribute 'org-level-1 nil :foreground (or color1 color9) :weight 'bold :height 1.3))
          (when (facep 'org-level-2)
            (set-face-attribute 'org-level-2 nil :foreground (or color2 color10) :weight 'bold :height 1.2))
          (when (facep 'org-level-3)
            (set-face-attribute 'org-level-3 nil :foreground (or color3 color11) :weight 'bold :height 1.1))
          (when (facep 'org-level-4)
            (set-face-attribute 'org-level-4 nil :foreground (or color4 color12) :weight 'bold))
          
          ;; Dired
          (when (facep 'dired-directory)
            (set-face-attribute 'dired-directory nil :foreground (or color4 color12) :weight 'bold))
          (when (facep 'dired-symlink)
            (set-face-attribute 'dired-symlink nil :foreground (or color6 color14)))
          (when (facep 'dired-executable)
            (set-face-attribute 'dired-executable nil :foreground (or color2 color10)))

          ;; Force redisplay on all frames
          (dolist (frame (frame-list))
            (with-selected-frame frame
              (redraw-frame frame)))

          (message "[pywal] Applied comprehensive color scheme.")))
    (error
     (message "[pywal] Failed to apply colors: %s" (error-message-string err)))))

(defun reload-pywal ()
  "Reload Pywal colors now (cancels any pending debounce)."
  (interactive)
  (when (timerp pywal--reload-timer)
    (cancel-timer pywal--reload-timer)
    (setq pywal--reload-timer nil))
  (pywal-apply-colors)
  (message "[pywal] Colors reloaded."))

(defun pywal--schedule-reload ()
  "Debounced schedule of `reload-pywal`."
  (when (timerp pywal--reload-timer)
    (cancel-timer pywal--reload-timer))
  (setq pywal--reload-timer
        (run-with-timer pywal-reload-delay nil
                        (lambda ()
                          (setq pywal--reload-timer nil)
                          (reload-pywal)))))

;; ---------- watch ----------

(defun pywal-start-watching ()
  "Watch `pywal-colors-json` for changes and auto-reload (debounced)."
  (interactive)
  (when pywal--watch-descriptor
    (pywal-stop-watching))
  (if (and (featurep 'filenotify) (file-exists-p pywal-colors-json))
      (setq pywal--watch-descriptor
            (file-notify-add-watch
             pywal-colors-json
             '(change attribute-change)
             (lambda (_event)
               ;; Many backends fire multiple events; debounce them.
               (pywal--schedule-reload))))
    (message "[pywal] Watch not started (filenotify unavailable or file missing).")))

(defun pywal-stop-watching ()
  "Stop watching `pywal-colors-json`."
  (interactive)
  (when pywal--watch-descriptor
    (file-notify-rm-watch pywal--watch-descriptor)
    (setq pywal--watch-descriptor nil)))

;; ---------- debug ----------

(defun pywal-debug-colors ()
  "Show current pywal colors for debugging."
  (interactive)
  (let ((data (pywal--read-colors)))
    (if data
        (with-output-to-temp-buffer "*Pywal Colors*"
          (princ "Pywal Colors Debug:\n\n")
          (princ (format "Colors file: %s\n\n" pywal-colors-json))
          (dolist (section '("special" "colors"))
            (let ((sec-data (pywal--alist-get* data section)))
              (when sec-data
                (princ (format "%s:\n" (capitalize section)))
                (dolist (item sec-data)
                  (princ (format "  %s: %s\n" (car item) (cdr item))))
                (princ "\n")))))
      (message "[pywal] No color data found or failed to read colors.json"))))

;; ---------- init ----------

;; Note: Auto-startup moved to theme system integration
;; The pywal-bridge will handle initialization and watching
;; to avoid conflicts with other themes

;; Legacy auto-startup (disabled when theme system is available)
(add-hook 'emacs-startup-hook
          (lambda ()
            ;; Only auto-start if theme system is not available
            (unless (featurep 'themes)
              (pywal-apply-colors)
              (pywal-start-watching))))

(provide 'pywal)
;;; pywal.el ends here
