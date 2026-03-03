{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    ffsubsync
  ];

  home.file = {
    # Pre-packaged mpv scripts from nixpkgs
    ".config/mpv/scripts/autosub.lua".source =
      "${pkgs.mpvScripts.autosub}/share/mpv/scripts/autosub.lua";
    ".config/mpv/scripts/autosubsync-mpv".source =
      "${pkgs.mpvScripts.autosubsync-mpv}/share/mpv/scripts/autosubsync-mpv";

    # Key remappings
    ".config/mpv/input.conf".source = ../../assets/mpv/input.conf;
  };
}
