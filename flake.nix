{
  description = "Python environment managed with flakes and venv";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:

    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pythonVersion = 313; # change this value to update the whole stack

        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (self: super: {
              pythonPackages = super."python${toString pythonVersion}Packages" // {
                pychrome = super."python${toString pythonVersion}Packages".buildPythonPackage rec {
                  pname = "pychrome";
                  version = "0.2.4";
                  src = super.fetchPypi {
                    inherit pname version;
                    sha256 = "sha256-cDkrZZLk0KAOkTJO/ZyJ9ubkf6MeezimmXPcZIlFNHg=";
                  };
                  propagatedBuildInputs = [
                    super."python${toString pythonVersion}Packages".click
                    super."python${toString pythonVersion}Packages".websocket-client
                    super."python${toString pythonVersion}Packages".requests
                  ];
                  pyproject = true;
                  build-system = [super."python${toString pythonVersion}Packages".setuptools];
                };
              };
            })
          ];
        };
        pythonPackages = pkgs.pythonPackages;
        python = pkgs."python${toString pythonVersion}";
        presencepulse = import ./buildApp.nix { inherit pkgs; };
      in
      {
        packages.default = presencepulse;
        devShell = pkgs.mkShellNoCC {
          name = "python dev env";

          packages = [
            # packages for emacs to use
            pkgs.isort
            python
            pythonPackages.pyflakes
            # app dependency packages
            pkgs.ungoogled-chromium
            pythonPackages.pychrome
            pythonPackages.aiohttp
            presencepulse
          ];
        };
      }
    );
}
