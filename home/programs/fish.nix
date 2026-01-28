{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;

    shellInit = ''
      # Disable greeting
      set fish_greeting

      # Enable 24-bit color support
      set -gx COLORTERM truecolor
    '';

    interactiveShellInit = ''
      # Starship prompt
      starship init fish | source

      # Zoxide - smart directory jumper
      zoxide init fish | source

      # Eza functions (override built-in ls)
      functions --erase ls ll la 2>/dev/null

      function ls
        eza --icons $argv
      end

      function ll
        eza -l --icons $argv
      end

      function la
        eza -la --icons $argv
      end

      function lt
        eza --tree --icons $argv
      end

      # Custom aliases
      alias g='git'
      alias vim='vim'
      alias code='code'
    '';

    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      "nixos-rebuild" = "sudo nixos-rebuild switch --flake /home/srie/nixos-config#nixos-vbox";
      "nixos-update" = "cd /home/srie/nixos-config && nix flake update && sudo nixos-rebuild switch --flake .#nixos-vbox";
    };
  };
}
