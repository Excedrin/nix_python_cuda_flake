# Nix Flake for Python CUDA Development Environment

This Nix flake sets up a Python development environment with CUDA support, intended for use on a NixOS machine. It addresses issues related to binaries installed via pip that depend on specific device driver versions.

## Key Components

### Pinning nixpkgs

To ensure compatibility with the NixOS system, nixpkgs is pinned to the same version:

```nix
# Using the same revision as my system to ensure that I get the right version of the nvidia_x11 package
nixpkgs.url = "github:nixos/nixpkgs/e9ee548d90ff586a6471b4ae80ae9cfcbceb3420";
```

This is obviously specific to my setup and would need to change on other systems.

### Including the Correct NVIDIA Driver Package

The flake includes the appropriate NVIDIA driver package:

```nix
# In my /etc/nixos/configuration.nix I use this setting:
# hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
# which in my case corresponds to this package:
linuxKernel.packages.linux_6_6.nvidia_x11_beta
```

### Setting LD_LIBRARY_PATH

The `LD_LIBRARY_PATH` is set to ensure proper library loading:

```nix
LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;

postShellHook = ''
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH
'';
```

## Usage

```
nix develop
pip install -r requirements.txt
python gpt2.py
```

## Demo Files

The `gpt2.py` and `requirements.txt` files demonstrate how to install torch, transformers, and flash_attn via pip without compiling everything.

## Testing OpenCV with CUDA using yolov7-segmentation Repository

To test OpenCV with CUDA, the following repository was used:
[https://github.com/RizwanMunawar/yolov7-segmentation/](https://github.com/RizwanMunawar/yolov7-segmentation/)

### Required Modification

To successfully set up the environment, one change to the `requirements.txt` file was necessary:

* Comment out `opencv-python` requirement to prevent the reversion to the default non-cuda opencv-python version, which would otherwise break the setup.

This modification ensures a smooth setup of the development environment with CUDA support for Python projects on NixOS.
