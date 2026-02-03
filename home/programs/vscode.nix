{ config, pkgs, lib, ... }:

let
  # Get the absolute path to settings.json in the nix-Rice repo
  settingsPath = "${config.home.homeDirectory}/Documents/nix-Rice/assets/vscode/settings.json";
in
{
  # Install VS Code as a package only
  home.packages = [ pkgs.vscode ];

  # Create VS Code User directory and symlink settings from assets
  # This activation script runs after home-manager creates its symlinks
  home.activation.vscodeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Ensure VS Code User directory exists
    mkdir -p ${config.home.homeDirectory}/.config/Code/User

    # Remove any existing settings.json (could be a symlink to Nix store)
    rm -f ${config.home.homeDirectory}/.config/Code/User/settings.json

    # Create direct symlink to assets file (writable location)
    ln -sf ${settingsPath} ${config.home.homeDirectory}/.config/Code/User/settings.json

    echo "VS Code settings.json symlinked to assets directory"
  '';

  # Optional: Install extensions via Nix (uncomment if desired)
  # Alternatively, let VS Code manage extensions directly for flexibility
  # programs.vscode = {
  #   enable = true;
  #   extensions = with pkgs.vscode-extensions; [
  #     ms-python.python
  #     ms-python.vscode-pylance
  #     eamodio.gitlens
  #     jnoortheen.nix-ide
  #     esbenp.prettier-vscode
  #     dbaeumer.vscode-eslint
  #   ];
  #   mutableExtensionsDir = true;
  # };
}
