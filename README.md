<h1 align="center">dotfiles</h1>

<p align="center">
  <img src="images/rice_preview.png" alt="desktop" width="800"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/OS-Fedora-294172?style=flat&logo=fedora&logoColor=white"/>
  <img src="https://img.shields.io/badge/WM-Hyprland-5f8787?style=flat"/>
  <img src="https://img.shields.io/badge/Shell-Zsh-4EAA25?style=flat&logo=zsh&logoColor=white"/>
  <img src="https://img.shields.io/badge/Editor-Neovim-57A143?style=flat&logo=neovim&logoColor=white"/>
  <img src="https://img.shields.io/badge/GTK-Void-8A2BE2?style=flat"/>
</p>

<p align="center">
  managed with <b>GNU Stow</b>
</p>

---

## stack

| component | tool |
|-----------|------|
| **wm** | Hyprland (lua config) |
| **bar** | Waybar |
| **launcher** | Rofi |
| **notifications** | Swaync |
| **osd** | Swayosd |
| **terminal** | Kitty + Ghostty |
| **shell** | Zsh |
| **editor** | Neovim |
| **multiplexer** | Tmux |
| **file manager** | Yazi (tui), Thunar (gui) |
| **music** | MPD + rmpc |
| **pdf** | Zathura |
| **system info** | Fastfetch |
| **wallpaper** | Swaybg |
| **idle / lock** | Hypridle + Hyprlock |
| **clipboard** | Cliphist |
| **color picker** | Hyprpicker |
| **gamma** | Wlsunset |
| **browser** | Zen |
| **gtk** | Void theme, Papirus-Dark icons |
| **font** | FiraCode Nerd Font |

## scripts

Custom scripts under `scripts/` for:
- **rofi** — clipboard history, emoji picker, wallpaper setter, wifi menu, powermenu, sessionizer
- **media** — screenshot (full/region/window), screen recording, volume/brightness with swayosd
- **misc** — mpd notifications, caffeine toggle, accent color setter, gdm wallpaper, reload workflows

## install

```bash
git clone https://github.com/k4rkie/dotfiles.git ~/dotfiles
cd ~/dotfiles

# stow what you want
stow hypr waybar rofi kitty nvim zsh tmux yazi scripts
```

