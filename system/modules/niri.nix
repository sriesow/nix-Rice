{ config, pkgs, ... }:

{
  programs.niri.enable = true;
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
}
