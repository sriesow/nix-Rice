{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;

    shellInit = ''
      set fish_greeting
      set -gx COLORTERM truecolor
    '';

    interactiveShellInit = ''
      starship init fish | source
      zoxide init fish --cmd cd | source

      functions --erase ls ll la 2>/dev/null
      function ls; eza --icons $argv; end
      function ll; eza -l --icons $argv; end
      function la; eza -la --icons $argv; end
      function lt; eza --tree --icons $argv; end

      function nix-cleanup
        echo "Starting Nix cleanup..."
        set -l before (du -sh /nix/store 2>/dev/null | awk '{print $1}')
        echo "Store size before: $before"
        sudo nix-collect-garbage --delete-old
        nix-store --gc
        nix-store --optimize
        set -l after (du -sh /nix/store 2>/dev/null | awk '{print $1}')
        echo "Store size after: $after"
      end

      function nix-gc
        nix-collect-garbage --delete-old
        nix-store --gc
      end

      function nix-optimize
        nix-store --optimize
      end

      function nix-list-gens
        echo "System generations:"
        sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
        echo ""
        echo "Home-manager generations:"
        home-manager generations
      end

      function activate_venv --on-variable PWD
        if test -f .venv/bin/activate.fish
          source .venv/bin/activate.fish
        end
      end

      alias g='git'
    '';

    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "nixos-rebuild" = "sudo nixos-rebuild switch --flake /home/srie/Documents/nix-Rice#nixos-workstation";
      "nixos-update" = "cd /home/srie/Documents/nix-Rice && nix flake update && sudo nixos-rebuild switch --flake .#nixos-workstation";
    };
  };
}
