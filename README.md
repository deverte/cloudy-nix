# cloudy-nix

[Cloudy](https://gitlab.nublado.org/cloudy/cloudy) Nix flake wrapper.

> Cloudy is an ab initio spectral synthesis code designed to model a wide range
> of interstellar "clouds", from H II regions and planetary nebulae, to Active
> Galactic Nuclei, and the hot intracluster medium that permeates galaxy
> clusters.  
> &copy; _**Gary Ferland**_

## Usage

Binaries and scripts:

- `cloudy`
- `cloudy-docs-quick-start`
- `cloudy-docs-hazy1`
- `cloudy-docs-hazy2`
- `cloudy-docs-hazy3`

## Installation

`flake.nix`:

```nix
{
  inputs = {
    cloudynixpkgs.url =
      "https://github.com/deverte/cloudy-nix/archive/refs/tags/c23.01-with-docs.tar.gz";
  };

  outputs = inputs@{ self, cloudynixpkgs, ... }:
  let
    system = "x86_64-linux";
    cloudy = cloudynixpkgs.packages.${system}.default;
  in {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [
        cloudy
      ];
    };
  };
}
```

## License

Original Cloudy code was developed by Gary Ferland and
[other contributors](https://gitlab.nublado.org/cloudy/cloudy/-/raw/master/others.txt),
and it is published under the
[zlib license](https://gitlab.nublado.org/cloudy/cloudy/-/raw/master/license.txt?ref_type=heads).

This wrapper is licensed under the [MIT license](./LICENSE) and was developed by
Artem Shepelin.
