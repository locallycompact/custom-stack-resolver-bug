{
  description = "A very basic flake";
  inputs.haskellNix.url = "github:input-output-hk/haskell.nix";
  inputs.nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils, haskellNix }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ] (system:
    let
      overlays = [ haskellNix.overlay
        (final: prev: {
          # This overlay adds our project to pkgs
          myproj =
            final.haskell-nix.project' {
              src = ./.;
              resolverSha256 = "0zhmk6qasy3zfr616n7a1kj34m16dcv47gjfvb2424wk7d9w1xr1";
              compiler-nix-name = "ghc8104";
              # This is used by `nix develop .` to open a shell for use with
              # `cabal`, `hlint` and `haskell-language-server`
              shell.tools = {
                cabal = {};
                hlint = {};
                haskell-language-server = {};
              };
              branchMap = {
                "https://github.com/brendanhay/amazonka"."020bc7bde47bb235e448c76088dc44d6cec13e9b" = "develop";
              };
              # This adds `js-unknown-ghcjs-cabal` to the shell.
              # shell.crossPlatform = p: [p.ghcjs];
            };
        })
      ];
      pkgs = import nixpkgs { inherit system overlays; };
      flake = pkgs.myproj.flake {
        # This adds support for `nix build .#js-unknown-ghcjs-cabal:myproj:exe:myproj`
        # crossPlatforms = p: [p.ghcjs];
      };
    in flake // {
      # Built by `nix build .`
      defaultPackage = flake.packages."myproj:exe:myproj";
    });
}
