{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "srie";
        email = "srie@example.com"; # Update with your actual email
      };

      init.defaultBranch = "main";
      pull.rebase = false;
      core.editor = "vim";

      # Better diff output
      diff.algorithm = "histogram";

      # Credential helper
      credential.helper = "store";

      # Aliases
      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        ci = "commit";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      };
    };
  };
}
