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
    make-firmware = (system: shield: zmk-nix.legacyPackages.${system}.buildSplitKeyboard rec {
      name = "firmware";

      src = ./.;

      board = "nice_nano_v2";
      inherit shield;

      extraCmakeFlags = ["-DZMK_EXTRA_MODULES=${src}"];

      zephyrDepsHash = "";

      meta = {
        description = "ZMK firmware";
        license = nixpkgs.lib.licenses.mit;
        platforms = nixpkgs.lib.platforms.all;
      };
    });
  in {
    packages = forAllSystems (system: rec {
      default = firmware;

      firmware = make-firmware system "temper_%PART%";
      firmware-reset = make-firmware system "settings_reset";

      keymap-drawer = nixpkgs.legacyPackages.${system}.callPackage ./nix/keymap-drawer.nix {};

      flash = zmk-nix.packages.${system}.flash.override { inherit firmware; };
      flash-reset = zmk-nix.packages.${system}.flash.override { firmware = firmware-reset; };
      update = zmk-nix.packages.${system}.update;
    });

    devShells = forAllSystems (system: {
      default = zmk-nix.devShells.${system}.default;
    });
  };
}
