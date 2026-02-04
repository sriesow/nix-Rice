{ config, pkgs, ... }:

{
  programs.starship.enable = true;
  home.file.".config/starship.toml".source = ../../assets/starship-catppuccin-powerline.toml;
}
