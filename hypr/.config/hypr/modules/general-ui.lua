-- General layout, decoration (opacity/blur/shadow), animations + curves.
hl.config({
  general    = {
    gaps_in     = 4,
    gaps_out    = 10,
    border_size = 0,
    col         = {
      active_border   = "rgb(7D718F)",
      inactive_border = "rgb(202020)",
    },
    layout      = "dwindle",
  },
  decoration = {
    rounding         = 2,
    active_opacity   = 0.92,
    inactive_opacity = 0.88,
    shadow           = {
      enabled      = true,
      range        = 13,
      render_power = 3,
      color        = "rgba(000000bb)",
    },
    blur             = {
      enabled           = true,
      size              = 4,
      passes            = 4,
      ignore_opacity    = true,

      noise             = 0.08,
      contrast          = 4.0,

      brightness        = 0.4,
      vibrancy          = 2.8,
      special           = false,
      popups            = false,

      xray              = false,
      new_optimizations = true
    },
  },
  animations = {
    enabled = true,
  },
  misc       = {
    force_default_wallpaper = 0,
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    mouse_move_enables_dpms = true,
    key_press_enables_dpms = true
  }
})

-- Animation curves
hl.curve("snappy", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("smooth", { type = "bezier", points = { { 0.5, 0.0 }, { 0.5, 1.0 } } })

-- Animation overrides
hl.animation({ leaf = "windows", enabled = true, speed = 1.5, bezier = "snappy", style = "popin" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.5, bezier = "snappy", style = "popin" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "snappy" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "snappy", style = "slide" })
hl.animation({ leaf = "global", enabled = true, speed = 5, bezier = "snappy" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 1.8, bezier = "snappy", style = "slide right" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 6, bezier = "snappy", style = "slide right" })
