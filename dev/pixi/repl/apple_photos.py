#!/usr/bin/env python
"""
REPL-friendly python mono-module for importing and execution singleton
"""

import os
from dataclasses import dataclass
from itertools import groupby
from typing import Iterable

mac_photos = os.getenv("MAC_PHOTOS_PATH", default="mac_photos")


@dataclass(slots=True, frozen=True)
class PhotosKExt:
    name: str
    parent: tuple[str, ...]
    exts_lowered: tuple[str, ...]

    @classmethod
    def from_root_file(cls, root: str, filename: str):
        ext_elems = filename.split('.')
        return cls(
            name=ext_elems[0],
            parent=os.path.split(root),
            exts_lowered=tuple(
                ext.lower() for ext in ext_elems[1:]
            )
        )


@dataclass(slots=True, frozen=True)
class PhotosKey:
    filename: str
    parent: tuple[str, ...]

    @classmethod
    def from_key_ext(cls, ext: PhotosKExt):
        return cls(filename=ext.name, parent=ext.parent)


@dataclass(slots=True)
class PhotosValue:
    exts: dict[str, list[str]]

    def heic_paths(self) -> list[str]:
        return self.exts.get("heic", list())

    def mov_paths(self) -> list[str]:
        return self.exts.get("mov", list())


def candidate_exts(file_exts: Iterable[PhotosKExt]):
    """
    >>> {ext: len(files)for ext, files in cexts.items()}
    stdout> {... 'mov': 2769, 'heic': 2354 ...}

    We could make a bold guess that iPhone 11 stores both `heic` and `mov`
    for materialized best capture and live movie for live capture.
    """
    exts_rv: dict[str, list[PhotosKExt]] = dict()

    for file in file_exts:
        for ext in file.exts_lowered:
            exts_rv.setdefault(ext, list()).append(file)

    return exts_rv


def file_exts(photos_dir: str = mac_photos):
    return {
        PhotosKExt.from_root_file(filename=file, root=root)
        for root, _, files in os.walk(photos_dir, followlinks=True)
        for file in files
    }


def photos_exts(files_with_ext: Iterable[PhotosKExt]):
    return {
        k: list(v)
        for k, v in groupby(files_with_ext, key=lambda x: (x.name, x.parent))
    }


def main():
    fexts = file_exts()
    cexts = candidate_exts(fexts)
    print(f"{photos_exts(fexts)=}")
    print(f"{cexts=}")

    ext_counts = {ext: len(files)for ext, files in cexts.items()}
    print(ext_counts)
    # stdout>
    """
{'jpeg': 6023, 'mov': 2769, 'heic': 2354, 'thm': 197, 'png': 168, 'plist': 163,
'log': 1, 'aae': 102, 'kgdb': 3, 'mp4': 26, 'data': 3, 'db': 3, 'xml': 26,
'cmap': 2, 'plj': 16, 'kgdb-wal': 3, 'sqlite-shm': 11, 'cloudphotodb-wal': 1,
'kgdb-shm': 3, '00001]': 1, 'frag': 2, 'ithmb': 3, 'sqlite': 15, 'lock': 1,
'sqlite-wal': 11, 'aoi': 3, '0': 1,
'm3u8-8f37dbfb-b3a6-4d52-beca-d17aaed01606': 2, 'jpg': 2, 'roi': 3, 'poi': 3,
'db-shm': 1, 'm3u8-37f64716-0b2d-4a82-854a-5a6c78ce505a': 1, 'descriptor': 3,
'bin': 2, 'm3u8': 5, 'cloudphotodb': 1, 'db-wal': 1, 'nature': 3,
'm3u8-d8faad08-4fcc-4161-a600-1562d755c97b': 1, 'initfrag': 2, '20201]': 1,
'cloudphotodb-shm': 1}
    """

    movs = cexts['mov']
    heics = cexts['heic']
    heic_name_set = {heic.name.lower() for heic in heics}
    mov_name_set = {mov.name.lower() for mov in movs}
    print(len(heic_name_set - mov_name_set) - len(heic_name_set))
    # stdout> (not 0)
    # Hence, we are not able to match `.heic` with its `.mov` with just names
    # Could it be that the `.heic` also contains the high-quality live?


if __name__ == "__main__":
    main()
