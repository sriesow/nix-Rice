{ config, pkgs, ... }:

{
  # Enable Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = true;
}
