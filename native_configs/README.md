# Native configs

Contains all configurations that are written in their native configuration language.

## Why native language?

- Easier portability
- Nix can read from [JSON](https://nixos.org/manual/nix/stable/language/builtins.html#builtins-fromJSON),
[TOML](https://nixos.org/manual/nix/stable/release-notes/rl-2.6.html#release-26-2022-01-24).
- We have also managed to hack together a [fromYaml](./../nix-conf/lib/serde/default.nix),
though it will not work for strictly pure builds or bootstrapping builds.

