{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    packages.${system}.default = pkgs.stdenv.mkDerivation {
      pname = "cloudy";
      version = "c23.01";
      src = pkgs.fetchgit {
        url = "https://gitlab.nublado.org/cloudy/cloudy";
        rev = "refs/tags/c23.01";
        hash = "sha256-lVVyxYjGc/GfCEv/V3sc+SSl2zPOsmZSp63bGW0/0QU=";
      };
      nativeBuildInputs = [
        pkgs.makeWrapper
        pkgs.perl
        pkgs.texliveFull
        pkgs.which
      ];
      buildPhase = ''
        # Compile binaries
        patchShebangs source/make_depend.pl
        cd source; \
          make; \
          cd ..

        # Compile docs
        patchShebangs docs/latex/CompileAll.pl
        cd docs/latex; \
          ./CompileAll.pl; \
          cd ../..
      '';
      installPhase = ''
        # Copy binaries
        mkdir -p $out/bin
        cp source/cloudy.exe $out/bin/cloudy
        cp source/vh128sum.exe $out/bin/vh128sum

        # Copy data
        cp -r data $out

        # Copy docs
        mkdir -p $out/share/doc/cloudy
        cp docs/latex/QuickStart/QuickStart.pdf \
          $out/share/doc/cloudy/QuickStart.pdf
        cp docs/latex/hazy1/hazy1.pdf $out/share/doc/cloudy/hazy1.pdf
        cp docs/latex/hazy2/hazy2.pdf $out/share/doc/cloudy/hazy2.pdf
        cp docs/latex/hazy3/hazy3.pdf $out/share/doc/cloudy/hazy3.pdf

        # Make docs convenient scripts
        # QuickStart.pdf
        cat > $out/bin/cloudy-docs-quick-start <<EOF
        #!/bin/sh
        xdg-open "\$CLOUDY_DOCS_PATH/QuickStart.pdf"
        EOF
        chmod +x $out/bin/cloudy-docs-quick-start
        # hazy1.pdf
        cat > $out/bin/cloudy-docs-hazy1 <<EOF
        #!/bin/sh
        xdg-open "\$CLOUDY_DOCS_PATH/hazy1.pdf"
        EOF
        chmod +x $out/bin/cloudy-docs-hazy1
        # hazy2.pdf
        cat > $out/bin/cloudy-docs-hazy2 <<EOF
        #!/bin/sh
        xdg-open "\$CLOUDY_DOCS_PATH/hazy2.pdf"
        EOF
        chmod +x $out/bin/cloudy-docs-hazy2
        # hazy3.pdf
        cat > $out/bin/cloudy-docs-hazy3 <<EOF
        #!/bin/sh
        xdg-open "\$CLOUDY_DOCS_PATH/hazy3.pdf"
        EOF
        chmod +x $out/bin/cloudy-docs-hazy3
      '';
      postFixup = ''
        wrapProgram "$out/bin/cloudy" --set CLOUDY_DATA_PATH "$out/data"
        wrapProgram "$out/bin/cloudy-docs-quick-start" \
          --set CLOUDY_DOCS_PATH "$out/share/doc/cloudy"
        wrapProgram "$out/bin/cloudy-docs-hazy1" \
          --set CLOUDY_DOCS_PATH "$out/share/doc/cloudy"
        wrapProgram "$out/bin/cloudy-docs-hazy2" \
          --set CLOUDY_DOCS_PATH "$out/share/doc/cloudy"
        wrapProgram "$out/bin/cloudy-docs-hazy3" \
          --set CLOUDY_DOCS_PATH "$out/share/doc/cloudy"
      '';
      meta = {
        homepage = "https://gitlab.nublado.org/cloudy/cloudy";
        description = "Spectral synthesis code";
        longDescription = ''
          Cloudy is an ab initio spectral synthesis code designed to model a
          wide range of interstellar "clouds", from H II regions and planetary
          nebulae, to Active Galactic Nuclei, and the hot intracluster medium
          that permeates galaxy clusters.

          This package includes documentation in PDF format, available in
          `$out/share/doc/cloudy/`, or can be opened using convenient scripts
          `cloudy-docs-quick-start`, `cloudy-docs-hazy1`, `cloudy-docs-hazy2`,
          `cloudy-docs-hazy3`.
        '';
        license = pkgs.lib.licenses.zlib;
        platforms = pkgs.lib.platforms.linux ++ pkgs.lib.platforms.darwin;
        mainProgram = "cloudy";
        maintainers = [ pkgs.lib.maintainers.ash ];
      };
    };
  };
}
