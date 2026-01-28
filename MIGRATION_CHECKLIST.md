# NixOS Migration Checklist - Linux Mint to NixOS Workstation

## VirtualBox VM Limitation: Clipboard Sharing

If you're testing in VirtualBox and clipboard sharing isn't working, use this prompt on your host machine:

---

**Copy this to Claude on your Linux Mint host machine:**

I'm continuing a NixOS migration conversation from a VirtualBox VM. I'm planning to install NixOS on my workstation (32GB RAM, NVIDIA RTX 2080 Ti) alongside Linux Mint in a dual-boot setup.

I need help calculating exact partition sizes for NixOS based on my current disk layout.

Please analyze my disk layout and recommend exact partition sizes for:
- NixOS Root (/) - recommended 150-200 GB
- NixOS Home (/home) - remaining space
- Swap - recommended 48-64 GB for hibernation

Here's my current disk layout:

```bash
# Run these commands on Linux Mint and paste output:
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT

sudo parted -l

df -h
```

**After you provide the output, I need:**
1. Exact partition sizes calculated based on available free space
2. Specific partition device names (e.g., /dev/sda4, /dev/sda5)
3. Commands to create these partitions during NixOS installation

**My NixOS config repository:** https://github.com/sriesow/nix-Rice (noctalia branch)

The config already has:
- NVIDIA RTX 2080 Ti configuration with CUDA support in `system/modules/nvidia.nix`
- Migration checklist in `MIGRATION_CHECKLIST.md`
- Workstation configuration that imports the NVIDIA module

---

## Pre-Migration: Data Backup (Do This First!)

### Critical Data to Backup
- [ ] **Home directory backup**
  ```bash
  # From Linux Mint
  rsync -avP /home/srie/ /mnt/external-drive/mint-backup/
  ```

- [ ] **Browser data**
  - [ ] Firefox: `~/.mozilla/firefox/`
  - [ ] Chrome: `~/.config/google-chrome/`
  - [ ] Brave: `~/.config/BraveSoftware/`
  - [ ] Bookmarks exported to HTML

- [ ] **SSH keys and Git credentials**
  - [ ] `~/.ssh/` directory (private keys!)
  - [ ] `~/.gitconfig`
  - [ ] Git credential store: `~/.git-credentials`

- [ ] **Application data**
  - [ ] VS Code: `~/.config/Code/User/` (settings, keybindings, snippets)
  - [ ] Postman: `~/.config/Postman/`
  - [ ] Slack: `~/.config/Slack/`
  - [ ] Any custom scripts in `~/bin` or `~/.local/bin`

- [ ] **Development projects**
  - [ ] `~/Projects/` or wherever your code lives
  - [ ] Docker volumes/containers list: `docker ps -a`, `docker volume ls`
  - [ ] Database dumps if you have local DBs

- [ ] **Cloud CLI configurations**
  - [ ] `~/.aws/` (AWS credentials)
  - [ ] `~/.config/gcloud/` (Google Cloud)
  - [ ] `~/.azure/` (Azure)

- [ ] **VPN configurations**
  - [ ] OpenVPN configs: `/etc/openvpn/` or `~/.config/openvpn/`
  - [ ] Any VPN certificates

- [ ] **Documents and media**
  - [ ] Documents: `~/Documents/`
  - [ ] Pictures: `~/Pictures/`
  - [ ] Downloads: `~/Downloads/` (check for important files)

---

## Phase 1: Pre-Installation Checks (Week 0)

### System Information Gathering
- [ ] **Check current partition layout**
  ```bash
  lsblk -f
  sudo fdisk -l
  sudo parted -l
  df -h
  ```
  - [ ] Note down disk device (e.g., /dev/sda, /dev/nvme0n1)
  - [ ] Note down available free space
  - [ ] Note down EFI partition location

- [ ] **Check user ID for consistency**
  ```bash
  id -u srie  # Should be 1000
  id -g srie  # Should be 1000
  ```

