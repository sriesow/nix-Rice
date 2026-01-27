{ config, pkgs, ... }:

{
  programs.firefox = {
    enable = true;

    profiles.default = {
      name = "Default";
      isDefault = true;

      settings = {
        # Privacy settings
        "privacy.donottrackheader.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;

        # Disable telemetry
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.archive.enabled" = false;

        # Performance
        "browser.sessionstore.interval" = 15000000;

        # UI preferences
        "browser.startup.page" = 3; # Resume previous session
        "browser.tabs.loadInBackground" = true;
        "browser.urlbar.suggest.searches" = true;

        # Enable Wayland
        "widget.use-xdg-desktop-portal.file-picker" = 1;
      };
    };
  };
}
