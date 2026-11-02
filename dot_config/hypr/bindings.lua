-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

local paths = require("default.hypr.paths")

-- Vim-style window navigation.
-- Rehome defaults that conflicted with SUPER+J/K/L:
--   SUPER+J was Toggle window split -> SUPER+ALT+J
--   SUPER+K was Keybindings -> SUPER+ALT+K
--   SUPER+ALT+K was Tmux keybindings -> SUPER+SHIFT+ALT+K
--   SUPER+L was Toggle workspace layout -> SUPER+ALT+L
hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + L")
hl.unbind("SUPER + ALT + K")

-- Sensible replacement bindings for the displaced actions.
o.bind("SUPER + ALT + J", "Toggle window split", hl.dsp.layout("togglesplit"))
o.bind("SUPER + ALT + K", "Keybindings", "omarchy-menu-keybindings")
o.bind("SUPER + SHIFT + ALT + K", "Tmux keybindings", "omarchy-menu-tmux-keybindings")
o.bind("SUPER + ALT + L", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")

-- Focus windows with SUPER+H/J/K/L.
o.bind("SUPER + H", "Focus on left window", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + J", "Focus on below window", hl.dsp.focus({ direction = "d" }))
o.bind("SUPER + K", "Focus on above window", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + L", "Focus on right window", hl.dsp.focus({ direction = "r" }))

-- Move windows with SUPER+SHIFT+H/J/K/L.
o.bind("SUPER + SHIFT + H", "Move window left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + SHIFT + J", "Move window down", hl.dsp.window.swap({ direction = "d" }))
o.bind("SUPER + SHIFT + K", "Move window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + SHIFT + L", "Move window right", hl.dsp.window.swap({ direction = "r" }))

-- Fullscreen, theme-aware flip clock, on a machine with the quickshell
-- plugin installed (~/.config/omarchy/plugins/anastasia.ascii-clock,
-- per-machine quickshell plugin, not chezmoi-managed).
if o.cmd_present(paths.config_home .. "/omarchy/plugins/anastasia.ascii-clock") then
  o.bind("SUPER + ALT + C", "Flip clock", "omarchy-shell shell toggle anastasia.ascii-clock")
end

-- Thundercloud fullscreen moon overlay, same per-machine quickshell plugin story.
if o.cmd_present(paths.config_home .. "/omarchy/plugins/anastasia.thundercloud") then
  o.bind("SUPER + ALT + M", "Thundercloud", "omarchy-shell shell toggle anastasia.thundercloud")
end

-- Use Podman instead of Omarchy's default Docker TUI binding, on a machine
-- with the wrapper script installed (~/.local/bin/omarchy-launch-podman-tui,
-- per-machine, not chezmoi-managed).
if o.cmd_present(paths.home .. "/.local/bin/omarchy-launch-podman-tui") then
  hl.unbind("SUPER + SHIFT + D")
  o.bind("SUPER + SHIFT + D", "Podman", paths.home .. "/.local/bin/omarchy-launch-podman-tui")
end

-- Use TUIOS as the multiplexer in the default terminal, on a machine with
-- it on PATH. Replace Omarchy's Tmux shortcut; keep SUPER+SHIFT+RETURN for
-- Browser.
if o.cmd_present("tuios") then
  hl.unbind("SUPER + ALT + RETURN")
  o.bind("SUPER + ALT + RETURN", "Terminal with TUIOS", "omarchy-launch-terminal tuios")
end

-- strata-installer: file-manager start
hl.unbind("SUPER + SHIFT + F")
hl.unbind("SUPER + ALT + SHIFT + F")
o.bind("SUPER + SHIFT + F", "File manager", { launch = paths.home .. "/.local/bin/strata" })
o.bind("SUPER + ALT + SHIFT + F", "File manager (cwd)",
  "uwsm-app -- " .. paths.home .. "/.local/bin/strata \"$(omarchy-cmd-terminal-cwd)\"")
-- strata-installer: file-manager end
