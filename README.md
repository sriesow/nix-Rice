# NixOS Configuration - Niri + Noctalia Shell

Modular NixOS configuration with niri compositor, Noctalia Shell, and beautiful lavender aesthetic.

## Features

- **Desktop Environment:** Niri (scrollable-tiling Wayland compositor)
- **Desktop Shell:** Noctalia - Sleek and minimal Wayland desktop shell with built-in app launcher
- **Terminal:** Alacritty with Starship prompt
- **Shell:** Fish - Friendly interactive shell with built-in fuzzy search
- **Applications:** Brave, Chrome, Firefox, VLC, Slack, Postman, Logseq, Sublime Text
- **Cloud Tools:** Google Cloud SDK, Azure CLI, AWS CLI
- **Terminal Tools:** Starship, Zoxide, Eza
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
│       └── noctalia.nix        # Noctalia shell config
├── assets/
│   ├── Clearnight.jpg          # Wallpaper
│   ├── niri-config.kdl         # Niri configuration
│   └── rofi-config.rasi        # Rofi configuration
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

- **starship:** Beautiful cross-shell prompt with customization
- **zoxide:** Smart directory jumper (`z` command)
- **eza:** Modern ls replacement with icons and git integration
- **fzf:** Fuzzy finder for command history and files
- **docker:** Container management
- **gcloud, az, aws:** Cloud CLIs

## Theme

Noctalia features a beautiful warm lavender aesthetic:
- Quiet by design philosophy - stays out of your way
- Modular status bar with workspace indicators
- Native support for Niri compositor
- Notification system with history panel
- Application launcher and control panels
- Fully customizable through settings panel

## License

MIT
