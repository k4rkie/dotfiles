{
  config,
  pkgs,
  lib,
  toofan,
  ...
}:
let
  dotfiles = "${config.home.homeDirectory}/dotfiles"; # repo location
  link = config.lib.file.mkOutOfStoreSymlink; # symlink instead of copying to the nix store
in
{
  home = {
    username = "k4rkie";
    homeDirectory = "/home/k4rkie";
    stateVersion = "26.05";
  };

  # ~/.config symlinks
  xdg.configFile = {
    "fastfetch".source = link "${dotfiles}/fastfetch";
    "foot".source = link "${dotfiles}/foot";
    "kitty".source = link "${dotfiles}/kitty";
    "mango".source = link "${dotfiles}/mango";
    "hypr".source = link "${dotfiles}/hypr";
    "mpd".source = link "${dotfiles}/mpd";
    "mpv".source = link "${dotfiles}/mpv";
    "nvim".source = link "${dotfiles}/nvim";
    "quickshell".source = link "${dotfiles}/quickshell";
    "rmpc".source = link "${dotfiles}/rmpc";
    "rofi".source = link "${dotfiles}/rofi";
    "swaync".source = link "${dotfiles}/swaync";
    "swayosd".source = link "${dotfiles}/swayosd";
    "waybar".source = link "${dotfiles}/waybar";
    "yazi".source = link "${dotfiles}/yazi";
    "zathura".source = link "${dotfiles}/zathura";
    "zed".source = link "${dotfiles}/zed";
  };

  # home directory symlinks
  home.file = {
    ".tmux.conf".source = link "${dotfiles}/tmux/tmux.conf";
    ".zshrc".source = link "${dotfiles}/zsh/zshrc";
    "scripts".source = link "${dotfiles}/scripts";
  };

  programs.home-manager.enable = true;

  # Disable Stylix targets that you manage manually stylix.targets.hyprland.enable = false;
  stylix.targets.waybar.enable = false;
  stylix.targets.neovim.enable = false;

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

  home.packages = with pkgs; [
    clang
    tree-sitter
    prettier
    uv

    # --- Editors & Notes ---
    neovim
    zed-editor
    obsidian
    vscode
    foot

    # --- Web & Communications ---
    localsend

    # --- Media, Graphics & Audio ---
    gimp
    blender
    kdePackages.kdenlive
    audacity
    mpv
    imv
    zathura
    zathuraPkgs.zathura_pdf_poppler
    rmpc
    zscroll

    # --- Terminal Utilities & Navigation ---
    tmux
    yazi
    lazygit
    lazydocker
    fd
    ripgrep
    zoxide
    fastfetch
    bat
    eza
    btop
    unzip
    file
    tree
    delta
    jq
    wallust
    awww
    ffmpeg
    yt-dlp
    toofan.packages.${pkgs.stdenv.hostPlatform.system}.default
    libreoffice

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
    nil
    lua-language-server
    gopls
    typescript-language-server
    clang-tools
    gnumake
    cmake
    zls

    # --- Misc Tools ---
    tesseract
    satty
    cava
    impala
    cmatrix
    cbonsai
    quickshell
    qalculate-gtk
    iwd
    sway-audio-idle-inhibit
  ];
}
