;;; spell.el --- Flyspell + aspell with vim-style interface -*- lexical-binding: t; -*-

(require 'cl-lib)

(setq ispell-program-name "aspell"
      ispell-extra-args '("--sug-mode=ultra" "--run-together")
      ispell-personal-dictionary (expand-file-name "~/.aspell.en.pws"))

(let ((word-lists '("/usr/share/dict/words"
                   "/run/current-system/sw/share/dict/words"
                   "/etc/dictionaries-common/words"
                   "/usr/dict/words")))
  (setq ispell-alternate-dictionary
        (cl-find-if #'file-exists-p word-lists)))

(use-package flyspell
  :diminish flyspell-mode
  :hook ((text-mode . flyspell-mode) (prog-mode . flyspell-prog-mode))
  :config 
  (setq flyspell-issue-message-flag nil
        flyspell-sort-corrections nil))

;; Make it more vim like. The default is fugly
(defun my/spell-add-word ()
  "Add word at point to personal dictionary (vim zg equivalent)."
  (interactive)
  (let ((word (thing-at-point 'word t)))
    (when word
      (ispell-send-string (concat "*" word "\n"))
      (setq ispell-pdict-modified-p '(t))
      (ispell-pdict-save t)
      (message "Added '%s' to dictionary" word)
      (flyspell-unhighlight-at (point)))))

(defun my/spell-correct-word ()
  "Show spelling corrections in vim-style bottom popup (vim z= equivalent)."
  (interactive)
  (let ((word (thing-at-point 'word t)))
    (if (not word)
        (message "No word at point")
      (let ((suggestions (my/get-aspell-suggestions word)))
        (if (not suggestions)
            (message "No suggestions for '%s'" word)
          (my/spell-show-suggestions word suggestions 
                                    (car (bounds-of-thing-at-point 'word))
                                    (cdr (bounds-of-thing-at-point 'word))))))))

(defun my/get-aspell-suggestions (word)
  "Get spelling suggestions using aspell directly."
  (when (and word (executable-find "aspell"))
    (with-temp-buffer
      (call-process "aspell" nil t nil "pipe")
      (goto-char (point-min))
      (insert (format "^%s\n" word))
      (call-process-region (point-min) (point-max) "aspell" t t nil "pipe")
      (goto-char (point-min))
      (when (re-search-forward "^& .* \\([0-9]+\\) .*: \\(.*\\)" nil t)
        (split-string (match-string 2) ", ")))))

(defun my/spell-show-suggestions (word suggestions start end)
  "Show spelling suggestions in vim-style numbered list at bottom."
  (let* ((max-suggestions 9)
         (limited-suggestions (seq-take suggestions max-suggestions))
         (choices (mapcar (lambda (item)
                           (cons (car item) (cadr item)))
                         (seq-map-indexed 
                          (lambda (suggestion index)
                            (list (1+ index) suggestion))
                          limited-suggestions)))
         (prompt (concat "Change '" word "' to:\n"
                        (mapconcat (lambda (choice)
                                    (format "%d: %s" (car choice) (cdr choice)))
                                  choices "\n")
                        "\n[1-9] Replace, [i]gnore, [a]dd to dict, [q]uit: ")))
    (let ((choice (read-char-choice prompt 
                                   (append (number-sequence ?1 (+ ?0 (length choices)))
                                           '(?i ?a ?q)))))
      (cond
       ((and (>= choice ?1) (<= choice ?9))
        (let* ((index (- choice ?1))
               (replacement (nth index limited-suggestions)))
          (when replacement
            (goto-char start)
            (delete-region start end)
            (insert replacement)
            (message "Replaced '%s' with '%s'" word replacement))))
       ((eq choice ?a)
        (ispell-send-string (concat "*" word "\n"))
        (setq ispell-pdict-modified-p '(t))
        (ispell-pdict-save t)  
        (flyspell-unhighlight-at (point))
        (message "Added '%s' to dictionary" word))
       ((eq choice ?i)
        (flyspell-unhighlight-at (point))
        (message "Ignored '%s'" word))
       ((eq choice ?q)
        (message "Cancelled"))))))

(defun my/spell-remove-word ()
  "Remove word from personal dictionary (vim zw equivalent)."
  (interactive)
  (let ((word (thing-at-point 'word t)))
    (when word
      ;; Hacky nonsense right here due to limitations with ispell.
      (let ((dict-file ispell-personal-dictionary))
        (when (and dict-file (file-exists-p dict-file))
          (with-temp-buffer
            (insert-file-contents dict-file)
            (goto-char (point-min))
            (when (re-search-forward (concat "^" (regexp-quote word) "$") nil t)
              (delete-region (line-beginning-position) (1+ (line-end-position)))
              (write-file dict-file)
              (message "Removed '%s' from dictionary" word)
              (ispell-kill-ispell t))))))))

(defun my/spell-next-error ()
  "Jump to next spelling error (vim ]s equivalent)."
  (interactive)
  (flyspell-goto-next-error))

(defun my/spell-previous-error ()
  "Jump to previous spelling error (vim [s equivalent)."
  (interactive)
  (let ((pos (point)))
    (flyspell-goto-next-error)
    (when (= (point) pos)
      (goto-char (point-min))
      (flyspell-goto-next-error))))

;; Evil mode integration
(with-eval-after-load 'evil
  (evil-define-key 'normal flyspell-mode-map
    "zg" 'my/spell-add-word
    "z=" 'my/spell-correct-word
    "zw" 'my/spell-remove-word
    "]s" 'my/spell-next-error
    "[s" 'my/spell-previous-error))

;; Never use these, as the vim bindings are better. But included for non-vim users.
(with-eval-after-load 'flyspell
  (define-key flyspell-mode-map (kbd "C-c s a") 'my/spell-add-word)
  (define-key flyspell-mode-map (kbd "C-c s c") 'my/spell-correct-word)
  (define-key flyspell-mode-map (kbd "C-c s r") 'my/spell-remove-word)
  (define-key flyspell-mode-map (kbd "C-c s n") 'my/spell-next-error)
  (define-key flyspell-mode-map (kbd "C-c s p") 'my/spell-previous-error))

(with-eval-after-load 'general
  (my/leader-keys
    "s"  '(:ignore t :which-key "Spell")
    "sa" '(my/spell-add-word     :which-key "Add word")
    "sc" '(my/spell-correct-word :which-key "Correct word")
    "sr" '(my/spell-remove-word  :which-key "Remove word")
    "sn" '(my/spell-next-error   :which-key "Next error")
    "sp" '(my/spell-previous-error :which-key "Previous error")
    "st" '(flyspell-mode         :which-key "Toggle flyspell")))

(provide 'spell)
