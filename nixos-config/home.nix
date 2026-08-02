{
  config,
  pkgs,
  lib,
  ...
}:
{
  home = {
    username = "k4rkie";
    homeDirectory = "/home/k4rkie";
    stateVersion = "26.05";
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
    changeDirWidgetCommand = "fd --type d";
    changeDirWidgetOptions = [ "--preview 'tree -C {} | head -200'" ];
    defaultCommand = "fd --type f";
  };

  home.packages = with pkgs; [
    kitty
    brave

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

    # --- Language Runtimes & Compilers ---
    nodejs
    bun
    pnpm
    go
    rustup
    python3

    # --- Language Servers (LSPs) & Build Tools ---
    nil
    lua-language-server
    gopls
    typescript-language-server
    clang-tools
    gnumake
    cmake

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
