#!/usr/bin/env python3
"""run_spike_tests.py <target-triple>

Behavioral correctness tests using Spike.

For every behav_*.c in this directory:
  1. Compile to assembly with the custom rvscN compiler (-S -O1).
  2. Assemble with riscvXX-none-elf-as (from binutils, already in nix shell).
  3. Link with riscvXX-none-elf-ld using the bare-metal HTIF linker script.
  4. Run the resulting ELF on Spike.
  5. Check exit code: 0 = pass, anything else = fail.

We use as+ld directly (not gcc) to avoid polluting CC/CXX env vars that would
break this project's own GCC configure runs.

Skips gracefully if the target compiler or spike is not on PATH.
"""

import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

THISDIR = Path(__file__).parent

# Per-target Spike ISA string and toolchain bitwidth.
TARGET_CONFIG = {
    "rvsc1-unknown-elf": {"bits": 32, "isa": "rv32i",           "march": "rv32i", "mabi": "ilp32"},
    "rvsc2-unknown-elf": {"bits": 32, "isa": "rv32i",           "march": "rv32i", "mabi": "ilp32"},
    "rvsc3-unknown-elf": {"bits": 32, "isa": "rv32i",           "march": "rv32i", "mabi": "ilp32"},
    "rvsc4-unknown-elf": {"bits": 64, "isa": "rv64i",           "march": "rv64i", "mabi": "lp64"},
    "rvsc5-unknown-elf": {"bits": 64, "isa": "rv64im",          "march": "rv64im","mabi": "lp64"},
    "rvsc6-unknown-elf": {"bits": 64, "isa": "rv64imfd_zicsr",  "march": "rv64imfd_zicsr", "mabi": "lp64d"},
    "rvsc7-unknown-elf": {"bits": 64, "isa": "rv64imafd_zicsr", "march": "rv64imafd_zicsr","mabi": "lp64d"},
}


def riscv_prefix(bits: int) -> str:
    return f"riscv{bits}-none-elf"


def compile_to_asm(gcc: str, src: Path, out: Path) -> tuple[bool, str]:
    r = subprocess.run(
        [gcc, "-S", "-O1", str(src), "-o", str(out)],
        capture_output=True, text=True,
    )
    return r.returncode == 0, r.stderr.strip()


def assemble(gas: str, march: str, mabi: str, src: Path, out: Path) -> tuple[bool, str]:
    r = subprocess.run(
        [gas, f"-march={march}", f"-mabi={mabi}", str(src), "-o", str(out)],
        capture_output=True, text=True,
    )
    return r.returncode == 0, r.stderr.strip()


def link_elf(ld: str, ld_script: Path, objs: list[Path], out: Path) -> tuple[bool, str]:
    r = subprocess.run(
        [ld, "-T", str(ld_script), *[str(o) for o in objs], "-o", str(out)],
        capture_output=True, text=True,
    )
    return r.returncode == 0, r.stderr.strip()


def run_spike(isa: str, elf: Path) -> tuple[bool, str]:
    r = subprocess.run(
        ["spike", f"--isa={isa}", str(elf)],
        capture_output=True, text=True,
        timeout=30,
    )
    return r.returncode == 0, (r.stdout + r.stderr).strip()


def main() -> None:
    if len(sys.argv) != 2:
        sys.exit(f"usage: {sys.argv[0]} <target-triple>")

    target = sys.argv[1]

    if target not in TARGET_CONFIG:
        print(f"SKIP  {target}: no Spike config (sc0 has no jalr; add entry to TARGET_CONFIG to enable)")
        sys.exit(0)

    cfg    = TARGET_CONFIG[target]
    bits   = cfg["bits"]
    isa    = cfg["isa"]
    march  = cfg["march"]
    mabi   = cfg["mabi"]

    custom_gcc = f"{target}-gcc"
    prefix     = riscv_prefix(bits)
    gas        = f"{prefix}-as"
    ld         = f"{prefix}-ld"
    startup    = THISDIR / f"startup{bits}.S"
    ld_script  = THISDIR / f"link{bits}.ld"

    # Preflight checks
    missing = []
    if not shutil.which(custom_gcc):
        missing.append(f"{custom_gcc} not on PATH (build and install first)")
    if not shutil.which(gas):
        missing.append(f"{gas} not on PATH (add riscv{bits}-embedded binutils to nix shell)")
    if not shutil.which(ld):
        missing.append(f"{ld} not on PATH (add riscv{bits}-embedded binutils to nix shell)")
    if not shutil.which("spike"):
        missing.append("spike not on PATH (add spike to nix shell)")
    if missing:
        for m in missing:
            print(f"ERROR  {m}", file=sys.stderr)
        sys.exit(1)

    sources = sorted(THISDIR.glob("behav_*.c"))
    if not sources:
        print(f"No behav_*.c files found in {THISDIR}")
        sys.exit(0)

    print(f"Spike behavioral tests for {target}  [{isa}]")
    print("-" * 50)

    passed = failed = 0

    with tempfile.TemporaryDirectory() as tmpdir:
        tmp = Path(tmpdir)

        # Assemble the startup once per target (it's the same for all tests)
        startup_obj = tmp / f"startup{bits}.o"
        ok, err = assemble(gas, march, mabi, startup, startup_obj)
        if not ok:
            print(f"ERROR  failed to assemble startup{bits}.S: {err}", file=sys.stderr)
            sys.exit(1)

        for src in sources:
            asm     = tmp / (src.stem + ".s")
            obj     = tmp / (src.stem + ".o")
            elf     = tmp / (src.stem + ".elf")

            ok, err = compile_to_asm(custom_gcc, src, asm)
            if not ok:
                print(f"FAIL  {src.name}  (compile error: {err[:120]})")
                failed += 1
                continue

            ok, err = assemble(gas, march, mabi, asm, obj)
            if not ok:
                print(f"FAIL  {src.name}  (assemble error: {err[:120]})")
                failed += 1
                continue

            ok, err = link_elf(ld, ld_script, [startup_obj, obj], elf)
            if not ok:
                print(f"FAIL  {src.name}  (link error: {err[:120]})")
                failed += 1
                continue

            try:
                ok, out = run_spike(isa, elf)
            except subprocess.TimeoutExpired:
                print(f"FAIL  {src.name}  (spike timeout — infinite loop?)")
                failed += 1
                continue

            if ok:
                print(f"PASS  {src.name}")
                passed += 1
            else:
                detail = f"exit {out[:80]}" if out else "non-zero exit"
                print(f"FAIL  {src.name}  ({detail})")
                failed += 1

    print("-" * 50)
    print(f"Results: {passed} passed, {failed} failed")
    sys.exit(0 if failed == 0 else 1)


if __name__ == "__main__":
    main()
