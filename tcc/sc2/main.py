#!/usr/bin/env python3
"""ISA compliance test runner for rvsc2.

sc2 ISA: full RV32I minus fence/CSR/system instructions.
No synthesis required — every allowed instruction is native.
"""

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from common import find_tool, validate_source

SCRIPT_DIR = Path(__file__).parent

# ── target config ──────────────────────────────────────────────────────────
COMPILER  = "rvsc2-unknown-elf-gcc"
BITS      = 32
MARCH     = f"rv{BITS}i"
BINUTILS  = f"riscv{BITS}-none-elf"
TEST_GLOB = "tests/*.c"

# RV32I base minus fence, CSR, and system instruction groups.
ALLOWED = {
    # integer arithmetic
    "add", "sub", "addi",
    "and", "andi", "or", "ori", "xor", "xori",
    "sll", "slli", "srl", "srli", "sra", "srai",
    # comparison
    "slt", "sltu", "slti", "sltiu",
    # loads
    "lw", "lh", "lhu", "lb", "lbu",
    # stores
    "sw", "sh", "sb",
    # branches
    "beq", "bne", "blt", "bge", "bltu", "bgeu",
    # jumps
    "jal", "jalr",
    # upper immediate
    "lui", "auipc",
}
# ──────────────────────────────────────────────────────────────────────────


def main() -> None:
    parser = argparse.ArgumentParser(
        description="ISA compliance tests for rvsc2 (RV32I minus fence/CSR/system)"
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
