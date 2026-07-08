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
        # package = pkgs.nerd-fonts.iosevka-term;
        # name = "IosevkaTerm Nerd Font";

        # package = pkgs.nerd-fonts.jetbrains-mono;
        # name = "JetBrainsMono Nerd Font";

        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font";
      };
      sansSerif = config.stylix.fonts.monospace;
      serif = config.stylix.fonts.monospace;
      sizes = {
        terminal = 16;
        applications = 13;
        desktop = 13;
        popups = 13;
      };
    };
  };
}
