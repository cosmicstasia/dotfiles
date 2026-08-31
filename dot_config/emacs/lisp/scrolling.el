;;; scrolling.el --- Vim-like scrolling behavior -*- lexical-binding: t; -*-
(setq scroll-conservatively most-positive-fixnum
      scroll-preserve-screen-position t
      scroll-step 1
      scroll-margin 3)
(provide 'scrolling)
