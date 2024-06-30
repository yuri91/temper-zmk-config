{ lib
, python3
, python3Packages
, fetchFromGitHub
}:

let
  # Keymap-drawer uses version 3 of `platformdirs` but NixPkgst only has
  # version 4.2 available. It's easier to brging the package from GitHub than
  # creating a flake input for an old version of NixPkgs, just to get this one
  # dependency
  platformdirs3 = python3Packages.buildPythonPackage rec {
    name = "platformdirs";
    version = "3.11.0";

    src = fetchFromGitHub {
      owner = "platformdirs";
      repo = "${name}";
      rev = "${version}";
      sha256 = "sha256-rMPpxwPbqAtvr3RtKQDisqQnCxnBfZdolMUPpDE+tR4=";
    };

    format = "pyproject";

    nativeBuildInputs = [
      python3Packages.hatchling
      python3Packages.hatch-vcs
    ];

    meta = {
      homepage = "https://github.com/platformdirs/platformdirs/tree/3.11.0";
      description = "A small Python module for determining appropriate platform-specific dirs";
      license = lib.licenses.mit;
    };
  };

  # NixPkgs does not offer `keymap-drawer` as a python package nor a
  # stand-alone application, so we have  pull the package into our environment
  keymap-drawer = python3Packages.buildPythonPackage rec {
    name = "keymap-drawer";
    version = "v0.17.0";

    src = fetchFromGitHub {
      owner = "caksoylar";
      repo = "${name}";
      rev = "main";
      sha256 = "sha256-qaqXFchwhn3rZJ4dsS9DdrGgPJfKs2nmViG77wCgpsY=";
    };

    format = "pyproject";

    nativeBuildInputs = [
      python3Packages.poetry-core
    ];

    propagatedBuildInputs = with python3Packages; [
      pcpp
      platformdirs3
      pydantic
      pydantic-settings
      pyparsing
      pyyaml
    ];

    meta = {
      homepage = "https://github.com/caksoylar/keymap-drawer";
      description = "Visualize keymaps that use advanced features like hold-taps and combos, with automatic parsing ";
      license = lib.licenses.mit;
      mainProgram = "keymap";
    };
  };
in
  keymap-drawer

