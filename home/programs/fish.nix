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
      zoxide init fish --cmd cd | source

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

      # Nix cleanup functions
      function nix-cleanup
        echo "🧹 Starting full Nix cleanup..."
        set -l before (du -sh /nix/store 2>/dev/null | awk '{print $1}')
        echo "Store size before: $before"
        echo ""

        echo "📦 Deleting old generations..."
        sudo nix-collect-garbage --delete-old

        echo "🗑️  Running garbage collection..."
        nix-store --gc

        echo "⚡ Optimizing store..."
        nix-store --optimize

        set -l after (du -sh /nix/store 2>/dev/null | awk '{print $1}')
        echo ""
        echo "✅ Cleanup complete!"
        echo "Store size after: $after"
      end

      function nix-gc
        echo "🗑️  Running garbage collection..."
        nix-collect-garbage --delete-old
        nix-store --gc
        echo "✅ Done!"
      end

      function nix-optimize
        echo "⚡ Optimizing Nix store..."
        nix-store --optimize
        echo "✅ Done!"
      end

      function nix-list-gens
        echo "📋 System generations:"
        sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
        echo ""
        echo "📋 Home-manager generations:"
        home-manager generations
      end

      # Custom aliases
      alias g='git'
      alias vim='vim'
      alias code='code'
    '';

    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "nixos-rebuild" =
        "sudo nixos-rebuild switch --flake /home/srie/Documents/nix-Rice#nixos-workstation";
      "nixos-update" =
        "cd /home/srie/Documents/nix-Rice && nix flake update && sudo nixos-rebuild switch --flake .#nixos-workstation";
    };
  };
}
