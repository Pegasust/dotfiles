{
  description = "Provides devShell for Nodejs + pnpm";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # https://github.com/vercel/turbo/issues/2293#issuecomment-1296094236
    # work-around for turbo-repo on nix
    turbo.url = "github:dlip/turbo";
  };

  outputs = { self, turbo, flake-utils, nixpkgs }:
    with flake-utils; lib.eachSystem lib.defaultSystems (sys:
      let
        overlays = [ turbo.overlay ];
        # pkgs is our tweaked nixpkgs
        pkgs = import nixpkgs { system = sys; overlays = overlays; };
        shellMsg = ''
          echo "Hello from nix ${sys}"
          echo "Local development may use our remote planetscale database (pscale login && pnpm dev:infra; pnpm dev)"
          echo "Or from the specified docker-compose.yml (pnpm dev:local_infra && pnpm dev)"
          echo "See more on CONTRIBUTING.md"
        '';
      in
      {
        devShell = pkgs.mkShell {
          nativeBuildInputs = [ pkgs.bashInteractive ];
          buildInputs = [
            pkgs.nodejs-18_x
            pkgs.nodePackages.pnpm
            pkgs.nodePackages.prisma
            pkgs.prisma-engines
            pkgs.turbo
            # pkgs.turbo-tooling
            pkgs.jq
            pkgs.pscale
            pkgs.act # Github workflow
          ];
          shellHook =
            # https://github.com/prisma/prisma/issues/3026#issuecomment-927258138
            # nix-direnv is required (impure build?) https://github.com/nix-community/nix-direnv
            ''
              export PRISMA_MIGRATION_ENGINE_BINARY="${pkgs.prisma-engines}/bin/migration-engine"
              export PRISMA_QUERY_ENGINE_BINARY="${pkgs.prisma-engines}/bin/query-engine"
              export PRISMA_QUERY_ENGINE_LIBRARY="${pkgs.prisma-engines}/lib/libquery_engine.node"
              export PRISMA_INTROSPECTION_ENGINE_BINARY="${pkgs.prisma-engines}/bin/introspection-engine"
              export PRISMA_FMT_BINARY="${pkgs.prisma-engines}/bin/prisma-fmt"
              export TURBO_BINARY_PATH="${pkgs.turbo}/bin/turbo"
              pnpm install
            '' + shellMsg;
        };
      });
}
