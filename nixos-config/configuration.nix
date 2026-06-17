# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Kathmandu";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."k4rkie" = {
    isNormalUser = true;
    description = "k4rkie";
    extraGroups = [ "networkmanager" "wheel" "video" "input" "storage" "docker" ];
    shell = pkgs.zsh;
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    kitty
    git
    wget
    curl
    firefox
    neovim
    yazi
    thunar
    gvfs
    tumbler
    udisks2
    xdg-user-dirs
    waybar
    rofi
    wl-clipboard
    cliphist
    networkmanagerapplet
    swaynotificationcenter
    swayosd
    swaybg
    wlsunset
    grim
    slurp
    fzf
    fd
    ripgrep
    zoxide
    fastfetch
    bat
    tmux
    brightnessctl
    acpi
    btop
    unzip
    xdg-utils
    pavucontrol
    playerctl
    docker-compose
    nodejs
    pnpm
    opencode
    bun
    go
    lazygit
    lazydocker
    python3
    libnotify
    apple-cursor
    glib
    gsettings-desktop-schemas
    dart-sass
    cliphist
  ];

  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.devmon.enable = true;
  virtualisation.docker.enable = true;
  programs.zsh.enable = true;

  programs.dconf.enable = true;

  programs.hyprland.enable = true;
  
  services.greetd = {
   enable = true;
   settings = {
    default_session = {
     command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd /run/current-system/sw/bin/start-hyprland";
     user = "greeter";
    };
   };
  };

  fonts.packages = with pkgs;[
   nerd-fonts.fira-code
   nerd-fonts.iosevka-term
  ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
