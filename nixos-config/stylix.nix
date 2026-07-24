{ config, pkgs, ... }: {
  stylix = {
    enable = true;
    polarity = "dark";

    base16Scheme = ./colors/black-metal-bathory-tweaked.yaml;

    cursor = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };

    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
      light = "Papirus";
    };

    fonts = {
      monospace = {
        package = pkgs.maple-mono.NF;
        name = "Maple Mono NF";
      };
      sansSerif = config.stylix.fonts.monospace;
      serif = config.stylix.fonts.monospace;
      sizes = {
        terminal = 18;
        applications = 14;
        desktop = 14;
        popups = 14;
      };
    };
  };
}
