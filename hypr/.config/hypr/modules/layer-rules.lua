-- Layer-shell blur + animation rules for waybar/rofi/swaync/swayosd.
hl.layer_rule({
  name         = "blur-swaync-notif",
  match        = { namespace = "swaync-notification-window" },
  blur         = false,
  ignore_alpha = 0,
})

hl.layer_rule({
  name         = "blur-swaync-ctrl",
  match        = { namespace = "swaync-control-center" },
  blur         = false,
  ignore_alpha = 0,
})

hl.layer_rule({
  name         = "no-blur-swayosd",
  match        = { namespace = "swayosd" },
  blur         = false,
  ignore_alpha = 0,
  animation    = "slide bottom",
})

hl.layer_rule({
  name         = "blur-waybar",
  match        = { namespace = "waybar" },
  blur         = true,
  ignore_alpha = 0,
  animation    = "slide bottom",
})

hl.layer_rule({
  match     = { namespace = "rofi" },
  blur      = true,
  animation = "fade",
})

hl.layer_rule({
  match     = { namespace = "quickshell" },
  animation = "slide bottom",
})
