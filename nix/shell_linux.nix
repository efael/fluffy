{
  pkgs,
  formatter,
  pinnedFlutter,
  androidCustomPackage,
  pinnedJDK,
  ...
}@attrs:
pkgs.mkShell {
  packages = [
    formatter
    pinnedFlutter
    androidCustomPackage
    pinnedJDK

    (import ./shell_vodozemac.nix attrs)
  ];

  env = {
    CMAKE_PREFIX_PATH = pkgs.lib.makeLibraryPath [
      pkgs.libsecret.dev
    ];
    FLUTTER_ROOT = "${pinnedFlutter}";
    CHROME_EXECUTABLE = "${pkgs.google-chrome}/bin/google-chrome-stable";
  };

  shellHook = ''
    init-vodozemac
  '';
}
