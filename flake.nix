{
  description = "A very basic flake";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ]
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          makeScope = nixpkgs.lib.makeScope;
          libsForQt5 = pkgs.libsForQt5;
          cutefishPkgs = import ./packages { inherit pkgs makeScope libsForQt5; };
        in
        rec {
          packages = flake-utils.lib.flattenTree cutefishPkgs;
          devShells = builtins.mapAttrs
            (
              name: value:
                pkgs.mkShell {
                  nativeBuildInputs = packages.${name}.nativeBuildInputs;
                  buildInputs = packages.${name}.buildInputs;
                }
            )
            packages;

          formatter = pkgs.nixpkgs-fmt;
        }
      ) // {
      overlays.default = final: prev: {
        cutefish = (import ./packages {
          pkgs = prev.pkgs;
          makeScope = prev.lib.makeScope;
          libsForQt5 = prev.pkgs.libsForQt5;
        });
      };
      nixosModules.default = import ./modules;
    };
}
