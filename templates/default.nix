# TODO: templates should be able to have initial states like
# repo name, author,...
{ pkgs
, lib
, ...
}: {
  rust = {
    path = ./rust;
    description = "Minimal Rust build template using Naersk, rust-overlay, rust-analyzer";
  };
  rust-monorepo = {
    path = ./rust-monorepo;
    description = "Opinionated Rust monorepo, extended from ./rust, using Cargo workspace";
  };
  ts-turborepo = {
    path = ./ts/turborepo;
    description = "Typescript monorepo with tsconfig, eslint, but with minimal framework attached";
  };
  py-poetry = {
    path = ./py-poetry;
    description = "Python repository with poetry & poetry2nix";
  };
}
