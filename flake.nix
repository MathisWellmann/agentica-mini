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
      in
      {
        packages.default = python.buildPythonApplication {
          name = "agentica";
          src = self;

          nativeBuildInputs = [
            python.pkgs.hatchling
          ];

          buildInputs = [
            python.pkgs.openai
            python.pkgs.ipython
            python.pkgs.typeguard
            python.pkgs.python-dotenv
            python.pkgs.aiohttp
            python.pkgs.aiosqlite
          ];

          devDependencies = [
            python.pkgs.pyright
          ];

          doCheck = true;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            python
            uv
            pyright
          ];

          shellHook = ''
            echo "Agentica Mini development environment"
            echo "Run 'uv run python -m chat' to start the chat interface"
          '';
        };
      }
    );
}
