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
    # the theme removes the ability to choose other
    # sessions with SDDM and should be enabled by default
    #services.xserver.displayManager.sddm.theme = mkDefault "cutefish";
    services.accounts-daemon.enable = true;

    # copy xdg desktop portal settings from plasma5
    xdg.portal.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-kde ];
    # xdg-desktop-portal-kde expects PipeWire to be running.
    # This does not, by default, replace PulseAudio.
    services.pipewire.enable = mkDefault true;

    environment.pathsToLink = [ "/share" ];
    environment.systemPackages =
      let
        cutefishPkgs = with pkgs.cutefish; [
          calculator
          core
          dock
          filemanager
          icons
          # kwin-plugins is currently broken,
          # please check the corresponding derivation
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
