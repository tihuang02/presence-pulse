{ pythonPackages, pkgs, pychrome }:

pythonPackages.buildPythonApplication {
  pname = "presencepulse";
  version = "0.1.0";
  src = ./.;
  propagatedBuildInputs = [
    pythonPackages.aiohttp
    pythonPackages.setuptools
    pychrome
    pkgs.ungoogled-chromium
  ];
  pyproject = true;
  installPhase = ''
    runHook preInstall

    python setup.py install --prefix $out

    runHook postInstall
  '';
}
