-- General layout, decoration (opacity/blur/shadow), animations + curves.
hl.config({
  general = {
    gaps_in     = 6,
    gaps_out    = 8,
    border_size = 2,
    col         = {
      active_border   = "rgb(7D718F)",
      inactive_border = "rgb(202020)",
    },
    layout      = "dwindle",
  },
  decoration = {
    rounding         = 0,
    active_opacity   = 0.95,
    inactive_opacity = 0.90,
    shadow           = {
      enabled      = true,
      range        = 12,
      render_power = 3,
      color        = "rgba(000000bb)",
    },
    blur             = {
      enabled    = true,
      size       = 12,
      passes     = 2,
      noise      = 0.02,
      contrast   = 2.0,
      brightness = 0.5,
      vibrancy   = 2.0,
      special    = false,
      popups     = false,
    },
  },
  animations = {
    enabled = true,
  },
})

-- Animation curves
hl.curve("snappy", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("smooth", { type = "bezier", points = { { 0.5, 0.0 }, { 0.5, 1.0 } } })

-- Animation overrides
hl.animation({ leaf = "windows",      enabled = true, speed = 1.5, bezier = "snappy",  style = "popin" })
hl.animation({ leaf = "windowsOut",   enabled = true, speed = 1.5, bezier = "snappy",  style = "popin" })
hl.animation({ leaf = "border",       enabled = true, speed = 10,  bezier = "default" })
hl.animation({ leaf = "borderangle",  enabled = true, speed = 8,   bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 3,   bezier = "snappy" })
hl.animation({ leaf = "workspaces",   enabled = true, speed = 2,   bezier = "snappy",  style = "slide" })
hl.animation({ leaf = "global",       enabled = true, speed = 5,   bezier = "snappy" })
hl.animation({ leaf = "layersIn",     enabled = true, speed = 1.8, bezier = "snappy",  style = "slide right" })
hl.animation({ leaf = "layersOut",    enabled = true, speed = 6,   bezier = "snappy",  style = "slide right" })