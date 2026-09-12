{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
  slink = path: config.lib.file.mkOutOfStoreSymlink path;
  configs = {
    foot = "foot";
    hypr = "hypr";
    mango = "mango";
    mpv = "mpv";
    nvim = "nvim";
    quickshell = "quickshell";
    rmpc = "rmpc";
    rofi = "rofi";
    swayosd = "swayosd";
    wallust = "wallust";
    yazi = "yazi";
    zathura = "zathura";
    zed = "zed";
  };
in
{
  home = {
    username = "k4rkie";
    homeDirectory = "/home/k4rkie";
    stateVersion = "26.05";
  };

  # ~/.config symlinks
  xdg.configFile = builtins.mapAttrs (name: subpath: {
    source = slink "${dotfiles}/${subpath}";
    recursive = true;
  }) configs;

  # home directory symlinks
  home.file = {
    ".tmux.conf".source = slink "${dotfiles}/tmux/tmux.conf";
    ".zshrc".source = slink "${dotfiles}/zsh/.zshrc";
    "scripts".source = slink "${dotfiles}/scripts";
  };

  programs.home-manager.enable = true;

  xdg.userDirs.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "k4rkie";
        email = "karkeekrish07@gmail.com";
      };
      init.defaultBranch = "main";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = false;
    changeDirWidgetCommand = "fd --type d";
    changeDirWidgetOptions = [ "--preview 'tree -C {} | head -200'" ];
    defaultCommand = "fd --type f";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = false;
  };

  # Sway audio idle inhibitor
  systemd.user.services.sway-audio-idle-inhibit = {
    Unit = {
      Description = "Prevent idle/sleep when audio is playing";
    };

    Service = {
      Type = "simple";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 3";
      ExecStart = "${pkgs.sway-audio-idle-inhibit}/bin/sway-audio-idle-inhibit";
      Restart = "on-failure";
      RestartSec = "5";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  services.mpd-mpris.enable = true;

  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/Music";
    network.startWhenNeeded = true;
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "PipeWire"
      }
    '';
  };

  home.packages = with pkgs; [
    clang
    tree-sitter
    uv
    wallust

    # --- Editors & Notes ---
    neovim
    zed-editor
    foot

    # --- Web & Communications ---
    firefox
    localsend

    # --- Desktop Environment & Wayland ---
    thunar
    tumbler
    rofi
    hyprlock
    hyprpicker
    wl-clipboard
    cliphist
    swayosd
    wlsunset
    grim
    slurp
    swayidle
    pavucontrol
    playerctl
    networkmanagerapplet
    blueman
    libnotify
    xdg-user-dirs
    xdg-utils

    # --- Media, Graphics & Audio ---
    gimp
    audacity
    mpv
    imv
    zathura
    zathuraPkgs.zathura_pdf_poppler
    libreoffice
    rmpc

    # --- Terminal Utilities & Navigation ---
    tmux
    tealdeer
    yazi
    fd
    ripgrep
    zoxide
    bat
    eza
    btop
    unzip
    file
    tree
    delta
    jq
    awww
    ffmpeg
    yt-dlp
    (pkgs.writeShellApplication {
      name = "ns";
      runtimeInputs = with pkgs; [
        fzf
        nix-search-tv
      ];
      text = builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh";
    })

    # --- Language Runtimes & Compilers ---
    nodejs
    bun
    pnpm
    go
    zig
    rustup
    python3
    jdk

    # --- Language Servers (LSPs) & Build Tools ---
    clang-tools
    gnumake
    cmake

    # --- Misc Tools ---
    tesseract
    satty
    quickshell
    qalculate-gtk
    sway-audio-idle-inhibit
    (papirus-icon-theme.override { color = "indigo"; })
  ];
}
