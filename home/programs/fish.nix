{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;

    shellInit = ''
      set fish_greeting
      set -gx COLORTERM truecolor
      fish_add_path -g $HOME/.local/bin
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
        # Use active NixOS system profiles to determine which boot files are needed
        # Boot filenames follow pattern: <store-dir-basename>-<filename>
        # e.g. /nix/store/abc123-linux-6.12.85/bzImage -> abc123-linux-6.12.85-bzImage
        set -l referenced

        # Safety: always include currently running system
        set -l running_kernel (readlink -f /run/current-system/kernel 2>/dev/null)
        set -l running_initrd (readlink -f /run/current-system/initrd 2>/dev/null)
        if test -z "$running_kernel" -o -z "$running_initrd"
          echo "ERROR: Cannot resolve running system kernel/initrd. Aborting boot cleanup for safety."
          return 1
        end

        for profile in /nix/var/nix/profiles/system-*-link /nix/var/nix/profiles/system /run/current-system
          if test -e "$profile"
            set -l kernel_store (readlink -f "$profile"/kernel 2>/dev/null)
            set -l initrd_store (readlink -f "$profile"/initrd 2>/dev/null)
            if test -n "$kernel_store"
              set -l dir_name (basename (dirname "$kernel_store"))
              set -l file_name (basename "$kernel_store")
              set -a referenced "$dir_name-$file_name"
            end
            if test -n "$initrd_store"
              set -l dir_name (basename (dirname "$initrd_store"))
              set -l file_name (basename "$initrd_store")
              set -a referenced "$dir_name-$file_name"
            end
          end
        end
        set referenced (printf '%s\n' $referenced | sort -u)
        if test (count $referenced) -eq 0
          echo "ERROR: Referenced file list is empty. Aborting boot cleanup for safety."
          return 1
        end

        # Safety: verify at least one kernel and one initrd in referenced list
        set -l has_kernel false
        set -l has_initrd false
        for ref in $referenced
          string match -q "*-bzImage" -- "$ref"; and set has_kernel true
          string match -q "*-initrd" -- "$ref"; and set has_initrd true
        end
        if test "$has_kernel" = false -o "$has_initrd" = false
          echo "ERROR: Referenced list missing kernel or initrd. Aborting boot cleanup for safety."
          echo "Referenced: $referenced"
          return 1
        end

        echo "Files needed by active profiles:"
        for ref in $referenced
          echo "  KEEP: $ref"
        end

        # Dry-run: collect files to delete
        set -l to_delete
        for f in /boot/kernels/*
          set -l fname (basename "$f")
          if string match -q "*.tmp" -- "$fname"
            set -a to_delete "$f"
          else if not contains -- "$fname" $referenced
            set -a to_delete "$f"
          end
        end

        if test (count $to_delete) -eq 0
          echo "No stale boot files found."
        else
          # Safety: ensure we are NOT deleting everything
          set -l total_files (count /boot/kernels/*)
          if test (count $to_delete) -ge $total_files
            echo "ERROR: Would delete ALL boot files. Aborting for safety."
            echo "Files on disk: $total_files, would delete: "(count $to_delete)
            return 1
          end

          echo "Files to remove:"
          for f in $to_delete
            echo "  DELETE: "(basename "$f")
          end

          read -P "Proceed with deletion? [y/N] " -l confirm
          if test "$confirm" = y -o "$confirm" = Y
            for f in $to_delete
              sudo rm -f "$f"
              echo "Removed: "(basename "$f")
            end
          else
            echo "Skipped boot cleanup."
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

      function cpsync
        if test (count $argv) -lt 2
          echo (set_color red)"Usage: cpsync <source> <destination>"(set_color normal)
          return 1
        end
        set -l src $argv[1..-2]
        set -l dst $argv[-1]
        echo (set_color cyan)"━━━ Syncing ━━━"(set_color normal)
        echo (set_color yellow)"  Source: "(set_color green)"$src"(set_color normal)
        echo (set_color yellow)"  Dest:   "(set_color green)"$dst"(set_color normal)
        echo (set_color cyan)"━━━━━━━━━━━━━━━"(set_color normal)
        echo
        rsync -avh --info=progress2 --stats --human-readable $argv
        if test $status -eq 0
          echo
          echo (set_color green)"✓ Sync completed successfully!"(set_color normal)
        else
          echo
          echo (set_color red)"✗ Sync failed!"(set_color normal)
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
