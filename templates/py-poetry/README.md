# A Python project that uses Poetry for packaging and package management

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

- Bootstrapped with [pegasust/dotfiles](https://git.pegasust.com/pegasust/dotfiles)

`nix flake new --template git:git.pegasust.com/pegasust/dotfiles#py-poetry ./`

- Provides [devShell (`nix develop`)](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-develop.html),
[shell.nix (`nix-shell -p ./`)](https://nixos.org/manual/nix/stable/command-ref/nix-shell.html)

- Install [nix-direnv](https://github.com/nix-community/nix-direnv) here for automatic
dev-shell integration

## Bootstrapping the project

- This repo uses [poetry](https://python-poetry.org/docs/cli/#init), a repo-manager
with an intuitive CLI

```sh
poetry init
```

### Libraries worth integrating

- [tophat/syrupy](https://github.com/tophat/syrupy) Snapshot testing plugin for (builtin) pytest

```sh
poetry add --group dev syrupy
```
- [HypothesisWorks/hypothesis](https://github.com/HypothesisWorks/hypothesis)
Hypothesis testing (generate testing data) framework - data driven testing.

```sh
poetry add --group dev hypothesis
```

- [requests](https://github.com/psf/requests) An intuitive way to perform network requests in Python

```sh
poetry add requests
```

- [plotly](https://github.com/plotly/plotly.py) Create plots.

```sh
poetry add plotly
```

- [toolz](https://github.com/pytoolz/toolz) Functional programming in Python
  - Beware, you might lose typesafety doing this, but this is what the 
      [REPL](https://github.com/Olical/conjure/wiki/Quick-start:-Python-(stdio))
      is invented to mitigate.

