#!/usr/bin/env python3
"""run_tests.py <target-triple> <instructions-file>

For every .c file in the test directory:
  Compile with -S -O1, assemble with riscvN-none-elf-as, disassemble with
  riscvN-none-elf-objdump -M no-aliases, and verify every real opcode in the
  binary is listed in <instructions-file>.

Exits non-zero if the GNU RISC-V binutils tools are not on PATH or if
<instructions-file> does not exist.
"""

import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

SRCDIR = Path(__file__).parent


def riscv_prefix(target: str) -> str:
    m = re.search(r"rvsc(\d+)", target)
    return "riscv64-none-elf" if m and int(m.group(1)) >= 4 else "riscv32-none-elf"


def compile_to_asm(gcc: str, src: Path, out: Path) -> bool:
    r = subprocess.run([gcc, "-S", "-O1", str(src), "-o", str(out)],
                       capture_output=True, text=True)
    return r.returncode == 0


def assemble(gas: str, asm_path: Path, obj_path: Path) -> bool:
    r = subprocess.run([gas, str(asm_path), "-o", str(obj_path)],
                       capture_output=True, text=True)
    return r.returncode == 0


def extract_opcodes(objdump: str, obj_path: Path) -> set[str]:
    """Return the set of real opcodes from the disassembly (-M no-aliases expands pseudos)."""
    r = subprocess.run(
        [objdump, "-d", "-M", "no-aliases", str(obj_path)],
        capture_output=True, text=True,
    )
    opcodes: set[str] = set()
    for line in r.stdout.splitlines():
        if not re.match(r"^\s+[0-9a-f]+:", line):
            continue
        # GNU objdump format: "   addr:\thex          \topcode\toperands"
        parts = line.split("\t")
        if len(parts) >= 3:
            mnemonic = parts[2].strip()
            if re.match(r"^[a-zA-Z][a-zA-Z0-9.]*$", mnemonic):
                opcodes.add(mnemonic)
    return opcodes


def load_allowed(path: Path) -> set[str]:
    allowed: set[str] = set()
    for line in path.read_text().splitlines():
        word = line.split("#")[0].strip()
        if word:
            allowed.add(word)
    return allowed


def main() -> None:
    if len(sys.argv) != 3:
        sys.exit(f"usage: {sys.argv[0]} <target-triple> <instructions-file>")

    target, instructions_path = sys.argv[1], Path(sys.argv[2])
    gcc = f"{target}-gcc"
    prefix = riscv_prefix(target)
    gas = f"{prefix}-as"
    objdump_bin = f"{prefix}-objdump"

    if not shutil.which(gcc):
        print(f"SKIP  {target}: {gcc} not on PATH (build and install first)")
        sys.exit(0)

    errors = []
    if not shutil.which(gas):
        errors.append(f"{gas} not on PATH (add {prefix} binutils to your nix shell)")
    if not shutil.which(objdump_bin):
        errors.append(f"{objdump_bin} not on PATH (add {prefix} binutils to your nix shell)")
    if not instructions_path.exists():
        errors.append(f"{instructions_path} not found")
    if errors:
        for e in errors:
            print(f"ERROR  {e}", file=sys.stderr)
        sys.exit(1)

    allowed = load_allowed(instructions_path)
    sources = sorted(SRCDIR.glob("*.c"))

    print(f"Testing {target}")
    print("-" * 40)

    passed = failed = 0

    with tempfile.TemporaryDirectory() as tmpdir:
        tmp = Path(tmpdir)
        for src in sources:
            asm_path = tmp / (src.stem + ".s")
            obj_path = tmp / (src.stem + ".o")

            if not compile_to_asm(gcc, src, asm_path):
                print(f"FAIL  {src.name}  (compile error)")
                failed += 1
                continue

            if not assemble(gas, asm_path, obj_path):
                print(f"FAIL  {src.name}  (assemble error)")
                failed += 1
                continue

            unexpected = extract_opcodes(objdump_bin, obj_path) - allowed
            if unexpected:
                print(f"FAIL  {src.name}  unexpected: {', '.join(sorted(unexpected))}")
                failed += 1
            else:
                print(f"PASS  {src.name}")
                passed += 1

    print("-" * 40)
    print(f"Results: {passed} passed, {failed} failed")
    sys.exit(0 if failed == 0 else 1)


if __name__ == "__main__":
    main()
