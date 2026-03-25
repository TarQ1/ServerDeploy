{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    futils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, futils } @ inputs:
    let
      inherit (nixpkgs) lib;
      inherit (lib) recursiveUpdate;
      inherit (futils.lib) eachDefaultSystem defaultSystems;

      nixpkgsFor = lib.genAttrs defaultSystems (system: import nixpkgs {
        inherit system;
      });
    in
    (eachDefaultSystem (system:
      let
        pkgs = nixpkgsFor.${system};
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            (poetry2nix.mkPoetryEnv {
              projectDir = self;

              overrides = poetry2nix.overrides.withDefaults (self: super: {
                cryptography = super.cryptography.overridePythonAttrs (old: {
                  CRYPTOGRAPHY_DONT_BUILD_RUST = 1;
                  propagatedBuildInputs = old.propagatedBuildInputs ++ [ super.setuptools-rust ];
                });
                enrich = super.enrich.overridePythonAttrs (old: {
                  propagatedBuildInputs = old.propagatedBuildInputs ++ [ super.toml ];
                });
              });
            })
            git
            poetry
            vault
          ];

          shellHook = ''
            export VAULT_ADDR='https://vault.cri.epita.fr:443'
          '';
        };
      }
    ));
}
