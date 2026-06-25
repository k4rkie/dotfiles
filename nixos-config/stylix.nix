{ config, pkgs, ... }: {
  stylix = {
    enable = true;
    polarity = "dark";

    base16Scheme = ./colors/bark.yaml;

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
        package = pkgs.nerd-fonts.zed-mono;
        name = "ZedMono Nerd Font";
      };
      sansSerif = config.stylix.fonts.monospace;
      serif = config.stylix.fonts.monospace;
      sizes = {
        terminal = 15;
        applications = 12;
        desktop = 12;
        popups = 12;
      };
    };
  };
}
