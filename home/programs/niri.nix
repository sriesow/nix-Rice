{ config, pkgs, ... }:

{
  # Niri configuration managed by Home Manager
  home.file.".config/niri/config.kdl".source = ../../assets/niri-config.kdl;
}
