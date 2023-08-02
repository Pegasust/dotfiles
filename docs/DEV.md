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

- `buildInputs` gives you access during runtime (if the package goes path build filter)

- `nativeBulidInputs` gives you access to packages during build time

- `mkShell` doesn't care about `packages`, `nativeBuildInputs`, `buildInputs`

## Archive a branch

Very common to see branches getting stale. We either want to have them become
PR or just have them stale and not deleted (for maximal data collection if 
needed)

Hence, here's the aspect of archiving a branch, that also reflects remote branch

```bash
# archive. Feel free to just rename the BRANCH_NAME here
BRANCH_NAME="boost"
git tag "archive/$BRANCH_NAME" $BRANCH_NAME
git branch -D $BRANCH_NAME
# Now delete at origin
git branch -d -r "origin/$BRANCH_NAME"
git push --tags
git push origin :$BRANCH_NAME

# restore
BRANCH_NAME="hello_world"
git fetch origin
git checkout -b "$BRANCH_NAME" "archive/$BRANCH_NAME"
```


