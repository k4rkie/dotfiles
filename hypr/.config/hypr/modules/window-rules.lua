-- Window rules + workspace rules.

-- dwindle pseudotile, no focus for XWayland empty windows
hl.window_rule({
  name     = "fix-xwayland-drags",
  match    = {
    class      = "^$",
    title      = "^$",
    xwayland   = true,
    float      = true,
    fullscreen = false,
    pin        = false,
  },
  no_focus = true,
})

hl.window_rule({
  name  = "float-pavucontrol",
  match = { class = "^(org.pulseaudio.pavucontrol)$" },
  float = true,
  size  = "1000 650",
})

hl.window_rule({
  name  = "float-blueman",
  match = { class = "^(blueman-manager)$" },
  float = true,
  size  = "1200 800",
})

hl.window_rule({
  name  = "float-qalculate",
  match = { class = "^(qalculate)$" },
  float = true,
})

hl.window_rule({
  name  = "float-imv",
  match = { class = "imv" },
  float = true,
})

hl.window_rule({
  name   = "float-rmpc",
  match  = { class = "rmpc" },
  float  = true,
  center = true,
  size   = "1200 800",
})

hl.window_rule({
  name   = "float-btop",
  match  = { class = "btop" },
  float  = true,
  center = true,
  size   = "1200 800",
})

hl.window_rule({
  name   = "center-file-picker-portal",
  match  = { class = "xdg-desktop-portal-gtk" },
  float  = true,
  center = true,
  size   = "1200 800",
})

hl.window_rule({
  name   = "float-satty",
  match  = { class = "com.gabm.satty" },
  float  = true,
  center = true,
  size   = "1250 800",
})

hl.window_rule({
  name      = "force-current-ws",
  match     = { class = ".*" },
  workspace = "current",
})

hl.window_rule({
  name      = "browser-on-1",
  match     = { class = "^(zen-beta|firefox|google-chrome)$" },
  opaque    = true,
  workspace = "1",
})

-- Workspace rules
hl.workspace_rule({ workspace = "7", gaps_in = 8, gaps_out = 100 })

