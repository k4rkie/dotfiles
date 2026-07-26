-- General layout, decoration (opacity/blur/shadow), animations + curves.
hl.config({
  general    = {
    gaps_in     = 3.5,
    gaps_out    = 8,
    border_size = 2,
    col         = {
      active_border   = "rgb(7D718F)",
      inactive_border = "rgb(202020)",
    },
    layout      = "scrolling",
    hl.config({
      scrolling = {
        column_width = 0.8,
        focus_fit_method = 1
      }
    })
  },
  decoration = {

    rounding         = 0,
    active_opacity   = 1,
    inactive_opacity = 0.96,

    shadow           = {
      enabled      = false,
      range        = 10,
      render_power = 3,
      color        = "rgba(00000099)",
    },

    blur             = {
      enabled           = true,
      size              = 6,
      passes            = 2,
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
    enabled = false,
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
hl.animation({ leaf = "windowsIn", enabled = true, speed = 1, bezier = "smooth", style = "popin" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.2, bezier = "smooth", style = "popin" })
hl.animation({ leaf = "border", enabled = true, speed = 1.8, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 1.8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 1.2, bezier = "smooth" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1, bezier = "smooth", style = "slide" })
hl.animation({ leaf = "global", enabled = true, speed = 1.5, bezier = "smooth" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 1.8, bezier = "smooth", style = "slide right" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "smooth", style = "slide right" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 0.6, bezier = "smooth", style = "popin" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1, bezier = "smooth", style = "popin" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 0.6, bezier = "smooth", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 0.6, bezier = "smooth", style = "fade" })
