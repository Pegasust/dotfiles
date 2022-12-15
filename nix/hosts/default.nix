{ flake-utils-plus
, lib # extended lib from ../lib
, ...
} @inputs:
lib.exportWithInputs [
    ./prince
    ./hwtr
] inputs

