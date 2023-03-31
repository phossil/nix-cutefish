{ config, lib, pkgs, ... }:
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
          #kwin-plugins
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
}
