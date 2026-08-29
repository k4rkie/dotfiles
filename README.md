<h1 align="center">dotfiles</h1>

<p align="center">
  <img src="images/rice_preview.png" alt="desktop" width="800"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/NixOS-5277C3?style=flat&logo=nixos&logoColor=white"/>
  <img src="https://img.shields.io/badge/WM-MangoWM-5f8787?style=flat"/>
</p>

<p align="center">
  managed with <b>Home Manager</b>
</p>

---

## stack

| component | tool |
|-----------|------|
| **wm** | Mango  |
| **bar** | Waybar |
| **launcher** | Rofi |
| **notifications** | Swaync |
| **osd** | Swayosd |
| **terminal** | foot |
| **shell** | Zsh |
| **editor** | Neovim |
| **multiplexer** | Tmux |
| **file manager** | Yazi (tui), Thunar (gui) |
| **music** | MPD + rmpc |
| **pdf** | Zathura |
| **system info** | Fastfetch |
| **wallpaper** | awww |
| **idle / lock** | swayidle + Hyprlock |
| **clipboard** | Cliphist |
| **color picker** | Hyprpicker |
| **gamma** | Wlsunset |
| **browser** | Zen |
| **gtk** | Base16 Bark theme, Papirus-Dark icons |
| **font** | DepartureMono Nerd Font|

## scripts

Custom scripts under `scripts/` for:
- **rofi** — clipboard history, emoji picker, wallpaper setter, wifi menu, powermenu, sessionizer
- **media** — screenshot (full/region/window), screen recording, volume/brightness with swayosd
- **misc** — mpd notifications, caffeine toggle, reload workflows

## install

```bash
git clone https://github.com/k4rkie/dotfiles.git ~/dotfiles
sudo nixos-rebuild switch --flake ~/dotfiles/nixos-config#nixxer
```

Home Manager symlinks everything into `~/.config` via out-of-store symlinks

