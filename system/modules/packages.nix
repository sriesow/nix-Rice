{ config, pkgs, pkgs-unstable, ... }:

{
  environment.systemPackages = with pkgs; [
    # Essential tools
    wget
    vim
    uv

    # Development
    claude-code
    # VS Code managed by Home Manager for better desktop integration
    # Git managed by Home Manager for better config management

    # Niri and Wayland essentials
    niri
    xwayland
    mesa
    libGL
    libGLU

    # Terminal (Alacritty managed by Home Manager)
    # Fish shell managed by Home Manager

    # Noctalia has built-in app launcher (no rofi needed)

    # Screenshots and screen recording
    grim
    slurp
    wl-clipboard

    # File manager
    nautilus
    sushi  # File previewer for Nautilus

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

    # Browsers (kept system-wide for multi-user access)
    brave
    # Firefox managed by Home Manager for better profile management
    google-chrome

    # Applications
    vlc
    slack
    postman
    # Logseq and Sublime4 managed by Home Manager
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

    # Terminal enhancements managed by Home Manager:
    # - starship (prompt)
    # - zoxide (directory jumper)
    # - eza (ls replacement)

    # Cursor theme
    catppuccin-cursors
  ];

  # Fish shell as default - keep system-wide to set default shell
  # Actual Fish configuration managed by Home Manager
  programs.fish.enable = true;
}
