;;; theme-definitions.el --- Premade themes -*- lexical-binding: t; -*-
;; This is the file where you put in your premade themes. Can be accessed with SPC h -

(require 'themes)

;; For Matugen - Material You colors from wallpaper
(themes-register
 (make-theme-def
  :name 'matugen
  :display-name "Matugen (Material You)"
  :description "Dynamic Material You colors from matugen"
  :type 'matugen
  :colors '((bg . "#000000") (fg . "#ffffff"))  ; Placeholder, updated by bridge
  :setup-func (lambda ()
                ;; Load matugen bridge if available
                (when (require 'matugen-bridge nil t)
                  (matugen-bridge-apply-colors)))
  :teardown-func nil))

;; For Pywal - Colors are dynamically updated by pywal-bridge
(themes-register
 (make-theme-def
  :name 'pywal
  :display-name "Pywal Dynamic"
  :description "Dynamic theme using pywal colors"
  :type 'pywal
  :colors '((bg . "#000000") (fg . "#ffffff"))  ; Placeholder, updated by bridge
  :setup-func (lambda ()
                ;; Refresh colors from pywal before applying
                (when (featurep 'pywal)
                  ;; Update theme colors from current pywal colors
                  (let* ((data (pywal--read-colors))
                         (spec (pywal--alist-get* data "special"))
                         (colors (pywal--alist-get* data "colors")))
                    (when colors
                      (let ((theme-colors
                             `((bg . ,(or (pywal--alist-get* spec "background")
                                          (pywal--alist-get* colors "color0")))
                               (fg . ,(or (pywal--alist-get* spec "foreground")
                                          (pywal--alist-get* colors "color7")))
                               (accent . ,(or (pywal--alist-get* colors "color4")
                                              (pywal--alist-get* colors "color2")))
                               (highlight . ,(or (pywal--alist-get* colors "color8")
                                                 (pywal--alist-get* colors "color0")))
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
                        ;; Update this theme's colors
                        (let ((pywal-theme (themes-get 'pywal)))
                          (when pywal-theme
                            (setf (theme-def-colors pywal-theme) theme-colors)))
                        ;; Apply the fresh colors
                        (themes--apply-colors theme-colors))))
                  ;; Start watching for changes
                  (when themes-enable-pywal-integration
                    (pywal-start-watching))))
  :teardown-func (lambda ()
                   (when (featurep 'pywal)
                     (pywal-stop-watching)))))

;; Doom One theme
(themes-register
 (make-theme-def
  :name 'doom-one
  :display-name "Doom One"
  :description "Dark theme inspired by Atom One Dark"
  :type 'static
  :colors '((bg . "#282c34")
            (fg . "#bbc2cf")
            (accent . "#51afef")
            (highlight . "#3f444a")
            (selection . "#3f444a")
            (comment . "#5B6268")
            (string . "#98be65")
            (keyword . "#c678dd")
            (warning . "#ECBE7B")
            (error . "#ff6c6b")
            (success . "#98be65"))
  :faces '((font-lock-builtin-face :foreground "#51afef")
           (font-lock-function-name-face :foreground "#c678dd" :weight bold)
           (font-lock-variable-name-face :foreground "#dcaeea")
           (font-lock-type-face :foreground "#ECBE7B")
           (font-lock-constant-face :foreground "#a9a1e1")
           (line-number :foreground "#3f444a" :background "#282c34")
           (line-number-current-line :foreground "#bbc2cf" :background "#282c34" :weight bold)
           (org-level-1 :foreground "#51afef" :weight bold :height 1.3)
           (org-level-2 :foreground "#c678dd" :weight bold :height 1.2)
           (org-level-3 :foreground "#98be65" :weight bold :height 1.1)
           (org-level-4 :foreground "#ECBE7B" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#282c34" :foreground "#bbc2cf" :box nil)
           (tab-bar-tab :background "#51afef" :foreground "#282c34" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#282c34" :foreground "#bbc2cf" :box nil)
           (tab-bar-tab-group-current :background "#51afef" :foreground "#282c34" :weight bold)
           (tab-bar-tab-group-inactive :background "#282c34" :foreground "#5B6268")
           (tab-bar-tab-ungrouped :background "#282c34" :foreground "#bbc2cf"))))

;; Doom One Light theme
(themes-register
 (make-theme-def
  :name 'doom-one-light
  :display-name "Doom One Light"
  :description "Light variant of Doom One"
  :type 'static
  :colors '((bg . "#fafafa")
            (fg . "#383a42")
            (accent . "#4078f2")
            (highlight . "#f0f0f0")
            (selection . "#f0f0f0")
            (comment . "#a0a1a7")
            (string . "#50a14f")
            (keyword . "#a626a4")
            (warning . "#986801")
            (error . "#e45649")
            (success . "#50a14f"))
  :faces '((font-lock-builtin-face :foreground "#4078f2")
           (font-lock-function-name-face :foreground "#a626a4" :weight bold)
           (font-lock-variable-name-face :foreground "#6f42c1")
           (font-lock-type-face :foreground "#986801")
           (font-lock-constant-face :foreground "#6f42c1")
           (line-number :foreground "#f0f0f0" :background "#fafafa")
           (line-number-current-line :foreground "#383a42" :background "#fafafa" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#fafafa" :foreground "#383a42" :box nil)
           (tab-bar-tab :background "#4078f2" :foreground "#fafafa" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#fafafa" :foreground "#383a42" :box nil)
           (tab-bar-tab-group-current :background "#4078f2" :foreground "#fafafa" :weight bold)
           (tab-bar-tab-group-inactive :background "#fafafa" :foreground "#a0a1a7")
           (tab-bar-tab-ungrouped :background "#fafafa" :foreground "#383a42"))))

;; Dracula theme
(themes-register
 (make-theme-def
  :name 'dracula
  :display-name "Dracula"
  :description "Dark theme with purple accents"
  :type 'static
  :colors '((bg . "#282a36")
            (fg . "#f8f8f2")
            (accent . "#bd93f9")
            (highlight . "#44475a")
            (selection . "#44475a")
            (comment . "#6272a4")
            (string . "#f1fa8c")
            (keyword . "#ff79c6")
            (warning . "#ffb86c")
            (error . "#ff5555")
            (success . "#50fa7b"))
  :faces '((font-lock-builtin-face :foreground "#8be9fd")
           (font-lock-function-name-face :foreground "#50fa7b" :weight bold)
           (font-lock-variable-name-face :foreground "#f8f8f2")
           (font-lock-type-face :foreground "#8be9fd")
           (font-lock-constant-face :foreground "#bd93f9")
           (line-number :foreground "#44475a" :background "#282a36")
           (line-number-current-line :foreground "#f8f8f2" :background "#282a36" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#282a36" :foreground "#f8f8f2" :box nil)
           (tab-bar-tab :background "#bd93f9" :foreground "#282a36" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#282a36" :foreground "#f8f8f2" :box nil)
           (tab-bar-tab-group-current :background "#bd93f9" :foreground "#282a36" :weight bold)
           (tab-bar-tab-group-inactive :background "#282a36" :foreground "#6272a4")
           (tab-bar-tab-ungrouped :background "#282a36" :foreground "#f8f8f2"))))

;; Gruvbox theme
(themes-register
 (make-theme-def
  :name 'gruvbox
  :display-name "Gruvbox"
  :description "Retro groove color scheme"
  :type 'static
  :colors '((bg . "#282828")
            (fg . "#ebdbb2")
            (accent . "#83a598")
            (highlight . "#3c3836")
            (selection . "#3c3836")
            (comment . "#928374")
            (string . "#b8bb26")
            (keyword . "#fb4934")
            (warning . "#fabd2f")
            (error . "#fb4934")
            (success . "#b8bb26"))
  :faces '((font-lock-builtin-face :foreground "#83a598")
           (font-lock-function-name-face :foreground "#fabd2f" :weight bold)
           (font-lock-variable-name-face :foreground "#8ec07c")
           (font-lock-type-face :foreground "#fabd2f")
           (font-lock-constant-face :foreground "#d3869b")
           (line-number :foreground "#3c3836" :background "#282828")
           (line-number-current-line :foreground "#ebdbb2" :background "#282828" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#282828" :foreground "#ebdbb2" :box nil)
           (tab-bar-tab :background "#83a598" :foreground "#282828" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#282828" :foreground "#ebdbb2" :box nil)
           (tab-bar-tab-group-current :background "#83a598" :foreground "#282828" :weight bold)
           (tab-bar-tab-group-inactive :background "#282828" :foreground "#928374")
           (tab-bar-tab-ungrouped :background "#282828" :foreground "#ebdbb2"))))

;; Nord theme
(themes-register
 (make-theme-def
  :name 'nord
  :display-name "Nord"
  :description "Arctic, north-bluish color palette"
  :type 'static
  :colors '((bg . "#2e3440")
            (fg . "#d8dee9")
            (accent . "#5e81ac")
            (highlight . "#3b4252")
            (selection . "#3b4252")
            (comment . "#616e88")
            (string . "#a3be8c")
            (keyword . "#81a1c1")
            (warning . "#ebcb8b")
            (error . "#bf616a")
            (success . "#a3be8c"))
  :faces '((font-lock-builtin-face :foreground "#5e81ac")
           (font-lock-function-name-face :foreground "#88c0d0" :weight bold)
           (font-lock-variable-name-face :foreground "#d8dee9")
           (font-lock-type-face :foreground "#5e81ac")
           (font-lock-constant-face :foreground "#b48ead")
           (line-number :foreground "#3b4252" :background "#2e3440")
           (line-number-current-line :foreground "#d8dee9" :background "#2e3440" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#2e3440" :foreground "#d8dee9" :box nil)
           (tab-bar-tab :background "#5e81ac" :foreground "#2e3440" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#2e3440" :foreground "#d8dee9" :box nil)
           (tab-bar-tab-group-current :background "#5e81ac" :foreground "#2e3440" :weight bold)
           (tab-bar-tab-group-inactive :background "#2e3440" :foreground "#616e88")
           (tab-bar-tab-ungrouped :background "#2e3440" :foreground "#d8dee9"))))

;; Tokyo Night theme
(themes-register
 (make-theme-def
  :name 'tokyo-night
  :display-name "Tokyo Night"
  :description "Clean, dark theme inspired by Tokyo Night"
  :type 'static
  :colors '((bg . "#1a1b26")
            (fg . "#c0caf5")
            (accent . "#7aa2f7")
            (highlight . "#292e42")
            (selection . "#292e42")
            (comment . "#565f89")
            (string . "#9ece6a")
            (keyword . "#bb9af7")
            (warning . "#e0af68")
            (error . "#f7768e")
            (success . "#9ece6a"))
  :faces '((font-lock-builtin-face :foreground "#7aa2f7")
           (font-lock-function-name-face :foreground "#7dcfff" :weight bold)
           (font-lock-variable-name-face :foreground "#c0caf5")
           (font-lock-type-face :foreground "#7aa2f7")
           (font-lock-constant-face :foreground "#bb9af7")
           (line-number :foreground "#292e42" :background "#1a1b26")
           (line-number-current-line :foreground "#c0caf5" :background "#1a1b26" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#1a1b26" :foreground "#c0caf5" :box nil)
           (tab-bar-tab :background "#7aa2f7" :foreground "#1a1b26" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#1a1b26" :foreground "#c0caf5" :box nil)
           (tab-bar-tab-group-current :background "#7aa2f7" :foreground "#1a1b26" :weight bold)
           (tab-bar-tab-group-inactive :background "#1a1b26" :foreground "#565f89")
           (tab-bar-tab-ungrouped :background "#1a1b26" :foreground "#c0caf5"))))

;; Solarized Dark theme
(themes-register
 (make-theme-def
  :name 'solarized-dark
  :display-name "Solarized Dark"
  :description "Precision colors for machines and people"
  :type 'static
  :colors '((bg . "#002b36")
            (fg . "#839496")
            (accent . "#268bd2")
            (highlight . "#073642")
            (selection . "#073642")
            (comment . "#586e75")
            (string . "#2aa198")
            (keyword . "#859900")
            (warning . "#b58900")
            (error . "#dc322f")
            (success . "#859900"))
  :faces '((font-lock-builtin-face :foreground "#268bd2")
           (font-lock-function-name-face :foreground "#268bd2" :weight bold)
           (font-lock-variable-name-face :foreground "#839496")
           (font-lock-type-face :foreground "#b58900")
           (font-lock-constant-face :foreground "#6c71c4")
           (line-number :foreground "#073642" :background "#002b36")
           (line-number-current-line :foreground "#839496" :background "#002b36" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#002b36" :foreground "#839496" :box nil)
           (tab-bar-tab :background "#268bd2" :foreground "#002b36" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#002b36" :foreground "#839496" :box nil)
           (tab-bar-tab-group-current :background "#268bd2" :foreground "#002b36" :weight bold)
           (tab-bar-tab-group-inactive :background "#002b36" :foreground "#586e75")
           (tab-bar-tab-ungrouped :background "#002b36" :foreground "#839496"))))

;; Catppuccin Mocha theme
(themes-register
 (make-theme-def
  :name 'catppuccin
  :display-name "Catppuccin Mocha"
  :description "Soothing pastel theme"
  :type 'static
  :colors '((bg . "#1e1e2e")
            (fg . "#cdd6f4")
            (accent . "#89b4fa")
            (highlight . "#313244")
            (selection . "#313244")
            (comment . "#6c7086")
            (string . "#a6e3a1")
            (keyword . "#cba6f7")
            (warning . "#f9e2af")
            (error . "#f38ba8")
            (success . "#a6e3a1"))
  :faces '((font-lock-builtin-face :foreground "#89b4fa")
           (font-lock-function-name-face :foreground "#74c7ec" :weight bold)
           (font-lock-variable-name-face :foreground "#cdd6f4")
           (font-lock-type-face :foreground "#f9e2af")
           (font-lock-constant-face :foreground "#cba6f7")
           (line-number :foreground "#313244" :background "#1e1e2e")
           (line-number-current-line :foreground "#cdd6f4" :background "#1e1e2e" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#1e1e2e" :foreground "#cdd6f4" :box nil)
           (tab-bar-tab :background "#89b4fa" :foreground "#1e1e2e" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#1e1e2e" :foreground "#cdd6f4" :box nil)
           (tab-bar-tab-group-current :background "#89b4fa" :foreground "#1e1e2e" :weight bold)
           (tab-bar-tab-group-inactive :background "#1e1e2e" :foreground "#6c7086")
           (tab-bar-tab-ungrouped :background "#1e1e2e" :foreground "#cdd6f4"))))

;; Ayu theme
(themes-register
 (make-theme-def
  :name 'ayu
  :display-name "Ayu"
  :description "Dark theme with warm oranges and cool blues"
  :type 'static
  :colors '((bg . "#0b0e14")
            (fg . "#bfbdb6")
            (accent . "#73b8ff")
            (highlight . "#131721")
            (selection . "#131721")
            (comment . "#787bb0")
            (string . "#aad94c")
            (keyword . "#d2a6ff")
            (warning . "#f2966b")
            (error . "#f07178")
            (success . "#7fd962"))
  :faces '((font-lock-builtin-face :foreground "#73b8ff")
           (font-lock-function-name-face :foreground "#f2966b" :weight bold)
           (font-lock-variable-name-face :foreground "#95e6cb")
           (font-lock-type-face :foreground "#f28779")
           (font-lock-constant-face :foreground "#d2a6ff")
           (line-number :foreground "#131721" :background "#0b0e14")
           (line-number-current-line :foreground "#bfbdb6" :background "#0b0e14" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#0b0e14" :foreground "#bfbdb6" :box nil)
           (tab-bar-tab :background "#73b8ff" :foreground "#0b0e14" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#0b0e14" :foreground "#bfbdb6" :box nil)
           (tab-bar-tab-group-current :background "#73b8ff" :foreground "#0b0e14" :weight bold)
           (tab-bar-tab-group-inactive :background "#0b0e14" :foreground "#787bb0")
           (tab-bar-tab-ungrouped :background "#0b0e14" :foreground "#bfbdb6"))))

;; Everforest theme
(themes-register
 (make-theme-def
  :name 'everforest
  :display-name "Everforest"
  :description "Green forest themed with soft colors"
  :type 'static
  :colors '((bg . "#141b1f")
            (fg . "#D3C6AA")
            (accent . "#A2C8C3")
            (highlight . "#2D363B")
            (selection . "#272E32")
            (comment . "#9DA9A0")
            (string . "#B2C98F")
            (keyword . "#D699B6")
            (warning . "#f2966b")
            (error . "#E67E80")
            (success . "#B2C98F"))
  :faces '((font-lock-builtin-face :foreground "#A2C8C3")
           (font-lock-function-name-face :foreground "#f2966b" :weight bold)
           (font-lock-variable-name-face :foreground "#D699B6")
           (font-lock-type-face :foreground "#B2C98F")
           (font-lock-constant-face :foreground "#D699B6")
           (line-number :foreground "#2D363B" :background "#141b1f")
           (line-number-current-line :foreground "#D3C6AA" :background "#141b1f" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#141b1f" :foreground "#D3C6AA" :box nil)
           (tab-bar-tab :background "#A2C8C3" :foreground "#141b1f" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#141b1f" :foreground "#D3C6AA" :box nil)
           (tab-bar-tab-group-current :background "#A2C8C3" :foreground "#141b1f" :weight bold)
           (tab-bar-tab-group-inactive :background "#141b1f" :foreground "#9DA9A0")
           (tab-bar-tab-ungrouped :background "#141b1f" :foreground "#D3C6AA"))))

;; Rose Pine theme 
(themes-register
 (make-theme-def
  :name 'rose-pine
  :display-name "Rose Pine"
  :description "Popular theme with pinks and purples"
  :type 'static
  :colors '((bg . "#191724")
            (fg . "#e0def4")
            (accent . "#c4a7e7")
            (highlight . "#26233a")
            (selection . "#26233a")
            (comment . "#6e6a86")
            (string . "#f6c177")
            (keyword . "#31748f")
            (warning . "#ea9a97")
            (error . "#eb6f92")
            (success . "#9ccfd8"))
  :faces '((font-lock-builtin-face :foreground "#31748f")
           (font-lock-function-name-face :foreground "#ebbcba" :weight bold)
           (font-lock-variable-name-face :foreground "#c4a7e7")
           (font-lock-type-face :foreground "#f6c177")
           (font-lock-constant-face :foreground "#eb6f92")
           (line-number :foreground "#26233a" :background "#191724")
           (line-number-current-line :foreground "#e0def4" :background "#191724" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#191724" :foreground "#e0def4" :box nil)
           (tab-bar-tab :background "#c4a7e7" :foreground "#191724" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#191724" :foreground "#e0def4" :box nil)
           (tab-bar-tab-group-current :background "#c4a7e7" :foreground "#191724" :weight bold)
           (tab-bar-tab-group-inactive :background "#191724" :foreground "#6e6a86")
           (tab-bar-tab-ungrouped :background "#191724" :foreground "#e0def4"))))

;; Oxocarbon theme
(themes-register
 (make-theme-def
  :name 'oxocarbon
  :display-name "Oxocarbon"
  :description "IBM-inspired dark theme"
  :type 'static
  :colors '((bg . "#161616")
            (fg . "#f2f4f8")
            (accent . "#78a9ff")
            (highlight . "#262626")
            (selection . "#393939")
            (comment . "#525252")
            (string . "#33b1ff")
            (keyword . "#be95ff")
            (warning . "#ee5396")
            (error . "#3ddbd9")
            (success . "#33b1ff"))
  :faces '((font-lock-builtin-face :foreground "#78a9ff")
           (font-lock-function-name-face :foreground "#ee5396" :weight bold)
           (font-lock-variable-name-face :foreground "#be95ff")
           (font-lock-type-face :foreground "#33b1ff")
           (font-lock-constant-face :foreground "#3ddbd9")
           (line-number :foreground "#262626" :background "#161616")
           (line-number-current-line :foreground "#f2f4f8" :background "#161616" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#161616" :foreground "#f2f4f8" :box nil)
           (tab-bar-tab :background "#78a9ff" :foreground "#161616" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#161616" :foreground "#f2f4f8" :box nil)
           (tab-bar-tab-group-current :background "#78a9ff" :foreground "#161616" :weight bold)
           (tab-bar-tab-group-inactive :background "#161616" :foreground "#525252")
           (tab-bar-tab-ungrouped :background "#161616" :foreground "#f2f4f8"))))

;; Oceanic theme
(themes-register
 (make-theme-def
  :name 'oceanic
  :display-name "Oceanic"
  :description "Ocean-inspired theme with blue and teal tones"
  :type 'static
  :colors '((bg . "#1b2b34")
            (fg . "#D8DEE9")
            (accent . "#6699CC")
            (highlight . "#1b2b34")
            (selection . "#1b2b34")
            (comment . "#65737E")
            (string . "#99C794")
            (keyword . "#C594C5")
            (warning . "#FAC863")
            (error . "#EC5F67")
            (success . "#5FB3B3"))
  :faces '((font-lock-builtin-face :foreground "#6699CC")
           (font-lock-function-name-face :foreground "#F99157" :weight bold)
           (font-lock-variable-name-face :foreground "#C594C5")
           (font-lock-type-face :foreground "#FAC863")
           (font-lock-constant-face :foreground "#5FB3B3")
           (line-number :foreground "#1b2b34" :background "#1b2b34")
           (line-number-current-line :foreground "#D8DEE9" :background "#1b2b34" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#1b2b34" :foreground "#D8DEE9" :box nil)
           (tab-bar-tab :background "#6699CC" :foreground "#1b2b34" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#1b2b34" :foreground "#D8DEE9" :box nil)
           (tab-bar-tab-group-current :background "#6699CC" :foreground "#1b2b34" :weight bold)
           (tab-bar-tab-group-inactive :background "#1b2b34" :foreground "#65737E")
           (tab-bar-tab-ungrouped :background "#1b2b34" :foreground "#D8DEE9"))))

;; Monokai theme
(themes-register
 (make-theme-def
  :name 'monokai
  :display-name "Monokai"
  :description "Classic Monokai color scheme with vibrant colors"
  :type 'static
  :colors '((bg . "#272822")
            (fg . "#f8f8f2")
            (accent . "#66d9ef")
            (highlight . "#3e3d32")
            (selection . "#49483e")
            (comment . "#75715e")
            (string . "#e6db74")
            (keyword . "#f92672")
            (warning . "#fd971f")
            (error . "#f92672")
            (success . "#a6e22e"))
  :faces '((font-lock-builtin-face :foreground "#66d9ef")
           (font-lock-function-name-face :foreground "#a6e22e" :weight bold)
           (font-lock-variable-name-face :foreground "#fd971f")
           (font-lock-type-face :foreground "#66d9ef")
           (font-lock-constant-face :foreground "#ae81ff")
           (line-number :foreground "#3e3d32" :background "#272822")
           (line-number-current-line :foreground "#f8f8f2" :background "#272822" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#272822" :foreground "#f8f8f2" :box nil)
           (tab-bar-tab :background "#66d9ef" :foreground "#272822" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#272822" :foreground "#f8f8f2" :box nil)
           (tab-bar-tab-group-current :background "#66d9ef" :foreground "#272822" :weight bold)
           (tab-bar-tab-group-inactive :background "#272822" :foreground "#75715e")
           (tab-bar-tab-ungrouped :background "#272822" :foreground "#f8f8f2"))))

;; Palenight theme
(themes-register
 (make-theme-def
  :name 'palenight
  :display-name "Palenight"
  :description "Material Design inspired dark theme"
  :type 'static
  :colors '((bg . "#292d3e")
            (fg . "#a6accd")
            (accent . "#82aaff")
            (highlight . "#3a3f58")
            (selection . "#3a3f58")
            (comment . "#676e95")
            (string . "#c3e88d")
            (keyword . "#c792ea")
            (warning . "#ffcb6b")
            (error . "#f07178")
            (success . "#c3e88d"))
  :faces '((font-lock-builtin-face :foreground "#82aaff")
           (font-lock-function-name-face :foreground "#82aaff" :weight bold)
           (font-lock-variable-name-face :foreground "#f07178")
           (font-lock-type-face :foreground "#ffcb6b")
           (font-lock-constant-face :foreground "#89ddff")
           (line-number :foreground "#3a3f58" :background "#292d3e")
           (line-number-current-line :foreground "#a6accd" :background "#292d3e" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#292d3e" :foreground "#a6accd" :box nil)
           (tab-bar-tab :background "#82aaff" :foreground "#292d3e" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#292d3e" :foreground "#a6accd" :box nil)
           (tab-bar-tab-group-current :background "#82aaff" :foreground "#292d3e" :weight bold)
           (tab-bar-tab-group-inactive :background "#292d3e" :foreground "#676e95")
           (tab-bar-tab-ungrouped :background "#292d3e" :foreground "#a6accd"))))

;; Nightfox theme
(themes-register
 (make-theme-def
  :name 'nightfox
  :display-name "Nightfox"
  :description "Dark theme with soft colors inspired by nature"
  :type 'static
  :colors '((bg . "#192330")
            (fg . "#cdcecf")
            (accent . "#719cd6")
            (highlight . "#2d3f4e")
            (selection . "#2d3f4e")
            (comment . "#575860")
            (string . "#81b29a")
            (keyword . "#9d79d6")
            (warning . "#dbc074")
            (error . "#c94f6d")
            (success . "#81b29a"))
  :faces '((font-lock-builtin-face :foreground "#719cd6")
           (font-lock-function-name-face :foreground "#719cd6" :weight bold)
           (font-lock-variable-name-face :foreground "#cdcecf")
           (font-lock-type-face :foreground "#dbc074")
           (font-lock-constant-face :foreground "#9d79d6")
           (line-number :foreground "#2d3f4e" :background "#192330")
           (line-number-current-line :foreground "#cdcecf" :background "#192330" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#192330" :foreground "#cdcecf" :box nil)
           (tab-bar-tab :background "#719cd6" :foreground "#192330" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#192330" :foreground "#cdcecf" :box nil)
           (tab-bar-tab-group-current :background "#719cd6" :foreground "#192330" :weight bold)
           (tab-bar-tab-group-inactive :background "#192330" :foreground "#575860")
           (tab-bar-tab-ungrouped :background "#192330" :foreground "#cdcecf"))))

;; Kanagawa theme
(themes-register
 (make-theme-def
  :name 'kanagawa
  :display-name "Kanagawa"
  :description "Dark theme inspired by famous painting 'The Great Wave off Kanagawa'"
  :type 'static
  :colors '((bg . "#1f1f28")
            (fg . "#dcd7ba")
            (accent . "#7e9cd8")
            (highlight . "#2a2a37")
            (selection . "#2d4f67")
            (comment . "#54546d")
            (string . "#76946a")
            (keyword . "#957fb8")
            (warning . "#c0a36e")
            (error . "#c34043")
            (success . "#76946a"))
  :faces '((font-lock-builtin-face :foreground "#7e9cd8")
           (font-lock-function-name-face :foreground "#7fb4ca" :weight bold)
           (font-lock-variable-name-face :foreground "#dcd7ba")
           (font-lock-type-face :foreground "#c0a36e")
           (font-lock-constant-face :foreground "#957fb8")
           (line-number :foreground "#2a2a37" :background "#1f1f28")
           (line-number-current-line :foreground "#dcd7ba" :background "#1f1f28" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#1f1f28" :foreground "#dcd7ba" :box nil)
           (tab-bar-tab :background "#7e9cd8" :foreground "#1f1f28" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#1f1f28" :foreground "#dcd7ba" :box nil)
           (tab-bar-tab-group-current :background "#7e9cd8" :foreground "#1f1f28" :weight bold)
           (tab-bar-tab-group-inactive :background "#1f1f28" :foreground "#54546d")
           (tab-bar-tab-ungrouped :background "#1f1f28" :foreground "#dcd7ba"))))

;; Catppuccin Latte (light) theme
(themes-register
 (make-theme-def
  :name 'catppuccin-latte
  :display-name "Catppuccin Latte"
  :description "Warm and cozy light theme"
  :type 'static
  :colors '((bg . "#eff1f5")
            (fg . "#4c4f69")
            (accent . "#1e66f5")
            (highlight . "#e6e9ef")
            (selection . "#dce0e8")
            (comment . "#9ca0b0")
            (string . "#40a02b")
            (keyword . "#ea76cb")
            (warning . "#df8e1d")
            (error . "#d20f39")
            (success . "#40a02b"))
  :faces '((font-lock-builtin-face :foreground "#1e66f5")
           (font-lock-function-name-face :foreground "#1e66f5" :weight bold)
           (font-lock-variable-name-face :foreground "#8839ef")
           (font-lock-type-face :foreground "#df8e1d")
           (font-lock-constant-face :foreground "#ea76cb")
           (line-number :foreground "#e6e9ef" :background "#eff1f5")
           (line-number-current-line :foreground "#4c4f69" :background "#eff1f5" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#eff1f5" :foreground "#4c4f69" :box nil)
           (tab-bar-tab :background "#1e66f5" :foreground "#eff1f5" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#eff1f5" :foreground "#4c4f69" :box nil)
           (tab-bar-tab-group-current :background "#1e66f5" :foreground "#eff1f5" :weight bold)
           (tab-bar-tab-group-inactive :background "#eff1f5" :foreground "#9ca0b0")
           (tab-bar-tab-ungrouped :background "#eff1f5" :foreground "#4c4f69"))))

;; Rose Pine Dawn (light) theme
(themes-register
 (make-theme-def
  :name 'rose-pine-dawn
  :display-name "Rose Pine Dawn"
  :description "Light variant of Rose Pine with soft, warm colors"
  :type 'static
  :colors '((bg . "#faf4ed")
            (fg . "#575279")
            (accent . "#907aa9")
            (highlight . "#f2e9e1")
            (selection . "#dfdad9")
            (comment . "#9893a5")
            (string . "#ea9d34")
            (keyword . "#286983")
            (warning . "#ea9d34")
            (error . "#b4637a")
            (success . "#56949f"))
  :faces '((font-lock-builtin-face :foreground "#286983")
           (font-lock-function-name-face :foreground "#d7827e" :weight bold)
           (font-lock-variable-name-face :foreground "#907aa9")
           (font-lock-type-face :foreground "#ea9d34")
           (font-lock-constant-face :foreground "#b4637a")
           (line-number :foreground "#f2e9e1" :background "#faf4ed")
           (line-number-current-line :foreground "#575279" :background "#faf4ed" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#faf4ed" :foreground "#575279" :box nil)
           (tab-bar-tab :background "#907aa9" :foreground "#faf4ed" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#faf4ed" :foreground "#575279" :box nil)
           (tab-bar-tab-group-current :background "#907aa9" :foreground "#faf4ed" :weight bold)
           (tab-bar-tab-group-inactive :background "#faf4ed" :foreground "#9893a5")
           (tab-bar-tab-ungrouped :background "#faf4ed" :foreground "#575279"))))

;; Everforest Light theme
(themes-register
 (make-theme-def
  :name 'everforest-light
  :display-name "Everforest Light"
  :description "Light variant of Everforest with warm, nature-inspired tones"
  :type 'static
  :colors '((bg . "#fdf6e3")
            (fg . "#5c6a72")
            (accent . "#3a94c5")
            (highlight . "#f4f0d9")
            (selection . "#e6e2cc")
            (comment . "#a6b0a0")
            (string . "#8da101")
            (keyword . "#df69ba")
            (warning . "#dfa000")
            (error . "#f85552")
            (success . "#8da101"))
  :faces '((font-lock-builtin-face :foreground "#3a94c5")
           (font-lock-function-name-face :foreground "#35a77c" :weight bold)
           (font-lock-variable-name-face :foreground "#df69ba")
           (font-lock-type-face :foreground "#8da101")
           (font-lock-constant-face :foreground "#df69ba")
           (line-number :foreground "#f4f0d9" :background "#fdf6e3")
           (line-number-current-line :foreground "#5c6a72" :background "#fdf6e3" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#fdf6e3" :foreground "#5c6a72" :box nil)
           (tab-bar-tab :background "#3a94c5" :foreground "#fdf6e3" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#fdf6e3" :foreground "#5c6a72" :box nil)
           (tab-bar-tab-group-current :background "#3a94c5" :foreground "#fdf6e3" :weight bold)
           (tab-bar-tab-group-inactive :background "#fdf6e3" :foreground "#a6b0a0")
           (tab-bar-tab-ungrouped :background "#fdf6e3" :foreground "#5c6a72"))))

;; Gruvbox Light theme
(themes-register
 (make-theme-def
  :name 'gruvbox-light
  :display-name "Gruvbox Light"
  :description "Light variant of Gruvbox with warm, earthy tones"
  :type 'static
  :colors '((bg . "#fbf1c7")
            (fg . "#3c3836")
            (accent . "#458588")
            (highlight . "#f2e5bc")
            (selection . "#ebdbb2")
            (comment . "#7c6f64")
            (string . "#98971a")
            (keyword . "#b16286")
            (warning . "#d79921")
            (error . "#cc241d")
            (success . "#98971a"))
  :faces '((font-lock-builtin-face :foreground "#458588")
           (font-lock-function-name-face :foreground "#689d6a" :weight bold)
           (font-lock-variable-name-face :foreground "#d65d0e")
           (font-lock-type-face :foreground "#d79921")
           (font-lock-constant-face :foreground "#b16286")
           (line-number :foreground "#f2e5bc" :background "#fbf1c7")
           (line-number-current-line :foreground "#3c3836" :background "#fbf1c7" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#fbf1c7" :foreground "#3c3836" :box nil)
           (tab-bar-tab :background "#458588" :foreground "#fbf1c7" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#fbf1c7" :foreground "#3c3836" :box nil)
           (tab-bar-tab-group-current :background "#458588" :foreground "#fbf1c7" :weight bold)
           (tab-bar-tab-group-inactive :background "#fbf1c7" :foreground "#7c6f64")
           (tab-bar-tab-ungrouped :background "#fbf1c7" :foreground "#3c3836"))))

;; Solarized Light theme
(themes-register
 (make-theme-def
  :name 'solarized-light
  :display-name "Solarized Light"
  :description "Light variant of Solarized with precision colors"
  :type 'static
  :colors '((bg . "#fdf6e3")
            (fg . "#657b83")
            (accent . "#268bd2")
            (highlight . "#eee8d5")
            (selection . "#eee8d5")
            (comment . "#93a1a1")
            (string . "#2aa198")
            (keyword . "#859900")
            (warning . "#b58900")
            (error . "#dc322f")
            (success . "#859900"))
  :faces '((font-lock-builtin-face :foreground "#268bd2")
           (font-lock-function-name-face :foreground "#268bd2" :weight bold)
           (font-lock-variable-name-face :foreground "#657b83")
           (font-lock-type-face :foreground "#b58900")
           (font-lock-constant-face :foreground "#6c71c4")
           (line-number :foreground "#eee8d5" :background "#fdf6e3")
           (line-number-current-line :foreground "#657b83" :background "#fdf6e3" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#fdf6e3" :foreground "#657b83" :box nil)
           (tab-bar-tab :background "#268bd2" :foreground "#fdf6e3" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#fdf6e3" :foreground "#657b83" :box nil)
           (tab-bar-tab-group-current :background "#268bd2" :foreground "#fdf6e3" :weight bold)
           (tab-bar-tab-group-inactive :background "#fdf6e3" :foreground "#93a1a1")
           (tab-bar-tab-ungrouped :background "#fdf6e3" :foreground "#657b83"))))

;; Cyberpunk theme
(themes-register
 (make-theme-def
  :name 'cyberpunk
  :display-name "Cyberpunk"
  :description "Neon-inspired futuristic dark theme"
  :type 'static
  :colors '((bg . "#000b1e")
            (fg . "#00f0ff")
            (accent . "#0080ff")
            (highlight . "#133e7c")
            (selection . "#133e7c")
            (comment . "#133e7c")
            (string . "#00ff9f")
            (keyword . "#bd00ff")
            (warning . "#ffff00")
            (error . "#ff0055")
            (success . "#00ff9f"))
  :faces '((font-lock-builtin-face :foreground "#0080ff")
           (font-lock-function-name-face :foreground "#00ccff" :weight bold)
           (font-lock-variable-name-face :foreground "#ff00aa")
           (font-lock-type-face :foreground "#ffff00")
           (font-lock-constant-face :foreground "#bd00ff")
           (line-number :foreground "#133e7c" :background "#000b1e")
           (line-number-current-line :foreground "#00f0ff" :background "#000b1e" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#000b1e" :foreground "#00f0ff" :box nil)
           (tab-bar-tab :background "#0080ff" :foreground "#000b1e" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#000b1e" :foreground "#00f0ff" :box nil)
           (tab-bar-tab-group-current :background "#0080ff" :foreground "#000b1e" :weight bold)
           (tab-bar-tab-group-inactive :background "#000b1e" :foreground "#133e7c")
           (tab-bar-tab-ungrouped :background "#000b1e" :foreground "#00f0ff"))))

;; Zenburn theme
(themes-register
 (make-theme-def
  :name 'zenburn
  :display-name "Zenburn"
  :description "Low-contrast dark theme easy on the eyes"
  :type 'static
  :colors '((bg . "#3f3f3f")
            (fg . "#dcdccc")
            (accent . "#8cd0d3")
            (highlight . "#4f4f4f")
            (selection . "#4f4f4f")
            (comment . "#5f5f5f")
            (string . "#7f9f7f")
            (keyword . "#dc8cc3")
            (warning . "#f0dfaf")
            (error . "#cc9393")
            (success . "#7f9f7f"))
  :faces '((font-lock-builtin-face :foreground "#8cd0d3")
           (font-lock-function-name-face :foreground "#93e0e3" :weight bold)
           (font-lock-variable-name-face :foreground "#dca3a3")
           (font-lock-type-face :foreground "#f0dfaf")
           (font-lock-constant-face :foreground "#dc8cc3")
           (line-number :foreground "#4f4f4f" :background "#3f3f3f")
           (line-number-current-line :foreground "#dcdccc" :background "#3f3f3f" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#3f3f3f" :foreground "#dcdccc" :box nil)
           (tab-bar-tab :background "#8cd0d3" :foreground "#3f3f3f" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#3f3f3f" :foreground "#dcdccc" :box nil)
           (tab-bar-tab-group-current :background "#8cd0d3" :foreground "#3f3f3f" :weight bold)
           (tab-bar-tab-group-inactive :background "#3f3f3f" :foreground "#5f5f5f")
           (tab-bar-tab-ungrouped :background "#3f3f3f" :foreground "#dcdccc"))))

;; Material theme
(themes-register
 (make-theme-def
  :name 'material
  :display-name "Material"
  :description "Material Design inspired dark theme"
  :type 'static
  :colors '((bg . "#263238")
            (fg . "#eeffff")
            (accent . "#82aaff")
            (highlight . "#37474f")
            (selection . "#37474f")
            (comment . "#546e7a")
            (string . "#c3e88d")
            (keyword . "#c792ea")
            (warning . "#ffcb6b")
            (error . "#f07178")
            (success . "#c3e88d"))
  :faces '((font-lock-builtin-face :foreground "#82aaff")
           (font-lock-function-name-face :foreground "#82aaff" :weight bold)
           (font-lock-variable-name-face :foreground "#ff5370")
           (font-lock-type-face :foreground "#ffcb6b")
           (font-lock-constant-face :foreground "#89ddff")
           (line-number :foreground "#37474f" :background "#263238")
           (line-number-current-line :foreground "#eeffff" :background "#263238" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#263238" :foreground "#eeffff" :box nil)
           (tab-bar-tab :background "#82aaff" :foreground "#263238" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#263238" :foreground "#eeffff" :box nil)
           (tab-bar-tab-group-current :background "#82aaff" :foreground "#263238" :weight bold)
           (tab-bar-tab-group-inactive :background "#263238" :foreground "#546e7a")
           (tab-bar-tab-ungrouped :background "#263238" :foreground "#eeffff"))))

;; Horizon theme
(themes-register
 (make-theme-def
  :name 'horizon
  :display-name "Horizon"
  :description "Dark theme inspired by the horizon at sunset"
  :type 'static
  :colors '((bg . "#1c1e26")
            (fg . "#e0e0e0")
            (accent . "#26bbd9")
            (highlight . "#2e303e")
            (selection . "#2e303e")
            (comment . "#6c6f93")
            (string . "#29d398")
            (keyword . "#ee64ac")
            (warning . "#fab795")
            (error . "#e95678")
            (success . "#29d398"))
  :faces '((font-lock-builtin-face :foreground "#26bbd9")
           (font-lock-function-name-face :foreground "#fab795" :weight bold)
           (font-lock-variable-name-face :foreground "#b877db")
           (font-lock-type-face :foreground "#fab795")
           (font-lock-constant-face :foreground "#ee64ac")
           (line-number :foreground "#2e303e" :background "#1c1e26")
           (line-number-current-line :foreground "#e0e0e0" :background "#1c1e26" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#1c1e26" :foreground "#e0e0e0" :box nil)
           (tab-bar-tab :background "#26bbd9" :foreground "#1c1e26" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#1c1e26" :foreground "#e0e0e0" :box nil)
           (tab-bar-tab-group-current :background "#26bbd9" :foreground "#1c1e26" :weight bold)
           (tab-bar-tab-group-inactive :background "#1c1e26" :foreground "#6c6f93")
           (tab-bar-tab-ungrouped :background "#1c1e26" :foreground "#e0e0e0"))))

;; Oasis Midnight theme
(themes-register
 (make-theme-def
  :name 'oasis
  :display-name "Oasis Midnight"
  :description "Dark theme inspired by desert midnight"
  :type 'static
  :colors '((bg . "#1B242B")
            (fg . "#DDDBD5")
            (accent . "#519BFF")
            (highlight . "#335668")
            (selection . "#335668")
            (comment . "#666666")
            (string . "#53D390")
            (keyword . "#C28EFF")
            (warning . "#FFA247")
            (error . "#D06666")
            (success . "#53D390"))
  :faces '((font-lock-builtin-face :foreground "#519BFF")
           (font-lock-function-name-face :foreground "#5ABAAE" :weight bold)
           (font-lock-variable-name-face :foreground "#D2ADFF")
           (font-lock-type-face :foreground "#87CEEB")
           (font-lock-constant-face :foreground "#C28EFF")
           (line-number :foreground "#335668" :background "#1B242B")
           (line-number-current-line :foreground "#DDDBD5" :background "#1B242B" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#1B242B" :foreground "#DDDBD5" :box nil)
           (tab-bar-tab :background "#519BFF" :foreground "#1B242B" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#1B242B" :foreground "#DDDBD5" :box nil)
           (tab-bar-tab-group-current :background "#519BFF" :foreground "#1B242B" :weight bold)
           (tab-bar-tab-group-inactive :background "#1B242B" :foreground "#666666")
           (tab-bar-tab-ungrouped :background "#1B242B" :foreground "#DDDBD5"))))

;; Jellybeans theme
(themes-register
 (make-theme-def
  :name 'jellybeans
  :display-name "Jellybeans"
  :description "Dark theme with colorful, candy-like accents"
  :type 'static
  :colors '((bg . "#151515")
            (fg . "#e8e8d3")
            (accent . "#8197bf")
            (highlight . "#1c1c1c")
            (selection . "#1c1c1c")
            (comment . "#888888")
            (string . "#99ad6a")
            (keyword . "#8197bf")
            (warning . "#ffb964")
            (error . "#cf6a4c")
            (success . "#99ad6a"))
  :faces '((font-lock-builtin-face :foreground "#8fbfdc")
           (font-lock-function-name-face :foreground "#fad07a" :weight bold)
           (font-lock-variable-name-face :foreground "#c6b6ee")
           (font-lock-type-face :foreground "#ffb964")
           (font-lock-constant-face :foreground "#cf6a4c")
           (line-number :foreground "#1c1c1c" :background "#151515")
           (line-number-current-line :foreground "#e8e8d3" :background "#151515" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#151515" :foreground "#e8e8d3" :box nil)
           (tab-bar-tab :background "#8197bf" :foreground "#151515" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#151515" :foreground "#e8e8d3" :box nil)
           (tab-bar-tab-group-current :background "#8197bf" :foreground "#151515" :weight bold)
           (tab-bar-tab-group-inactive :background "#151515" :foreground "#888888")
           (tab-bar-tab-ungrouped :background "#151515" :foreground "#e8e8d3"))))

;; Paper theme
(themes-register
 (make-theme-def
  :name 'paper
  :display-name "Paper"
  :description "Light theme for LCD displays with reduced colors"
  :type 'static
  :colors '((bg . "#F2EEDE")
            (fg . "#000000")
            (accent . "#1E6FCC")
            (highlight . "#D8D5C7")
            (selection . "#D8D5C7")
            (comment . "#AAAAAA")
            (string . "#216609")
            (keyword . "#1E6FCC")
            (warning . "#B58900")
            (error . "#CC3E28")
            (success . "#216609"))
  :faces '((font-lock-builtin-face :foreground "#1E6FCC")
           (font-lock-function-name-face :foreground "#5C21A5" :weight bold)
           (font-lock-constant-face :foreground "#CC3E28")
           (line-number :foreground "#AAAAAA" :background "#F2EEDE")
           (tab-bar :background "#F2EEDE" :foreground "#000000" :box nil)
           (tab-bar-tab :background "#1E6FCC" :foreground "#F2EEDE" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#F2EEDE" :foreground "#000000" :box nil))))

;; Amber theme
(themes-register
 (make-theme-def
  :name 'amber
  :display-name "Amber"
  :description "Monochrome amber CRT terminal theme"
  :type 'static
  :colors '((bg . "#140b05")
            (fg . "#fc9505")
            (accent . "#e58806")
            (highlight . "#1c1008")
            (selection . "#1c1008")
            (comment . "#9e5d07")
            (string . "#fc9505")
            (keyword . "#e58806")
            (warning . "#e58806")
            (error . "#ff0000")
            (success . "#c56306"))
  :faces '((font-lock-builtin-face :foreground "#e58806")
           (font-lock-function-name-face :foreground "#fc9505" :weight bold)
           (font-lock-constant-face :foreground "#c56306")
           (line-number :foreground "#9e5d07" :background "#140b05")
           (tab-bar :background "#140b05" :foreground "#fc9505" :box nil)
           (tab-bar-tab :background "#e58806" :foreground "#140b05" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#140b05" :foreground "#fc9505" :box nil))))

;; Tender theme
(themes-register
 (make-theme-def
  :name 'tender
  :display-name "Tender"
  :description "24-bit dark colorscheme for comfortable coding"
  :type 'static
  :colors '((bg . "#282828")
            (fg . "#eeeeee")
            (accent . "#73cef4")
            (highlight . "#323232")
            (selection . "#323232")
            (comment . "#bbbbbb")
            (string . "#d3b987")
            (keyword . "#73cef4")
            (warning . "#ffc24b")
            (error . "#f43753")
            (success . "#c9d05c"))
  :faces '((font-lock-builtin-face :foreground "#b3deef")
           (font-lock-function-name-face :foreground "#c9d05c" :weight bold)
           (font-lock-constant-face :foreground "#ffc24b")
           (line-number :foreground "#bbbbbb" :background "#282828")
           (tab-bar :background "#282828" :foreground "#eeeeee" :box nil)
           (tab-bar-tab :background "#73cef4" :foreground "#282828" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#282828" :foreground "#eeeeee" :box nil))))

;; PaperColor Light theme
(themes-register
 (make-theme-def
  :name 'papercolor-light
  :display-name "PaperColor Light"
  :description "Light theme inspired by Google's Material Design"
  :type 'static
  :colors '((bg . "#eeeeee")
            (fg . "#444444")
            (accent . "#0087af")
            (highlight . "#bcbcbc")
            (selection . "#bcbcbc")
            (comment . "#808080")
            (string . "#008700")
            (keyword . "#0087af")
            (warning . "#d75f00")
            (error . "#af0000")
            (success . "#008700"))
  :faces '((font-lock-builtin-face :foreground "#0087af")
           (font-lock-function-name-face :foreground "#d70087" :weight bold)
           (font-lock-constant-face :foreground "#5f8700")
           (line-number :foreground "#808080" :background "#eeeeee")
           (tab-bar :background "#eeeeee" :foreground "#444444" :box nil)
           (tab-bar-tab :background "#0087af" :foreground "#eeeeee" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#eeeeee" :foreground "#444444" :box nil))))

;; PaperColor Dark theme
(themes-register
 (make-theme-def
  :name 'papercolor-dark
  :display-name "PaperColor Dark"
  :description "Dark theme inspired by Google's Material Design"
  :type 'static
  :colors '((bg . "#1c1c1c")
            (fg . "#d0d0d0")
            (accent . "#5fafd7")
            (highlight . "#585858")
            (selection . "#585858")
            (comment . "#808080")
            (string . "#5faf00")
            (keyword . "#5fafd7")
            (warning . "#d7875f")
            (error . "#af005f")
            (success . "#5faf00"))
  :faces '((font-lock-builtin-face :foreground "#00afaf")
           (font-lock-function-name-face :foreground "#ff5faf" :weight bold)
           (font-lock-constant-face :foreground "#d7af5f")
           (line-number :foreground "#808080" :background "#1c1c1c")
           (tab-bar :background "#1c1c1c" :foreground "#d0d0d0" :box nil)
           (tab-bar-tab :background "#5fafd7" :foreground "#1c1c1c" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#1c1c1c" :foreground "#d0d0d0" :box nil))))

;; Seoul256 theme
(themes-register
 (make-theme-def
  :name 'seoul256
  :display-name "Seoul256"
  :description "Low-contrast theme based on Seoul Colors"
  :type 'static
  :colors '((bg . "#3a3a3a")
            (fg . "#d0d0d0")
            (accent . "#87afaf")
            (highlight . "#4e4e4e")
            (selection . "#4e4e4e")
            (comment . "#719872")
            (string . "#87afaf")
            (keyword . "#d75faf")
            (warning . "#ffd787")
            (error . "#d7af5f")
            (success . "#719872"))
  :faces '((font-lock-builtin-face :foreground "#87afaf")
           (font-lock-function-name-face :foreground "#d7d7af" :weight bold)
           (font-lock-constant-face :foreground "#ffd787")
           (line-number :foreground "#719872" :background "#3a3a3a")
           (tab-bar :background "#3a3a3a" :foreground "#d0d0d0" :box nil)
           (tab-bar-tab :background "#87afaf" :foreground "#3a3a3a" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#3a3a3a" :foreground "#d0d0d0" :box nil))))

;; Fluoromachine theme
(themes-register
 (make-theme-def
  :name 'fluoromachine
  :display-name "Fluoromachine"
  :description "Synthwave neon-drenched retro-futuristic theme"
  :type 'static
  :colors '((bg . "#190920")
            (fg . "#49eaff")
            (accent . "#9544f7")
            (highlight . "#0d0614")
            (selection . "#0d0614")
            (comment . "#9544f7")
            (string . "#49eaff")
            (keyword . "#ffadff")
            (warning . "#ffe756")
            (error . "#ff1e34")
            (success . "#49eaff"))
  :faces '((font-lock-builtin-face :foreground "#9544f7")
           (font-lock-function-name-face :foreground "#ffadff" :weight bold)
           (font-lock-constant-face :foreground "#f38e21")
           (line-number :foreground "#9544f7" :background "#190920")
           (tab-bar :background "#190920" :foreground "#49eaff" :box nil)
           (tab-bar-tab :background "#9544f7" :foreground "#190920" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#190920" :foreground "#49eaff" :box nil))))

;; Bluloco Dark theme
(themes-register
 (make-theme-def
  :name 'bluloco-dark
  :display-name "Bluloco Dark"
  :description "Fancy and sophisticated dark designer color scheme"
  :type 'static
  :colors '((bg . "#282c34")
            (fg . "#b9c0cb")
            (accent . "#3476ff")
            (highlight . "#41444d")
            (selection . "#41444d")
            (comment . "#8f9aae")
            (string . "#3fc56b")
            (keyword . "#3476ff")
            (warning . "#f9c859")
            (error . "#fc2f52")
            (success . "#3fc56b"))
  :faces '((font-lock-builtin-face :foreground "#10b1fe")
           (font-lock-function-name-face :foreground "#ff78f8" :weight bold)
           (font-lock-constant-face :foreground "#ff936a")
           (line-number :foreground "#8f9aae" :background "#282c34")
           (tab-bar :background "#282c34" :foreground "#b9c0cb" :box nil)
           (tab-bar-tab :background "#3476ff" :foreground "#282c34" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#282c34" :foreground "#b9c0cb" :box nil))))

;; Bluloco Light theme
(themes-register
 (make-theme-def
  :name 'bluloco-light
  :display-name "Bluloco Light"
  :description "Fancy and sophisticated light designer color scheme"
  :type 'static
  :colors '((bg . "#f7f7f7")
            (fg . "#000000")
            (accent . "#1d44dd")
            (highlight . "#dddee8")
            (selection . "#dddee8")
            (comment . "#6f6f74")
            (string . "#34b253")
            (keyword . "#1d44dd")
            (warning . "#b79326")
            (error . "#c80d41")
            (success . "#34b253"))
  :faces '((font-lock-builtin-face :foreground "#1085d9")
           (font-lock-function-name-face :foreground "#c00cb2" :weight bold)
           (font-lock-constant-face :foreground "#d44d16")
           (line-number :foreground "#6f6f74" :background "#f7f7f7")
           (tab-bar :background "#f7f7f7" :foreground "#000000" :box nil)
           (tab-bar-tab :background "#1d44dd" :foreground "#f7f7f7" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#f7f7f7" :foreground "#000000" :box nil))))

;; Rusty theme
(themes-register
 (make-theme-def
  :name 'rusty
  :display-name "Rusty"
  :description "Inspired by Tomorrow Night for comfortable coding"
  :type 'static
  :colors '((bg . "#1d1f21")
            (fg . "#c5c8c6")
            (accent . "#81a2be")
            (highlight . "#282a2e")
            (selection . "#373b41")
            (comment . "#969896")
            (string . "#b5bd68")
            (keyword . "#81a2be")
            (warning . "#f0c674")
            (error . "#cc6666")
            (success . "#b5bd68"))
  :faces '((font-lock-builtin-face :foreground "#8abeb7")
           (font-lock-function-name-face :foreground "#b294bb" :weight bold)
           (font-lock-constant-face :foreground "#de935f")
           (line-number :foreground "#969896" :background "#1d1f21")
           (tab-bar :background "#1d1f21" :foreground "#c5c8c6" :box nil)
           (tab-bar-tab :background "#81a2be" :foreground "#1d1f21" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#1d1f21" :foreground "#c5c8c6" :box nil))))

;; Darcula theme
(themes-register
 (make-theme-def
  :name 'darcula
  :display-name "Darcula"
  :description "JetBrains IDE classic dark theme"
  :type 'static
  :colors '((bg . "#252024")
            (fg . "#a9b7c6")
            (accent . "#6897bb")
            (highlight . "#323232")
            (selection . "#323232")
            (comment . "#808080")
            (string . "#6a8759")
            (keyword . "#cc7832")
            (warning . "#bbb529")
            (error . "#bc3f3c")
            (success . "#6a8759"))
  :faces '((font-lock-builtin-face :foreground "#6897bb")
           (font-lock-function-name-face :foreground "#9876aa" :weight bold)
           (font-lock-constant-face :foreground "#9876aa")
           (line-number :foreground "#808080" :background "#252024")
           (tab-bar :background "#252024" :foreground "#a9b7c6" :box nil)
           (tab-bar-tab :background "#6897bb" :foreground "#252024" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#252024" :foreground "#a9b7c6" :box nil))))

;; Rosé Pine theme
(themes-register
 (make-theme-def
  :name 'rosepine
  :display-name "Rosé Pine"
  :description "All natural pine, faux fur and a bit of soho vibes"
  :type 'static
  :colors '((bg . "#191724")
            (fg . "#e0def4")
            (accent . "#31748f")
            (highlight . "#1f1d2e")
            (selection . "#1f1d2e")
            (comment . "#6e6a86")
            (string . "#f6c177")
            (keyword . "#31748f")
            (warning . "#f6c177")
            (error . "#eb6f92")
            (success . "#31748f"))
  :faces '((font-lock-builtin-face :foreground "#9ccfd8")
           (font-lock-function-name-face :foreground "#c4a7e7" :weight bold)
           (font-lock-constant-face :foreground "#ebbcba")
           (line-number :foreground "#6e6a86" :background "#191724")
           (tab-bar :background "#191724" :foreground "#e0def4" :box nil)
           (tab-bar-tab :background "#31748f" :foreground "#191724" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#191724" :foreground "#e0def4" :box nil))))

;; Rosé Pine Moon theme
(themes-register
 (make-theme-def
  :name 'rosepine-moon
  :display-name "Rosé Pine Moon"
  :description "Rosé Pine for those who prefer a more subtle palette"
  :type 'static
  :colors '((bg . "#232136")
            (fg . "#e0def4")
            (accent . "#3e8fb0")
            (highlight . "#2a273f")
            (selection . "#2a273f")
            (comment . "#6e6a86")
            (string . "#f6c177")
            (keyword . "#3e8fb0")
            (warning . "#f6c177")
            (error . "#eb6f92")
            (success . "#3e8fb0"))
  :faces '((font-lock-builtin-face :foreground "#9ccfd8")
           (font-lock-function-name-face :foreground "#c4a7e7" :weight bold)
           (font-lock-constant-face :foreground "#ea9a97")
           (line-number :foreground "#6e6a86" :background "#232136")
           (tab-bar :background "#232136" :foreground "#e0def4" :box nil)
           (tab-bar-tab :background "#3e8fb0" :foreground "#232136" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#232136" :foreground "#e0def4" :box nil))))

;; Rosé Pine Dawn theme
(themes-register
 (make-theme-def
  :name 'rosepine-dawn
  :display-name "Rosé Pine Dawn"
  :description "Rosé Pine for those who prefer a lighter palette"
  :type 'static
  :colors '((bg . "#faf4ed")
            (fg . "#575279")
            (accent . "#286983")
            (highlight . "#fffaf3")
            (selection . "#fffaf3")
            (comment . "#9893a5")
            (string . "#ea9d34")
            (keyword . "#286983")
            (warning . "#ea9d34")
            (error . "#b4637a")
            (success . "#286983"))
  :faces '((font-lock-builtin-face :foreground "#56949f")
           (font-lock-function-name-face :foreground "#907aa9" :weight bold)
           (font-lock-constant-face :foreground "#d7827e")
           (line-number :foreground "#9893a5" :background "#faf4ed")
           (tab-bar :background "#faf4ed" :foreground "#575279" :box nil)
           (tab-bar-tab :background "#286983" :foreground "#faf4ed" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#faf4ed" :foreground "#575279" :box nil))))

;; Leaf Light theme
(themes-register
 (make-theme-def
  :name 'leaf-light
  :display-name "Leaf Light"
  :description "Light variant of Leaf theme from leaf.nvim"
  :type 'static
  :colors '((bg . "#F1F5EC")
            (fg . "#3E3D3F")
            (accent . "#83B28A")
            (highlight . "#E1E4DC")
            (selection . "#D1D3CC")
            (comment . "#A0A19D")
            (string . "#E5BF79")
            (keyword . "#5EA7E3")
            (warning . "#D2846D")
            (error . "#CD6169")
            (success . "#83B28A"))
  :faces '((font-lock-builtin-face :foreground "#51AEB9")
           (font-lock-function-name-face :foreground "#9E77BD" :weight bold)
           (font-lock-variable-name-face :foreground "#609B8C")
           (font-lock-type-face :foreground "#D2846D")
           (font-lock-constant-face :foreground "#9A716F")
           (line-number :foreground "#C0C3BD" :background "#F1F5EC")
           (line-number-current-line :foreground "#3E3D3F" :background "#F1F5EC" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#F1F5EC" :foreground "#3E3D3F" :box nil)
           (tab-bar-tab :background "#83B28A" :foreground "#F1F5EC" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#F1F5EC" :foreground "#3E3D3F" :box nil)
           (tab-bar-tab-group-current :background "#83B28A" :foreground "#F1F5EC" :weight bold)
           (tab-bar-tab-group-inactive :background "#F1F5EC" :foreground "#A0A19D")
           (tab-bar-tab-ungrouped :background "#F1F5EC" :foreground "#3E3D3F"))))

;; Leaf Dark theme
(themes-register
 (make-theme-def
  :name 'leaf-dark
  :display-name "Leaf Dark"
  :description "Dark variant of Leaf theme from leaf.nvim"
  :type 'static
  :colors '((bg . "#1E1B1F")
            (fg . "#D1D3CC")
            (accent . "#83B28A")
            (highlight . "#2E2C2F")
            (selection . "#3E3D3F")
            (comment . "#6F6F6E")
            (string . "#E5BF79")
            (keyword . "#5EA7E3")
            (warning . "#D2846D")
            (error . "#CD6169")
            (success . "#83B28A"))
  :faces '((font-lock-builtin-face :foreground "#51AEB9")
           (font-lock-function-name-face :foreground "#9E77BD" :weight bold)
           (font-lock-variable-name-face :foreground "#609B8C")
           (font-lock-type-face :foreground "#D2846D")
           (font-lock-constant-face :foreground "#9A716F")
           (line-number :foreground "#5F5E5E" :background "#1E1B1F")
           (line-number-current-line :foreground "#D1D3CC" :background "#1E1B1F" :weight bold)
           ;; Tab bar faces
           (tab-bar :background "#1E1B1F" :foreground "#D1D3CC" :box nil)
           (tab-bar-tab :background "#83B28A" :foreground "#1E1B1F" :weight bold :box nil)
           (tab-bar-tab-inactive :background "#1E1B1F" :foreground "#D1D3CC" :box nil)
           (tab-bar-tab-group-current :background "#83B28A" :foreground "#1E1B1F" :weight bold)
           (tab-bar-tab-group-inactive :background "#1E1B1F" :foreground "#6F6F6E")
           (tab-bar-tab-ungrouped :background "#1E1B1F" :foreground "#D1D3CC"))))

(provide 'theme-definitions)
;;; theme-definitions.el ends here
