# NixOS Dual Boot Installation Guide
## Workstation: 32GB RAM, NVIDIA RTX 2080 Ti, alongside Linux Mint

**IMPORTANT: Keep this guide on your USB drive for reference during installation!**

---

## Pre-Installation Checklist

- [x] Backup complete
- [ ] Booted to NixOS installer USB
- [ ] Internet connection working (test with `ping google.com`)

---

## Part 1: Partition Management

### Step 1.1: Verify Current Layout

```bash
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
sudo parted /dev/nvme0n1 print free
```

**Expected: nvme0n1p4 should be 836GB**

---

### Step 1.2: Shrink Linux Mint /home Partition

```bash
# Check filesystem integrity
sudo e2fsck -f /dev/nvme0n1p4
```

**Wait for completion. Should show: "clean, X files, Y blocks"**

```bash
# Shrink filesystem to 275GB (5GB safety buffer)
sudo resize2fs /dev/nvme0n1p4 275G
```

**This will take several minutes. Watch for "The filesystem on /dev/nvme0n1p4 is now..."**

```bash
# Shrink partition to 445GB
sudo parted /dev/nvme0n1 resizepart 4 445GB
```

**Type the partition number: 4**
**Type the end position: 445GB**

```bash
# Final verification check
sudo e2fsck -f /dev/nvme0n1p4
```

**Should complete without errors**

```bash
# Verify free space available
sudo parted /dev/nvme0n1 print free
```

**You should see ~556GB free space after nvme0n1p4**

---

### Step 1.3: Create NixOS Partitions

```bash
# Create NixOS Swap (48GB) - for hibernation
sudo parted /dev/nvme0n1 mkpart primary linux-swap 445GB 493GB

# Create NixOS Root (200GB) - for /
sudo parted /dev/nvme0n1 mkpart primary ext4 493GB 693GB

# Create NixOS Home (307GB) - for /home (remaining space)
sudo parted /dev/nvme0n1 mkpart primary ext4 693GB 100%
```

```bash
# Set swap flag
sudo parted /dev/nvme0n1 set 5 swap on
```

```bash
# Verify all partitions created
sudo parted /dev/nvme0n1 print
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
```

**Expected layout:**
```
nvme0n1p1   524MB   EFI (shared)
nvme0n1p2    64GB   Linux Mint swap
nvme0n1p3   100GB   Linux Mint root
nvme0n1p4   280GB   Linux Mint /home (resized)
nvme0n1p5    48GB   NixOS swap (NEW)
nvme0n1p6   200GB   NixOS root (NEW)
nvme0n1p7   307GB   NixOS /home (NEW)
```

---

## Part 2: Format NixOS Partitions

```bash
# Format swap
sudo mkswap -L nixos-swap /dev/nvme0n1p5
sudo swapon /dev/nvme0n1p5

# Format root
sudo mkfs.ext4 -L nixos /dev/nvme0n1p6

# Format home
sudo mkfs.ext4 -L nixos-home /dev/nvme0n1p7
```

```bash
# Verify formatting
lsblk -f
```

**Should show:**
- nvme0n1p5: swap, LABEL="nixos-swap"
- nvme0n1p6: ext4, LABEL="nixos"
- nvme0n1p7: ext4, LABEL="nixos-home"

---

## Part 3: Mount Partitions

```bash
# Mount root
sudo mount /dev/nvme0n1p6 /mnt

# Create mount points
sudo mkdir -p /mnt/boot
sudo mkdir -p /mnt/home

# Mount EFI (shared with Linux Mint)
sudo mount /dev/nvme0n1p1 /mnt/boot

# Mount home
sudo mount /dev/nvme0n1p7 /mnt/home
```

```bash
# Verify mounts
mount | grep nvme0n1
df -h | grep /mnt
```

**Expected:**
```
/dev/nvme0n1p6 on /mnt type ext4
/dev/nvme0n1p1 on /mnt/boot type vfat
/dev/nvme0n1p7 on /mnt/home type ext4
```

---

## Part 4: Network Setup

```bash
# Test internet connection
ping -c 3 google.com
```

**If no internet, connect:**

### For WiFi:
```bash
sudo systemctl start wpa_supplicant
wpa_passphrase "YOUR_WIFI_SSID" "YOUR_PASSWORD" | sudo tee /etc/wpa_supplicant.conf
sudo wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant.conf
sudo dhclient wlan0
```

### For Ethernet:
```bash
sudo dhclient eth0
```

---

## Part 5: Clone Your NixOS Configuration

