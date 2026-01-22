# NixOS Configuration - Niri + DankMaterialShell

Modular NixOS configuration with niri compositor, DankMaterialShell, and Catppuccin theme.

## Features

- **Desktop Environment:** Niri (scrollable-tiling Wayland compositor)
- **Shell:** DankMaterialShell with Catppuccin Mocha theme
- **Terminal:** Alacritty with Starship prompt
- **Applications:** Brave, Chrome, VLC, Slack, Postman, Logseq, Sublime Text, and more
- **Cloud Tools:** Google Cloud SDK, Azure CLI, AWS CLI
- **Docker:** Full Docker support with compose
- **VPN:** OpenVPN configured

## Structure

```
nixos-config/
├── flake.nix                    # Flake configuration
├── flake.lock                   # Locked dependencies
├── system/
│   ├── configuration.nix        # Main system config
│   ├── hardware-configuration.nix
│   └── modules/
│       ├── niri.nix            # Niri compositor
│       ├── virtualbox.nix      # VirtualBox guest (testing)
│       ├── workstation.nix     # Workstation hardware (production)
│       ├── fonts.nix           # Font configuration
│       ├── docker.nix          # Docker configuration
│       └── packages.nix        # System packages
├── home/
│   ├── home.nix                # Home Manager config
│   └── programs/
│       ├── alacritty.nix       # Alacritty terminal
│       ├── niri.nix            # Niri user config
│       ├── rofi.nix            # Rofi launcher
│       ├── starship.nix        # Starship prompt
│       └── shell.nix           # Shell (bash/zsh) config
└── README.md                    # This file
```

## Installation

### VirtualBox (Testing)

```bash
sudo nixos-rebuild switch --flake ~/nixos-config#nixos-vbox
```

### Workstation (Production)

```bash
sudo nixos-rebuild switch --flake ~/nixos-config#nixos-workstation
```

## Profiles

- **nixos-vbox:** VirtualBox guest configuration with 3D acceleration
- **nixos-workstation:** Production workstation with proper GPU drivers

## Keybindings (Niri)

- `Mod+Return`: Open Alacritty terminal
- `Mod+D`: Application launcher (Rofi)
- `Mod+Q`: Close window
- `Mod+H/J/K/L`: Navigate windows
- `Mod+Shift+H/J/K/L`: Move windows
- `Mod+1-5`: Switch workspaces
- `Mod+Shift+1-5`: Move window to workspace
- `Mod+Shift+E`: Logout
- `Print`: Screenshot

## Terminal Tools

- **starship:** Beautiful shell prompt
- **zoxide:** Smart directory jumper (`z` command)
- **docker:** Container management
- **gcloud, az, aws:** Cloud CLIs

## Theme

Catppuccin Mocha throughout:
- Primary: `#CBA6F7` (Mauve)
- Background: `#1E1E2E`
- Accent colors match Catppuccin palette

## License

MIT
