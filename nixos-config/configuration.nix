# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "mentat"; # Define your hostname.
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
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "input"
      "storage"
      "docker"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [ ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl

    # --- Hardware & Core Integration ---
    brightnessctl
    acpi
    pavucontrol
    playerctl
    networkmanagerapplet
    blueman
    bluez

    # --- Containers/Virtualization ---
    docker-compose

    # --- File System & Storage Mechanics ---
    thunar
    gvfs
    tumbler
    udisks2
    xdg-user-dirs
    xdg-utils

    # --- Wayland Session Essentials ---
    (pkgs.waybar.overrideAttrs (oldAttrs: {
      src = inputs.waybar;
      # Disable Cava via Meson build flag
      mesonFlags = (oldAttrs.mesonFlags or [ ]) ++ [
        "-Dcava=disabled"
      ];
      # Include ModemManager dependency added in newer master commits
      buildInputs = (oldAttrs.buildInputs or [ ]) ++ [
        pkgs.modemmanager
      ];
    }))

    rofi
    hyprlock
    hyprpicker
    wl-clipboard
    cliphist
    swayosd
    wlsunset
    grim
    slurp
    libnotify
    swayidle

    # --- System/GTK Foundation libraries ---
    glib
    gsettings-desktop-schemas

    # --- Audio Daemons Helpers ---
    mpd
  ];

  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.devmon.enable = true;
  services.mpd = {
    enable = true;
    user = "k4rkie";
    musicDirectory = "/home/k4rkie/Music";
    settings = {
      audio_output = [
        {
          type = "pipewire";
          name = "PipeWire";
        }
      ];
    };
  };

  systemd.services.mpd.environment = {
    PIPEWIRE_RUNTIME_DIR = "/run/user/1000";
  };

  virtualisation.docker.enable = true;
  programs.zsh.enable = true;

  programs.dconf.enable = true;

  programs.mango.enable = true;
  programs.sway.enable = true;

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # X11 dependencies required by LWJGL / GLFW
      xorg.libX11
      xorg.libXext
      xorg.libXcursor
      xorg.libXrandr
      xorg.libXi
      xorg.libXinerama
      xorg.libXxf86vm
      xorg.libXrender

      # Graphics and Wayland fallbacks
      libGL
      libxkbcommon
      wayland
      alsa-lib
    ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.mononoki
    nerd-fonts.departure-mono
    maple-mono.NF
    dejavu_fonts
    noto-fonts-color-emoji
  ];
  fonts.fontconfig.enable = true;

  programs.xfconf.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --asterisks";
        user = "greeter";
      };
    };
  };

  # Create cache directory for tuigreet to remember users
  systemd.tmpfiles.rules = [
    "d /var/cache/tuigreet 0755 greeter greeter - -"
  ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };

  security.sudo.extraConfig = ''
    Defaults pwfeedback
  '';

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  # Keep boot menu clean but still allow rollbacks
  boot.loader.systemd-boot.configurationLimit = 10;

  # Automatic garbage collection, clean snaps older than 30d
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  zramSwap.enable = true;

  # Prevent unlimited generations per profile

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
  networking.firewall.allowedTCPPorts = [ 53317 ];
  networking.firewall.allowedUDPPorts = [ 53317 ];
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
