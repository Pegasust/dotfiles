#!/usr/bin/env python3
# execution: fetch.py >nvidia_versions.json

import http.client
import json
import sys

NV_FREE_X86_URL = "download.nvidia.com"
POTENTIAL_SHA256_EXTS = [".sha256sum", ".sha256"]
RIGHT_PAD = " " * 20

conn = http.client.HTTPSConnection(NV_FREE_X86_URL)
conn.request("GET", "/XFree86/Linux-x86_64/")
response = conn.getresponse()
dir_html = response.read()

assert (response.status < 400), "Error occurred fetching for source from"

def scrape_driver_versions(dir_html: bytes):
    # The idea is to recursively follows all interesting `src` from `<a href={src}>`
    def _rec(dir_html: bytes, href_url_start: int = 0, so_far: list[str] = []) -> list[str]:
        MATCH_START = b"<span class=\'dir\'><a href=\'"
        href_url_start = dir_html.find(MATCH_START, href_url_start)
        if href_url_start == -1: # EOF
            return so_far

        # version href should start with a number
        potential_version_start = href_url_start + len(MATCH_START)
        p = potential_version_start
        if not (dir_html[p: p+1].decode().isnumeric()):
            return _rec(dir_html, potential_version_start, so_far)

        version_end = dir_html.find(b"/", potential_version_start)
        assert version_end != -1, "Should have end-signaling /"
        so_far.append(dir_html[potential_version_start:version_end].decode())
        return _rec(dir_html, version_end, so_far)

    versions = _rec(dir_html, 0, [])
    num_versions = len(versions)
    for i, version in enumerate(versions):
        print(f"[{i+1}/{num_versions}] Processing version {version}{RIGHT_PAD}", end="\r", file=sys.stderr)
        yield version
    print()

versions = scrape_driver_versions(dir_html)

download_urls_of = lambda ver: [f"/XFree86/Linux-x86_64/{ver}/NVIDIA-Linux-x86_64-{ver}.run"]
sha256_urls_of = lambda ver: [
    f"{url}{dl_ext}" 
    for dl_ext in POTENTIAL_SHA256_EXTS 
    for url in download_urls_of(ver)
]

def sha256_of(version: str) -> str | None:
    if int(version.split(".")[0]) < 256:
        # Has 3 different packages that we should probably not bother
        return None
    for url in sha256_urls_of(version):
        conn = http.client.HTTPSConnection(NV_FREE_X86_URL)
        conn.request("GET", url)
        response = conn.getresponse()
        if response.status < 400:
            return response.read().decode().split()[0]
    print(f"No sha256 for {version}{RIGHT_PAD}", file=sys.stderr)
    return None

def fetch(version: str):
    dl_url = download_urls_of(version)[0]
    sha256 = sha256_of(version)
    return (version, dl_url, sha256)

fetch_data = [fetch(v) for v in versions]
fetch_data.append(("latest", *fetch_data[-1][1:]))

# now print the JSON object
print(json.dumps({
    version: {
        "url": f"https://{NV_FREE_X86_URL}{dl_url}", 
        "sha256": sha256
    } for (version, dl_url, sha256) in fetch_data if sha256 is not None}, indent=4))

