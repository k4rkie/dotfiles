-- Hyprland Lua Config (ported from hyprland.conf)
local mainMod    = "SUPER"
local terminal   = "kitty"
local fileManage = "thunar"
local menu       = "rofi -show"

---- MONITORS ----
hl.monitor({
  output = "eDP-1",
  mode = "preferred",
  position = "auto",
  scale = "1",
}) ---- MISC (SWALLOW) ----
hl.config({
  misc = {
    enable_swallow = true,
    swallow_regex  = "^(thunar|zen|zen-beta|firefox|google-chrome|chromium|nautilus|nemo)$",
  },
})

---- INPUT ----
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

---- LAYER RULES ----
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
  name         = "blur-swayosd",
  match        = { namespace = "swayosd" },
  blur         = true,
  ignore_alpha = 0,
  animation    = "slide bottom"
})
hl.layer_rule({
  name         = "animate-waybar",
  match        = { namespace = "waybar" },
  blur         = false,
  ignore_alpha = 0,
  animation    = "slide bottom"
})
hl.layer_rule({
  match     = { namespace = "rofi" },
  animation = "popin"
})

---- GENERAL ----
hl.config({
  general = {
    gaps_in     = 4,
    gaps_out    = 10,
    border_size = 0,
    col         = {
      active_border   = "rgb(83a598)",
      inactive_border = "rgb(202020)",
    },
    layout      = "dwindle",
  },
  decoration = {
    rounding         = 0,
    active_opacity   = 1,
    inactive_opacity = 1,
    shadow           = {
      enabled      = false,
      range        = 12,
      render_power = 4,
      color        = "rgba(000000aa)",
    },
    blur             = {
      enabled    = true,
      size       = 8,
      passes     = 2,
      noise      = 0.01,
      contrast   = 0.95,
      brightness = 0.95,
      vibrancy   = 0.8,
      special    = true,
      popups     = true,
    },
  },
  animations = {
    enabled = true,
  },
})

---- ANIMATION CURVES ----
hl.curve("snappy", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("smooth", { type = "bezier", points = { { 0.5, 0.0 }, { 0.5, 1.0 } } })

---- ANIMATIONS ----
hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "snappy", style = "popin" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "snappy", style = "popin" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "snappy" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "snappy", style = "slide" })
hl.animation({ leaf = "global", enabled = true, speed = 5, bezier = "snappy" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 2, bezier = "snappy", style = "slide right" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 5, bezier = "snappy", style = "slide right" })

---- AUTOSTART ----
hl.on("hyprland.start", function()
  hl.exec_cmd("nm-applet")
  hl.exec_cmd("blueman-applet")
  hl.exec_cmd("swaync")
  hl.exec_cmd("swayosd-server")
  local wall_path = (io.open(os.getenv("HOME") .. "/.config/hypr/current_wallpaper", "r") or io.open("/dev/null")):read(
    "*a"):gsub("%s+$", "")
  if wall_path == "" then
    wall_path =
    "/home/k4rkie/Pictures/Wallhaven/sea_sky_clouds_sand_beach_beacon_sunset_purple.jpg"
  end
  hl.exec_cmd("swaybg -i " .. wall_path .. " -m fill")
  hl.exec_cmd("wlsunset -l 27.7006 -L 83.4484 -t 3800 -T 6500")
  hl.exec_cmd("gsettings set org.gnome.desktop.interface font-name 'IosevkaTerm Nerd Font 12'")
  hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'Void'")
  hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'")
  hl.exec_cmd("sed -i 's/gtk-icon-theme-name=\"hicolor\"/gtk-icon-theme-name=\"Papirus-Dark\"/' \"${HOME}/.gtkrc-2.0\"")
  hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
  hl.exec_cmd("hypridle")
  hl.exec_cmd("hyprpolkitagent")
  hl.exec_cmd("~/scripts/mpd-notify.sh")
  hl.exec_cmd("waybar")
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

---- MEDIA KEYS ----
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume +2"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume -2"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("swayosd-client --brightness +2"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness -2"), { locked = true, repeating = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("mpc toggle"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("mpc next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("mpc prev"))
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("mpc stop"))

