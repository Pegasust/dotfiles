# Local nixlib in `nix repl`

Pretty useful for airplane-driven development
```console
nixlib = import <nixpkgs/lib>

nix-repl> nixlib.genAttrs
«lambda @ /nix/var/nix/profiles/per-user/root/channels/nixpkgs/lib/attrsets.nix:619:5»
```
