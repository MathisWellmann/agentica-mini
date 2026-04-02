{
  description = "Agentica Mini - A miniature version of Agentica for local agent execution";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        python = pkgs.python312;
        buildInputs = with python.pkgs; [
          openai
          ipython
          typeguard
          python-dotenv
          aiohttp
          aiosqlite
        ];
        tools = with pkgs; [
          python
          uv
          pyright
          ruff
        ];
      in
      {
        packages.default = pkgs.python312Packages.buildPythonPackage {
          name = "agentica";
          src = self;

          nativeBuildInputs = [
            python.pkgs.hatchling
          ];
          inherit buildInputs;

          pyproject = true;
          doCheck = true;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = buildInputs ++ tools;

          shellHook = ''
            echo "Agentica Mini development environment"
            echo "Run 'uv run python -m chat' to start the chat interface"
          '';
        };
      }
    );
}
