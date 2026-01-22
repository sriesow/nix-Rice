{ config, pkgs, ... }:

{
  # Enable niri compositor
  programs.niri.enable = true;

  # Enable graphics drivers (required for Wayland compositors)
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
}
