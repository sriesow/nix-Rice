{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Enable NVIDIA drivers for RTX 2080 Ti
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Modesetting is required for Wayland compositors
    modesetting.enable = true;

    # Enable power management (useful for laptops, generally safe for desktops)
    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and can cause sleep/suspend issues.
    # Disable if you experience issues.
    powerManagement.finegrained = false;

    # Use the proprietary NVIDIA driver (not the open source nouveau)
    # RTX 2080 Ti works better with proprietary driver
    open = false;

    # Enable the NVIDIA settings menu (nvidia-settings command)
    nvidiaSettings = true;

    # Use stable driver version
    # For RTX 2080 Ti (Turing architecture), stable driver is recommended
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Optionally use latest or beta for newer features
    # package = config.boot.kernelPackages.nvidiaPackages.latest;
    # package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  # OpenGL/Graphics settings
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # For 32-bit applications and Steam games
  };

  # Enable CUDA support for GPU computing/ML workloads
  nixpkgs.config.cudaSupport = false;

  # Environment variables for Wayland + NVIDIA
  environment.sessionVariables = {
    # Use NVIDIA's GBM backend for Wayland
    GBM_BACKEND = "nvidia-drm";

    # Explicitly use NVIDIA for GLX
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";

    # Disable hardware cursors (can fix cursor issues in Wayland)
    # Remove this line if cursors work fine
    WLR_NO_HARDWARE_CURSORS = "1";

    # CUDA environment variables (uncomment if you need CUDA)
    # CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
    # CUDA_HOME = "${pkgs.cudaPackages.cudatoolkit}";
  };

  # Kernel modules and boot options
  boot.kernelParams = [
    # Enable NVIDIA DRM (Direct Rendering Manager) support
    "nvidia-drm.modeset=1"

    # Optionally disable nouveau (open source driver) to avoid conflicts
    # Usually not needed as NVIDIA driver handles this
    # "nouveau.modeset=0"
  ];

  # Early KMS (Kernel Mode Setting) for NVIDIA
  # This loads NVIDIA driver early in boot process
  boot.initrd.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];

  # Blacklist nouveau driver to prevent conflicts (optional but recommended)
  boot.blacklistedKernelModules = [ "nouveau" ];

  # Additional packages for NVIDIA and CUDA
  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia # GPU monitoring tool
    libva-utils # VA-API utilities for video acceleration
    vdpauinfo # VDPAU utilities for video acceleration

    # Development tools (optional, uncomment if needed)
    # cudaPackages.cudatoolkit        # CUDA toolkit
    # cudaPackages.cudnn              # CUDA Deep Neural Network library
    # cudaPackages.cuda_nsight        # NVIDIA Nsight Systems
    # cudaPackages.cuda_nvprof        # NVIDIA Visual Profiler
    # cudaPackages.cuda_samples       # CUDA samples
  ];

  # Screen tearing prevention (if you experience tearing)
  # services.xserver.screenSection = ''
  #   Option "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
  # '';

  # Preserve video memory allocations across suspend/resume
  # Can help with stability but uses more power
  # hardware.nvidia.powerManagement.finegrained = false;
}
