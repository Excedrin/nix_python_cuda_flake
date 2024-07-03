{
  description = "Python venv development template";

  inputs = {
    # Using the same revision as my system to ensure that I get the right version of the nvidia_x11 package
    nixpkgs.url = "github:nixos/nixpkgs/e9ee548d90ff586a6471b4ae80ae9cfcbceb3420";

    # nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    utils.url = "github:numtide/flake-utils";

    # nix-ld.url = "github:Mic92/nix-ld";
    # nix-ld.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
    ...
  }:
    utils.lib.eachDefaultSystem (system: let
      config.allowUnfree = true;
      config.cudaSupport = true;
      config.rocmSupport = false;
      pkgs = import nixpkgs {inherit system config;};
      pythonPackages = pkgs.python311Packages;
    in {
      devShells.default = with pkgs;
        mkShell rec {
          name = "python-venv";
          venvDir = "./.venv";
          packages = [
            # A Python interpreter including the 'venv' module is required to bootstrap
            # the environment.
            pythonPackages.python

            # This executes some shell code to initialize a venv in $venvDir before
            # dropping into the shell
            pythonPackages.venvShellHook
          ];

          buildInputs = [
            stdenv.cc.cc
            zlib

            # Apparently none of these are needed because of nvidia_x11 inclusion
            # cudaPackages.cudatoolkit
            # cudaPackages.cudnn
            # cudaPackages.libcublas

            # In my /etc/nixos/configuration.nix I use this setting:
            # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
            # which in my case corresponds to this package:
            linuxKernel.packages.linux_6_6.nvidia_x11_beta
          ];

          LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;

          # These are not needed
          # Requires impure flake
          # NIX_LD = lib.fileContents "${stdenv.cc}/nix-support/dynamic-linker";
          # Does not require impure flake
          # NIX_LD = "${stdenv.cc.libc_bin}/bin/ld.so";

          # Not needed
          # export CUDA_PATH=${cudatoolkit}
          # export CUDNN_PATH=${cudaPackages.cudnn}
          # export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH

          postShellHook = ''
            export LD_LIBRARY_PATH=$LD_LIBRARY_PATH

            # allow pip to install wheels
            unset SOURCE_DATE_EPOCH

            exec $SHELL
          '';
        };
    });
}
