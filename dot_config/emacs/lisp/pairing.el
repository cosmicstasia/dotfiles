;;; pairing.el --- Electric pairs -*- lexical-binding: t; -*-
(electric-pair-mode 1)
(setq electric-pair-pairs
      '((?\( . ?\)) (?\[ . ?\]) (?\{ . ?\}) (?\< . ?\>)
        (?\« . ?\») (?\" . ?\")))
(setq electric-pair-skip-whitespace 'chomp)

;; Disable electric-pair-mode during Evil visual state to avoid breaking visual block insert
(with-eval-after-load 'evil
  (add-hook 'evil-visual-state-entry-hook (lambda () (electric-pair-local-mode -1)))
  (add-hook 'evil-visual-state-exit-hook (lambda () (electric-pair-local-mode 1))))

(provide 'pairing)
