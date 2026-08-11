# fxlz4 — user design summary

fxlz4 is a **file pack/unpack CLI** using one documented **LZ4 frame** mode under `--allow` (FsCap read + OutCap write).

## Why fxlz4

| Keep | Refuse (v1) |
|------|-------------|
| Official frame + content checksum | Legacy block / multi-format maze |
| `pack` / `unpack` subcommands | Flag soup |
| No silent clobber (`--force` to overwrite) | Ambient overwrite |
| Required `--allow` | Ambient filesystem |
| Dual-path emit-C + IR | Optional-IR theater |

## Exit codes

| Code | Meaning |
|------|---------|
| 0 | ok |
| 1 | usage / bad flags |
| 2 | path deny / missing src / dest exists |
| 3 | compress/decompress / corrupt frame |

## Rebuild

See root README. Needs fx 0.9.6+ with `--cli`, `host/cap`, and lz4 third_party sources.

## Non-goals

zstd · dictionaries · streaming circus · macOS claim
