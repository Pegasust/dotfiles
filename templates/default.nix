# TODO: templates should be able to have initial states like
# repo name, author,...
{pkgs
,lib
,...
}: {
  rust = {
    path = ./rust;
    description = "Minimal Rust build template using Naersk, rust-overlay, rust-analyzer";
  };
  rust-monorepo = {
    path = ./rust-monorepo;
    description = "hungtr's opinionated Rust monorepo, extended from ./rust, using Cargo workspace";
  };
}
