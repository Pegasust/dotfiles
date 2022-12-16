let
  pkgs = import <nixpkgs> { };
  inherit (pkgs) lib;
  inherit (lib) runTests;
  c_ = import ./default.nix;
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
    bulkExprTest {
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
          args = [["123" "abc" "1414"]];
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

