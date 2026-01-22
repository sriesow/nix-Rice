{ config, pkgs, ... }:

{
  # Workstation-specific hardware configuration
  # This will be used for the production deployment

  # GPU drivers - uncomment based on your GPU
  # For NVIDIA:
  # services.xserver.videoDrivers = [ "nvidia" ];
  # hardware.nvidia.modesetting.enable = true;

  # For AMD:
  # services.xserver.videoDrivers = [ "amdgpu" ];

  # For Intel:
  # services.xserver.videoDrivers = [ "intel" ];

  # Additional workstation-specific settings can be added here
}
