# Emacs Keybindings Cheatsheet

## Quick Access
- **F5** - Reload Emacs config
- **SPC ?** or **C-SPC ?** - Open this cheatsheet
- **C-h** after any prefix key - Show available bindings with which-key

## Hydra Menus (Visual Command Popups)
- **SPC w w** - Window management hydra
- **SPC g h** - Git hydra
- **C-c l SPC** - LSP hydra (in code files with LSP)

---

## Leader Key Bindings (SPC / C-SPC)

### Files & Buffers
| Key | Command | Description |
|-----|---------|-------------|
| `SPC f` | find-file | Open file |
| `SPC b` | consult-buffer | Switch buffer |

### Tabs
| Key | Command | Description |
|-----|---------|-------------|
| `SPC c` | tab-new | Create new tab |
| `SPC vo` | tab-bar-switch-to-next-tab | Next tab |
| `SPC vO` | tab-bar-switch-to-prev-tab | Previous tab |
| `SPC vb` | switch-to-buffer-other-tab | Open buffer in new tab |
| `SPC vf` | find-file-other-tab | Open file in new tab |
| `M-1` to `M-9` | - | Jump to tab 1-9 |

### Windows & Splits
| Key | Command | Description |
|-----|---------|-------------|
| `SPC w w` | hydra-window/body | **Window Hydra Menu** |
| `SPC w v` | split-window-right | Vertical split |
| `SPC w h` | split-window-below | Horizontal split |
| `SPC w d` | delete-window | Close window |
| `SPC w o` | delete-other-windows | Close other windows |
| `C-h` | windmove-left | Move to left window |
| `C-j` | windmove-down | Move to down window |
| `C-k` | windmove-up | Move to up window |
| `C-l` | windmove-right | Move to right window |

#### Window Hydra Commands
When Window Hydra is open (`SPC w w`):
- **Split**: `v` (vertical), `s` (horizontal)
- **Switch**: `h` (left), `j` (down), `k` (up), `l` (right)
- **Resize**: `H` (shrink width), `J` (shrink height), `K` (grow height), `L` (grow width)
- **Delete**: `d` (delete window), `o` (delete others)

### Terminal & File Tree
| Key | Command | Description |
|-----|---------|-------------|
| `SPC t` | vterm-toggle | Toggle terminal |
| `SPC n` | dired-sidebar-toggle | Toggle file tree |

### Git (SPC g)
| Key | Command | Description |
|-----|---------|-------------|
| `SPC g s` | magit-status | Git status |
| `SPC g h` | hydra-git/body | **Git Hydra Menu** |
| `SPC g d` | magit-diff-unstaged | Diff unstaged |
| `SPC g c` | magit-branch-or-checkout | Branch/Checkout |
| `SPC g l` | magit-log-oneline | View log |
| `SPC g p` | magit-push | Push |
| `SPC g P` | magit-pull | Pull |
| `SPC g f` | magit-fetch | Fetch |
| `SPC g F` | magit-fetch-all | Fetch all |
| `SPC g r` | magit-rebase | Rebase |
| `SPC g n` | diff-hl-next-hunk | Next hunk |
| `SPC g o` | diff-hl-previous-hunk | Previous hunk |
| `SPC g R` | diff-hl-revert-hunk | Revert hunk |
| `SPC g S` | diff-hl-show-hunk | Show hunk |

### Themes (SPC h)
| Key | Command | Description |
|-----|---------|-------------|
| `SPC h t` | themes-load | Load theme |
| `SPC h r` | themes-reload | Reload current theme |
| `SPC h p` | themes-toggle-previous | Previous theme |
| `SPC h c` | themes-cycle | Cycle themes |
| `SPC h i` | themes-info | Theme info |
| `SPC h s` | pywal-bridge-create-static-theme | Save Pywal as static |
| `SPC h d` | themes-debug | Debug theme system |
| `SPC h D` | pywal-debug-colors | Debug Pywal colors |
| `SPC h S` | themes-config-save-current | Manual save theme |
| `SPC r` | reload-pywal | Reload Pywal |

### Jump to Directories (SPC j)
| Key | Command | Description |
|-----|---------|-------------|
| `SPC j d` | - | Documents |

---

## LSP Commands (C-c l)

### LSP Hydra Menu
Press **C-c l SPC** in any file with LSP support to open the LSP Hydra menu.

### Individual LSP Keybindings
| Key | Command | Description |
|-----|---------|-------------|
| `C-c l SPC` | hydra-lsp/body | **LSP Hydra Menu** |
| `C-c l r` | eglot-rename | Rename symbol |
| `C-c l a` | eglot-code-actions | Code actions |
| `C-c l f` | eglot-format | Format buffer |
| `C-c l d` | eldoc-doc-buffer | Show documentation |
| `C-c l i` | eglot-find-implementation | Find implementation |
| `C-c l t` | eglot-find-typeDefinition | Find type definition |
| `gd` (Evil) | xref-find-definitions | Go to definition |