- [ ] **Check NVIDIA driver version in Mint**
  ```bash
  nvidia-smi
  ```

- [ ] **List installed applications**
  ```bash
  dpkg --get-selections | grep -v deinstall > ~/mint-packages.txt
  ```

- [ ] **Document current system specs**
  ```bash
  inxi -Fxz > ~/system-info.txt
  ```

### Create Installation Media
- [ ] Download NixOS 25.11 ISO
  ```bash
  wget https://channels.nixos.org/nixos-25.11/latest-nixos-minimal-x86_64-linux.iso
  ```
- [ ] Verify checksum
- [ ] Create bootable USB
  ```bash
  sudo dd if=latest-nixos-minimal-x86_64-linux.iso of=/dev/sdX bs=4M status=progress oflag=sync
  ```

---

## Phase 2: NixOS Installation (Week 1, Day 1-2)

### Partitioning
- [ ] Boot from NixOS USB
- [ ] Check available space: `lsblk`
- [ ] Create partitions using `parted` or `gparted`:
  - [ ] NixOS root: 100-150 GB (ext4)
  - [ ] NixOS home: Remaining space (ext4)
  - [ ] Swap: 32-64 GB (for hibernation with 32GB RAM)

### Format and Mount
- [ ] Format partitions:
  ```bash
  sudo mkfs.ext4 -L nixos-root /dev/sdaX
  sudo mkfs.ext4 -L nixos-home /dev/sdaY
  sudo mkswap -L swap /dev/sdaZ
  ```
- [ ] Mount partitions:
  ```bash
  sudo mount /dev/sdaX /mnt
  sudo mkdir -p /mnt/home /mnt/boot
  sudo mount /dev/sdaY /mnt/home
  sudo mount /dev/sda1 /mnt/boot  # Existing EFI partition
  sudo swapon /dev/sdaZ
  ```

### Base Installation
- [ ] Generate config: `sudo nixos-generate-config --root /mnt`
- [ ] Edit `/mnt/etc/nixos/configuration.nix`:
  - [ ] Set hostname
  - [ ] Create user account (uid = 1000)
  - [ ] Enable NetworkManager
  - [ ] Add basic packages
- [ ] Install: `sudo nixos-install`
- [ ] Set root password
- [ ] Reboot into NixOS

### First Boot
- [ ] Login as user
- [ ] Test network: `ping google.com`
- [ ] Test sudo access
- [ ] Check partitions mounted correctly: `df -h`

---

## Phase 3: Apply Your Configuration (Week 1, Day 3-4)

### Clone and Setup Config
- [ ] Install git if not available: `nix-shell -p git`
- [ ] Clone your config:
  ```bash
  cd ~
  git clone https://github.com/YOUR_USERNAME/nixos-config
  cd nixos-config
  ```

### Update Configuration for Workstation
- [ ] Update `flake.nix` if needed
- [ ] Ensure `system/modules/nvidia.nix` is imported in workstation config
- [ ] Check `system/modules/workstation.nix` exists and imports nvidia module
- [ ] Verify hardware-configuration.nix matches your system

### Apply Configuration
- [ ] Build configuration:
  ```bash
  cd ~/nixos-config
  sudo nixos-rebuild switch --flake .#nixos-workstation
  ```
- [ ] Reboot to load NVIDIA drivers
- [ ] Verify NVIDIA working: `nvidia-smi`
- [ ] Verify CUDA working: `nvcc --version`

### Test Niri + Noctalia Shell
- [ ] Login to Niri session
- [ ] Check Noctalia Shell loads: `systemctl --user status noctalia-shell`
- [ ] Test Alacritty transparency
- [ ] Test basic keybindings (Mod+Return for terminal)

---

## Phase 4: Application Migration (Week 1-2)

### Development Environment
- [ ] **VS Code**
  - [ ] Verify VS Code installed (already in your config)
  - [ ] Copy settings: `~/.config/Code/User/settings.json`
  - [ ] Install extensions (sync via GitHub account or manually)
  - [ ] Test Wayland mode works (NIXOS_OZONE_WL=1 already in config)

