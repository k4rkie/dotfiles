{ pkgs, zen-browser, ... }:
{
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl

    zen-browser.packages.${pkgs.system}.beta

    # --- Hardware & Core Integration ---
    brightnessctl
    acpi
    pavucontrol
    playerctl
    networkmanagerapplet
    blueman

    # --- Containers/Virtualization ---
    docker-compose

    # --- File System & Storage Mechanics ---
    thunar
    gvfs
    tumbler
    udisks2
    xdg-user-dirs
    xdg-utils

    # --- Hyprland / Wayland Session Essentials ---
    waybar
    rofi
    hypridle
    hyprlock
    hyprpicker
    wl-clipboard
    cliphist
    swaynotificationcenter
    swayosd
    swaybg
    wlsunset
    grim
    slurp
    libnotify

    # --- System/GTK Foundation libraries ---
    glib
    gsettings-desktop-schemas

    # --- Audio Daemons Helpers ---
    mpd
    mpc
  ];
}
