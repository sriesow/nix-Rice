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
        echo "Cleaning stale boot files..."
        # Collect nix store dir names (e.g. "abc123-linux-6.12.74") for remaining profiles
        set -l keep_patterns
        for profile in /nix/var/nix/profiles/system /nix/var/nix/profiles/system-*-link
          for target in kernel initrd
            if test -L "$profile/$target"
              set -l store_path (readlink -f "$profile/$target" 2>/dev/null)
              if test -n "$store_path"
                set -l store_dir (string replace -r '^/nix/store/([^/]+)/.*' '$1' -- "$store_path")
                if test -n "$store_dir"
                  set -a keep_patterns "$store_dir"
                end
              end
            end
          end
        end
        if test (count $keep_patterns) -eq 0
          echo "Warning: Could not determine current kernel store paths. Skipping boot cleanup."
          set -l after (du -sh /nix/store 2>/dev/null | awk '{print $1}')
          echo "Store size after: $after"
          return
        end
        echo "Keeping boot files matching: $keep_patterns"
        for f in /boot/kernels/*
          set -l fname (basename "$f")
          if string match -q "*.tmp" -- "$fname"
            echo "Removing incomplete: $fname"
            sudo rm -f "$f"
            continue
          end
          set -l keep false
          for pattern in $keep_patterns
            if string match -q "*$pattern*" -- "$fname"
              set keep true
              break
            end
          end
          if test "$keep" = false
            echo "Removing stale: $fname"
            sudo rm -f "$f"
          end
        end
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
