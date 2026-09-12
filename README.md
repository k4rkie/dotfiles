<h1 align="center">dotfiles</h1>

<p align="center">
  <img src="images/rice_preview.png" alt="desktop" width="800"/>
</p>

---

## stack

| component | tool |
|-----------|------|
| **wm** | Mango  |
| **shell** | Quickshell |
| **osd** | Swayosd |
| **terminal** | foot |
| **shell** | Zsh |
| **editor** | Neovim |
| **multiplexer** | Tmux |
| **file manager** | Yazi (tui), Thunar (gui) |
| **music** | MPD + rmpc |
| **pdf** | Zathura |
| **wallpaper** | awww |
| **idle / lock** | swayidle + Hyprlock |
| **clipboard** | Cliphist |
| **color picker** | Hyprpicker |
| **gamma** | Wlsunset |
| **gtk** | Rose Pine, Papirus-Dark icons |
| **font** | Maple Mono NF |


## install

### nixos 

This setup uses NixOS Flakes and Home Manager as a module in `nixos-config/`.

1. Install NixOS (this generates your system's `/etc/nixos/hardware-configuration.nix`).
2. Clone this repository to your home folder: `git clone https://github.com/k4rkie/dotfiles.git ~/dotfiles`
3. Change to the config directory: `cd ~/dotfiles/nixos-config`
4. Rebuild the system using the `--impure` flag (this is required so the flake can dynamically read hardware config from `/etc/nixos/`):

```bash
sudo nixos-rebuild switch --flake .#mentat --impure
```

*(Note: If you are already using `nh`, you can just run `nh os switch --impure`)*

---

### non-nixos 

Use the install script to symlink everything:

> [!WARNING]  
> Make sure to backup your old configs as this script will override the old ones and create new symlinks.

```bash
git clone https://github.com/k4rkie/dotfiles.git 
cd ~/dotfiles
./install.sh 
```

