#!/usr/bin/env python3
"""ISA compliance test runner for rvsc1.

sc1 ISA: lw sw beq add addi sub and or lui jalr
All other rv32i instructions are synthesized from these ten.
After -M no-aliases: ret → jalr, mv → addi, nop → addi, li → addi or lui+addi.
"""

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from common import find_tool, validate_source

SCRIPT_DIR = Path(__file__).parent

# ── target config ──────────────────────────────────────────────────────────
COMPILER  = "rvsc1-unknown-elf-gcc"
BITS      = 32
MARCH     = f"rv{BITS}i"
BINUTILS  = f"riscv{BITS}-none-elf"
TEST_GLOB = "tests/*.c"

# sc0 set extended with lui and jalr — minimum for the C calling convention.
ALLOWED = {
    "lw", "sw", "beq",
    "add", "addi", "sub", "and", "or",
    "lui", "jalr",
}
# ──────────────────────────────────────────────────────────────────────────


def main() -> None:
    parser = argparse.ArgumentParser(
        description="ISA compliance tests for rvsc1 (sc0 + lui jalr)"
    )
    parser.add_argument(
        "sources", nargs="*", type=Path,
        help=f"C source files (default: {TEST_GLOB})",
    )
    parser.add_argument(
        "--cflag", dest="cflags", action="append", default=[],
        metavar="FLAG", help="Extra compiler flag (repeatable)",
    )
    args = parser.parse_args()

    sources = args.sources or sorted(SCRIPT_DIR.glob(TEST_GLOB))
    if not sources:
        sys.exit(f"error: no test sources found (looked for {SCRIPT_DIR / TEST_GLOB})")

    compiler = find_tool(COMPILER)
    assembler = find_tool(f"{BINUTILS}-as")
    objdump   = find_tool(f"{BINUTILS}-objdump")

    passed = failed = 0
    for src in map(Path, sources):
        print(f"  {src.name} ...", end=" ", flush=True)
        ok, violations = validate_source(
            compiler, assembler, objdump, MARCH, src, ALLOWED, args.cflags
        )
        if ok:
            print("PASS")
            passed += 1
        else:
            print("FAIL")
            for v in violations:
                print(f"    forbidden: {v}")
            failed += 1

    total = passed + failed
    print(f"\n{passed}/{total} passed")
    if failed:
        sys.exit(1)


if __name__ == "__main__":
    main()
