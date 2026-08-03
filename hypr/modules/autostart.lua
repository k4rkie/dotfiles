-- Autostart hook: things to launch once Hyprland is up.
-- Daemons (waybar, swaync, swayosd, hypridle) and tray applets.
hl.on("hyprland.start", function()
  -- --- tray applets ---
  hl.exec_cmd("nm-applet")
  hl.exec_cmd("blueman-applet")
  hl.exec_cmd("hyprpolkitagent")

  -- --- shell/bar/notifications/OSD ---
  hl.exec_cmd("quickshell")
  hl.exec_cmd("waybar")
  hl.exec_cmd("swaync")
  hl.exec_cmd("swayosd-server")
  hl.exec_cmd("awww-daemon")

  -- --- idle/notification helpers ---
  hl.exec_cmd("hypridle")
  hl.exec_cmd("~/scripts/mpd-notify.sh")

  -- --- clipboard history ---
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")

  -- --- wallpaper + gamma ---
  -- Wallpaper state lives in ~/.cache/quickshell/last-wallpaper.
  hl.exec_cmd("sleep 0.5 && ~/scripts/wallpaper-restore.sh")
  hl.exec_cmd("wlsunset -l 27.7006 -L 83.4484 -t 3800 -T 6500")
end)
