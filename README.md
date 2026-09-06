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
| **gtk** | Base16 theme, Papirus-Dark icons |
| **font** | Mononoki Nerd Font|


## install

### nixos 

This setup uses nixos modules (home-manager) in `nixos-config/`.

1. Copy your `hardware-configuration.nix` into `nixos-config/`
2. Update the config paths in `nixos-config/configuration.nix` to match your setup
3. Rebuild and switch
```bash
sudo nixos-rebuild switch --flake .#your-hostname
```

This will set up all nixos services and home-manager configs automatically.

---

### non-nixos 

Use the install script to symlink everything:
```bash
git clone https://github.com/k4rkie/dotfiles.git 
cd ~/dotfiles
./install.sh 
```

**For help**
```bash
./install.sh --help 
```

