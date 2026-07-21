-- Autostart hook: things to launch once Hyprland is up.
-- Daemons (waybar, swaync, swayosd, hypridle) and tray applets.
hl.on("hyprland.start", function()
  -- --- tray applets ---
  hl.exec_cmd("nm-applet")
  hl.exec_cmd("blueman-applet")
  hl.exec_cmd("hyprpolkitagent")

  -- --- shell/bar/notifications/OSD ---
  hl.exec_cmd("waybar")
  hl.exec_cmd("swaync")
  hl.exec_cmd("swayosd-server")

  -- --- idle/notification helpers ---
  hl.exec_cmd("hypridle")
  hl.exec_cmd("~/scripts/mpd-notify.sh")

  -- --- clipboard history ---
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")

  -- --- wallpaper + gamma ---
  local ok, wall_path = pcall(require, "modules.wallpaper")
  if not ok or type(wall_path) ~= "string" or wall_path == "" then
    wall_path = "/home/k4rkie/Pictures/Wallhaven/sea_sky_clouds_sand_beach_beacon_sunset_purple.jpg"
  end
  hl.exec_cmd("swaybg -i " .. wall_path .. " -m fill")
  hl.exec_cmd("wlsunset -l 27.7006 -L 83.4484 -t 3800 -T 6500")
end)

