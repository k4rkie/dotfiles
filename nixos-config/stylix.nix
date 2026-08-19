{ config, pkgs, ... }: {
  stylix = {
    enable = true;
    polarity = "dark";

    base16Scheme = ./colors/black-metal-bathory-tweaked.yaml;

    targets.chromium.enable = false;

    cursor = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };

    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme.override { color = "nordic"; };
      dark = "Papirus-Dark";
      light = "Papirus";
    };

    fonts = {
      monospace = {
        package = pkgs.maple-mono.NF;
        name = "Maple Mono NF";

        # package = pkgs.runCommand "Monasekva Code Nerd Font" { } ''
        #   install -Dm644 ${./fonts/MonasevkaCodeNerdFont-Regular.ttf} $out/share/fonts/truetype/MonasevkaCodeNerdFont-Regular.ttf
        # '';
        # name = "Monasevka Code Nerd Font";
      };
      sansSerif = config.stylix.fonts.monospace;
      serif = config.stylix.fonts.monospace;
      sizes = {
        terminal = 16;
        applications = 15;
        desktop = 15;
        popups = 15;
      };
    };
  };
}
