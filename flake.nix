{
  description = "🌍";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    blueprint.url = "github:numtide/blueprint";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:
    inputs.blueprint {
      inherit inputs;
      systems = [ "aarch64-darwin" ];
    };
}
