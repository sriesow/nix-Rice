{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    ffsubsync
  ];

  home.file = {
    # Pre-packaged mpv scripts from nixpkgs
    ".config/celluloid/scripts/autosub.lua".source =
      "${pkgs.mpvScripts.autosub}/share/mpv/scripts/autosub.lua";
    ".config/celluloid/scripts/autosubsync-mpv".source =
      "${pkgs.mpvScripts.autosubsync-mpv}/share/mpv/scripts/autosubsync-mpv";

    # Key remappings
    ".config/celluloid/input.conf".source = ../../assets/celluloid/input.conf;
  };

  # Tell Celluloid to load the input config
  dconf.settings."io/github/celluloid-player/Celluloid" = {
    mpv-input-config-enable = true;
    mpv-input-config-file = "${config.home.homeDirectory}/.config/celluloid/input.conf";
  };
}
