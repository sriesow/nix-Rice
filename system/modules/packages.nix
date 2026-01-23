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

    # Application launcher
    rofi

    # Screenshots and screen recording
    grim
    slurp
    wl-clipboard

    # File manager
    xfce.thunar
    xfce.thunar-volman

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
    caffeine-ng

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
    fzf

    # Cursor theme
    catppuccin-cursors
  ];

  # Shell configuration with modern terminal tools
  programs.bash.interactiveShellInit = ''
    # Zoxide - smart directory jumper
    eval "$(zoxide init bash)"

    # Eza - modern ls replacement
    alias ls='eza --icons'
    alias ll='eza -l --icons'
    alias la='eza -la --icons'
    alias lt='eza --tree --icons'

    # Fzf - fuzzy finder
    eval "$(fzf --bash)"
  '';

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