- [ ] **Git Configuration**
  - [ ] Already configured in `home/programs/git.nix`
  - [ ] Copy SSH keys from Mint:
    ```bash
    sudo mount /dev/sdaY /mnt/mint-home  # Your Mint home partition
    cp -a /mnt/mint-home/srie/.ssh ~/.ssh
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/id_*
    ```
  - [ ] Test git authentication: `ssh -T git@github.com`

- [ ] **Docker**
  - [ ] Already configured in your config
  - [ ] Add user to docker group (should be automatic)
  - [ ] Test: `docker run hello-world`
  - [ ] Migrate docker volumes if needed

- [ ] **Development Projects**
  - [ ] Copy projects from Mint:
    ```bash
    sudo mount /dev/sdaY /mnt/mint-home
    cp -a /mnt/mint-home/srie/Projects ~/Projects
    ```
  - [ ] Test builds in each project
  - [ ] Verify dependencies work in NixOS

### Browsers and Communication
- [ ] **Firefox**
  - [ ] Already configured via Home Manager
  - [ ] Copy profile from Mint:
    ```bash
    sudo mount /dev/sdaY /mnt/mint-home
    cp -a /mnt/mint-home/srie/.mozilla ~/.mozilla
    ```
  - [ ] Or use Firefox Sync

- [ ] **Chrome/Brave**
  - [ ] Already in system packages
  - [ ] Login to sync settings
  - [ ] Or manually copy profiles

- [ ] **Slack**
  - [ ] Already in system packages
  - [ ] Login to workspaces
  - [ ] Test notifications

### Cloud Tools
- [ ] **AWS CLI**
  - [ ] Already in packages
  - [ ] Copy credentials:
    ```bash
    sudo mount /dev/sdaY /mnt/mint-home
    cp -a /mnt/mint-home/srie/.aws ~/.aws
    chmod 600 ~/.aws/credentials
    ```
  - [ ] Test: `aws s3 ls` or similar

- [ ] **Google Cloud SDK**
  - [ ] Already in packages
  - [ ] Copy config:
    ```bash
    cp -a /mnt/mint-home/srie/.config/gcloud ~/.config/gcloud
    ```
  - [ ] Or login fresh: `gcloud auth login`

- [ ] **Azure CLI**
  - [ ] Already in packages
  - [ ] Copy config:
    ```bash
    cp -a /mnt/mint-home/srie/.azure ~/.azure
    ```
  - [ ] Or login fresh: `az login`

### VPN
- [ ] **OpenVPN**
  - [ ] Already configured (networkmanager-openvpn)
  - [ ] Copy VPN configs if stored locally
  - [ ] Test VPN connection

### Other Applications
- [ ] **Postman**
  - [ ] Already in packages
  - [ ] Copy workspace data:
    ```bash
    cp -a /mnt/mint-home/srie/.config/Postman ~/.config/Postman
    ```

- [ ] **VLC**
  - [ ] Already in packages
  - [ ] Test media playback

- [ ] **Nautilus (File Manager)**
  - [ ] Already in packages
  - [ ] Copy bookmarks if any

---

## Phase 5: System Optimization (Week 2)

### NVIDIA Optimization
- [ ] Test GPU performance: `glxinfo | grep "OpenGL renderer"`
- [ ] Test CUDA: Run a simple CUDA program or PyTorch
- [ ] Monitor GPU: `nvtop`
- [ ] Check for screen tearing (uncomment fix in nvidia.nix if needed)
- [ ] Test hardware acceleration in browsers: `about:support` in Firefox

### Performance Tuning
- [ ] Check boot time: `systemd-analyze`
- [ ] Optimize nix store: `nix-store --optimize`
- [ ] Setup automatic garbage collection:
  ```nix
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  ```

