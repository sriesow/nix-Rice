{ config, pkgs, inputs, ... }:

{
  # Import Noctalia Home Manager module
  imports = [ inputs.noctalia.homeModules.default ];

  # Configure Noctalia Shell
  programs.noctalia-shell = {
    enable = true;

    # Enable systemd service for automatic startup
    systemd.enable = true;

    # Settings will use defaults from Noctalia
    # You can customize later by accessing:
    # "Open Settings Panel" → "General" → "Copy Settings"
    # Then paste the JSON here
    settings = {
      # Noctalia will use its default settings
      # Includes the beautiful lavender aesthetic
    };
  };
}
