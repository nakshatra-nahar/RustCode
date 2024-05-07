{
  description = "A post-modern text editor.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    crane,
    flake-utils,
    rust-overlay,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [(import rust-overlay)];
      };
      mkRootPath = rel:
        builtins.path {
          path = "${toString ./.}/${rel}";
          name = rel;
        };
      filteredSource = let
        pathsToIgnore = [
          ".envrc"
          ".ignore"
          ".github"
          ".gitignore"
          "logo_dark.svg"
          "logo_light.svg"
          "rust-toolchain.toml"
          "rustfmt.toml"
          "runtime"
          "screenshot.png"
          "book"
          "docs"
          "README.md"
          "CHANGELOG.md"
          "shell.nix"
          "default.nix"
          "grammars.nix"
          "flake.nix"
          "flake.lock"
        ];
        ignorePaths = path: type: let
          inherit (nixpkgs) lib;
          # split the nix store path into its components
          components = lib.splitString "/" path;
          # drop off the `/nix/hash-source` section from the path
          relPathComponents = lib.drop 4 components;
          # reassemble the path components
          relPath = lib.concatStringsSep "/" relPathComponents;
        in
          lib.all (p: ! (lib.hasPrefix p relPath)) pathsToIgnore;
      in
        builtins.path {
          name = "rustcode-source";
          path = toString ./.;
          # filter out unnecessary paths
          filter = ignorePaths;
        };
      makeOverridablerustcode = old: config: let
        grammars = pkgs.callPackage ./grammars.nix config;
        runtimeDir = pkgs.runCommand "rustcode-runtime" {} ''
          mkdir -p $out
          ln -s ${mkRootPath "runtime"}/* $out
          rm -r $out/grammars
          ln -s ${grammars} $out/grammars
        '';
        rustcode-wrapped =
          pkgs.runCommand
          old.name
          {
            inherit (old) pname version;
            meta = old.meta or {};
            passthru =
              (old.passthru or {})
              // {
                unwrapped = old;
              };
            nativeBuildInputs = [pkgs.makeWrapper];
            makeWrapperArgs = config.makeWrapperArgs or [];
          }
          ''
            cp -rs --no-preserve=mode,ownership ${old} $out
            wrapProgram "$out/bin/hx" ''${makeWrapperArgs[@]} --set rustcode_RUNTIME "${runtimeDir}"
          '';
      in
        rustcode-wrapped
        // {
          override = makeOverridablerustcode old;
          passthru =
            rustcode-wrapped.passthru
            // {
              wrapper = old: makeOverridablerustcode old config;
            };
        };
      stdenv =
        if pkgs.stdenv.isLinux
        then pkgs.stdenv
        else pkgs.clangStdenv;
      rustFlagsEnv =
        if stdenv.isLinux
        then ''$RUSTFLAGS -C link-arg=-fuse-ld=lld -C target-cpu=native -Clink-arg=-Wl,--no-rosegment''
        else "$RUSTFLAGS";
      rustToolchain = pkgs.pkgsBuildHost.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
      craneLibMSRV = (crane.mkLib pkgs).overrideToolchain rustToolchain;
      craneLibStable = (crane.mkLib pkgs).overrideToolchain pkgs.pkgsBuildHost.rust-bin.stable.latest.default;
      commonArgs = {
        inherit stdenv;
        inherit (craneLibMSRV.crateNameFromCargoToml {cargoToml = ./rustcode-term/Cargo.toml;}) pname;
        inherit (craneLibMSRV.crateNameFromCargoToml {cargoToml = ./Cargo.toml;}) version;
        src = filteredSource;
        # disable fetching and building of tree-sitter grammars in the rustcode-term build.rs
        rustcode_DISABLE_AUTO_GRAMMAR_BUILD = "1";
        buildInputs = [stdenv.cc.cc.lib];
        # disable tests
        doCheck = false;
        meta.mainProgram = "hx";
      };
      cargoArtifacts = craneLibMSRV.buildDepsOnly commonArgs;
    in {
      packages = {
        rustcode-unwrapped = craneLibStable.buildPackage (commonArgs
          // {
            cargoArtifacts = craneLibStable.buildDepsOnly commonArgs;
            postInstall = ''
              mkdir -p $out/share/applications $out/share/icons/hicolor/scalable/apps $out/share/icons/hicolor/256x256/apps
              cp contrib/rustcode.desktop $out/share/applications
              cp logo.svg $out/share/icons/hicolor/scalable/apps/rustcode.svg
              cp contrib/rustcode.png $out/share/icons/hicolor/256x256/apps
            '';
          });
        rustcode = makeOverridablerustcode self.packages.${system}.rustcode-unwrapped {};
        default = self.packages.${system}.rustcode;
      };

      checks = {
        # Build the crate itself
        inherit (self.packages.${system}) rustcode;

        clippy = craneLibMSRV.cargoClippy (commonArgs
          // {
            inherit cargoArtifacts;
            cargoClippyExtraArgs = "--all-targets -- --deny warnings";
          });

        fmt = craneLibMSRV.cargoFmt commonArgs;

        doc = craneLibMSRV.cargoDoc (commonArgs
          // {
            inherit cargoArtifacts;
          });

        test = craneLibMSRV.cargoTest (commonArgs
          // {
            inherit cargoArtifacts;
          });
      };

      devShells.default = pkgs.mkShell {
        inputsFrom = builtins.attrValues self.checks.${system};
        nativeBuildInputs = with pkgs;
          [lld_13 cargo-flamegraph rust-analyzer]
          ++ (lib.optional (stdenv.isx86_64 && stdenv.isLinux) pkgs.cargo-tarpaulin)
          ++ (lib.optional stdenv.isLinux pkgs.lldb)
          ++ (lib.optional stdenv.isDarwin pkgs.darwin.apple_sdk.frameworks.CoreFoundation);
        shellHook = ''
          export rustcode_RUNTIME="$PWD/runtime"
          export RUST_BACKTRACE="1"
          export RUSTFLAGS="${rustFlagsEnv}"
        '';
      };
    })
    // {
      overlays.default = final: prev: {
        inherit (self.packages.${final.system}) rustcode;
      };
    };

  nixConfig = {
    extra-substituters = ["https://rustcode.cachix.org"];
    extra-trusted-public-keys = ["rustcode.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="];
  };
}
