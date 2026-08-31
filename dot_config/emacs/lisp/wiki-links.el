;;; wiki-links.el --- Vimwiki-style [[link]] support for markdown -*- lexical-binding: t; -*-

;; Provides vimwiki-style wiki links in markdown files:
;; - [[link]] creates a link to link.md in the current directory
;; - RET in normal mode follows the link (creates if doesn't exist)
;; - Conceals brackets in normal mode with wiki icon

(eval-when-compile (require 'use-package))
(require 'evil nil t)

;;; Configuration Variables

(defvar wiki/icon "📝")  ;; Wiki link icon (different from regular link 🔗)
(defvar wiki/conceal--category 'wiki-conceal)  ;; Our own invisibility category

;;; Link Detection

(defconst wiki/link-regex "\\[\\[\\([^]\n|]+\\)\\(?:|\\([^]\n]+\\)\\)?\\]\\]"
  "Regex to match wiki links.
Captures:
  Group 1: link target (required)
  Group 2: display text (optional, after |)")

(defun wiki/link-at-point ()
  "Return (TARGET DISPLAY-TEXT START END) if point is on a wiki link, else nil.
TARGET is the file to link to (without .md extension).
DISPLAY-TEXT is the optional display text after |, or nil."
  (save-excursion
    (let ((orig-point (point))
          (line-start (line-beginning-position))
          (line-end (line-end-position)))
      ;; Search for wiki link on current line
      (goto-char line-start)
      (catch 'found
        (while (re-search-forward wiki/link-regex line-end t)
          (let ((start (match-beginning 0))
                (end (match-end 0))
                (target (match-string 1))
                (display (match-string 2)))
            (when (and (>= orig-point start) (< orig-point end))
              (throw 'found (list target display start end)))))
        nil))))

;;; Link Following

(defun wiki/follow-link ()
  "Follow wiki link at point. Create file if it doesn't exist.
Supports folder paths like [[folder/page]] or [[folder/page.md]]."
  (interactive)
  (if-let ((link-info (wiki/link-at-point)))
      (let* ((target (nth 0 link-info))
             ;; Add .md extension if not present
             (file-name (if (string-suffix-p ".md" target)
                           target
                         (concat target ".md")))
             ;; Expand relative to current directory
             (file-path (expand-file-name file-name default-directory))
             ;; Extract directory part
             (dir (file-name-directory file-path))
             (existed (file-exists-p file-path)))
        ;; Create directory if it doesn't exist
        (when (and dir (not (file-directory-p dir)))
          (make-directory dir t)
          (message "Created directory: %s" dir))
        ;; Open/create the file
        (find-file file-path)
        (unless existed
          (message "Created new wiki page: %s" file-name)))
    (message "No wiki link at point")))

;;; Concealment (Normal mode only)

(defun wiki/in-normal-state-p ()
  "Check if we're in evil normal state."
  (and (boundp 'evil-local-mode) evil-local-mode
       (boundp 'evil-state) (eq evil-state 'normal)))

(defun wiki/conceal--clear-all ()
  "Remove all wiki link overlays and invisibility."
  ;; Clear icon overlays
  (remove-overlays (point-min) (point-max) 'wiki/icon t)
  ;; Clear invisibility properties
  (let ((inhibit-read-only t))
    (remove-text-properties (point-min) (point-max) '(invisible nil))))

(defun wiki/conceal--apply-all ()
  "Apply concealment to all wiki links in the buffer."
  (when (wiki/in-normal-state-p)
    (wiki/conceal--clear-all)
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward wiki/link-regex nil t)
        (wiki/conceal--apply-to-link)))))

(defun wiki/conceal--apply-to-link ()
  "Apply concealment to the wiki link at match.
For paths like [[folder/file]], shows only the filename in normal mode."
  (let* ((whole-start (match-beginning 0))
         (whole-end (match-end 0))
         (target-start (match-beginning 1))
         (target-end (match-end 1))
         (display-start (match-beginning 2))
         (display-end (match-end 2))
         (target (match-string 1)))

    (if display-start
        ;; [[target|display]] - show only display text with icon
        (progn
          ;; Hide opening [[
          (let ((ov (make-overlay whole-start (+ whole-start 2))))
            (overlay-put ov 'wiki/icon t)
            (overlay-put ov 'invisible 'wiki-conceal))
          ;; Hide target
          (let ((ov (make-overlay target-start target-end)))
            (overlay-put ov 'wiki/icon t)
            (overlay-put ov 'invisible 'wiki-conceal))
          ;; Hide | separator
          (let ((ov (make-overlay (- display-start 1) display-start)))
            (overlay-put ov 'wiki/icon t)
            (overlay-put ov 'invisible 'wiki-conceal))
          ;; Hide closing ]]
          (let ((ov (make-overlay (- whole-end 2) whole-end)))
            (overlay-put ov 'wiki/icon t)
            (overlay-put ov 'invisible 'wiki-conceal))
          ;; Add icon before display text
          (let ((ov (make-overlay display-start display-start))
                (icon-str (propertize (concat wiki/icon " ") 'face 'default)))
            (overlay-put ov 'wiki/icon t)
            (overlay-put ov 'before-string icon-str)))

      ;; [[target]] - show filename only (hide path) with icon
      (progn
        ;; Hide opening [[
        (let ((ov (make-overlay whole-start (+ whole-start 2))))
          (overlay-put ov 'wiki/icon t)
          (overlay-put ov 'invisible 'wiki-conceal))
        ;; Hide closing ]]
        (let ((ov (make-overlay (- whole-end 2) whole-end)))
          (overlay-put ov 'wiki/icon t)
          (overlay-put ov 'invisible 'wiki-conceal))

        ;; Check if target contains a path (has /)
        (if (string-match-p "/" target)
            (let* ((filename (file-name-nondirectory target))
                   (path-end-pos (- target-end (length filename))))
              ;; Hide the path part (everything before the filename)
              (when (> path-end-pos target-start)
                (let ((ov (make-overlay target-start path-end-pos)))
                  (overlay-put ov 'wiki/icon t)
                  (overlay-put ov 'invisible 'wiki-conceal)))
              ;; Add icon before the filename
              (let ((ov (make-overlay path-end-pos path-end-pos))
                    (icon-str (propertize (concat wiki/icon " ") 'face 'default)))
                (overlay-put ov 'wiki/icon t)
                (overlay-put ov 'before-string icon-str)))
          ;; No path - just add icon before target
          (let ((ov (make-overlay target-start target-start))
                (icon-str (propertize (concat wiki/icon " ") 'face 'default)))
            (overlay-put ov 'wiki/icon t)
            (overlay-put ov 'before-string icon-str)))))))

(defun wiki/conceal--on-normal-entry ()
  "Apply concealment when entering normal mode."
  (when (derived-mode-p 'markdown-mode 'markdown-ts-mode)
    (add-to-invisibility-spec 'wiki-conceal)
    (wiki/conceal--apply-all)))

(defun wiki/conceal--on-insert-entry ()
  "Clear concealment when entering insert mode."
  (when (derived-mode-p 'markdown-mode 'markdown-ts-mode)
    (wiki/conceal--clear-all)
    (remove-from-invisibility-spec 'wiki-conceal)))

;;; Minor Mode

(defvar wiki/links-mode-map
  (let ((map (make-sparse-keymap)))
    map)
  "Keymap for `wiki/links-mode'.")

(define-minor-mode wiki/links-mode
  "Enable vimwiki-style [[link]] support in markdown."
  :init-value nil
  :lighter " Wiki"
  :keymap wiki/links-mode-map
  (if wiki/links-mode
      (progn
        ;; Hook into evil state changes
        (add-hook 'evil-normal-state-entry-hook #'wiki/conceal--on-normal-entry nil t)
        (add-hook 'evil-insert-state-entry-hook #'wiki/conceal--on-insert-entry nil t)

        ;; Bind RET in evil normal and visual states
        (when (and (boundp 'evil-local-mode) evil-local-mode)
          (evil-define-key 'normal wiki/links-mode-map
            (kbd "RET") #'wiki/follow-link-or-default)
          (evil-define-key 'visual wiki/links-mode-map
            (kbd "RET") #'wiki/follow-link-or-default))

        ;; Apply concealment if already in normal mode
        (when (wiki/in-normal-state-p)
          (wiki/conceal--on-normal-entry)))

    ;; Disable
    (remove-hook 'evil-normal-state-entry-hook #'wiki/conceal--on-normal-entry t)
    (remove-hook 'evil-insert-state-entry-hook #'wiki/conceal--on-insert-entry t)
    (wiki/conceal--clear-all)))

;;; Word Linkification

(defun wiki/word-at-point ()
  "Return (WORD START END) if point is on a word, else nil."
  (let ((bounds (bounds-of-thing-at-point 'word)))
    (when bounds
      (list (buffer-substring-no-properties (car bounds) (cdr bounds))
            (car bounds)
            (cdr bounds)))))

(defun wiki/visual-selection ()
  "Return (TEXT START END) if there's an active visual selection, else nil."
  (when (and (boundp 'evil-local-mode) evil-local-mode
             (eq evil-state 'visual)
             (region-active-p))
    (let ((start (region-beginning))
          (end (region-end)))
      (list (buffer-substring-no-properties start end)
            start
            end))))

(defun wiki/linkify-text-and-follow (text start end)
  "Convert TEXT between START and END to [[text]] and follow it.
Handles folder paths if TEXT contains slashes."
  (let* (;; Trim whitespace and newlines from text
         (clean-text (string-trim text))
         ;; Add .md extension if not present
         (file-name (if (string-suffix-p ".md" clean-text)
                       clean-text
                     (concat clean-text ".md")))
         ;; Expand relative to current directory
         (file-path (expand-file-name file-name default-directory))
         ;; Extract directory part
         (dir (file-name-directory file-path))
         (existed (file-exists-p file-path)))
    ;; Replace text with [[clean-text]]
    (save-excursion
      (goto-char start)
      (delete-region start end)
      (insert "[[" clean-text "]]"))
    ;; Reapply concealment to update display
    (wiki/conceal--apply-all)
    ;; Create directory if it doesn't exist
    (when (and dir (not (file-directory-p dir)))
      (make-directory dir t)
      (message "Created directory: %s" dir))
    ;; Follow the link
    (find-file file-path)
    (unless existed
      (message "Created new wiki page: %s" file-name))))

(defun wiki/linkify-word-and-follow ()
  "Convert word at point to [[word]] and follow it."
  (interactive)
  (when-let ((word-info (wiki/word-at-point)))
    (let ((word (nth 0 word-info))
          (start (nth 1 word-info))
          (end (nth 2 word-info)))
      (wiki/linkify-text-and-follow word start end))))

(defun wiki/linkify-selection-and-follow ()
  "Convert visual selection to [[selection]] and follow it."
  (interactive)
  (when-let ((sel-info (wiki/visual-selection)))
    (let ((text (nth 0 sel-info))
          (start (nth 1 sel-info))
          (end (nth 2 sel-info)))
      ;; Exit visual mode first
      (evil-normal-state)
      (wiki/linkify-text-and-follow text start end))))

;;; Smart RET Handler

(defun wiki/follow-link-or-default ()
  "Follow wiki link at point, linkify word/selection at point, or fall back to default RET behavior."
  (interactive)
  (cond
   ;; Visual selection - linkify and follow
   ((wiki/visual-selection)
    (wiki/linkify-selection-and-follow))
   ;; On a wiki link - follow it
   ((wiki/link-at-point)
    (wiki/follow-link))
   ;; On a word - linkify and follow
   ((wiki/word-at-point)
    (wiki/linkify-word-and-follow))
   ;; Otherwise - default behavior
   (t
    (evil-ret))))

;;; Integration with Markdown Mode

(defun wiki/enable-for-markdown ()
  "Enable wiki links mode in markdown buffers."
  (when (derived-mode-p 'markdown-mode 'markdown-ts-mode)
    (wiki/links-mode 1)))

;; Auto-enable in markdown buffers
(add-hook 'markdown-mode-hook #'wiki/enable-for-markdown)
(when (fboundp 'markdown-ts-mode)
  (add-hook 'markdown-ts-mode-hook #'wiki/enable-for-markdown))

;;; Leader Key Bindings

(with-eval-after-load 'helpers
  (when (fboundp 'my/leader-keys)
    (my/leader-keys
      "ml" '(wiki/follow-link :which-key "follow wiki link"))))

(provide 'wiki-links)
;;; wiki-links.el ends here
