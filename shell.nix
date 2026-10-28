{
  pkgs ? import <nixpkgs> { },
  android-nixpkgs ? pkgs.callPackage (import (
    builtins.fetchGit { url = "https://github.com/tadfisher/android-nixpkgs.it"; }
  )) { channel = "stable"; },
}:

pkgs.mkShellNoCC {
  shellHook = ''
    export IN_PROJECT_DEV_SHELL=1
  '';

  packages = with pkgs; [
    nodejs_24
    ninja
    gradle_9
    jdk
    yarn
    pnpm
    direnv
  ];

  buildInputs =
    let
      android-sdk = android-nixpkgs.sdk (
        sdkPkgs: with sdkPkgs; [
          (cmake-3-22-1.overrideAttrs (oldAttrs: {
            dontAutoPatchelf = true;

            postFixup = (oldAttrs.postFixup or "") + ''
              autoPatchelf $out/bin/cmake $out/bin/ctest $out/bin/cpack
            '';
          }))
          (cmake-3-30-5.overrideAttrs (oldAttrs: {
            dontAutoPatchelf = true;

            postFixup = (oldAttrs.postFixup or "") + ''
              autoPatchelf $out/bin/cmake $out/bin/ctest $out/bin/cpack
            '';
          }))
          cmdline-tools-latest
          build-tools-36-0-0
          build-tools-37-0-0
          platform-tools
          platforms-android-37-0
          emulator
          system-images-android-35-google-apis-playstore-arm64-v8a
          ndk-27-1-12297006
        ]
      );
    in
    [
      android-sdk
    ];
}
