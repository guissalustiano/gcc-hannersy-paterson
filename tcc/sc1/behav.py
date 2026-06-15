#!/usr/bin/env python3
"""Behavioral differential test for rvsc1.

For each behav_*.c:
  1. Compile with rvsc1-unknown-elf-gcc  →  assemble  →  link with startup32  →  spike
  2. Compile with riscv32-none-elf-gcc   →  assemble  →  link with startup32  →  spike
  PASS if both spike runs produce the same exit code.

startup32.S is always assembled with the reference toolchain (it uses full rv32i
instructions like slli, ori, la, call that sc1 does not emit natively).
"""

import argparse
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from common import (
    find_tool, compile_to_asm, assemble, assemble_file,
    link_elf, run_spike, SpikeTimeout,
)

SCRIPT_DIR = Path(__file__).parent

# ── config ──────────────────────────────────────────────────────────────────
SC1_COMPILER = "rvsc1-unknown-elf-gcc"
REF_COMPILER = "riscv32-none-elf-gcc"
REF_CFLAGS   = ["-march=rv32i", "-mabi=ilp32"]
MARCH        = "rv32i"
ISA          = "rv32i"
BINUTILS     = "riscv32-none-elf"
STARTUP      = SCRIPT_DIR / "startup32.S"
LD_SCRIPT    = SCRIPT_DIR / "link32.ld"
TEST_GLOB    = "tests/behav_*.c"
# ────────────────────────────────────────────────────────────────────────────


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Behavioral differential tests: rvsc1 vs reference rv32i on Spike"
    )
    parser.add_argument(
        "sources", nargs="*", type=Path,
        help=f"C source files (default: {TEST_GLOB})",
    )
    args = parser.parse_args()

    sources = args.sources or sorted(SCRIPT_DIR.glob(TEST_GLOB))
    if not sources:
        sys.exit(f"error: no test sources found (looked for {SCRIPT_DIR / TEST_GLOB})")

    sc1_gcc   = find_tool(SC1_COMPILER)
    ref_gcc   = find_tool(REF_COMPILER)
    assembler = find_tool(f"{BINUTILS}-as")
    linker    = find_tool(f"{BINUTILS}-ld")
    find_tool("spike")

    passed = failed = 0

    with tempfile.TemporaryDirectory() as _tmp:
        tmp = Path(_tmp)

        # startup32.S assembled once and shared across all tests
        startup_obj = tmp / "startup32.o"
        assemble_file(assembler, MARCH, STARTUP, startup_obj)

        for src in map(Path, sources):
            print(f"  {src.name} ...", end=" ", flush=True)

            # sc1 build
            sc1_obj = tmp / f"{src.stem}_sc1.o"
            sc1_elf = tmp / f"{src.stem}_sc1.elf"
            sc1_asm = compile_to_asm(sc1_gcc, src, [])
            sc1_tmp = assemble(assembler, MARCH, sc1_asm)
            sc1_tmp.rename(sc1_obj)
            link_elf(linker, LD_SCRIPT, [startup_obj, sc1_obj], sc1_elf)

            # reference build
            ref_obj = tmp / f"{src.stem}_ref.o"
            ref_elf = tmp / f"{src.stem}_ref.elf"
            ref_asm = compile_to_asm(ref_gcc, src, REF_CFLAGS)
            ref_tmp = assemble(assembler, MARCH, ref_asm)
            ref_tmp.rename(ref_obj)
            link_elf(linker, LD_SCRIPT, [startup_obj, ref_obj], ref_elf)

            # run both and compare
            try:
                sc1_exit = run_spike(ISA, sc1_elf)
                ref_exit = run_spike(ISA, ref_elf)
            except SpikeTimeout as e:
                print(f"FAIL  (spike timeout: {e})")
                failed += 1
                continue

            if sc1_exit == ref_exit:
                print(f"PASS  (exit {sc1_exit})")
                passed += 1
            else:
                print(f"FAIL  (sc1={sc1_exit}, ref={ref_exit})")
                failed += 1

    total = passed + failed
    print(f"\n{passed}/{total} passed")
    if failed:
        sys.exit(1)


if __name__ == "__main__":
    main()
