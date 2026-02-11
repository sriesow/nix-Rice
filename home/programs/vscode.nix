{ config, pkgs, pkgs-unstable, lib, ... }:

let
  settingsPath = "${config.home.homeDirectory}/Documents/nix-Rice/assets/vscode/settings.json";

  marketplace = pkgs.vscode-utils.extensionFromVscodeMarketplace;
in
{
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    extensions = with pkgs.vscode-extensions; [
      # Theme
      catppuccin.catppuccin-vsc
      catppuccin.catppuccin-vsc-icons

      # AI
      github.copilot
      github.copilot-chat
      (marketplace {
        name = "claude-code";
        publisher = "anthropic";
        version = "2.1.39";
        sha256 = "11xwyvp6h7yx9b7vmgx4w7c3xrkjcrmahqzqdgf135dx04xqvrph";
      })
      (marketplace {
        name = "chatgpt";
        publisher = "openai";
        version = "0.4.71";
        sha256 = "1ag1iy8cb7wy9vq9bs22xkpzzsr4ycb9dj3q871h8ijmp3k5wja3";
      })

      # Git
      eamodio.gitlens

      # Formatters / Linters
      esbenp.prettier-vscode
      dbaeumer.vscode-eslint

      # Database
      (marketplace {
        name = "vscode-postgres";
        publisher = "ckolkman";
        version = "1.4.3";
        sha256 = "054a34icj8xig47w6k3j42i99b6srf254s5cl2knrgprrlsvcb1q";
      })

      # Nix
      jnoortheen.nix-ide

      # Python
      ms-python.python
      ms-python.vscode-pylance
    ];
  };

  home.activation.vscodeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${config.home.homeDirectory}/.config/Code/User
    rm -f ${config.home.homeDirectory}/.config/Code/User/settings.json
    ln -sf ${settingsPath} ${config.home.homeDirectory}/.config/Code/User/settings.json
  '';
}
