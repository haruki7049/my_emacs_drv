{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      flake.overlays = {
        default = ./overlay.nix;
      };

      perSystem = { pkgs, ... }:
      let
        emacs = pkgs.callPackage ./. { };
      in
      {
        packages = {
          inherit emacs;
          default = emacs;
        };
      };
    };
}