```bash
# Install git (if not available)
nix-shell -p git

# Clone your nix-Rice repository to /mnt/etc/nixos
cd /mnt/etc
sudo rm -rf nixos  # Remove default config
sudo git clone -b noctalia https://github.com/sriesow/nix-Rice.git nixos
```

**If repository is private, you may need to:**
```bash
# Option 1: Use personal access token
sudo git clone -b noctalia https://YOUR_GITHUB_TOKEN@github.com/sriesow/nix-Rice.git nixos

# Option 2: Clone to /tmp first, then copy
cd /tmp
git clone -b noctalia https://github.com/sriesow/nix-Rice.git
sudo cp -r nix-Rice /mnt/etc/nixos
```

```bash
# Verify configuration files
ls -la /mnt/etc/nixos
```

**Should see: system/, users/, flake.nix, MIGRATION_CHECKLIST.md, etc.**

---

## Part 6: Generate Hardware Configuration

```bash
# Generate hardware-configuration.nix
sudo nixos-generate-config --root /mnt
```

**This creates: /mnt/etc/nixos/hardware-configuration.nix**

```bash
# Verify the hardware config
cat /mnt/etc/nixos/hardware-configuration.nix
```

**Check for:**
- fileSystems."/" pointing to /dev/disk/by-label/nixos
- fileSystems."/boot" pointing to /dev/disk/by-label/EFI
- fileSystems."/home" pointing to /dev/disk/by-label/nixos-home
- swapDevices with /dev/disk/by-label/nixos-swap

**If /home is missing, you need to add it manually!**

---

## Part 7: Configure Hardware Settings

### Step 7.1: Edit hardware-configuration.nix

```bash
sudo nano /mnt/etc/nixos/hardware-configuration.nix
```

**Ensure this content is present:**

```nix
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];  # or "kvm-intel" if Intel CPU
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/nixos-home";
    fsType = "ext4";
  };

  swapDevices = [
    { device = "/dev/disk/by-label/nixos-swap"; }
  ];

  # Enable hibernation support
  boot.resumeDevice = "/dev/disk/by-label/nixos-swap";

  # 32GB RAM system
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
```

**Save and exit: Ctrl+O, Enter, Ctrl+X**

---

### Step 7.2: Verify Your Configuration Structure

```bash
# Check your main configuration file
cat /mnt/etc/nixos/flake.nix
```

**Or if not using flakes:**
```bash
cat /mnt/etc/nixos/configuration.nix
```

**Ensure these are configured:**
1. Hostname set
2. User account defined (username: srie)
3. NVIDIA drivers enabled (should import system/modules/nvidia.nix)
4. Boot loader configured for dual boot
5. Networking enabled

---

### Step 7.3: Configure Dual Boot

```bash
sudo nano /mnt/etc/nixos/configuration.nix
```

**Or edit your flake configuration. Ensure bootloader section has:**

```nix
boot.loader = {
  efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot";
  };
  grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;  # CRITICAL for detecting Linux Mint
    configurationLimit = 10;
  };
};
```

**The `useOSProber = true;` is essential for dual boot!**

---

## Part 8: Install NixOS

```bash
# Final pre-flight check
lsblk -f
mount | grep /mnt
cat /mnt/etc/nixos/hardware-configuration.nix
```

**Everything looks good? Proceed with installation:**

### If using flakes:
```bash
sudo nixos-install --flake /mnt/etc/nixos#workstation
```

**Replace `workstation` with your actual host configuration name from flake.nix**

### If NOT using flakes:
```bash
sudo nixos-install
```

**This will take 15-30 minutes. Watch for:**
- Building system
- Installing packages
- Setting up NVIDIA drivers
- Creating bootloader entries

---

### Step 8.1: Set Root Password

When prompted:
```
Enter root password: [type password]
Confirm root password: [type password]
```

**Remember this password!**

---

### Step 8.2: Set User Password

```bash
# After installation completes, set user password
sudo nixos-enter --root /mnt
passwd srie
# Enter password for your user account
exit
```

---

## Part 9: Post-Installation

```bash
# Unmount all partitions
sudo umount -R /mnt

# Reboot
sudo reboot
```

**Remove USB drive during reboot**

---

## Part 10: First Boot into NixOS

### Step 10.1: GRUB Bootloader

You should see GRUB menu with:
- NixOS (default)
- Linux Mint
- Linux Mint (recovery)

**Select NixOS to boot**

---

### Step 10.2: Login

```
Username: srie
Password: [your password]
```

---

### Step 10.3: Verify Installation

