{
  description = "fluffychat nix";

  # Flake inputs
  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1"; # Stable Nixpkgs (use 0.1 for unstable)
  inputs.android-nixpkgs = {
    url = "github:tadfisher/android-nixpkgs";
    inputs = {
      nixpkgs.follows = "nixpkgs";
    };
  };

  # Flake outputs
  outputs =
    inputs:
    let
      attrs = system: import ./nix/attrs.nix { inherit system inputs; };
    in
    {
      devShells =
        let
          linux = system: { ${system}.default = import ./nix/shell_linux.nix (attrs system); };
        in
        inputs.nixpkgs.lib.mergeAttrsList [
          (linux "x86_64-linux")
          (linux "aarch64-linux")
        ];
    };
}