### LSP Hydra Commands
When LSP Hydra is open:
- **Navigation**: `d` (definition), `i` (implementation), `t` (type def), `R` (references), `.` (find symbol)
- **Actions**: `a` (code action), `f` (format), `x` (quickfix)
- **Refactor**: `r` (rename), `o` (organize imports)
- **Info**: `D` (doc buffer), `h` (signature), `e` (errors), `s` (symbols)

---

## Flymake (Error Checking)

| Key | Command | Description |
|-----|---------|-------------|
| `C-c ! n` | flymake-goto-next-error | Next error |
| `C-c ! p` | flymake-goto-prev-error | Previous error |
| `C-c ! l` | flymake-show-buffer-diagnostics | Show buffer errors |
| `C-c ! L` | flymake-show-project-diagnostics | Show project errors |

---

## Evil Mode Bindings

### Normal Mode
| Key | Command | Description |
|-----|---------|-------------|
| `j` / `k` | - | Visual line movement |
| `u` | undo-only | Undo |
| `C-r` | undo-redo | Redo |
| `y` | evil-yank | Yank (copy) |
| `Y` | evil-yank-line | Yank line |
| `p` | evil-paste-after | Paste after |
| `P` | evil-paste-before | Paste before |
| `ZZ` | my/smart-save-and-close | Save and close |
| `ZQ` | my/smart-close-buffer | Close without saving |
| `C-t` | my/smart-ctrl-t | New tab / xref-go-back |

### Ex Commands
| Command | Description |
|---------|-------------|
| `:q` | Smart close (closes window/tab/buffer) |
| `:wq` | Smart save and close |

### Evil Plugins
- **evil-surround**: `ys`, `cs`, `ds` for surrounding text
- **evil-commentary**: `gc` to comment/uncomment
- **evil-snipe**: `s` and `S` for 2-char search
- **evil-visualstar**: `*` and `#` in visual mode

---

## Markdown Mode (when in .md files)

| Key | Command | Description |
|-----|---------|-------------|
| `SPC m p` | markdown-live-preview | Live preview |
| `SPC m P` | markdown-stop-live-preview | Stop preview |
| `SPC m i` | markdown-toggle-inline-images | Toggle images |

---

## Utility Commands

| Key | Command | Description |
|-----|---------|-------------|
| `C-c t` | insert-timestamp | Insert current time |
| `C-c y` | insert-youtube-shortcode | Insert YouTube shortcode |
| `C-c s` | insert-hugo-shortcode | Insert Hugo shortcode |
  *Note: hugo shortcodes include all of the possible shortcodes in menu form*
---

## Company (Autocomplete)

| Key | Command | Description |
|-----|---------|-------------|
| `TAB` | company-complete-selection | Complete selection |
| `C-n` | company-select-next | Next completion |
| `C-p` | company-select-previous | Previous completion |
| `RET` | company-complete-selection | Insert completion |

---

## Supported Languages & LSP Servers

| Language | Mode | LSP Server | Install Command |
|----------|------|------------|-----------------|
| **Rust** | rust-mode | rust-analyzer | (usually auto-installed) |
| **Python** | python-mode | pyright | `npm install -g pyright` |
| **TypeScript** | typescript-mode | typescript-language-server | `npm install -g typescript-language-server typescript` |
| **JavaScript** | js-mode | typescript-language-server | `npm install -g typescript-language-server typescript` |
| **React/TSX** | tsx-ts-mode | typescript-language-server | (same as above) |
| **React/JSX** | web-mode | vscode-html-language-server | `npm install -g vscode-langservers-extracted` |
| **JSON** | json-mode | vscode-json-language-server | `npm install -g vscode-langservers-extracted` |
| **HTML/CSS** | web-mode | vscode-html-language-server | `npm install -g vscode-langservers-extracted` |
| **Bash** | sh-mode | bash-language-server | `npm install -g bash-language-server` |
| **Nix** | nix-mode | nil or nixd | `nix profile install nixpkgs#nil` |
| **C/C++** | c-mode, c++-mode | clangd | (system package manager) |
| **Lua** | lua-mode | lua-language-server | (system package manager) |

---

## Tips

1. **Discover keybindings**: Press `SPC` and wait - which-key will show all available bindings
2. **LSP quick access**: Press `C-c l SPC` in code files to see the LSP hydra menu, or use individual `C-c l` commands
3. **Git quick access**: Press `SPC g h` to see the Git hydra menu
4. **Window management**: Press `SPC w w` for the window hydra menu
5. **Custom config reload**: Press `F5` to reload your config without restarting
6. **Help system**: `C-h k` (describe-key), `C-h f` (describe-function), `C-h v` (describe-variable)

---

*Last updated: 2026-02-02*
