{
  inputs,
  ...
}:
let
  user = "genki";
in
{

  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.self.darwinModules.common
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  networking.hostName = "d";

  users.users.${user} = {
    isHidden = false;
    home = "/Users/${user}";
    name = "${user}";
    shell = "/run/current-system/sw/bin/bash";
  };

  nix-homebrew = {
    inherit user;
    enable = true;
    mutableTaps = false;
    taps = with inputs; {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
      "homebrew/homebrew-bundle" = homebrew-bundle;
    };
  };

  homebrew = {
    enable = true;
    casks = [
      "raycast"
      "arc"
    ];
    masApps = {
      # `nix run nixpkgs#mas -- search <app name>`
      "Keynote" = 409183694;
    };
  };

  programs.fish.enable = true;

  home-manager.users.${user}.imports = [ inputs.self.homeModules.daniel ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Enable tailscale. We manually authenticate when we want with out or delete all of this.
  services.tailscale.enable = true;

  nix = {
    settings.trusted-users = [
      "@admin"
      "${user}"
    ];

    gc = {
      user = "root";
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 2;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };
  };
}