---- SCREENSHOTS ----
hl.bind("Print", hl.dsp.exec_cmd("~/scripts/screenshot.sh"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("~/scripts/screenshot.sh region"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd("~/scripts/screenshot.sh window"))

---- LAUNCHER / SESSION ----
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("/opt/zen/zen"))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd(fileManage))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("~/scripts/rofi-powermenu"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("~/scripts/rofi-sessionizer.sh"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("~/scripts/reload.sh"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("killall -SIGUSR1 waybar"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("~/scripts/rofi-cliphist.sh"))
hl.bind(mainMod .. " + period", hl.dsp.exec_cmd("~/scripts/rofi-emoji.sh"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("~/scripts/rofi-wallpaper.sh"))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))
hl.bind(mainMod .. " + SHIFT + E",
  hl.dsp.exec_cmd("rofimoji --keybinding-copy Alt+Return --max-recent 3 --prompt \"Emoji\""))

---- FOCUS MOVEMENT ----
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + semicolon", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + Left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + Down", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + Up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + Right", hl.dsp.focus({ direction = "right" }))

---- MOVE WINDOW ----
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + semicolon", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + Left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + Down", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + Up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + Right", hl.dsp.window.move({ direction = "right" }))

---- MOUSE ----
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

---- ZOOM ----
local MAX_ZOOM = 8
local MIN_ZOOM = 1
local ZOOM_TOGGLE_FACTOR = 1.5

local function zoom(offset)
  local current = hl.get_config("cursor.zoom_factor")
  if offset ~= nil then
    current = current + offset
  elseif current ~= MIN_ZOOM then
    current = MIN_ZOOM
  else
    current = ZOOM_TOGGLE_FACTOR
  end
  current = math.max(MIN_ZOOM, math.min(MAX_ZOOM, current))
  hl.config({ cursor = { zoom_factor = current } })
end

hl.bind(mainMod .. " + equal", function()
  zoom(0.5)
end)
hl.bind(mainMod .. " + minus", function()
  zoom(-0.5)
end)
hl.bind(mainMod .. " + Z", zoom)

---- LAYOUT / WINDOWS ----
hl.bind(mainMod .. " + h", hl.dsp.layout("preselect l"))
hl.bind(mainMod .. " + v", hl.dsp.layout("preselect d"))
hl.bind(mainMod .. " + f", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
hl.bind(mainMod .. " + e", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + SHIFT + t", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + space", hl.dsp.window.cycle_next())
hl.bind(mainMod .. " + a", hl.dsp.layout("focusparent"))

---- WORKSPACES ----
for i = 1, 10 do
  local key = i % 10
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

---- RESIZE MODE ----
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
  hl.bind("j", hl.dsp.window.resize({ x = -5, y = 0, relative = true }), { repeating = true })
  hl.bind("k", hl.dsp.window.resize({ x = 0, y = 5, relative = true }), { repeating = true })
  hl.bind("l", hl.dsp.window.resize({ x = 0, y = -5, relative = true }), { repeating = true })
  hl.bind("semicolon", hl.dsp.window.resize({ x = 5, y = 0, relative = true }), { repeating = true })
  hl.bind("Left", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
  hl.bind("Down", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
  hl.bind("Up", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
  hl.bind("Right", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
  hl.bind("Return", hl.dsp.submap("reset"))
  hl.bind("Escape", hl.dsp.submap("reset"))
  hl.bind(mainMod .. " + R", hl.dsp.submap("reset"))
end)

---- WINDOW RULES ----
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
})

hl.window_rule({
  name  = "float-blueman",
  match = { class = "^(blueman-manager)$" },
  float = true,
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
  name      = "force-current-ws",
  match     = { class = "." },
  workspace = "current"
})

hl.window_rule({
  name      = "browser-on-1",
  match     = { class = "^(zen|firefox|google-chrome)$" },
  workspace = "1"
})

-- hl.window_rule({
--   name      = "terminal-on-2",
--   match     = { class = "^(kitty)$" },
--   workspace = "2"
-- })
