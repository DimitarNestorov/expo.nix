{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      android-nixpkgs,
    }:
    let
      forEachSystem =
        function:
        nixpkgs.lib.genAttrs nixpkgs.lib.platforms.all (
          system: function (import nixpkgs { inherit system; })
        );
    in
    {
      devShells = forEachSystem (pkgs: {
        default = import ./shell.nix {
          inherit pkgs;
          android-nixpkgs = {
            sdk = android-nixpkgs.sdk.${pkgs.stdenv.hostPlatform.system};
          };
        };
      });
    };
}
