{
  description = "NixOS starter for a personal agent VM";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { self, nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      makeHost =
        modules:
        lib.nixosSystem {
          modules = [
            self.nixosModules.default
            {
              nixpkgs.hostPlatform = lib.mkDefault system;
              system.configurationRevision = lib.mkDefault (self.rev or (self.dirtyRev or null));
            }
          ]
          ++ modules;
        };

      exampleHost = makeHost [ ./tests/example-host.nix ];
    in
    {
      nixosModules.default = ./modules/agent-box.nix;

      # The deployable output appears after importing this guest's configuration.
      nixosConfigurations = lib.optionalAttrs (builtins.pathExists ./host/configuration.nix) {
        agent-box = makeHost [
          ./host/configuration.nix
          ./host/settings.nix
        ];
      };

      packages.${system}.git-twig = pkgs.callPackage ./pkgs/git-twig.nix { };

      checks.${system}.host = builtins.seq exampleHost.config.system.build.toplevel.drvPath (
        pkgs.runCommand "agent-box-host-evaluates" { } "touch $out"
      );
    };
}
