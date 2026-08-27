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
      package = pkgs.papirus-icon-theme.override { color = "white"; };
      dark = "Papirus-Dark";
      light = "Papirus";
    };

    fonts = {
      monospace = {

        # package = pkgs.runCommand "SevrainsMono Nerd Font" { } ''
        #   install -Dm644 ${./fonts/SevrainsMonoNerdFont-Regular.ttf} $out/share/fonts/truetype/SevrainsMonoNerdFont-Regular.ttf
        # '';
        # name = "SevrainsMono Nerd Font";

        package = pkgs.nerd-fonts.departure-mono;
        name = "DepartureMono Nerd Font";
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
