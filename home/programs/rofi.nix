{ config, pkgs, ... }:

{
  # Rofi configuration managed by Home Manager
  home.file.".config/rofi/config.rasi".source = ../../assets/rofi-config.rasi;
}
