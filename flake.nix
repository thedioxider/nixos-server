{
  description = "A flake that supposed to set up a server";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, ... }@inputs: {
    # Use this for all other targets
    # nixos-anywhere --flake .#generic --generate-hardware-config nixos-generate-config ./hardware-configuration.nix <hostname>
    nixosConfigurations.generic = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ disko.nixosModules.disko ./hardware-configuration.nix ];
    };

    nixosConfigurations."CalistoSE" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        {
          nixpkgs.overlays = [
            (self: super: {
              unstable = import inputs.nixpkgs-unstable {
                inherit (self.stdenv.hostPlatform) system;
              };
            })
          ];
        }
        disko.nixosModules.disko
        {
          networking.hostName = "CalistoSE";

          # enable the OpenSSH daemon
          services.openssh = { enable = true; };
        }

        ./CalistoSE/configuration.nix
      ];
    };

    nixosConfigurations."mieNor" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        {
          nixpkgs.overlays = [
            (self: super: rec {
              unstable = import inputs.nixpkgs-unstable {
                inherit (self.stdenv.hostPlatform) system;
              };
            })
          ];
        }
        {
          networking.hostName = "mieNor";

          # enable the OpenSSH daemon
          services.openssh = { enable = true; };
        }

        ./mieNor/configuration.nix
      ];
    };
  };
}
