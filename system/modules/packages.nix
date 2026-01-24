{ config, pkgs, pkgs-unstable, ... }:

{
  environment.systemPackages = with pkgs; [
    # Essential tools
    wget
    git
    vim
    uv

    # Development
    claude-code
    vscode

    # Niri and Wayland essentials
    niri
    xwayland
    mesa
    libGL
    libGLU

    # Terminal
    alacritty
    fish

    # Noctalia has built-in app launcher (no rofi needed)

    # Screenshots and screen recording
    grim
    slurp
    wl-clipboard

    # File manager
    kdePackages.dolphin
    kdePackages.dolphin-plugins

    # System utilities
    pavucontrol
    networkmanagerapplet
    brightnessctl
    wireplumber
    lm_sensors

    # Noctalia Shell will be configured via Home Manager with flake input

    # Wayland utilities
    wlr-randr
    swaybg

    # Image format support
    libpng
    libjpeg
    libwebp

    # Browsers
    brave
    firefox
    google-chrome

    # Applications
    vlc
    slack
    postman
    logseq
    sublime4
    solaar
    # Noctalia has built-in keep awake feature (removed caffeine-ng)

    # Network & VPN
    openvpn
    networkmanager-openvpn

    # Docker tools
    docker-compose

    # Cloud CLIs
    google-cloud-sdk
    azure-cli
    awscli2

    # Terminal enhancements
    starship
    zoxide
    eza
    # Fish has built-in fuzzy finder, no fzf needed

    # Cursor theme
    catppuccin-cursors
  ];

  # Fish shell as default
  programs.fish = {
    enable = true;
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
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
        style = "bold cyan";
      };
      git_branch = {
        symbol = " ";
        style = "bold purple";
      };
      git_status = {
        style = "bold yellow";
      };
      cmd_duration = {
        min_time = 500;
        format = "took [$duration](bold yellow)";
      };
    };
  };
}
