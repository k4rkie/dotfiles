{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
    inputs.mangowm.nixosModules.mango
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.k4rkie = import ./home.nix;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "mentat"; # Define your hostname.

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
    wget
    curl

    # --- Hardware & Core Integration ---
    brightnessctl
    acpi

    # --- Containers/Virtualization ---
    docker-compose
    podman
    distrobox

    # --- System/GTK Foundation libraries ---
    glib
    gsettings-desktop-schemas
  ];
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.devmon.enable = true;

  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  virtualisation.docker.enable = true;
  virtualisation.podman = {
    enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  programs.zsh.enable = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/k4rkie/dotfiles/nixos-config";
  };
  programs.dconf.enable = true;

  programs.mango.enable = true;

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # X11 dependencies required by LWJGL / GLFW
      libX11
      libXext
      libXcursor
      libXrandr
      libXi
      libXinerama
      libXxf86vm
      libXrender

      # Graphics and Wayland fallbacks
      libGL
      libxkbcommon
      wayland
      alsa-lib

      stdenv.cc.cc.lib # libstdc++.so.6, libgcc_s.so.1 (C++ stdlib)
      stdenv.cc.libc # Standard C library primitives
      glibc # Core glibc dynamic links
      util-linux # System utilities & libuuid
      libffi # Foreign Function Interface (used by ctypes/cffi)

      openssl # libssl, libcrypto (psycopg2, cryptography, requests)
      curl # libcurl
      libsodium # Modern cryptography primitives
      libxml2 # XML parsing native bindings

      postgresql.lib # libpq (psycopg2, asyncpg, node-postgres)
      sqlite # Embedded database C bindings
    ];
  };

  services.envfs.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.mononoki
    nerd-fonts.departure-mono
    maple-mono.NF
    nerd-fonts.ubuntu-mono
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

  security.rtkit.enable = true;
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

  boot.loader.systemd-boot.configurationLimit = 10;

  zramSwap = {
    enable = true;
    memoryPercent = 100;
    algorithm = "zstd";
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 53317 ];
  networking.firewall.allowedUDPPorts = [ 53317 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "26.05";

}
