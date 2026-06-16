{ config, pkgs, pkgs-unstable, lib, ... }:

let
  settingsPath = "${config.home.homeDirectory}/Documents/nix-Rice/assets/vscode/settings.json";

  marketplace = pkgs.vscode-utils.extensionFromVscodeMarketplace;
in
{
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      # Theme
      catppuccin.catppuccin-vsc
      catppuccin.catppuccin-vsc-icons

      # AI
      github.copilot
      github.copilot-chat
      (marketplace {
        name = "claude-code";
        publisher = "anthropic";
        version = "2.1.160";
        sha256 = "0cmdl6mwv2llqhmlg84jkkdfvfh5zb7l33pavzbrspqg29m2j30r";
      })
      (marketplace {
        name = "chatgpt";
        publisher = "openai";
        version = "0.4.71";
        sha256 = "1ag1iy8cb7wy9vq9bs22xkpzzsr4ycb9dj3q871h8ijmp3k5wja3";
      })
      (marketplace {
        name = "claude-sessions";
        publisher = "es6kr";
        version = "0.4.7";
        sha256 = "189gbpqs105zz0i6pzm74jqhn3xzdwiy9cwvqfdzifxz4xpamb8f";
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

      # Web
      (marketplace {
        name = "LiveServer";
        publisher = "ritwickdey";
        version = "5.7.9";
        sha256 = "0dycc18i1zn20zgh5ymqbi1nmg2an49ndf9r2w6dr5lx8d49hh63";
      })

      # Remote
      ms-vscode-remote.remote-ssh

      # Java
      (marketplace {
        name = "vscode-gradle";
        publisher = "vscjava";
        version = "3.17.2";
        sha256 = "1698y7nzdb67sdc9bws6cx1x6wc8vcdiyqpw1bzywcl69c7586x0";
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
