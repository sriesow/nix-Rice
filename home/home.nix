{ config, pkgs, pkgs-unstable, ... }:

{
  home.username = "srie";
  home.homeDirectory = "/home/srie";
  home.stateVersion = "25.11";

  imports = [
    ./programs/alacritty.nix
    ./programs/brave.nix
    ./programs/niri.nix
    ./programs/noctalia.nix
    ./programs/vscode.nix
    ./programs/firefox.nix
    ./programs/git.nix
    ./programs/starship.nix
    ./programs/fish.nix
    ./programs/gtk.nix
    ./programs/mpv.nix
  ];

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    logseq
    sublime4
    zoxide
    eza
  ];

  home.file = {
    ".face.icon".source = ../assets/avatar.png;
    ".config/wallpapers/Clearnight.jpg".source = ../assets/Clearnight.jpg;
    ".config/wallpapers/set-wallpaper.sh" = {
      text = ''
        #!/usr/bin/env bash
        swaybg -i ~/.config/wallpapers/Clearnight.jpg -m fill &
      '';
      executable = true;
    };
  };

  home.sessionVariables = {
    EDITOR = "vim";
    NIXOS_OZONE_WL = "1";
    COLORTERM = "truecolor";
  };
}
