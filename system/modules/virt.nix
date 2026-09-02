{ config, pkgs, ... }:

{
  # libvirt/QEMU/KVM host — Vagrant provider backend
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };

  # optional GUI to manage VMs
  programs.virt-manager.enable = true;

  # NAT/DHCP for default libvirt network
  virtualisation.libvirtd.onBoot = "ignore";

  environment.systemPackages = with pkgs; [
    vagrant
    qemu_kvm
    libvirt
    virt-manager
    dnsmasq # libvirt NAT networking
    ebtables
    # build deps so `vagrant plugin install vagrant-libvirt` compiles
    gcc
    gnumake
    pkg-config
    libxml2
    libxslt
    zlib
    ruby
  ];

  # env for the runtime plugin build against system libvirt
  environment.variables.CONFIGURE_ARGS =
    "with-ldflags=-L${pkgs.libvirt}/lib with-libvirt-include=${pkgs.libvirt}/include/libvirt with-libvirt-lib=${pkgs.libvirt}/lib";

  environment.variables.VAGRANT_DEFAULT_PROVIDER = "libvirt";

  # NixOS has no /usr/share/OVMF — point vagrant-libvirt at nix-store firmware
  environment.variables.VAGRANT_LIBVIRT_OVMF_CODE = "${pkgs.OVMF.fd}/FV/OVMF_CODE.fd";
  environment.variables.VAGRANT_LIBVIRT_OVMF_VARS = "${pkgs.OVMF.fd}/FV/OVMF_VARS.fd";
}