```bash
# Check NixOS version
nixos-version

# Check NVIDIA driver
nvidia-smi

# Should show RTX 2080 Ti with driver version

# Check partitions
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT

# Check swap
swapon --show

# Test hibernation (optional)
systemctl hibernate
```

---

### Step 10.4: Update System

```bash
# Update channels
sudo nix-channel --update

# Rebuild system
sudo nixos-rebuild switch

# Or if using flakes:
cd /etc/nixos
sudo nixos-rebuild switch --flake .#workstation
```

---

## Part 11: Test Dual Boot

```bash
# Reboot and test Linux Mint
sudo reboot
```

**In GRUB, select Linux Mint**

**Verify Linux Mint still boots:**
- Login works
- /home partition accessible
- Data intact

**Then reboot back to NixOS to continue migration**

---

## Troubleshooting

### Issue: GRUB doesn't show Linux Mint

**Solution:**
```bash
# Boot into NixOS
sudo nixos-rebuild switch

# Update GRUB to detect Linux Mint
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

Ensure `boot.loader.grub.useOSProber = true;` in configuration.nix

---

### Issue: NVIDIA driver not loading

**Verify in configuration:**
```bash
cat /etc/nixos/system/modules/nvidia.nix
```

Should have:
```nix
hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
services.xserver.videoDrivers = [ "nvidia" ];
```

Rebuild:
```bash
sudo nixos-rebuild switch
```

---

### Issue: No internet connection

```bash
# Check network interfaces
ip a

# Start NetworkManager
sudo systemctl start NetworkManager
sudo systemctl enable NetworkManager

# Connect to WiFi
nmtui
```

---

### Issue: Swap not working

```bash
# Check swap device
swapon --show

# If not showing, check label
lsblk -f | grep swap

# Re-enable swap
sudo swapon /dev/nvme0n1p5
```

---

## Quick Reference

### Partition Layout
```
/dev/nvme0n1p1   524MB   EFI          Shared /boot
/dev/nvme0n1p2    64GB   swap         Linux Mint swap
/dev/nvme0n1p3   100GB   ext4         Linux Mint /
/dev/nvme0n1p4   280GB   ext4         Linux Mint /home
/dev/nvme0n1p5    48GB   swap         NixOS swap
/dev/nvme0n1p6   200GB   ext4         NixOS /
/dev/nvme0n1p7   307GB   ext4         NixOS /home
```

### Important Paths
- Configuration: `/etc/nixos/`
- Hardware config: `/etc/nixos/hardware-configuration.nix`
- NVIDIA config: `/etc/nixos/system/modules/nvidia.nix`
- Migration checklist: `/etc/nixos/MIGRATION_CHECKLIST.md`

### Useful Commands
```bash
# Rebuild system
sudo nixos-rebuild switch

# Test configuration without applying
sudo nixos-rebuild test

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Garbage collect old generations
sudo nix-collect-garbage -d

# Check NVIDIA
nvidia-smi

# Check system info
neofetch
```

---

## Success Criteria

- [x] NixOS boots successfully
- [x] NVIDIA RTX 2080 Ti detected (nvidia-smi works)
- [x] User login works
- [x] Dual boot menu shows both NixOS and Linux Mint
- [x] Linux Mint still boots and /home accessible
- [x] Network/WiFi working
- [x] Swap active (48GB)
- [x] Hibernation works

---

## Next Steps After Installation

1. **Follow MIGRATION_CHECKLIST.md** in your nix-Rice repository
2. **Install your applications** via configuration.nix
3. **Migrate data** from Linux Mint /home to NixOS /home
4. **Test all workflows** in NixOS before phasing out Linux Mint
5. **Keep dual boot** until confident NixOS handles everything

---

## Emergency Recovery

### Boot to Linux Mint if NixOS fails:
1. Reboot
2. Select Linux Mint in GRUB
3. Your data is safe in /home

### Boot to NixOS recovery:
1. Reboot
2. In GRUB, select "NixOS - Configuration X (old)"
3. Rollback: `sudo nixos-rebuild switch --rollback`

### Re-install GRUB if bootloader broken:
```bash
# Boot from USB
sudo mount /dev/nvme0n1p6 /mnt
sudo mount /dev/nvme0n1p1 /mnt/boot
sudo nixos-enter --root /mnt
nixos-rebuild switch
exit
sudo reboot
```

---

**Good luck with your NixOS installation! 🚀**

**Save this file to USB: Copy to /media/your_usb/NIXOS_INSTALL_GUIDE.md**
