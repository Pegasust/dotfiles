{ home-manager
, lib # extended lib from ../lib
, pkgs
, ... }@inputs: 
lib.exportWithInputs [
  ./hwtr
  ./prince
  ./hungtr
] inputs

