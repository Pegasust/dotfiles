let
  pkgs = import <nixpkgs> { };
  inherit (pkgs) lib;
  inherit (lib) runTests;
  c_ = import ./default.nix { inherit pkgs lib; };
  bulkExprTest = { name, fn, list_case, ... }@test: (c_.foldl'
    (acc: { name, args, expected, ... }@case: acc // {
      "test_${test.name}_${case.name}" = {
        expr = c_.foldl' (f: x: f x) fn args;
        inherit expected;
      };
    })
    { }
    list_case);
  tests = (
    bulkExprTest
      {
        name = "filterMap_";
        fn = c_.filterMap_;
        list_case = [
          {
            name = "odd";
            args = [ [ 1 2 3 4 5 6 ] (e: if (c_.mod e 2) == 0 then null else e) ];
            expected = [ 1 3 5 ];
          }
          {
            name = "even";
            args = [ [ 1 2 3 4 5 6 ] (e: if (c_.mod e 2) == 1 then null else e) ];
            expected = [ 2 4 6 ];
          }
        ];
      } // bulkExprTest {
      name = "filterMap";
      fn = c_.filterMap;
      list_case = [
        {
          name = "odd";
          args = [ (e: if (c_.mod e 2) == 0 then null else e) [ 1 2 3 4 5 6 ] ];
          expected = [ 1 3 5 ];
        }
        {
          name = "even";
          args = [ (e: if (c_.mod e 2) == 1 then null else e) [ 1 2 3 4 5 6 ] ];
          expected = [ 2 4 6 ];
        }
      ];
    } // bulkExprTest {
      name = "list2Attrs_";
      fn = c_.list2Attrs_;
      list_case = [
        {
          name = "attach";
          args = [ [ "123" "abc" "1414" ] (_x: 515) ];
          expected = { "123" = 515; "abc" = 515; "1414" = 515; };
        }
      ];
    } // bulkExprTest {
      name = "zip";
      fn = c_.zip;
      list_case = [
        {
          name = "equal_length";
          args = [ [ 1 2 3 ] [ 4 5 6 ] ];
          expected = [ [ 1 4 ] [ 2 5 ] [ 3 6 ] ];
        }
        {
          name = "left_more";
          args = [ [ 1 2 3 4 ] [ 5 6 7 ] ];
          expected = [ [ 1 5 ] [ 2 6 ] [ 3 7 ] ];
        }
      ];
    } // bulkExprTest {
      name = "enumerate";
      fn = c_.enumerate;
      list_case = [
        {
          name = "empty";
          args = [ [ ] ];
          expected = [ ];
        }
        {
          name = "normal";
          args = [ [ 51 51 11 23 17 125 ] ];
          expected = [
            { idx = 0; val = 51; }
            { idx = 1; val = 51; }
            { idx = 2; val = 11; }
            { idx = 3; val = 23; }
            { idx = 4; val = 17; }
            { idx = 5; val = 125; }
          ];
        }
      ];
    }
  );
in
{
  inherit pkgs lib runTests c_;
  _tests = tests;
  tests = runTests tests;
}

