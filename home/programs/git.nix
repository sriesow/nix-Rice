{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    userName = "srie";
    userEmail = "srie@example.com"; # Update with your actual email

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      core.editor = "vim";

      # Better diff output
      diff.algorithm = "histogram";

      # Credential helper
      credential.helper = "store";
    };

    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
    };
  };
}