### Backup Strategy
- [ ] Setup automated backups for NixOS
- [ ] Document your configuration in git
- [ ] Keep your flake.lock updated: `nix flake update`

---

## Phase 6: Full Migration (Week 3-4)

### Daily Driver Testing
- [ ] Use NixOS as primary for 1 week
- [ ] Document any issues or missing features
- [ ] Add missing packages to config as needed
- [ ] Test all workflows:
  - [ ] Development (coding, building, testing)
  - [ ] Communication (Slack, email, video calls)
  - [ ] Web browsing
  - [ ] Media playback
  - [ ] GPU workloads (CUDA, ML if applicable)

### Configuration Refinement
- [ ] Tune Alacritty settings (opacity, fonts)
- [ ] Customize Starship prompt if still having issues
- [ ] Adjust Noctalia Shell widgets
- [ ] Setup custom keybindings in Niri
- [ ] Configure application-specific settings

### Final Migration
- [ ] Copy remaining data from Mint
- [ ] Verify all critical files copied
- [ ] Keep Mint bootable as emergency backup
- [ ] Update documentation

---

## Rollback Plan (If Things Go Wrong)

### If NixOS Won't Boot
- [ ] Boot from USB
- [ ] Mount NixOS partitions
- [ ] `nixos-enter` to chroot
- [ ] Rollback: `nixos-rebuild switch --rollback`

### If You Need to Go Back to Mint
- [ ] Linux Mint should still be bootable
- [ ] All your data in Mint home is untouched
- [ ] NixOS home is separate, won't interfere

### If Dual Boot Fails
- [ ] Boot from USB
- [ ] Reinstall systemd-boot or GRUB
- [ ] Check `/boot/loader/entries/` for boot entries

---

## Post-Migration Checklist (Month 2+)

### Maintenance
- [ ] Weekly: Cleanup old generations
  ```bash
  nix-collect-garbage --delete-older-than 7d
  sudo nixos-rebuild switch
  ```
- [ ] Monthly: Update flake inputs
  ```bash
  nix flake update
  sudo nixos-rebuild switch --flake .#nixos-workstation
  ```
- [ ] Commit all config changes to git
- [ ] Push to remote repository

### Optional: Reclaim Mint Partitions
Only after you're 100% confident:
- [ ] Backup any remaining data from Mint
- [ ] Delete Mint partitions using `parted` or `gparted`
- [ ] Expand NixOS home partition to use freed space
- [ ] Update `/etc/nixos/hardware-configuration.nix` if needed

---

## Quick Reference: Useful Commands

### NixOS Management
```bash
# Rebuild system
sudo nixos-rebuild switch --flake .#nixos-workstation

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Delete old generations
sudo nix-collect-garbage --delete-older-than 7d

# Optimize store
nix-store --optimize

# Update flake
nix flake update
```

### NVIDIA Commands
```bash
# Check GPU status
nvidia-smi

# Monitor GPU
nvtop

# Check CUDA
nvcc --version

# OpenGL info
glxinfo | grep "OpenGL"
```

### Niri Commands
```bash
# Reload config
niri msg action load-config-file

# List windows
niri msg windows

# Restart Niri
systemctl restart --user niri
```

### Noctalia Commands
```bash
# Check status
systemctl --user status noctalia-shell

# Restart
systemctl --user restart noctalia-shell

# View logs
journalctl --user -u noctalia-shell -f
```

---

## Emergency Contacts / Resources

- NixOS Manual: https://nixos.org/manual/nixos/stable/
- NixOS Discourse: https://discourse.nixos.org/
- Niri Wiki: https://github.com/YaLTeR/niri/wiki
- Your config repo: Check README and commit history
- This checklist: Keep updated as you learn

---

## Notes and Customizations

Add your own notes here as you go through migration:

```
[Date] [Issue/Success] [Resolution]
Example:
2026-01-28 | Screen tearing in Chrome | Fixed by enabling ForceFullCompositionPipeline
2026-01-29 | CUDA not found | Added CUDA_PATH to environment variables
```
