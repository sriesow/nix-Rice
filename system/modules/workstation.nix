{ config, pkgs, ... }:

{
  imports = [
    ./nvidia.nix  # NVIDIA RTX 2080 Ti configuration with CUDA support
  ];

  # Workstation-specific hardware configuration
  # This will be used for the production deployment with:
  # - 32 GB RAM
  # - NVIDIA RTX 2080 Ti
  # - CUDA support enabled

  # Additional workstation-specific settings can be added here
}
