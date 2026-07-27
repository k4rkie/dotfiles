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

  programs.home-manager.enable = true;
  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;

      # Text & Layout
      window_padding_width = 0;

      # Cursor Appearance
      cursor_shape = "block";
      cursor_blink_interval = 0;

      # Shell Integration
      shell_integration = "enabled no-cursor";

      # Keymaps
      "map ctrl+f" = "launch --type=overlay zsh -ic \"~/scripts/tmux-session-dispensary.sh\"";
    };
  };

  programs.fzf = {
    enable = true;
    changeDirWidgetCommand = "fd --type d";
    changeDirWidgetOptions = [ "--preview 'tree -C {} | head -200'" ];
    defaultCommand = "fd --type f";
  };

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
    librewolf

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

    # --- Misc Desktop Tools ---
    tesseract
    satty

    quickshell

    rofimoji

    qalculate-gtk
    gsimplecal
  ];
}
