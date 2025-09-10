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
        pkgs = import nixpkgs { inherit system; };
        python = pkgs."python${toString pythonVersion}";
        pythonPackages = pkgs."python${toString pythonVersion}Packages";

        pychrome =
          with pythonPackages;
          buildPythonPackage rec {
            pname = "pychrome";
            version = "0.2.4";
            src = fetchPypi {
              inherit pname version;
              sha256 = "sha256-cDkrZZLk0KAOkTJO/ZyJ9ubkf6MeezimmXPcZIlFNHg=";
            };
            propagatedBuildInputs = [
              click
              websocket-client
              requests
            ];
            pyproject = true;
            build-system = [ setuptools ];
          };
        presencepulse =
          with pythonPackages;
          buildPythonApplication {
            pname = "presencepulse";
            version = "0.1.0";
            src = ./.;
            propagatedBuildInputs = [
              aiohttp
              pychrome
              pkgs.ungoogled-chromium
            ];
            pyproject = true;
            build-system = [ setuptools ];
            installPhase = ''
              runHook preInstall

              python setup.py install --prefix $out

              runHook postInstall
            '';
          };
      in
      {
        packages.default = presencepulse;
        devShell = pkgs.mkShellNoCC {
          name = "python";

          packages = [
            # packages for emacs to use
            pkgs.isort
            python
            pythonPackages.pyflakes
            # app dependency packages
            pkgs.ungoogled-chromium
            pychrome
            pythonPackages.aiohttp
            presencepulse
          ];
        };
      }
    );
}
