# a small helper that only builds on top of builtins functions
_: (builtins // (
  let
    formatSecondsSinceEpoch = t:
      let
        rem = x: y: x - x / y * y;
        days = t / 86400;
        secondsInDay = rem t 86400;
        hours = secondsInDay / 3600;
        minutes = (rem secondsInDay 3600) / 60;
        seconds = rem t 60;

        # Courtesy of https://stackoverflow.com/a/32158604.
        z = days + 719468;
        era = (if z >= 0 then z else z - 146096) / 146097;
        doe = z - era * 146097;
        yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
        y = yoe + era * 400;
        doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
        mp = (5 * doy + 2) / 153;
        d = doy - (153 * mp + 2) / 5 + 1;
        m = mp + (if mp < 10 then 3 else -9);
        y' = y + (if m <= 2 then 1 else 0);

        pad = s: if builtins.stringLength s < 2 then "0" + s else s;
      in
      "${toString y'}${pad (toString m)}${pad (toString d)}${pad (toString hours)}"
        + "${pad (toString minutes)}${pad (toString seconds)}";

    fetchTree =
      # this is the value of flake.lock#lock.nodes.${input_name}.locked
      { type
      , host ? ""
      , owner ? ""
      , repo ? ""
      , rev ? ""
      , submodules ? ""
      , path ? ""
      , narHash ? null
      , lastModified ? 0
      , src ? ./.
      }@info:
      if info.type == "github" then
        {
          outPath =
            fetchTarball
              ({
                url = "https://api.${info.host or "github.com"}/repos/"
                  + "${info.owner}/${info.repo}/tarball/${info.rev}";
              }
              // (if info ? narHash then { sha256 = info.narHash; } else { })
              );
          rev = info.rev;
          shortRev = builtins.substring 0 7 info.rev;
          lastModified = info.lastModified;
          lastModifiedDate = formatSecondsSinceEpoch info.lastModified;
          narHash = info.narHash;
        }
      else if info.type == "git" then
        {
          outPath =
            builtins.fetchGit
              ({ url = info.url; }
                // (if info ? rev then { inherit (info) rev; } else { })
                // (if info ? ref then { inherit (info) ref; } else { })
                // (if info ? submodules then { inherit (info) submodules; } else { })
              );
          lastModified = info.lastModified;
          lastModifiedDate = formatSecondsSinceEpoch info.lastModified;
          narHash = info.narHash;
        } // (if info ? rev then {
          rev = info.rev;
          shortRev = builtins.substring 0 7 info.rev;
        } else { })
      else if info.type == "path" then
        {
          outPath = builtins.path {
            path =
              if builtins.substring 0 1 info.path != "/"
              then src + ("/" + info.path)  # make this absolute path by prepending ./
              else info.path; # it's already an absolute path
          };
          narHash = info.narHash;
        }
      else if info.type == "tarball" then
        {
          outPath =
            fetchTarball
              ({ inherit (info) url; }
                // (if info ? narHash then { sha256 = info.narHash; } else { })
              );
        }
      else if info.type == "gitlab" then
        {
          inherit (info) rev narHash lastModified;
          outPath =
            fetchTarball
              ({ url = "https://${info.host or "gitlab.com"}/api/v4/projects/${info.owner}%2F${info.repo}/repository/archive.tar.gz?sha=${info.rev}"; }
                // (if info ? narHash then { sha256 = info.narHash; } else { })
              );
          shortRev = builtins.substring 0 7 info.rev;
        }
      else
      # FIXME: add Mercurial, tarball inputs.
        throw "flake input has unsupported input type '${info.type}'";
  in
  {
    inherit fetchTree;
  }
)) nil

