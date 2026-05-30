{ config, lib, pkgs, ... }:

{
  # ====== SSH ======
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
    };
    openFirewall = false;
  };

  # ====== Tailscale ======
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "client";
  };

  # ====== Sunshine (NVENC remote desktop) ======
  # capSysAdmin = false: with cap set, glibc strips LD_LIBRARY_PATH on the
  # setcap wrapper, so libcuda.so.1 (NVENC) cannot be loaded. niri implements
  # wlr-screencopy, which Sunshine uses as capture path without CAP_SYS_ADMIN.
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = false;
    openFirewall = true;
  };

  systemd.user.services.sunshine.environment = {
    LD_LIBRARY_PATH = "/run/opengl-driver/lib";
  };

  # ====== Wake-on-LAN ======
  networking.interfaces.eno1.wakeOnLan.enable = true;

  systemd.services.wol-persist = {
    description = "Enable Wake-on-LAN on eno1";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.ethtool}/bin/ethtool -s eno1 wol g";
    };
  };

  # Disable USB wake on Logitech receiver (mouse twitch wakes box).
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{power/wakeup}="disabled"
  '';

  # Disable spurious ACPI wake sources. Keep GLAN (magic packet path) only.
  # Re-runs on boot and after each S3 resume because kernel re-enables them.
  systemd.services.disable-spurious-wakes = {
    description = "Disable spurious ACPI wake sources";
    wantedBy = [ "multi-user.target" "post-resume.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      for dev in XHC PEG0 RP01 RP08 RP09 RP21; do
        if grep -q "^$dev.*\*enabled" /proc/acpi/wakeup; then
          echo "$dev" > /proc/acpi/wakeup
        fi
      done
    '';
  };

  # ====== Firewall ======
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  # ====== Tools ======
  environment.systemPackages = with pkgs; [
    ethtool
    wakeonlan
    tailscale
  ];

  # ====== Suspend behavior ======
  # S3 suspend allowed (waker wakes us via WoL). Hibernate disabled.
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  services.logind.settings.Login = {
    IdleAction = "suspend";
    IdleActionSec = "30min";
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  # ====== NVIDIA suspend/resume ======
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.powerManagement.finegrained = false;
}
