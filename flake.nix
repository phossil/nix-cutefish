{
  description = "A very basic flake";

  inputs.flake-utils.url = "github:numtide/flake-utils";

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
        }
      ) // {
      overlay = final: prev: {
        cutefish = (import ./packages {
          pkgs = prev.pkgs;
          makeScope = prev.lib.makeScope;
          libsForQt5 = prev.pkgs.libsForQt5;
        });
      };
      nixosModule = { config, lib, pkgs, ... }:
        with lib;
        let
          xcfg = config.services.xserver;
          cfg = xcfg.desktopManager.cutefish;
        in
        {
          options = {
            services.xserver.desktopManager.cutefish.enable = mkOption {
              type = types.bool;
              default = false;
              description = "Enable the Cutefish desktop manager";
            };
          };
          config = mkIf cfg.enable {
            services.xserver.displayManager.sessionPackages = [ pkgs.cutefish.core ];
            services.xserver.displayManager.sddm.theme = mkDefault "cutefish";
            services.accounts-daemon.enable = true;

            environment.pathsToLink = [ "/share" ];
            environment.systemPackages =
              let
                cutefishPkgs = with pkgs.cutefish; [
                  calculator
                  core
                  dock
                  filemanager
                  icons
                  kwin-plugins
                  launcher
                  qt-plugins
                  screenlocker
                  sddm-theme
                  settings
                  statusbar
                  terminal
                  wallpapers
                ];
                plasmaPkgs = with pkgs.libsForQt5; [
                  kglobalaccel
                  kinit
                  kwin
                ];
              in
              cutefishPkgs ++ plasmaPkgs;
          };
        };
    };
}
