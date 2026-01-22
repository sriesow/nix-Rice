{ config, pkgs, ... }:

{
  # VirtualBox Guest Additions for testing environment
  virtualisation.virtualbox.guest.enable = true;
  virtualisation.virtualbox.guest.dragAndDrop = true;
  virtualisation.virtualbox.guest.clipboard = true;
}
