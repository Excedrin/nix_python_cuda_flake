{
  description = "Python venv development template";

  inputs = {
    # Using the same revision as my system to ensure that I get the right version of the nvidia_x11 package
    nixpkgs.url = "github:nixos/nixpkgs/e9ee548d90ff586a6471b4ae80ae9cfcbceb3420";

    # nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    utils.url = "github:numtide/flake-utils";
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

            # Adding these for opencv, pytorch apparently does not depend on them
            cudaPackages.cudnn
            cudaPackages.cutensor
            cudaPackages.libnpp
            cudaPackages.libcublas
            cudaPackages.libcufft

            # In my /etc/nixos/configuration.nix I use this setting:
            # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
            # which in my case corresponds to this package:
            linuxKernel.packages.linux_6_6.nvidia_x11_beta
          ];

          LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;

          postShellHook = ''
            export LD_LIBRARY_PATH=$LD_LIBRARY_PATH

            # allow pip to install wheels
            unset SOURCE_DATE_EPOCH

            exec $SHELL
          '';
        };
    });
}
