{ config, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    # Using direct TOML file to preserve Nerd Font icons and Unicode characters
    # which get corrupted when converted through Nix
  };

  # Link the Catppuccin Powerline preset TOML directly
  home.file.".config/starship.toml".source = ../../assets/starship-catppuccin-powerline.toml;
}
