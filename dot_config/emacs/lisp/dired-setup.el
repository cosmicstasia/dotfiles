;;; dired-setup.el --- Dired configuration -*- lexical-binding: t; -*-

(eval-when-compile (require 'use-package))

(use-package nerd-icons-dired)

(defcustom list-of-dired-switches
  '(("-ahl --group-directories-first -v" . "everything")
    ("-Bhl --group-directories-first -v" . ""))
  "List of ls switches (together with a name to display in the mode-line) for dired to cycle among.")

(defun me/cycle-dired-switches ()
  "Cycle through the list `list-of-dired-switches' of switches for ls"
  (interactive)
  (setq list-of-dired-switches
        (append (cdr list-of-dired-switches)
                (list (car list-of-dired-switches))))
  (dired-sort-other (caar list-of-dired-switches))
  (setq mode-name (concat "Dired " (cdar list-of-dired-switches)))
  (force-mode-line-update))

(use-package dired-sidebar
  :commands (dired-sidebar-toggle-sidebar)
  :custom
  (dired-sidebar-width 35)
  (dired-sidebar-theme 'nerd-icons)
  (dired-sidebar-use-custom-font nil)
  (dired-sidebar-no-delete-other-windows t)
  :hook (dired-sidebar-mode . dired-hide-details-mode)
  :config
  ;; Open files in the main window, not splits
  (setq dired-sidebar-should-follow-file nil)
  (defun my/dired-sidebar-up-directory ()
    "Go up directory in sidebar without leaving it."
    (interactive)
    (let ((current (dired-current-directory)))
      (dired-sidebar-find-file (file-name-directory (directory-file-name current)))))

  (with-eval-after-load 'evil
    (evil-define-key 'normal dired-sidebar-mode-map
      "j" 'dired-next-line
      "k" 'dired-previous-line
      "l" 'dired-sidebar-find-file
      "h" 'my/dired-sidebar-up-directory
      "q" 'dired-sidebar-toggle-sidebar
      "r" 'revert-buffer
      "I" 'me/cycle-dired-switches
      "d" 'dired-hide-details-mode
      (kbd "SPC n") 'dired-sidebar-toggle-sidebar)))

(use-package dired
  :ensure nil
  :hook ((dired-mode . hl-line-mode)
         (dired-mode . dired-hide-details-mode))
  :custom
  (dired-recursive-copies 'always)
  (dired-recursive-deletes 'always)
  ;; Use to copy to the next buffer visible
  (dired-dwim-target t)
  ;; Auto refresh Dired, but be quiet about it
  (global-auto-revert-non-file-buffers t)
  (auto-revert-verbose nil)
  :config
  ;; Enable global auto-revert
  (global-auto-revert-mode t)

  (setq dired-listing-switches "-ahl --group-directories-first -v")

  ;; Only set dired-header face if it exists
  (when (facep 'dired-header)
    (set-face-attribute 'dired-header nil
                        :foreground "#282c34"
                        :weight 'bold))

  (defun me/dired-open()
    (interactive)
    (cond
     ;; Use dired-find-file if it is a directory
     ((file-directory-p (dired-get-file-for-visit))
      (dired-find-file))
     ;; Use dired-find-file if the mime type of the file is emacs.desktop
     ((string= "emacs.desktop" (string-trim-right (shell-command-to-string
                                                   (format "xdg-mime query filetype %s | xargs xdg-mime query default"
                                                           (shell-quote-argument (dired-get-file-for-visit))))))
      (dired-find-file))
     (t
      ;; Use xdg-open for everything else
      ;; start-process quotes the arguments so you do not need the shell-quote-argument function
      (start-process "ram-dired-open" nil "xdg-open" (dired-get-file-for-visit))))))

(with-eval-after-load 'evil
  (evil-define-key 'normal dired-mode-map
    "j" 'dired-next-line
    "k" 'dired-previous-line
    "l" 'me/dired-open
    "h" 'dired-up-directory
    ;; Copy file
    "yy" 'dired-do-copy
    ;; Copy file name
    "yn" 'dired-copy-filename-as-kill
    ;; Copy full path
    "yp" (lambda() (interactive) (dired-copy-filename-as-kill 0))
    ;; Quick access directories
    "gk" (lambda() (interactive) (dired "~/Documents"))
    "gn" (lambda() (interactive) (dired "~/Documents/notes"))
    "gd" (lambda() (interactive) (dired "~/Downloads"))
    "gp" (lambda() (interactive) (dired "~/Projects"))
    ;; Mark file or directory
    "m" 'dired-mark
    "u" 'dired-unmark
    "t" 'dired-toggle-marks
    ;; Rename file or directory
    "R" 'dired-do-rename
    ;; Update current directory
    "r" 'revert-buffer
    ;; Create new directory
    "nd" 'dired-create-directory
    ;; Create new file
    "nf" 'dired-create-empty-file
    "q" 'quit-window
    ;; Toggle files and directories details
    "d" 'dired-hide-details-mode
    ;; Delete file or directory
    "D" 'dired-do-delete
    "za" 'me/cycle-dired-switches
    "q" 'quit-window))

(provide 'dired-setup)
