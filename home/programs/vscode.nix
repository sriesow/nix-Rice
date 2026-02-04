{ config, pkgs, lib, ... }:

let
  settingsPath = "${config.home.homeDirectory}/Documents/nix-Rice/assets/vscode/settings.json";
in
{
  home.packages = [ pkgs.vscode ];

  home.activation.vscodeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${config.home.homeDirectory}/.config/Code/User
    rm -f ${config.home.homeDirectory}/.config/Code/User/settings.json
    ln -sf ${settingsPath} ${config.home.homeDirectory}/.config/Code/User/settings.json
  '';
}
