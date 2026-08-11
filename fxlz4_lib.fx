// fxlz4_lib — LZ4 pack/unpack under FsCap (--cli auto-host).
// Public design: docs/FXLZ4.md (this tree) · fxlang host/cli + host/cap
module fxlz4_lib;

using core;
import std/io;
import std/string;
import std/strutil;

extern "c" {
    fn fx_cli_argc() -> i32;
    fn fx_cli_arg(i: i32) -> string;
    effects { alloc } fn fx_guest_begin(root: string, arena_bytes: i64) -> i64;
    effects { alloc } fn fx_guest_end(ctx_handle: i64) -> i32;
    effects { alloc } fn fx_guest_mint_fscap(ctx_handle: i64, root: string) -> i64;
    effects { alloc } fn fx_guest_mint_outcap(ctx_handle: i64, root: string) -> i64;
    fn fx_lz4_pack_cap(fs_handle: i64, out_handle: i64, src: string, dst: string, force: i32) -> i32;
    fn fx_lz4_unpack_cap(fs_handle: i64, out_handle: i64, src: string, dst: string, force: i32) -> i32;
}

fn eq(a: string, b: string) -> bool {
    return string.compare(a, b);
}

fn usage() -> i32 effects { io } {
    let _u = io.write_err("usage: fxlz4 --allow <dir> [--force] pack|unpack <src> <dst>");
    return 1;
}

fn path_has_dotdot(s: string) -> bool {
    return strutil.contains(s, "..");
}

fn resolve_under(allow: string, rel: string) -> Result<string, core_Err> effects { alloc } {
    let al = string.len(allow);
    let dl = string.len(rel);
    if (dl > al) {
        if (strutil.starts_with(rel, allow) == true) {
            let c = string.byte_at(rel, al);
            if (c == 47) {
                return Ok(rel);
            }
            if (c == 92) {
                return Ok(rel);
            }
        }
    }
    let mid = string.concat(allow, "/")?;
    return string.concat(mid, rel);
}

fn map_st(st: i32) -> i32 effects { io } {
    if (st == 0) {
        return 0;
    }
    if (st == -5) {
        let _d = io.write_err("fxlz4: path outside allow / denied");
        return 2;
    }
    if (st == -4) {
        let _e = io.write_err("fxlz4: destination exists (pass --force)");
        return 2;
    }
    if (st == -6) {
        let _m = io.write_err("fxlz4: source missing or unreadable");
        return 2;
    }
    let _f = io.write_err("fxlz4: compress/decompress failed");
    return 3;
}

fn run_op(allow: string, src: string, dst: string, pack: i32, force: i32) -> i32 effects { alloc, io } {
    let g = fx_guest_begin(allow, 65536);
    if (g == 0) {
        let _g = io.write_err("fxlz4: guest begin failed");
        return 2;
    }
    let fs = fx_guest_mint_fscap(g, "");
    if (fs == 0) {
        let _e0 = fx_guest_end(g);
        let _f = io.write_err("fxlz4: mint_fs failed");
        return 2;
    }
    let out = fx_guest_mint_outcap(g, "");
    if (out == 0) {
        let _e1 = fx_guest_end(g);
        let _o = io.write_err("fxlz4: mint_out failed");
        return 2;
    }
    let st: i32 = 0;
    if (pack != 0) {
        st = fx_lz4_pack_cap(fs, out, src, dst, force);
    } else {
        st = fx_lz4_unpack_cap(fs, out, src, dst, force);
    }
    let _en = fx_guest_end(g);
    return map_st(st);
}

fn cli_main() -> Result<i32, core_Err> effects { alloc, io } {
    let allow = "";
    let cmd = "";
    let src = "";
    let dst = "";
    let force: i32 = 0;
    let argc = fx_cli_argc();
    let i: i32 = 1;
    while (i < argc) {
        let a = fx_cli_arg(i);
        if (eq(a, "--help") == true) {
            return Ok(usage());
        }
        if (eq(a, "-h") == true) {
            return Ok(usage());
        }
        if (eq(a, "--force") == true) {
            force = 1;
            i = i + 1;
        } else {
            if (eq(a, "--allow") == true) {
                i = i + 1;
                if (i >= argc) {
                    let _m = io.write_err("fxlz4: --allow requires a directory");
                    return Ok(1);
                }
                allow = fx_cli_arg(i);
                i = i + 1;
            } else {
                if (string.len(a) > 0) {
                    if (string.byte_at(a, 0) == 45) {
                        let _u = io.write_err("fxlz4: unknown flag");
                        return Ok(1);
                    }
                }
                if (string.len(cmd) == 0) {
                    cmd = a;
                    i = i + 1;
                } else {
                    if (string.len(src) == 0) {
                        src = a;
                        i = i + 1;
                    } else {
                        if (string.len(dst) == 0) {
                            dst = a;
                            i = i + 1;
                        } else {
                            let _e = io.write_err("fxlz4: extra arguments");
                            return Ok(1);
                        }
                    }
                }
            }
        }
    }
    if (string.len(allow) == 0) {
        let _a = io.write_err("fxlz4: --allow <dir> is required");
        return Ok(1);
    }
    if (string.len(cmd) == 0) {
        return Ok(usage());
    }
    if (string.len(src) == 0) {
        let _s = io.write_err("fxlz4: missing <src>");
        return Ok(1);
    }
    if (string.len(dst) == 0) {
        let _d = io.write_err("fxlz4: missing <dst>");
        return Ok(1);
    }
    if (path_has_dotdot(allow) == true) {
        let _pa = io.write_err("fxlz4: path outside allow / denied");
        return Ok(2);
    }
    if (path_has_dotdot(src) == true) {
        let _ps = io.write_err("fxlz4: path outside allow / denied");
        return Ok(2);
    }
    if (path_has_dotdot(dst) == true) {
        let _pd = io.write_err("fxlz4: path outside allow / denied");
        return Ok(2);
    }

    let pack: i32 = 0;
    if (eq(cmd, "pack") == true) {
        pack = 1;
    } else {
        if (eq(cmd, "unpack") == true) {
            pack = 0;
        } else {
            let _c = io.write_err("fxlz4: command must be pack or unpack");
            return Ok(1);
        }
    }

    let src_p = resolve_under(allow, src)?;
    let dst_p = resolve_under(allow, dst)?;
    let code = run_op(allow, src_p, dst_p, pack, force);
    return Ok(code);
}
