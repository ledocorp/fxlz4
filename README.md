# fxlz4

**LZ4 pack/unpack CLI for [fx](https://github.com/ledocorp/fxlang) projects.**

fxlz4 compresses and decompresses files under `--allow` using the official **LZ4 frame** format (content checksum on). Product logic is **fx**; rebuild with `fx build … --cli`. Dual-path: emit-C and IR.

| | |
|--|--|
| **Requires** | [fx](https://github.com/ledocorp/fxlang) **0.9.6+** (with `--cli`) |
| **Platforms** | Windows + Linux **x86_64** |
| **License** | Apache-2.0 (tool) · BSD-2-Clause (lz4) |
| **Org** | [LedoCorp](http://www.ledocorp.org) |

## Install (release binaries)

1. Install [fx 0.9.6+](https://github.com/ledocorp/fxlang/releases/tag/v0.9.6).  
2. Download the asset for your OS from [Releases](https://github.com/ledocorp/fxlz4/releases).  
3. Put `bin/windows/fxlz4.exe` or `bin/linux/fxlz4` on your `PATH`.

```text
# Windows (PowerShell)
Invoke-WebRequest -Uri https://github.com/ledocorp/fxlz4/releases/download/v0.1.0/fxlz4-0.1.0-windows-x86_64.zip -OutFile fxlz4.zip
Expand-Archive fxlz4.zip -DestinationPath .
.\bin\windows\fxlz4.exe --help

# Linux
curl -LO https://github.com/ledocorp/fxlz4/releases/download/v0.1.0/fxlz4-0.1.0-linux-x86_64.tar.gz
tar xzf fxlz4-0.1.0-linux-x86_64.tar.gz
./bin/linux/fxlz4 --help
```

Optional: `fxlz4-ir` is the IR dual-path binary (same CLI).

## Quick start

```text
fxlz4 --allow . pack hello.txt hello.txt.lz4
fxlz4 --allow . unpack hello.txt.lz4 hello.out
fxlz4 --allow . --force pack hello.txt hello.txt.lz4
```

Destination exists → refuse (exit 2) unless `--force`. Paths must resolve under `--allow`.

## CLI

| Invocation | Behavior |
|------------|----------|
| `fxlz4 --allow <dir> pack <src> <dst>` | Compress file → `.lz4` frame |
| `fxlz4 --allow <dir> unpack <src> <dst>` | Decompress frame → file |
| `fxlz4 --allow <dir> --force …` | Overwrite destination |
| `fxlz4 --help` | Usage |

Exit codes: `0` ok · `1` usage · `2` path deny / missing src / dest exists · `3` compress/decompress / corrupt frame.

## Rebuild from source

With `fx` 0.9.6+ on `PATH`, `FX_STD_ROOT` pointing at fx `std/`, and access to the lz4 wrap + `host/cap`:

```text
fx build fxlz4_lib.fx -o out --emit-c --cli \
  --link <wrap_lz4>/lz4_ref.c \
  --link <wrap_lz4>/third_party/lz4.c \
  --link <wrap_lz4>/third_party/lz4hc.c \
  --link <wrap_lz4>/third_party/lz4frame.c \
  --link <wrap_lz4>/third_party/xxhash.c \
  --link <host>/cap/fx_cap_runtime.c \
  --link-include <wrap_lz4>/third_party \
  --link-include <host>/cap
```

Same links with `--backend ir` for the IR binary. No author-written `host.c`.

## Non-goals (v1)

zstd · dictionaries · streaming circus · legacy LZ4 block frame · macOS prebuilt claim

## Docs

- [docs/FXLZ4.md](docs/FXLZ4.md) — design summary  
- [docs/releases/](docs/releases/) — release notes  
- Language: [ledocorp/fxlang](https://github.com/ledocorp/fxlang)

## License

Copyright Shawn Londono · LedoCorp · Apache-2.0 — see [LICENSE](LICENSE).
