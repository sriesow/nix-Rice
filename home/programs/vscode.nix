{ config, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    # VS Code settings with profiles support
    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      # Essential extensions
      extensions = with pkgs.vscode-extensions; [
        # Python development
        ms-python.python
        ms-python.vscode-pylance

        # General development
        vscodevim.vim
        eamodio.gitlens

        # Nix support
        jnoortheen.nix-ide

        # Additional useful extensions
        esbenp.prettier-vscode
        dbaeumer.vscode-eslint
      ];

      userSettings = {
        "window.titleBarStyle" = "custom";
        "window.menuBarVisibility" = "toggle";
        "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'monospace'";
        "editor.fontSize" = 13;
        "editor.minimap.enabled" = false;
        "workbench.startupEditor" = "none";
        "telemetry.telemetryLevel" = "off";

        # Python settings
        "python.languageServer" = "Pylance";
        "python.analysis.typeCheckingMode" = "basic";

        # Editor settings
        "files.autoSave" = "afterDelay";
        "editor.formatOnSave" = true;
        "editor.tabSize" = 2;
      };
    };
  };
}
