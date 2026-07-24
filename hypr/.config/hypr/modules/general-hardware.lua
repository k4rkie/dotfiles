-- Monitor(s), keyboard/mouse input, touchpad gesture config.
hl.monitor({
  output = "eDP-1",
  mode = "preferred",
  position = "auto",
  scale = "1",
})

hl.config({
  input = {
    kb_options     = "caps:escape",
    natural_scroll = false,
    touchpad       = {
      natural_scroll = true,
      drag_lock      = true,
    },
  },
})

hl.gesture({
  fingers   = 3,
  direction = "horizontal",
  action    = "workspace",
})

-- hl.gesture({
--   fingers = 3,
--   direction = "vertical",
--   action = function()
--     hl.exec_cmd("quickshell ipc call launcher toggle")
--   end
-- })

hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "24")
