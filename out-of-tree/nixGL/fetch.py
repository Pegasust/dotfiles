#!/usr/bin/env python3
import urllib3
import json

http = urllib3.PoolManager()
dl_dir = http.request("GET", "https://download.nvidia.com/XFree86/Linux-x86_64/")

assert (dl_dir.status < 400), "Error probably occurred"

def find_versions(dir_html: bytes) -> list[str]:
    # this algorithm obviously need recursion because we need to discover the items
    def _rec(dir_html: bytes, start: int = 0, so_far: list[str] = []) -> list[str]:
        MATCH_START = b"<span class=\'dir\'><a href=\'"
        potential_start = dir_html.find(MATCH_START, start)
        if potential_start == -1:
            return so_far
        # check that it starts with a number
        potential_version_start = potential_start + len(MATCH_START)
        p = potential_version_start
        if not (dir_html[p: p+1].decode().isnumeric()):
            return _rec(dir_html, potential_version_start, so_far)

        # this thing matches, add to so_far and continue
        version_end = dir_html.find(b"/", potential_version_start)
        assert version_end != -1, "There should be matching /"
        so_far.append(dir_html[potential_version_start:version_end].decode())
        return _rec(dir_html, version_end, so_far)
    return _rec(dir_html, 0, [])
    
versions = find_versions(dl_dir.data)

download_urls = lambda ver: [f"https://download.nvidia.com/XFree86/Linux-x86_64/{ver}/NVIDIA-Linux-x86_64-{ver}.run"]
sha256_urls = lambda ver: [f"{url}{dl_ext}" for dl_ext in [".sha256sum", ".sha256"] for url in download_urls(ver)]
def req_monad(url: str, err_fn, then_fn):
    res = http.request("GET", url)
    if res.status >= 400:
        return err_fn(res.status)
    return then_fn(res.data)

identity = lambda e: e
none_id = lambda _: None

def get_sha256(version: str) -> str | None:
    for url in sha256_urls(version):
        res = http.request("GET", url)
        if res.status < 400:
            return res.data.decode().split()[0]
    return None
fetch_data = [(v, download_urls(v)[0], get_sha256(v)) for v in versions]
fetch_data.append(("latest", *fetch_data[-1][1:]))


# now print the JSON object
print(json.dumps({
    version: {
        "url": dl_url, 
        "sha256": sha256
    } for (version, dl_url, sha256) in fetch_data if sha256 is not None}, indent=4))
# execution: fetch.py >nvidia_versions.json

