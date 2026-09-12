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

  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      mangowm,
      ...
    }@inputs:
    {
      nixosConfigurations.mentat = nixpkgs.lib.nixosSystem {

        system = "x86_64-linux";
        specialArgs = { inherit inputs; };

        modules = [
          ./configuration.nix
        ];
      };
    };
}
