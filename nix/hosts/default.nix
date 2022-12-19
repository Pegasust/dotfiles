# Each host will export optionally its nixosConfiguration, which also manages its 
# own hardware-configuration
{ pkgs # nixpkgs imported
, lib  # extended lib
, c_
, nixos_lib # nixpkgs/nixos/lib
, flake-utils-plus
, ...
}@inputs:
let
  # ({sys: str} -> nixosConfiguration) -> nixosConfigurations-compatible-host for defaultSystems
  mkHost = nixosConfigFn: c_.list2Attrs_ flake-utils-plus.lib.defaultSystems (sys: {
    ${sys} = nixos_lib.nixosSystem ({ system = sys; } // (nixosConfigFn { inherit sys; }));
  });
in
{
  Felia = mkHost { };
  lizzi = mkHost { };
}

