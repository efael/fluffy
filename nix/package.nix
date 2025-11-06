{
  pkgs,
  pinnedFlutter,
  libwebrtcRpath,
  libwebrtc,
  vodozemac,
  packageAttrs,
  ...
}:
targetFlutterPlatform:
pinnedFlutter.buildFlutterApplication (
  packageAttrs
  // rec {
    pname = "fluffychat-${targetFlutterPlatform}";

    src = ../.;

    inherit targetFlutterPlatform;

    meta = {
      description = "Chat with your friends (matrix client)";
      homepage = "https://fluffychat.im/";
      license = pkgs.lib.licenses.agpl3Plus;
      maintainers = with pkgs.lib.maintainers; [
        mkg20001
        tebriel
        aleksana
      ];
      badPlatforms = pkgs.lib.platforms.darwin;
    }
    // pkgs.lib.optionalAttrs (targetFlutterPlatform == "linux") {
      mainProgram = "fluffychat";
    };
  }
  // pkgs.lib.optionalAttrs (targetFlutterPlatform == "linux") {
    nativeBuildInputs = [
      pkgs.imagemagick
      pkgs.copyDesktopItems
    ];

    runtimeDependencies = [ pkgs.pulseaudio ];

    env.NIX_LDFLAGS = "-rpath-link ${libwebrtcRpath}";

    desktopItems = [
      (pkgs.makeDesktopItem {
        name = "Fluffychat";
        exec = "fluffychat";
        icon = "fluffychat";
        desktopName = "Fluffychat";
        genericName = "Chat with your friends (matrix client)";
        categories = [
          "Chat"
          "Network"
          "InstantMessaging"
        ];
      })
    ];

    customSourceBuilders = {
      flutter_webrtc =
        {
          version,
          src,
          ...
        }:
        pkgs.stdenv.mkDerivation {
          pname = "flutter_webrtc";
          inherit version src;
          inherit (src) passthru;

          postPatch = ''
            substituteInPlace third_party/CMakeLists.txt \
              --replace-fail "\''${CMAKE_CURRENT_LIST_DIR}/downloads/libwebrtc.zip" ${libwebrtc}
              ln -s ${libwebrtc} third_party/libwebrtc
          '';

          installPhase = ''
            runHook preInstall

            mkdir $out
            cp -r ./* $out/

            runHook postInstall
          '';
        };
    };

    postInstall = ''
      FAV=$out/app/fluffychat-linux/data/flutter_assets/assets/favicon.png
      ICO=$out/share/icons

      for size in 24 32 42 64 128 256 512; do
        D=$ICO/hicolor/''${size}x''${size}/apps
        mkdir -p $D
        magick $FAV -resize ''${size}x''${size} $D/fluffychat.png
      done

      patchelf --add-rpath ${libwebrtcRpath} $out/app/fluffychat-linux/lib/libwebrtc.so
    '';
  }
  // pkgs.lib.optionalAttrs (targetFlutterPlatform == "web") {
    preBuild = ''
      cp -r ${vodozemac}/* ./assets/vodozemac/
    '';
  }
)
