# Native configs

Contains all configurations that are written in their native configuration language.

## Why native language?

- Easier portability
- Syntax highlighting and robust checking without needing to realize derivation
- Nix can read from [JSON](https://nixos.org/manual/nix/stable/language/builtins.html#builtins-fromJSON),
[TOML](https://nixos.org/manual/nix/stable/release-notes/rl-2.6.html#release-26-2022-01-24).
- We have also managed to hack together a [fromYaml](./../nix-conf/lib/serde/default.nix),
though it will not work for strictly pure builds or bootstrapping builds.

## When to use Nix to generate config?

- Original configuraiton language requires too much duplication that can be solved with Nix 

