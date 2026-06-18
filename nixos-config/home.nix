{ config, pkgs, ... }: {
  home = {
    username = "k4rkie";
    homeDirectory = "/home/k4rkie";
    stateVersion = "26.05";
  };

  gtk = {
    enable = true;
  };

  programs.home-manager.enable = true;
}
