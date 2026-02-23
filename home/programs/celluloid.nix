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

    # mpv config for stable NVIDIA Wayland playback
    ".config/celluloid/mpv.conf".text = ''
      vo=gpu-next
      hwdec=nvdec
      gpu-api=vulkan
    '';
  };

  # Tell Celluloid to load the input and mpv configs
  dconf.settings."io/github/celluloid-player/Celluloid" = {
    mpv-input-config-enable = true;
    mpv-input-config-file = "${config.home.homeDirectory}/.config/celluloid/input.conf";
    mpv-config-enable = true;
    mpv-config-file = "${config.home.homeDirectory}/.config/celluloid/mpv.conf";
  };
}
