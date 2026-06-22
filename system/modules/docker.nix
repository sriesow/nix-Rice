{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = true;
  # docker_28 unmaintained since Nov 2025 (marked insecure); use docker_29.
  virtualisation.docker.package = pkgs.docker_29;
}
