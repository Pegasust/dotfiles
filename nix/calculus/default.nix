{ pkgs ? import <nixpkgs> { }
, lib ? inputs.pkgs.lib
, ...
}@inputs:
builtins // rec {
  mod = base: int: base - (int * (builtins.div base int));
  map_ = list: fn: (builtins.map fn list);
  mapAttrs_ = attrset: fn: (builtins.mapAttrs fn attrset);
  # :: [T] -> (T -> null | V) -> [V]
  # Filters if return null, otherwise, remap to V
  filterMap_ = list: fn: (builtins.filter (e: e != null) (builtins.map fn list));
  filterMap = fn: list: (filterMap_ list fn);
  filter_ = list: fn: (builtins.filter fn list);

  # :: [T] -> (T -> V) -> {T[int] = V;}
  list2Attrs_ = list: fn_k_v (builtins.foldl' (acc: k: acc // { k = (fn_k_v k); }) { } list);
  list2Attrs = fn_k_v: list (list2Attrs_ list fn_k_v);

  # range :: int -> int -> [int]
  rangeIn = lib.range;
  rangeEx = start: stop: (lib.range start stop-1);

  # [T] -> int
  len = builtins.length;
  zip = lib.zipLists;
  # [T] -> [{idx: int, val: T}]
  enumerate = list: lib.zipListsWith (idx: val: { inherit idx val; }) (rangeEx 0 (len list)) list;
}

