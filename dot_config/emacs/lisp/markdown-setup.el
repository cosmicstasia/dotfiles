;;; markdown-setup.el --- Markdown configuration -*- lexical-binding: t; -*-

(eval-when-compile (require 'use-package))

(defvar md/icon-link  "🔗") ;; Link icon
(defvar md/icon-image "🖼") ;; Image icon

(defvar md/conceal--category 'md-conceal)

;; Table box-drawing characters
(defconst md/table-chars
  '((top-left     . ?┌)
    (top-right    . ?┐)
    (bottom-left  . ?└)
    (bottom-right . ?┘)
    (horizontal   . ?─)
    (vertical     . ?│)
    (cross        . ?┼)
    (t-down       . ?┬)
    (t-up         . ?┴)
    (t-right      . ?├)
    (t-left       . ?┤)))

(defun md/conceal--hide (beg end)
  "Hide region BEG..END using our invisibility category."
  (when (< beg end)
    (add-text-properties beg end `(invisible ,md/conceal--category))))

(defun md/conceal--ensure-spec () (add-to-invisibility-spec md/conceal--category))

(defun md/conceal--unhide-buffer ()
  "Remove our conceal from the buffer and clear our icon overlays."
  (remove-overlays (point-min) (point-max) 'md/icon t)
  (remove-overlays (point-min) (point-max) 'md/table t)
  (remove-overlays (point-min) (point-max) 'md/checkbox t)
  (let ((pos (point-min)))
    (while (< pos (point-max))
      (let ((next (next-single-property-change pos 'invisible nil (point-max))))
        (when (eq (get-text-property pos 'invisible) md/conceal--category)
          (remove-text-properties pos next '(invisible nil)))
        (setq pos next))))
  (when (member md/conceal--category buffer-invisibility-spec)
    (remove-from-invisibility-spec md/conceal--category)))

(defun md/pretty-fontlock-keywords ()
  `(
    ;; Bullets: -, *, + -> •
    ("^\\s-*\\([-*+]\\)\\s-"
     (1 (prog1 nil (compose-region (match-beginning 1) (match-end 1) ?•))))
    ;; Checkboxes: [ ] ☐, [x] ☑, [-] ☑
    ("^\\s-*[-*+]\\s-+\\(\\[ \\]\\)"
     (1 (prog1 nil (compose-region (match-beginning 1) (match-end 1) ?☐))))
    ("^\\s-*[-*+]\\s-+\\(\\[[xX]\\]\\)"
     (1 (prog1 nil (compose-region (match-beginning 1) (match-end 1) ?☑))))
    ("^\\s-*[-*+]\\s-+\\(\\[-\\]\\)"
     (1 (prog1 nil (compose-region (match-beginning 1) (match-end 1) ?☑))))
    ))

(defun md/enable-pretty-lists ()
  (prettify-symbols-mode 1)
  (font-lock-add-keywords nil (md/pretty-fontlock-keywords) 'append)
  (font-lock-flush) (font-lock-ensure))

;; Header styling
(defun md/setup-header-faces ()
  "Set up markdown header faces with appropriate font sizes."
  ;; Header 1 - Largest
  (when (facep 'markdown-header-face-1)
    (set-face-attribute 'markdown-header-face-1 nil 
                        :height 1.6 
                        :weight 'bold 
                        :foreground nil  ; Use default or theme color
                        :inherit 'markdown-header-face))
  
  ;; Header 2
  (when (facep 'markdown-header-face-2)
    (set-face-attribute 'markdown-header-face-2 nil 
                        :height 1.4 
                        :weight 'bold 
                        :foreground nil
                        :inherit 'markdown-header-face))
  
  ;; Header 3
  (when (facep 'markdown-header-face-3)
    (set-face-attribute 'markdown-header-face-3 nil 
                        :height 1.3 
                        :weight 'bold 
                        :foreground nil
                        :inherit 'markdown-header-face))
  
  ;; Header 4
  (when (facep 'markdown-header-face-4)
    (set-face-attribute 'markdown-header-face-4 nil 
                        :height 1.2 
                        :weight 'bold 
                        :foreground nil
                        :inherit 'markdown-header-face))
  
  ;; Header 5
  (when (facep 'markdown-header-face-5)
    (set-face-attribute 'markdown-header-face-5 nil 
                        :height 1.1 
                        :weight 'bold 
                        :foreground nil
                        :inherit 'markdown-header-face))
  
  ;; Header 6 - Same size as body but bold
  (when (facep 'markdown-header-face-6)
    (set-face-attribute 'markdown-header-face-6 nil 
                        :height 1.0 
                        :weight 'bold 
                        :foreground nil
                        :inherit 'markdown-header-face)))

(defun md/in-normal-state-p ()
  (and (boundp 'evil-local-mode) evil-local-mode
       (boundp 'evil-state) (eq evil-state 'normal)))

(defun md/link--clear-icons () (remove-overlays (point-min) (point-max) 'md/icon t))

;; for images, !
;; Regex with captured delimiters:
;; 1: '!' (optional), 2: '[', 3: title, 4: ']', 5: '(', 6: url, 7: ')'
(defconst md/link--rx "\\(!\\)?\\(\\[\\)\\([^]\n]+\\)\\(\\]\\)\\((\\)\\([^)\n]+\\)\\()\\)")

(defun md/link--apply-invisibilities ()
  (md/conceal--ensure-spec)
  (let* ((is-image (match-beginning 1))
         (open-br   (match-beginning 2))
         (title-beg (match-beginning 3))
         (title-end (match-end 3))
         (close-br  (match-beginning 4))
         (open-par  (match-beginning 5))
         (url-beg   (match-beginning 6))
         (url-end   (match-end 6))
         (close-par (match-beginning 7)))
    (remove-overlays (match-beginning 0) (match-end 0) 'md/icon t)
    (remove-overlays title-beg title-beg 'md/icon t)
    (when is-image (md/conceal--hide (match-beginning 1) (match-end 1))) ; '!'
    (md/conceal--hide open-br (1+ open-br))                               ; '['
    (md/conceal--hide close-br (1+ close-br))                             ; ']'
    (md/conceal--hide open-par (1+ open-par))                             ; '('
    (md/conceal--hide url-beg url-end)                                    ; URL
    (md/conceal--hide close-par (1+ close-par))                           ; ')'
    (let* ((icon (if is-image md/icon-image md/icon-link))
           (ov   (make-overlay title-beg title-beg))
           (icon-str (propertize (concat icon " ") 'face 'default)))
      (overlay-put ov 'md/icon t)
      (overlay-put ov 'before-string icon-str))))

(defun md/link--fontlock-matcher (limit)
  (when (md/in-normal-state-p)
    (when (re-search-forward md/link--rx limit t)
      (save-excursion (md/link--apply-invisibilities))
      (match-end 0))))

(defconst md/link--fontlock-spec
  '((md/link--fontlock-matcher (0 (progn nil)))))

(defun md/link--enable ()
  (unless (bound-and-true-p md/link--keywords-installed)
    (font-lock-add-keywords nil md/link--fontlock-spec 'append)
    (setq-local md/link--keywords-installed t))
  (font-lock-flush) (font-lock-ensure))

(defun md/link--disable ()
  (when (bound-and-true-p md/link--keywords-installed)
    (font-lock-remove-keywords nil md/link--fontlock-spec)
    (kill-local-variable 'md/link--keywords-installed))
  (md/conceal--unhide-buffer)
  (font-lock-flush) (font-lock-ensure))

;; ─────────────────────────────────────────────────────────────────────────────
;; Checkbox formatting
;; ─────────────────────────────────────────────────────────────────────────────

(defun md/checkbox--clear-overlays ()
  "Remove all checkbox overlays."
  (remove-overlays (point-min) (point-max) 'md/checkbox t))

(defun md/checkbox--position-cursor-inside ()
  "If cursor is on a checkbox opening bracket, move inside on insert mode entry."
  (when (and (looking-at "\\[[ xX-]\\]")
             (eq (char-after) ?\[))
    (forward-char 1)))

(defun md/checkbox--format-all ()
  "Format all checkboxes in the buffer."
  (when (md/in-normal-state-p)
    (save-excursion
      (goto-char (point-min))
      ;; Match [ ], [x], [X], or [-] with or without bullet points
      ;; Matches both "- [ ] task" and "[ ] task"
      (while (re-search-forward "^\\s-*\\(?:[-*+]\\s-+\\)?\\(\\[[ xX-]\\]\\)" nil t)
        (let* ((checkbox-start (match-beginning 1))
               (checkbox-end (match-end 1))
               (checkbox-text (match-string 1))
               (display-char (cond
                              ((string-match-p "\\[[ ]\\]" checkbox-text) "☐")
                              ((string-match-p "\\[[xX]\\]" checkbox-text) "☑")
                              ((string-match-p "\\[-\\]" checkbox-text) "☑")))
               (ov (make-overlay checkbox-start checkbox-end)))
          (overlay-put ov 'md/checkbox t)
          (overlay-put ov 'display display-char)
          (overlay-put ov 'evaporate t))))))

(defun md/checkbox--enable ()
  "Enable checkbox formatting."
  (md/checkbox--format-all))

(defun md/checkbox--disable ()
  "Disable checkbox formatting."
  (md/checkbox--clear-overlays))

(defun md/checkbox--refresh ()
  "Refresh checkbox formatting in the buffer."
  (when (derived-mode-p 'markdown-mode 'markdown-ts-mode)
    (md/checkbox--clear-overlays)
    (md/checkbox--format-all)))

(defun md/checkbox--on-insert-entry ()
  "Clear overlays and position cursor when entering insert mode."
  (md/checkbox--position-cursor-inside)
  (md/checkbox--clear-overlays))

(define-minor-mode md/markdown-checkbox-mode
  "Format markdown checkboxes with symbols in Normal mode."
  :init-value t :lighter ""
  (if md/markdown-checkbox-mode
      (progn
        (md/checkbox--enable)
        (add-hook 'evil-normal-state-entry-hook #'md/checkbox--refresh nil t)
        (add-hook 'evil-insert-state-entry-hook #'md/checkbox--on-insert-entry nil t)
        (when (md/in-normal-state-p) (md/checkbox--refresh)))
    (remove-hook 'evil-normal-state-entry-hook #'md/checkbox--refresh t)
    (remove-hook 'evil-insert-state-entry-hook #'md/checkbox--on-insert-entry t)
    (md/checkbox--disable)))

;; ─────────────────────────────────────────────────────────────────────────────
;; Table formatting
;; ─────────────────────────────────────────────────────────────────────────────

(defun md/table--clear-overlays ()
  "Remove all table overlays."
  (remove-overlays (point-min) (point-max) 'md/table t))

(defun md/table--parse-cell (str)
  "Parse a table cell, stripping whitespace."
  (string-trim str))

(defun md/table--split-row (line)
  "Split a table row LINE into cells."
  (let* ((trimmed (string-trim line))
         ;; Remove leading pipe if present
         (without-leading (if (string-prefix-p "|" trimmed)
                              (substring trimmed 1)
                            trimmed))
         ;; Remove trailing pipe if present
         (without-edges (if (string-suffix-p "|" without-leading)
                            (substring without-leading 0 -1)
                          without-leading)))
    (mapcar #'md/table--parse-cell (split-string without-edges "|"))))

(defun md/table--is-separator-row-p (line)
  "Check if LINE is a separator row (e.g., |---|---|)."
  (string-match-p "^\\s-*|?\\s-*[-:]+\\s-*\\(|\\s-*[-:]+\\s-*\\)*|?\\s-*$" line))

(defun md/table--find-table-at-point ()
  "Find the markdown table at point. Returns (START END ROWS) or nil."
  (save-excursion
    (let ((orig-line (line-number-at-pos))
          start end rows)
      ;; Move to beginning of table
      (beginning-of-line)
      (while (and (not (bobp))
                  (looking-at "^\\s-*|"))
        (forward-line -1))
      (unless (looking-at "^\\s-*|")
        (forward-line 1))
      (setq start (point))

      ;; Collect all table rows (with or without trailing |)
      (while (and (not (eobp))
                  (looking-at "^\\s-*|.*$"))
        (let ((line (match-string 0)))
          (push line rows))
        (forward-line 1))
      (setq end (point))
      (setq rows (nreverse rows))

      (when (and rows (>= (length rows) 2))
        (list start end rows)))))

(defun md/table--calculate-widths (rows)
  "Calculate column widths for ROWS, excluding separator rows."
  (let ((widths '())
        (ncols 0))
    (dolist (row rows)
      (unless (md/table--is-separator-row-p row)
        (let ((cells (md/table--split-row row)))
          (setq ncols (max ncols (length cells)))
          (dotimes (i (length cells))
            (let ((cell-width (length (nth i cells))))
              (while (<= (length widths) i)
                (setq widths (append widths '(0))))
              (setf (nth i widths) (max (nth i widths) cell-width)))))))
    widths))

(defun md/table--format-table (rows widths)
  "Format table ROWS with column WIDTHS using box-drawing characters."
  (let* ((chars md/table-chars)
         (ncols (length widths))
         (top-line (concat (char-to-string (alist-get 'top-left chars))
                           (mapconcat (lambda (w)
                                        (make-string (+ w 2) (alist-get 'horizontal chars)))
                                      widths
                                      (char-to-string (alist-get 't-down chars)))
                           (char-to-string (alist-get 'top-right chars))))
         (bottom-line (concat (char-to-string (alist-get 'bottom-left chars))
                              (mapconcat (lambda (w)
                                           (make-string (+ w 2) (alist-get 'horizontal chars)))
                                         widths
                                         (char-to-string (alist-get 't-up chars)))
                              (char-to-string (alist-get 'bottom-right chars))))
         (formatted-rows '())
         (after-header nil))

    ;; Format each row
    (dolist (row rows)
      (if (md/table--is-separator-row-p row)
          (progn
            (push (concat (char-to-string (alist-get 't-right chars))
                          (mapconcat (lambda (w)
                                       (make-string (+ w 2) (alist-get 'horizontal chars)))
                                     widths
                                     (char-to-string (alist-get 'cross chars)))
                          (char-to-string (alist-get 't-left chars)))
                  formatted-rows)
            (setq after-header t))
        (let* ((cells (md/table--split-row row))
               (formatted-cells '()))
          (dotimes (i ncols)
            (let* ((cell (if (< i (length cells)) (nth i cells) ""))
                   (width (nth i widths))
                   (padded (concat " " cell (make-string (- width (length cell)) ?\s) " ")))
              (push padded formatted-cells)))
          (push (concat (char-to-string (alist-get 'vertical chars))
                        (mapconcat #'identity (nreverse formatted-cells)
                                   (char-to-string (alist-get 'vertical chars)))
                        (char-to-string (alist-get 'vertical chars)))
                formatted-rows))))

    (setq formatted-rows (nreverse formatted-rows))

    ;; Add top and bottom borders
    (setq formatted-rows (cons top-line formatted-rows))
    (setq formatted-rows (append formatted-rows (list bottom-line)))

    formatted-rows))

(defun md/table--apply-formatting ()
  "Apply box-drawing formatting to the table at point."
  (when-let* ((table-info (md/table--find-table-at-point))
              (start (nth 0 table-info))
              (end (nth 1 table-info))
              (rows (nth 2 table-info))
              (widths (md/table--calculate-widths rows))
              (formatted (md/table--format-table rows widths)))

    ;; Remove old overlays in this region
    (remove-overlays start end 'md/table t)

    ;; Create overlay to display formatted table
    (let ((ov (make-overlay start end)))
      (overlay-put ov 'md/table t)
      (overlay-put ov 'display (mapconcat #'identity formatted "\n"))
      (overlay-put ov 'evaporate t))))

(defun md/table--format-all-tables ()
  "Format all tables in the buffer."
  (when (md/in-normal-state-p)
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward "^\\s-*|" nil t)
        (beginning-of-line)
        (if-let ((table-info (md/table--find-table-at-point)))
            (progn
              (md/table--apply-formatting)
              ;; Jump past the entire table
              (goto-char (nth 1 table-info)))
          ;; Not a table, just move forward one line
          (forward-line 1))))))

(defun md/table--enable ()
  "Enable table formatting."
  (md/table--format-all-tables))

(defun md/table--disable ()
  "Disable table formatting."
  (md/table--clear-overlays))

;; Modes
(define-minor-mode md/markdown-table-mode
  "Format markdown tables with box-drawing characters in Normal mode."
  :init-value t :lighter ""
  (if md/markdown-table-mode
      (progn
        (md/table--enable)
        (add-hook 'evil-normal-state-entry-hook #'md/table--refresh nil t)
        (add-hook 'evil-insert-state-entry-hook #'md/table--clear-overlays nil t)
        (when (md/in-normal-state-p) (md/table--refresh)))
    (remove-hook 'evil-normal-state-entry-hook #'md/table--refresh t)
    (remove-hook 'evil-insert-state-entry-hook #'md/table--clear-overlays t)
    (md/table--disable)))

(defun md/table--refresh ()
  "Refresh table formatting in the buffer."
  (when (derived-mode-p 'markdown-mode 'markdown-ts-mode)
    (md/table--clear-overlays)
    (md/table--format-all-tables)))

(define-minor-mode md/markdown-conceal-mode
  "Conceal Markdown link/image markup in Normal; expand in Insert."
  :init-value t :lighter ""
  (if md/markdown-conceal-mode
      (progn
        (md/link--enable)
        (add-hook 'evil-normal-state-entry-hook #'md/conceal--apply nil t)
        (add-hook 'evil-insert-state-entry-hook #'md/conceal--clear nil t)
        (when (md/in-normal-state-p) (md/conceal--apply)))
    (remove-hook 'evil-normal-state-entry-hook #'md/conceal--apply t)
    (remove-hook 'evil-insert-state-entry-hook #'md/conceal--clear t)
    (md/link--disable)))

(defun md/conceal--apply ()
  (when (derived-mode-p 'markdown-mode 'markdown-ts-mode)
    (md/link--clear-icons)
    (md/link--enable)))

(defun md/conceal--clear ()
  (when (derived-mode-p 'markdown-mode 'markdown-ts-mode)
    (md/conceal--unhide-buffer)
    (font-lock-flush) (font-lock-ensure)))

(define-minor-mode md/markdown-list-pretty-mode
  "Compose bullets and checkboxes."
  :init-value t :lighter ""
  (if md/markdown-list-pretty-mode
      (md/enable-pretty-lists)
    (font-lock-remove-keywords nil (md/pretty-fontlock-keywords))
    (remove-list-of-text-properties (point-min) (point-max) '(composition))
    (font-lock-flush) (font-lock-ensure)))

(defun md/ret-dwim ()
  "If on a Markdown list item, continue the list; else defer to markdown/newline."
  (interactive)
  (setq-local electric-indent-inhibit t)
  (let ((on-list
         (save-excursion
           (beginning-of-line)
           (looking-at "\\s-*\\([-*+]\\|[0-9]+[.)]\\)\\s-"))))
    (cond
     (on-list
      ;; Custom list continuation (don't call markdown-insert-list-item to avoid double insertion)
      (let* ((indent (save-excursion (back-to-indentation) (current-column)))
             (bullet (match-string 1))
             (num (when (string-match "\\`\\([0-9]+\\)\\([.)]\\)\\'" bullet)
                    (string-to-number (match-string 1 bullet))))
             (punct (or (and (string-match "\\`\\([0-9]+\\)\\([.)]\\)\\'" bullet)
                             (match-string 2 bullet))
                        "."))
             (next (if num (format "%d%s" (1+ num) punct) bullet)))
        (end-of-line) (newline) (indent-to indent) (insert next " ")))
     ((fboundp 'markdown-enter-key)
      (call-interactively 'markdown-enter-key))
     (t (newline)))))

(defvar md/markdown-keys-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "RET") #'md/ret-dwim)
    (define-key map (kbd "C-m") #'md/ret-dwim)
    map)
  "Keymap for `md/markdown-keys-mode'.")

(define-minor-mode md/markdown-keys-mode
  "Minor mode to provide smart RET for Markdown lists."
  :init-value t :lighter "" :keymap md/markdown-keys-mode-map
  (setq-local electric-indent-inhibit t))

(add-hook 'markdown-mode-hook #'md/markdown-keys-mode)
(when (fboundp 'markdown-ts-mode)
  (add-hook 'markdown-ts-mode-hook #'md/markdown-keys-mode))

;; Activation
(defun md/markdown-activate-visuals ()
  (md/markdown-conceal-mode 1)
  (md/markdown-list-pretty-mode 1)
  (md/markdown-checkbox-mode 1)
  ;; (md/markdown-table-mode 1)  ;; Disabled: table formatting in normal mode
  (prettify-symbols-mode 1)
  (md/markdown-keys-mode 1)
  (md/setup-header-faces))

(use-package markdown-mode
  :mode (("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init
  (setq markdown-fontify-code-blocks-natively t
        markdown-enable-math t
        ;; Use pandoc for preview if available
        markdown-command (cond
                          ((executable-find "pandoc") "pandoc -f markdown -t html5 --standalone --quiet")
                          ((executable-find "multimarkdown") "multimarkdown")
                          ((executable-find "markdown") "markdown")
                          (t "markdown"))
        ;; Delete temp file after export
        markdown-live-preview-delete-export 'delete-on-export)
  :config
  (add-hook 'markdown-mode-hook     #'md/markdown-activate-visuals)
  (when (fboundp 'markdown-ts-mode)
    (add-hook 'markdown-ts-mode-hook #'md/markdown-activate-visuals)))

;; Simple markdown preview in browser (one-shot, not live)
(defun my/markdown-preview-browser ()
  "Export markdown to HTML and open in browser."
  (interactive)
  (let* ((input-file (buffer-file-name))
         (output-file (concat (file-name-sans-extension input-file) ".html"))
         (browser (or (executable-find "firefox")
                      (executable-find "chromium")
                      (executable-find "google-chrome")
                      (executable-find "brave")))
         (pandoc (executable-find "pandoc")))
    (unless input-file
      (user-error "Buffer is not visiting a file"))
    (when (buffer-modified-p) (save-buffer))
    (if pandoc
        (let ((exit-code (call-process pandoc nil nil nil
                                       "-f" "markdown"
                                       "-t" "html5"
                                       "--standalone"
                                       "-o" output-file
                                       input-file)))
          (if (= exit-code 0)
              (if browser
                  (start-process "markdown-preview" nil browser output-file)
                (browse-url (concat "file://" output-file)))
            (user-error "Pandoc failed with exit code %d" exit-code)))
      (user-error "Pandoc not found. Install it with: nix-env -iA nixpkgs.pandoc"))))

(when (fboundp 'my/leader-keys)
  (my/leader-keys
    "m"  '(:ignore t :which-key "markdown")
    "mh" '(markdown-toggle-markup-hiding :which-key "toggle hiding")
    "mp" '(my/markdown-preview-browser   :which-key "preview in browser")
    "ml" '(markdown-live-preview-mode    :which-key "live preview (eww)")))

(add-hook 'minibuffer-setup-hook
          (lambda ()
            (when (bound-and-true-p md/markdown-keys-mode)
              (md/markdown-keys-mode -1))))


(provide 'markdown-setup)
