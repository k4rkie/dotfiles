{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  dotfiles = "${config.home.homeDirectory}/dotfiles"; slink = path: config.lib.file.mkOutOfStoreSymlink path; configs = {
    foot = "foot";
    fastfetch = "fastfetch";
    hypr = "hypr";
    mango = "mango";
    mako = "mako";
    mpv = "mpv";
    nvim = "nvim";
    rmpc = "rmpc";
    rofi = "rofi";
    swayosd = "swayosd";
    wallust = "wallust";
    waybar = "waybar";
    yazi = "yazi";
    zathura = "zathura";
    zed = "zed";
  };
in
{
  imports = [
    ./services/services.nix
  ];
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
    ".bashrc".source = slink "${dotfiles}/bash/.bashrc";
    "scripts".source = slink "${dotfiles}/scripts";
  };

  programs.home-manager.enable = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "image/png" = "imv.desktop";
      "image/jpeg" = "imv.desktop";
      "image/webp" = "imv.desktop";
      "application/pdf" = "org.pwmt.zathura.desktop";
      "video/mp4" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "video/quicktime" = "mpv.desktop";
      "video/mpeg" = "mpv.desktop";
      "video/ogg" = "mpv.desktop";
    };
  };

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
    enableBashIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    (lib.hiPrio gcc)
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
    waybar
    thunar
    tumbler
    rofi
    hyprlock
    hyprpicker
    wl-clipboard
    cliphist
    swayosd
    mako
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
    adw-gtk3

    # --- Media, Graphics & Audio ---
    gimp
    krita
    audacity
    mpv
    imv
    zathura
    zathuraPkgs.zathura_pdf_poppler
    libreoffice
    nwg-look

    # --- Terminal Utilities & Navigation ---
    tmux
    tealdeer
    yazi
    fd
    ripgrep
    zoxide
    bat
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
    lazygit
    lazydocker

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
    fastfetch
    cmatrix
    tesseract
    satty
    qalculate-gtk
    sway-audio-idle-inhibit
    (papirus-icon-theme.override { color = "indigo"; })
  ];
}
