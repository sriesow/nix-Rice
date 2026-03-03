{ config, pkgs, pkgs-unstable, ... }:

let
  gcloud-with-gke-auth = pkgs.google-cloud-sdk.withExtraComponents (
    with pkgs.google-cloud-sdk.components; [ gke-gcloud-auth-plugin ]
  );
in
{
  environment.systemPackages = with pkgs; [
    # Essential
    wget
    vim
    uv

    # Development
    claude-code
    nixfmt-rfc-style
    nodejs_22

    # Wayland/Niri
    niri
    xwayland
    mesa
    libGL
    libGLU
    grim
    slurp
    wl-clipboard
    wlr-randr
    swaybg

    # Desktop apps
    nautilus
    sushi
    brave
    google-chrome
    mpv
    slack
    postman
    solaar
    remmina
    loupe
    papers

    # System utilities
    pavucontrol
    networkmanagerapplet
    brightnessctl
    wireplumber
    lm_sensors
    exfatprogs
    ntfs3g

    # Image libraries
    libpng
    libjpeg
    libwebp

    # Network/VPN
    openvpn
    networkmanager-openvpn

    # Torrents
    fragments

    # Containers
    docker-compose

    # Cloud CLIs
    gcloud-with-gke-auth
    azure-cli
    awscli2
    kubectl

    # Theme
    catppuccin-cursors
  ];

  programs.fish.enable = true;
  programs.bash.enable = true;
}
