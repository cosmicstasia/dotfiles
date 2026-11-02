-- Replace the default launcher with oma-cast on SUPER+SPACE too.
hl.unbind("SUPER + SPACE")
o.bind("SUPER + SPACE", "oma-cast launcher", hl.dsp.global("oma-cast:toggle"))
o.bind("ALT + SPACE", "oma-cast launcher", hl.dsp.global("oma-cast:toggle"))
