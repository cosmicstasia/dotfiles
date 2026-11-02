-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Restore live Wallpaper Engine wallpaper on login (omarchy-wallpaper-engine),
-- on a machine that has it installed (~/.local/bin/omarchy-we, per-machine
-- plugin install, not chezmoi-managed).
if o.cmd_present("omarchy-we") then
  o.launch_on_start("omarchy-we launch")
end
