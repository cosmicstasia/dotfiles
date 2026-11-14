-- Migrated from tmux, Herdr, Ghostty and kitty.

-- Programs that use ctrl+a themselves still receive it.
rex.bind("ctrl+a>ctrl+a", "pane.send_key", { key = "ctrl+a" })

-- tmux: repeat mode for bind -r keys (^a then ctrl+r enters it).
rex.mode("repeat", { exclusive = true })
rex.bind("ctrl+a>ctrl+r", "client.mode.enter", { name = "repeat" })
rex.bind("repeat/enter", "client.mode.exit")
rex.bind("repeat/escape", "client.mode.exit")

rex.bind("ctrl+a>shift+h", "client.tab.previous")
rex.bind("ctrl+a>shift+l", "client.tab.next")
rex.bind("ctrl+a>r", "client.tab.rename")
rex.bind("ctrl+a>z", "pane.zoom")
rex.bind("ctrl+a>shift+\\", "pane.split", { direction = "down" })
rex.bind("ctrl+a>s", "pane.split", { direction = "down" })
rex.bind("ctrl+a>h", "pane.focus", { direction = "left" })
rex.bind("ctrl+a>j", "pane.focus", { direction = "down" })
rex.bind("ctrl+a>k", "pane.focus", { direction = "up" })
rex.bind("ctrl+a>l", "pane.focus", { direction = "right" })
rex.bind("ctrl+a>,", "pane.resize", { amount = 20, direction = "left" })
rex.bind("repeat/,", "pane.resize", { amount = 20, direction = "left" })
rex.bind("ctrl+a>.", "pane.resize", { amount = 20, direction = "right" })
rex.bind("repeat/.", "pane.resize", { amount = 20, direction = "right" })
rex.bind("ctrl+a>=", "pane.resize", { amount = 7, direction = "up" })
rex.bind("repeat/=", "pane.resize", { amount = 7, direction = "up" })
rex.bind("ctrl+a>shift+s", "session.switch")
rex.bind("ctrl+a>shift+r", "client.config.reload")
rex.bind("ctrl+a>shift+4", "session.rename")
rex.bind("ctrl+a>-", "pane.split", { direction = "down" })
rex.bind("ctrl+a>v", "pane.split", { direction = "right" })
rex.bind("ctrl+a>c", "client.tab.new")
rex.bind("ctrl+a>shift+'", "pane.split", { direction = "down" })
rex.bind("ctrl+a>shift+5", "pane.split", { direction = "right" })
rex.bind("ctrl+a>x", "client.tab.close")
rex.bind("ctrl+a>q", "pane.close")
rex.bind("ctrl+a>ctrl+c", "client.tab.new")

-- tmux binds w and C-w to list-windows. Jump picker is the equivalent.
-- Session switch stays on prefix+S and prefix+o.
rex.bind("ctrl+a>w", "pane.go_to")
rex.bind("ctrl+a>ctrl+w", "pane.go_to")
rex.bind("ctrl+a>n", "session.new")
rex.bind("ctrl+a>shift+k", "com.superlogical.terminal.clear")

-- tmux.conf: prefix+o sesh picker. No zoxide/config half; session list only.
rex.bind("ctrl+a>o", "session.switch")

-- tmux.reset.conf: prefix+: command prompt. On a US layout : is shift+;.
rex.bind("ctrl+a>shift+;", "client.palette.toggle")

-- tmux-sensible, still live: prefix+C-n / C-p.
rex.bind("ctrl+a>ctrl+n", "client.tab.next")
rex.bind("ctrl+a>ctrl+p", "client.tab.previous")

-- Default select-window 1-9. base-index is 1. Never unbound.
rex.bind("ctrl+a>1", "client.tab.goto", { index = 1 })
rex.bind("ctrl+a>2", "client.tab.goto", { index = 2 })
rex.bind("ctrl+a>3", "client.tab.goto", { index = 3 })
rex.bind("ctrl+a>4", "client.tab.goto", { index = 4 })
rex.bind("ctrl+a>5", "client.tab.goto", { index = 5 })
rex.bind("ctrl+a>6", "client.tab.goto", { index = 6 })
rex.bind("ctrl+a>7", "client.tab.goto", { index = 7 })
rex.bind("ctrl+a>8", "client.tab.goto", { index = 8 })
rex.bind("ctrl+a>9", "client.tab.goto", { index = 9 })

-- Defaults still live: find-window, paste-buffer, break-pane.
rex.bind("ctrl+a>f", "pane.go_to")
-- tmux-fzf launch key. Palette, not process/clipboard/keybinding search.
rex.bind("ctrl+a>shift+f", "client.palette.toggle")
rex.bind("ctrl+a>]", "pane.paste")
rex.bind("ctrl+a>shift+1", "pane.move_to_new_tab")

-- kitty.
rex.bind("ctrl+shift+w", "pane.close")
rex.bind("ctrl+shift+enter", "client.window.new")
rex.bind("ctrl+shift+d", "pane.split", { direction = "down" })
rex.bind("ctrl+alt+shift+d", "pane.split", { direction = "right" })

-- No rex action, so these tmux binds are not mapped:
--   a / C-a last-window (C-a sends ctrl+a to the program instead)
--   C-d detach, C-x lock-server, * synchronize-panes, C-l refresh-client
--   p/P floax, Space thumbs, u fzf-url, y/Y yank, C-s/C-r resurrect
