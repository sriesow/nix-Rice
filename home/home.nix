{ config, pkgs, pkgs-unstable, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = "srie";
  home.homeDirectory = "/home/srie";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "25.11";

  # Import program configurations
  imports = [
    ./programs/alacritty.nix
    ./programs/niri.nix
    ./programs/noctalia.nix
    ./programs/vscode.nix
    ./programs/firefox.nix
    ./programs/git.nix
    ./programs/starship.nix
    ./programs/fish.nix
    # Rofi removed - using Noctalia's built-in app launcher
  ];

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Additional packages specific to user environment
  home.packages = with pkgs; [
    # User applications
    logseq
    sublime4

    # CLI tools
    zoxide
    eza
  ];

  # Home Manager managed dotfiles
  home.file = {
    # Wallpaper
    ".config/wallpapers/Clearnight.jpg".source = ../assets/Clearnight.jpg;
    ".config/wallpapers/set-wallpaper.sh" = {
      text = ''
        #!/usr/bin/env bash
        # Wallpaper setter for niri with swaybg
        swaybg -i ~/.config/wallpapers/Clearnight.jpg -m fill &
      '';
      executable = true;
    };
  };

  # Environment variables
  home.sessionVariables = {
    EDITOR = "vim";
    # Enable Wayland support for Electron apps (VS Code, etc.)
    NIXOS_OZONE_WL = "1";
    # Enable 24-bit true color support in terminals
    COLORTERM = "truecolor";
  };
}
