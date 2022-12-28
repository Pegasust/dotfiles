# Journal on development

This contains information dump to record thoughts as I design this repo

## Nix as first-class citizen instead of native config

- Nix can export JSON and other object serialization formats

- Still allows native config, so that Neovim, for example, which uses Turing-complete
  config language, to make full use of its native LSP.

## Design pattern emerges from unstructured code

### Modules

- Main thing for the first big refactor of codebase

- nixpkgs and home-manager has their own interface for modules 

- The main benefit is to provide (runtime) type-safety on options, along with
documentations and defaults

## Nitpicky details

### `nativeBuildInputs` vs `buildInputs`

- `nativeBuildInputs` is available **before** `buildInputs`.

- `nativeBuildInputs` is supposed to be built by a deployment machine (not target)

- `buildInputs` gives you access during runtime

- `nativeBulidInputs` gives you access to packages during build time

- `mkShell` doesn't care about `packages`, `nativeBuildInputs`, `buildInputs`

