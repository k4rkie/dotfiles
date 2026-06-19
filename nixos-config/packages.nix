{ pkgs, zen-browser, ... }:
{
  environment.systemPackages = with pkgs; [
    # editor
    vim
    neovim
    zed-editor

    kitty
    git
    wget
    curl
    yazi
    thunar
    gvfs
    tumbler
    udisks2
    xdg-user-dirs
    waybar
    rofi

    # clipboard
    wl-clipboard
    cliphist

    networkmanagerapplet

    # notificaitons
    swaynotificationcenter
    swayosd
    swaybg
    wlsunset

    # screenshot
    grim
    slurp
    libnotify

    fzf
    fd
    ripgrep
    zoxide
    fastfetch
    bat
    tmux
    brightnessctl
    hypridle
    hyprlock
    acpi

    # sys monitor
    btop

    unzip
    xdg-utils

    pavucontrol
    playerctl

    docker-compose
    lazygit
    lazydocker
    python3
    apple-cursor
    glib
    gsettings-desktop-schemas
    dart-sass
    eza
    localsend
    rmpc
    mpd
    mpc
    zscroll

    # zen-browser
    zen-browser.packages.${pkgs.system}.beta

    # lang tools
    nodejs
    bun
    pnpm
    go
    rustup

    # lsp
    nil
    lua-language-server
    gopls
    typescript-language-server
    clang-tools
    gnumake

    # utils
    tesseract
    hyprpicker

    gimp
    blender
    kdePackages.kdenlive
    audacity
    mpv

    blueman
    imv
    zathura
    zathuraPkgs.zathura_pdf_poppler
  ];
}
