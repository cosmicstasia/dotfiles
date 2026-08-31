;;; cache-management.el --- Safe cache management without moving packages -*- lexical-binding: t; -*-

;; Define cache directory (respects XDG Base Directory specification)
(defvar my/cache-dir
  (expand-file-name 
   (or (getenv "XDG_CACHE_HOME")
       "~/.cache/emacs"))
  "Directory for storing Emacs cache files.")

;; Ensure cache directory exists
(unless (file-directory-p my/cache-dir)
  (make-directory my/cache-dir t))

;; Backup and autosave files (replaces your backups.el)
(setq backup-directory-alist `((".*" . ,(expand-file-name "backups" my/cache-dir)))
      auto-save-file-name-transforms `((".*" ,(expand-file-name "auto-saves" my/cache-dir) t))
      auto-save-list-file-prefix (expand-file-name "auto-save-list/.saves-" my/cache-dir))

;; DO NOT MOVE PACKAGES - leave them in ~/.emacs.d/elpa
;; (setq package-user-dir (expand-file-name "packages" my/cache-dir))

;; Byte compilation cache
(when (boundp 'native-comp-eln-load-path)
  (setq native-comp-eln-load-path 
        (list (expand-file-name "eln-cache" my/cache-dir))))

;; Recent files
(setq recentf-save-file (expand-file-name "recentf" my/cache-dir))

;; Bookmarks
(setq bookmark-default-file (expand-file-name "bookmarks" my/cache-dir))

;; Savehist (minibuffer history)
(setq savehist-file (expand-file-name "history" my/cache-dir))

;; Save-place (cursor position in files)
(setq save-place-file (expand-file-name "places" my/cache-dir))

;; Server files (with proper permissions) - this fixes your original error
(let ((server-dir (expand-file-name "server" my/cache-dir)))
  (unless (file-directory-p server-dir)
    (make-directory server-dir t)
    (set-file-modes server-dir #o700))  ; Owner read/write/execute only
  (setq server-socket-dir server-dir))

;; Tramp cache
(setq tramp-cache-file (expand-file-name "tramp" my/cache-dir)
      tramp-connection-properties-file (expand-file-name "tramp-connection-properties" my/cache-dir))

;; URL cache
(setq url-cache-directory (expand-file-name "url" my/cache-dir))

;; Undo history (if using undo-tree)
(with-eval-after-load 'undo-tree
  (setq undo-tree-history-directory-alist 
        `((".*" . ,(expand-file-name "undo-tree" my/cache-dir)))))

;; Company cache
(with-eval-after-load 'company
  (setq company-cache-directory (expand-file-name "company" my/cache-dir)))

;; Projectile cache (if you add it later)
(with-eval-after-load 'projectile
  (setq projectile-cache-file (expand-file-name "projectile.cache" my/cache-dir)
        projectile-known-projects-file (expand-file-name "projectile-bookmarks.eld" my/cache-dir)))

;; Create necessary subdirectories with proper permissions
(dolist (subdir '("backups" "auto-saves" "auto-save-list" "eln-cache" 
                  "undo-tree" "url" "company"))
  (let ((dir (expand-file-name subdir my/cache-dir)))
    (unless (file-directory-p dir)
      (make-directory dir t)
      ;; Set secure permissions for sensitive directories
      (when (member subdir '("server" "auto-saves" "backups"))
        (set-file-modes dir #o700)))))

;; Function to show cache directory size
(defun my/cache-size ()
  "Show the size of the cache directory."
  (interactive)
  (if (executable-find "du")
      (let ((size (shell-command-to-string 
                   (format "du -sh %s 2>/dev/null | cut -f1" 
                           (shell-quote-argument my/cache-dir)))))
        (message "Cache directory size: %s" (string-trim size)))
    (message "Cache directory: %s" my/cache-dir)))

;; Function to clean cache (leaves important files like bookmarks)
(defun my/clean-cache ()
  "Clean temporary cache files but preserve important data."
  (interactive)
  (when (yes-or-no-p (format "Clean temporary cache files in %s? " my/cache-dir))
    (let ((dirs-to-clean '("auto-saves" "auto-save-list" "eln-cache" "url" "company")))
      (dolist (dir dirs-to-clean)
        (let ((full-path (expand-file-name dir my/cache-dir)))
          (when (file-directory-p full-path)
            (delete-directory full-path t)
            (make-directory full-path t))))
      (message "Temporary cache files cleaned (bookmarks, history, and places preserved)."))))

(provide 'cache-management)
;;; cache-management.el ends here
