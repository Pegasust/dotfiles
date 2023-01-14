# Rust-monorepo. TODO: Change this to your monorepo name

## About this template 

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

- Bootstrapped with [pegasust/dotfiles](https://git.pegasust.com/pegasust/dotfiles)

- Uses [naersk](https://github.com/nix-community/naersk.git) to build package(s)

- Provides [devShell (`nix develop`)](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-develop.html),
[shell.nix (`nix-shell -p ./`)](https://nixos.org/manual/nix/stable/command-ref/nix-shell.html)
for development environment. It contains:
  - The default `devShell` provides Nightly rustc via 
[`gh:oxalica/rust-overlay`](https://github.com/oxalica/rust-overlay.git)
  - [rustc components](https://rust-lang.github.io/rustup/concepts/components.html) includes
  `rust-src`, [`rust-analyzer`](https://github.com/rust-lang/rust-analyzer.git),
  `clippy`, `miri`
  - [`evcxr`: Rust REPL]() and [`bacon`: Rust nodemon]()

## Check out these [killer libraries](https://jondot.medium.com/12-killer-rust-libraries-you-should-know-c60bab07624f)
### Application development

- [Serde](https://github.com/serde-rs/serde) for (de)serialization needs
  - Data-driven programming in Rust starts with Serde
  - Service system programming starts with defining your message protocols & data formats

- [Clap](https://docs.rs/clap/latest/clap/) declarative CLI arguments
  - Data-driven CLI development in Rust starts with Clap

- [itertools](https://lib.rs/crates/itertools) for extra juice to iterators

- [log](https://lib.rs/crates/log) or [env-logger](https://docs.rs/env_logger/latest/env_logger)
for logging needs

### Library development

- [proptest](https://lib.rs/crates/proptest) for hyppothesis testing
  - Data-driven testing starts with proptest


