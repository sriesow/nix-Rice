{ config, pkgs, ... }:

{
  home.file.".config/niri/config.kdl".source = ../../assets/niri-config.kdl;
}
