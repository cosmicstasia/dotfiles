# CosmicEmacs Configuration

A sophisticated, modular Emacs configuration designed for Vim users, content creators, and developers. Features a custom Doom-inspired theme system, comprehensive Evil mode integration, advanced Markdown support, and seamless Pywal integration.

---

## 📋 Table of Contents

- [Features](#-features)
- [Quick Start](#-quick-start)
- [Configuration Structure](#-configuration-structure)
- [Keybindings](#-keybindings)
- [Theme System](#-theme-system)
- [Development Tools](#-development-tools)
- [Markdown & Writing](#-markdown--writing)
- [Dependencies](#-dependencies)
- [Customization](#-customization)

---

## ✨ Features

### Core Capabilities
- **🎨 Advanced Theme System**: 25+ hand-tuned themes with custom Doom-inspired implementation
- **⚡ Full Vim Emulation**: Evil mode with leader keys, modal editing, and all your favorite plugins
- **📝 Rich Markdown Support**: Live preview, Hugo shortcodes, pretty rendering, and more
- **🔗 Wiki Links**: Vimwiki-style `[[link]]` syntax with folder paths, visual mode multi-word selection, and smart concealment
- **🔧 LSP Integration**: Language servers for Rust, Bash, Nix, C/C++, and Lua
- **🌈 Pywal Integration**: Dynamic theming that syncs with your system colors
- **📁 File Tree Sidebar**: Dired-based explorer with Nerd Icons
- **🔀 Git Integration**: Full Magit support with diff highlighting
- **📊 Integrated Terminal**: VTerm with project awareness
- **✍️ Smart Note-Taking**: Daily notes with templates and quick timestamped notes

### Unique Features
- **Custom theme engine** with color manipulation utilities (lighten/darken/blend)
- **Time-based theme switching** (different themes for morning/afternoon/evening)
- **External theme coordination** (maps system theme names to Emacs themes)
- **Hugo shortcode system** with interactive parameter prompts
- **Vim-style spell checking** interface (zg, z=, ]s, [s)
- **Dashboard with custom banner** and quick access links

---

## 🚀 Quick Start

### Installation

```bash
# Backup your existing config
mv ~/.config/emacs ~/.config/emacs.backup

# Clone this repository
git clone <your-repo-url> ~/.config/emacs

# Install Nerd Fonts (required for icons)
# On first run, Emacs will also prompt to install nerd-icons fonts
```

### First Launch

1. Start Emacs
2. Packages will auto-install on first run
3. Run `M-x nerd-icons-install-fonts` to install icon fonts
4. Choose your theme with `SPC h t`
5. Reload config with `F5`

### Essential Keybindings

| Key | Action |
|-----|--------|
| `SPC` | Leader key (in normal mode) |
| `C-SPC` | Leader key (global) |
| `F5` | Reload configuration |
| `C-h/j/k/l` | Navigate windows (left/down/up/right) |

---

## 📂 Configuration Structure

```
.config/emacs/
├── init.el                 # Main entry point
├── custom.el              # Emacs customize interface
├── lisp/                  # Modular configuration (29 files)
│   ├── Theme System
│   │   ├── themes.el              # Core theme engine
│   │   ├── theme-definitions.el   # 25+ pre-defined themes
│   │   ├── themes-config.el       # Theme persistence & scheduling
│   │   ├── pywal.el              # Pywal color integration
│   │   └── pywal-bridge.el       # Pywal/theme coordination
│   │
│   ├── Evil & Keybindings
│   │   ├── evil-setup.el         # Vim emulation
│   │   └── helpers.el            # Leader keys & utilities
│   │
│   ├── UI & Visual
│   │   ├── ui.el                 # Basic UI setup
│   │   ├── fonts.el              # Font configuration
│   │   ├── powerline-setup.el    # Status bar
│   │   ├── tabs.el               # Tab bar with icons
│   │   └── dashboard-setup.el    # Startup screen
│   │
│   ├── File Management
│   │   ├── dired-setup.el        # File explorer
│   │   ├── completion.el         # Vertico/Ivy
│   │   └── minibuffer.el         # Minibuffer tweaks
│   │
│   ├── Development
│   │   ├── lsp.el                # Language servers
│   │   ├── git.el                # Magit & diff-hl
│   │   └── vterm-setup.el        # Terminal
│   │
│   ├── Writing & Notes
│   │   ├── markdown-setup.el     # Markdown features
│   │   ├── wiki-links.el         # Vimwiki-style links
│   │   └── spell.el              # Spell checking
│   │
│   └── Utilities
│       ├── pairing.el            # Auto-pairs
│       ├── scrolling.el          # Smooth scrolling
│       ├── clipboard-tty.el      # TTY clipboard
│       ├── cache-management.el   # XDG-compliant caching
│       └── server-init.el        # Emacs server
│
├── elpa/                  # Installed packages
└── .cache/               # Runtime cache (backups, etc.)
```

---

## ⌨️ Keybindings

### Leader Key System

The configuration uses `SPC` as the leader key in normal mode, `C-SPC` globally.

#### File & Buffer Management

| Key | Command | Description |
|-----|---------|-------------|
| `SPC f` | find-file | Find/open file |
| `SPC b` | switch-buffer | Switch buffer |
| `SPC n` | toggle-sidebar | File tree sidebar |

#### Tabs & Windows

| Key | Command | Description |
|-----|---------|-------------|
| `SPC c` | new-tab | Create new tab |
| `SPC vo` | next-tab | Next tab |
| `SPC vO` | prev-tab | Previous tab |
| `M-1` to `M-9` | select-tab | Jump to tab 1-9 |
| `SPC w v` | split-vertical | Vertical split |
| `SPC w h` | split-horizontal | Horizontal split |
| `SPC w d` | delete-window | Delete window |
| `SPC w o` | delete-other-windows | Delete other windows |
| `SPC w w` | other-window | Switch window |

#### Git Operations

| Key | Command | Description |
|-----|---------|-------------|
| `SPC g s` | magit-status | Git status |
| `SPC g d` | magit-diff | Diff unstaged |
| `SPC g c` | branch-checkout | Branch/checkout |
| `SPC g l` | magit-log | Git log |
| `SPC g p` | magit-push | Push |
| `SPC g P` | magit-pull | Pull |
| `SPC g f` | magit-fetch | Fetch |
| `SPC g n` | next-hunk | Next git hunk |
| `SPC g o` | prev-hunk | Previous hunk |
| `SPC g R` | revert-hunk | Revert hunk |

#### Theme Management

| Key | Command | Description |
|-----|---------|-------------|
| `SPC h t` | load-theme | Load theme (picker) |
| `SPC h r` | reload-theme | Reload current theme |
| `SPC h p` | previous-theme | Previous theme |
| `SPC h c` | cycle-themes | Cycle through themes |
| `SPC h i` | theme-info | Show theme info |
| `SPC h s` | save-pywal-static | Save Pywal as static theme |
| `SPC h d` | debug-theme | Debug theme system |

#### Markdown

| Key | Command | Description |
|-----|---------|-------------|
| `SPC m p` | markdown-preview | Start live preview |
| `SPC m P` | stop-preview | Stop preview |
| `SPC m i` | toggle-images | Toggle inline images |
| `SPC m l` | follow-wiki-link | Follow wiki link at point |
| `RET` (normal) | smart-follow | Follow link or linkify word at cursor |
| `RET` (visual) | smart-follow | Linkify selected text (multi-word support) |
| `C-c s` | insert-shortcode | Insert Hugo shortcode |
| `C-c y` | youtube-shortcode | Insert YouTube shortcode |
| `C-c t` | insert-timestamp | Insert timestamp |

#### Spell Checking (Vim-style)

| Key | Command | Description |
|-----|---------|-------------|
| `z=` | correct-word | Correct word at point |
| `zg` | add-word | Add word to dictionary |
| `zw` | remove-word | Remove word from dictionary |
| `]s` | next-error | Next spelling error |
| `[s` | prev-error | Previous spelling error |

#### File Tree Sidebar (when focused)

| Key | Command | Description |
|-----|---------|-------------|
| `j/k` | down/up | Navigate files |
| `l` | open | Open file/folder |
| `h` | parent | Go to parent directory |
| `r` | refresh | Refresh sidebar |
| `I` | toggle-hidden | Show/hide hidden files |
| `d` | toggle-details | Toggle file details |
| `q` | quit | Close sidebar |
| `SPC n` | toggle-sidebar | Close sidebar |

#### Terminal

| Key | Command | Description |
|-----|---------|-------------|
| `SPC t` | vterm-toggle | Toggle terminal |
| `C-RET` | insert-dir | Insert current directory |

#### Other Utilities

| Key | Command | Description |
|-----|---------|-------------|
| `F5` | reload-config | Reload Emacs config |
| `C-t` | smart-toggle | xref-go-back or new-tab |
| `C-h/j/k/l` | window-nav | Navigate windows |

---

## 🎨 Theme System

### Available Themes

**Dark Themes:**
- Pywal (dynamic system colors)
- Doom One, Doom Dracula, Doom Nord
- Gruvbox Dark, Tokyo Night, Catppuccin Mocha
- Ayu Dark, Everforest Dark, Rose Pine
- Nord, Zenburn, Solarized Dark
- Material, One Dark, Monokai Pro

**Light Themes:**
- Doom One Light, Doom Solarized Light
- Gruvbox Light, Everforest Light
- Rose Pine Dawn, Catppuccin Latte
- Solarized Light

### Using Themes

```elisp
;; Load a theme
SPC h t (then select from list)

;; Cycle through themes
SPC h c

;; Go back to previous theme
SPC h p

;; Reload current theme (if colors look off)
SPC h r

;; Get theme information
SPC h i
```

### Pywal Integration

The config includes deep Pywal integration:

1. **Automatic syncing**: Watches `~/.cache/wal/colors.json` for changes
2. **Debounced reload**: 250ms delay to avoid flickering
3. **Smart coordination**: Won't override when using other themes
4. **Save as static**: `SPC h s` to save current Pywal colors as permanent theme

### Time-Based Theme Switching

Edit `themes-config.el` to enable automatic theme switching:

```elisp
(defun themes-config-get-scheduled-theme ()
  (let ((hour (string-to-number (format-time-string "%H"))))
    (cond
     ((< hour 6)  'doom-one)           ; Night
     ((< hour 9)  'gruvbox)            ; Early morning
     ((< hour 17) 'doom-one-light)     ; Day
     ((< hour 20) 'everforest-light)   ; Late afternoon
     (t           'tokyo-night))))     ; Evening
```

---

## 🔧 Development Tools

### Supported Languages

| Language | LSP Server | Features |
|----------|-----------|----------|
| Rust | rust-analyzer | Full LSP, format-on-save |
| Bash/Shell | bash-language-server | Completion, linting |
| Nix | nil | Nix expression support |
| C/C++ | clangd | IntelliSense, navigation |
| Lua | lua-language-server | Completion, diagnostics |

### LSP Features

- **Code completion** via Company mode
- **Jump to definition** with `M-.`
- **Find references** with `M-?`
- **Rename symbol** with `C-c r n`
- **Format buffer** with `C-c r f`
- **Code actions** with `C-c r a`

### Git Workflow

1. Open Magit status: `SPC g s`
2. Stage files: `s` on file
3. Commit: `c c`, write message, `C-c C-c`
4. Push: `P p`
5. View diff of changes: `SPC g d`
6. Navigate hunks in buffer: `SPC g n` / `SPC g o`

---

## 📝 Markdown & Writing

### Live Preview

Start a Hugo development server for live Markdown preview:

```elisp
SPC m p  ; Start preview
SPC m P  ; Stop preview
```

### Hugo Shortcodes

Interactive shortcode insertion with `C-c s`:

- **wrap**: Wrapped images with float/caption
- **image**: Simple image insertion
- **figure**: Image with caption
- **youtube**: YouTube video embed
- **collapse**: Collapsible content sections
- **code**: Code blocks with syntax highlighting

Example workflow:
1. Press `C-c s`
2. Select shortcode type
3. Answer prompts for parameters
4. Shortcode is inserted at cursor

### Markdown Rendering

In normal mode, Markdown files display with:
- **Pretty bullets**: `- ` → `•`
- **Checkboxes**: `[ ]` → `☐`, `[x]` → `☑`
- **Links with icons**: 🔗 for links, 🖼 for images, 📝 for wiki links
- **Scaled headers**: H1 (1.6x) down to H6 (1.0x)

Switch to insert mode to see raw Markdown.

### Wiki Links

Vimwiki-style wiki links for interconnected note-taking with advanced folder support:

**Syntax:**
```markdown
[[page-name]]                    → Links to page-name.md
[[folder/page-name]]             → Links to folder/page-name.md (creates folder if needed)
[[path/to/nested/file]]          → Supports deep nested paths
[[page-name|Display Text]]       → Link with custom display text
[[folder/file.md]]               → .md extension optional
```

**Usage:**
1. **Create links from single words**: Position cursor on any word in normal mode and press `RET`
   - The word becomes `[[word]]` and `word.md` is created/opened

2. **Create links from multiple words**: Select text in visual mode and press `RET`
   - Example: Visually select "my cool project" → becomes `[[my cool project]]`
   - Opens/creates `my cool project.md`

3. **Follow existing links**: Press `RET` on a `[[link]]` to open the file
   - Automatically creates directories if they don't exist

4. **Smart concealment**:
   - **Normal mode**: `[[folder/file]]` appears as `📝 file` (path hidden, only filename shown)
   - **Insert mode**: Full syntax `[[folder/file]]` is visible for editing

**Example workflows:**

*Single word linkification:*
```markdown
I need to work on the project today.
       ↓ (cursor on "project", press RET)
I need to work on the [[project]] today.
       ↓ (in normal mode, appears as)
I need to work on the 📝 project today.
```

*Multi-word linkification (visual mode):*
```markdown
Check out my cool new idea for the blog.
             ^^^^^^^^^^^^
             (visually select, press RET)
       ↓
Check out my [[cool new idea]] for the blog.
       ↓ (in normal mode, appears as)
Check out my 📝 cool new idea for the blog.
```

*Folder organization:*
```markdown
See [[projects/coding/new-app]] for details.
       ↓ (press RET - creates projects/coding/ directories)
       ↓ (in normal mode, appears as)
See 📝 new-app for details.
```

All wiki links are relative to the current file's directory, with automatic directory creation for organized note hierarchies.

---

## 📦 Dependencies

### Required

- **Emacs 25.1+** (28+ recommended)
- **Git**
- **Nerd Fonts** (for icons)

### External System Packages

> **Important:** These are system-level packages that Emacs calls externally. They **must** be installed on your system and cannot be managed by Emacs's package manager.

#### Language Servers (for LSP support)

Install the language servers for the languages you want to use:

```bash
# Arch/Manjaro
sudo pacman -S rust-analyzer bash-language-server lua-language-server clang nil

# NixOS - add to your configuration.nix packages:
# rust-analyzer
# nodePackages.bash-language-server
# lua-language-server
# clang-tools  # provides clangd
# nil          # Nix language server

# Cargo
cargo install rust-analyzer

# NPM
npm install -g bash-language-server

# For Nix LSP
nix-env -iA nixpkgs.nil
```

#### Spell Checking

```bash
# Arch/Manjaro
sudo pacman -S aspell aspell-en

# Debian/Ubuntu
sudo apt install aspell aspell-en

# NixOS - add to your configuration.nix packages:
# aspell
# aspellDicts.en
```

#### Pywal (Optional)

For dynamic theming that syncs with system colors:

```bash
# Arch/Manjaro
sudo pacman -S python-pywal

# pip
pip install pywal

# NixOS - add to your configuration.nix packages:
# python3Packages.pywal
```

#### Hugo (Optional)

For Markdown live preview functionality:

```bash
# Arch/Manjaro
sudo pacman -S hugo

# Debian/Ubuntu
sudo apt install hugo

# NixOS - add to your configuration.nix packages:
# hugo
```

### NixOS Users

If you're using NixOS, add these packages to your `configuration.nix` or `home.nix`:

```nix
users.users.<username>.packages = with pkgs; [
  # Required
  emacs
  git
  # Build tools for vterm compilation
  cmake
  gnumake
  gcc
  libtool
  libvterm
  (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })

  # Language servers (optional, for LSP)
  rust-analyzer
  nodePackages.bash-language-server
  lua-language-server
  clang-tools  # provides clangd
  nil          # Nix language server

  # Spell checking
  aspell
  aspellDicts.en

  # Optional tools
  python3Packages.pywal  # Dynamic theming
  hugo                   # Markdown preview
];
```

> **Note:** Do NOT install Emacs packages (like `markdown-mode`, `vterm`, `powerline`) through Nix. These are managed by Emacs's package manager and will be auto-installed on first launch.
>
> **Important:** VTerm requires build tools (`cmake`, `gnumake`, `gcc`, `libtool`, `libvterm`) to compile its native module. Without these, you'll get compilation errors when VTerm tries to install.

---

## 🔨 Customization

### Changing Fonts

Edit `lisp/fonts.el`:

```elisp
(set-face-attribute 'default nil
  :family "JetBrainsMono Nerd Font"
  :height 130)  ; Change size (130 = 13pt)
```

### Modifying Leader Key

Edit `init.el`:

```elisp
(defun my/leader-keys (&rest args)
  (apply #'general-define-key
    :states '(normal visual emacs)
    :prefix "SPC"     ; Change to your preferred key
    :global-prefix "C-SPC"
    args))
```

### Adding Custom Themes

Edit `lisp/theme-definitions.el`:

```elisp
(deftheme-custom my-custom-theme "My Custom Theme"
  :colors '((bg       . "#1e1e2e")
            (fg       . "#cdd6f4")
            (red      . "#f38ba8")
            ;; ... define 16 colors
            )
  :faces
  (theme-set-faces
   'my-custom-theme
   `(default ((t (:background ,bg :foreground ,fg))))
   ;; ... customize faces
   ))
```

Then add to `themes-available-themes` list.

### Disabling Modules

Edit `init.el` and comment out unwanted modules:

```elisp
(dolist (m '(ui fonts themes ...
             ;; dired-setup  ; Disable file tree
             ;; spell        ; Disable spell checking
             ))
  (require m nil t))
```

### Adding Keybindings

Edit `lisp/helpers.el`:

```elisp
(my/leader-keys
  "x" '(my-custom-function :which-key "My Function"))
```

---

## 🐛 Troubleshooting

### Icons not displaying

Run `M-x nerd-icons-install-fonts` and restart Emacs.

### LSP not working

1. Verify language server is installed: `which rust-analyzer`
2. Check `*eglot-events*` buffer for errors
3. Restart LSP: `M-x eglot-reconnect`

### Pywal colors not updating

1. Check if file exists: `cat ~/.cache/wal/colors.json`
2. Reload manually: `SPC r` (reload-pywal)
3. Check `*Messages*` buffer for errors

### Theme looks broken

1. Reload theme: `SPC h r`
2. Check for conflicting packages
3. Verify faces with `M-x describe-face`

### Slow startup

1. Check package load times: `M-x esup`
2. Disable unused modules in `init.el`
3. Ensure packages use `:defer` or `:hook` in `use-package`

---

## 📄 License

This configuration is provided as-is for personal use. Feel free to use, modify, and share.

---

## 🙏 Acknowledgments

Inspired by:
- [Doom Emacs](https://github.com/doomemacs/doomemacs)
- [Spacemacs](https://www.spacemacs.org/)
- The Emacs and Vim communities

Built with:
- [Evil Mode](https://github.com/emacs-evil/evil)
- [Magit](https://magit.vc/)
- [use-package](https://github.com/jwiegley/use-package)
- [General.el](https://github.com/noctuid/general.el)
- And many more amazing packages

---

**Happy Editing!** 🚀

*"I Still Like Vim Better."* - But now with Emacs superpowers.
