# Emacs Theme System

A Doom Emacs-inspired theme management system for your Emacs configuration.

## Features

- **Multiple Built-in Themes**: Doom One, Dracula, Gruvbox, Nord, Tokyo Night, Solarized, Catppuccin, and more
- **Pywal Integration**: Seamless integration with your existing pywal setup
- **Easy Theme Switching**: Quick keybindings for theme management
- **Custom Theme Support**: Create and register your own themes
- **Theme Persistence**: Remember your theme across sessions
- **Hook System**: Run custom code when themes change
- **Color Utilities**: Built-in functions for color manipulation

## Quick Start

### Keybindings (with SPC leader key)

| Key Combination | Function | Description |
|---|---|---|
| `SPC h t` | `themes-load` | Load/switch to a theme |
| `SPC h r` | `themes-reload` | Reload current theme |
| `SPC h p` | `themes-toggle-previous` | Switch to previous theme |
| `SPC h c` | `themes-cycle` | Cycle through all themes |
| `SPC h i` | `themes-info` | Show current theme info |
| `SPC h s` | `pywal-bridge-create-static-theme` | Save current pywal colors as static theme |
| `SPC h d` | `pywal-debug-colors` | Debug pywal colors |

### Available Themes

- **`pywal`** - Dynamic theme using pywal colors (default)
- **`doom-one`** - Dark theme inspired by Atom One Dark
- **`doom-one-light`** - Light variant of Doom One
- **`dracula`** - Dark theme with purple accents
- **`gruvbox`** - Retro groove color scheme
- **`nord`** - Arctic, north-bluish color palette
- **`tokyo-night`** - Clean, dark theme inspired by Tokyo Night
- **`solarized-dark`** - Precision colors for machines and people
- **`catppuccin`** - Soothing pastel theme

## Usage Examples

### Basic Theme Switching
```elisp
;; Load a theme
(themes-load 'doom-one)

;; Cycle through themes
(themes-cycle)

;; Go back to previous theme
(themes-toggle-previous)
```

### Creating Custom Themes
```elisp
(themes-register
 (make-theme-def
  :name 'my-theme
  :display-name "My Custom Theme"
  :description "A theme I created"
  :type 'static
  :colors '((bg . "#1a1a1a")
            (fg . "#ffffff")
            (accent . "#ff6b6b"))
  :faces '((font-lock-keyword-face :foreground "#ff6b6b" :weight bold))))
```

### Pywal Integration

The theme system seamlessly integrates with your existing pywal setup:

- **Dynamic Updates**: When pywal colors change, the theme updates automatically
- **Color Extraction**: Pywal colors are mapped to semantic theme colors
- **Static Snapshots**: Save current pywal colors as a static theme for later use

### Advanced Features

#### Theme Hooks
Run custom code when themes change:

```elisp
(themes-add-hook 
 (lambda ()
   (message "Theme changed to: %s" themes--current-theme)))
```

#### Color Utilities
Built-in functions for color manipulation:

```elisp
;; Lighten a color by 20%
(themes--lighten-color "#ff0000" 0.2)

;; Darken a color by 30%
(themes--darken-color "#ff0000" 0.3)

;; Blend two colors
(themes--blend-colors "#ff0000" "#00ff00" 0.5)
```

#### Theme Persistence
Automatically save and restore your current theme:

```elisp
;; In themes-config.el (already set up)
(themes-add-hook 'themes-config-save-current)
(add-hook 'after-init-hook 'themes-config-load-saved)
```

## Configuration

### Customization Variables

```elisp
;; Set default theme
(setq themes-default-theme 'doom-one)

;; Enable/disable pywal integration
(setq themes-enable-pywal-integration t)
```

### Theme-Specific Customizations

Add custom behavior for specific themes in `themes-config.el`:

```elisp
(themes-add-hook 
 (lambda ()
   (pcase themes--current-theme
     ('gruvbox
      ;; Custom setup for Gruvbox
      (set-face-attribute 'default nil :height 105))
     ('doom-one
      ;; Custom setup for Doom One
      (set-face-attribute 'default nil :height 110)))))
```

## File Structure

```
.emacs.d/lisp/
├── themes.el              # Core theme system
├── theme-definitions.el   # Built-in theme definitions  
├── pywal-bridge.el       # Pywal integration
└── themes-config.el      # Configuration and examples
```

## Integration with Existing Setup

The theme system is designed to work alongside your existing configuration:

- **Pywal Compatibility**: Your existing pywal setup continues to work
- **Face Preservation**: Existing face customizations are respected
- **Module System**: Integrates with your modular configuration structure
- **Keybinding Integration**: Uses your existing leader key system

## Troubleshooting

### Theme not loading
```elisp
;; Check if theme is registered
(themes-list)

;; Get theme info
(themes-info 'theme-name)
```

### Pywal not working
```elisp
;; Debug pywal colors
(pywal-debug-colors)

;; Check pywal bridge status
(pywal-bridge-setup)
```

### Colors not applying
```elisp
;; Reload current theme
(themes-reload)

;; Check face definitions
(describe-face 'default)
```

## Extending the System

### Adding New Themes

1. Create a theme definition in `theme-definitions.el` or `themes-config.el`
2. Use `themes-register` to add it to the system
3. The theme becomes immediately available

### Custom Color Schemes

You can create themes that:
- Use static color definitions
- Pull colors from external sources
- Dynamically generate colors
- Integrate with other programs

### External Integration

The theme system can integrate with:
- Terminal emulators
- Compositor effects (picom)
- Other Emacs packages
- External color management tools

## Contributing

To add new built-in themes:
1. Add the theme definition to `theme-definitions.el`
2. Follow the existing naming and structure conventions
3. Test with various face combinations
4. Update this documentation

---

Enjoy your new theme system! 🎨