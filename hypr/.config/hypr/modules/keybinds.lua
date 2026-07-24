-- All keybinds: media keys, launcher/session, focus/move, zoom, layout,
-- workspaces, resize submap.

local mainMod     = "SUPER"
local terminal    = "kitty"
local fileManager = "thunar"
local menu        = "quickshell ipc call launcher toggle"
local browser     = "zen-beta"

---- MEDIA KEYS ----
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume +2"),
  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume -2"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("swayosd-client --brightness +2"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness -2"), { locked = true, repeating = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("mpc toggle"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("mpc next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("mpc prev"))
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("mpc stop"))

--- Utils menu ----
hl.bind(mainMod .. " + SHIFT + U", hl.dsp.exec_cmd("rofi -show Utils -modi 'Utils:~/scripts/utils-menu.sh'"))

---- LAUNCHER / SESSION ----
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("~/scripts/rofi-powermenu.sh"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("hyprpicker -a -n"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("~/scripts/rofi-sessionizer.sh"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("~/scripts/reload.sh"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"))

hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("quickshell ipc call launcher openClipboard"))
hl.bind(mainMod .. " + period", hl.dsp.exec_cmd("quickshell ipc call launcher openEmoji"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("quickshell ipc call launcher openWallpaper"))
hl.bind(mainMod .. " + SHIFT + E",
  hl.dsp.exec_cmd('quickshell ipc call launcher openEmoji'))

---- FOCUS MOVEMENT ----
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + Left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + Down", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + Up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + Right", hl.dsp.focus({ direction = "right" }))

---- MOVE WINDOW ----
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + Left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + Down", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + Up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + Right", hl.dsp.window.move({ direction = "right" }))

---- MOUSE ----
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

---- LAYOUT / WINDOWS ----
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
  hl.bind("h", hl.dsp.window.resize({ x = -5, y = 0, relative = true }), { repeating = true })
  hl.bind("j", hl.dsp.window.resize({ x = 0, y = 5, relative = true }), { repeating = true })
  hl.bind("k", hl.dsp.window.resize({ x = 0, y = -5, relative = true }), { repeating = true })
  hl.bind("l", hl.dsp.window.resize({ x = 5, y = 0, relative = true }), { repeating = true })
  hl.bind("Left", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
  hl.bind("Down", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
  hl.bind("Up", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
  hl.bind("Right", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
  hl.bind("Return", hl.dsp.submap("reset"))
  hl.bind("Escape", hl.dsp.submap("reset"))
  hl.bind(mainMod .. " + R", hl.dsp.submap("reset"))
end)
