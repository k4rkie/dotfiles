{
  description = "k4rkie's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mangowm = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    toofan = {
      url = "github:vyrx-dev/toofan";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    waybar = {
      url = "github:Alexays/Waybar/6d60c8e02be67bb85bb9b1ea803f2fbcf0722002";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      mangowm,
      toofan,
      ...
    }@inputs:
    {
      nixosConfigurations.mentat = nixpkgs.lib.nixosSystem {

        system = "x86_64-linux";
        specialArgs = { inherit inputs; };

        modules = [
          home-manager.nixosModules.home-manager
          mangowm.nixosModules.mango
          ./hardware-configuration.nix
          ./configuration.nix
          {
            # use same system pkgs and store in the nix/store
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit toofan; };

            # Per-user Home Manager config
            home-manager.users.k4rkie = import ./home.nix;
          }
        ];
      };
    };
}
