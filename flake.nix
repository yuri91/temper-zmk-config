{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, zmk-nix }: let
    forAllSystems = nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames zmk-nix.packages);
  in {
    packages = forAllSystems (system: rec {
      default = firmware;

      firmware = zmk-nix.legacyPackages.${system}.buildSplitKeyboard rec {
        name = "firmware";

        src = ./.;

        board = "nice_nano_v2";
        shield = "temper_%PART%";

        extraCmakeFlags = ["-DZMK_EXTRA_MODULES=${src}"];

        zephyrDepsHash = "sha256-FpBaJdVc4LpizpTc04fm7GQ2uLO02Yvx4abHw9uEpIQ=";

        meta = {
          description = "ZMK firmware";
          license = nixpkgs.lib.licenses.mit;
          platforms = nixpkgs.lib.platforms.all;
        };
      };

      keymap-drawer = nixpkgs.legacyPackages.${system}.callPackage ./nix/keymap-drawer.nix {};

      flash = zmk-nix.packages.${system}.flash.override { inherit firmware; };
      update = zmk-nix.packages.${system}.update;
    });

    devShells = forAllSystems (system: {
      default = zmk-nix.devShells.${system}.default;
    });
  };
}
