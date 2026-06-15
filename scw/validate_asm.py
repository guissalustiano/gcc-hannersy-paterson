#!/usr/bin/env python3
"""
validate_asm.py — ISA compliance checker for rvscN GCC targets.

Compiles a C source with the target GCC, assembles it, disassembles with
-M no-aliases to expand pseudo-instructions, then verifies that every
mnemonic appears in the target's allowlist.

Usage:
    validate_asm.py sc1 path/to/test.c
    validate_asm.py sc1 path/to/test.c --compiler /path/to/rvsc1-unknown-elf-gcc
    validate_asm.py sc1 path/to/test.c --allowlist path/to/instructions.txt
    validate_asm.py sc1 path/to/test.c --cflag -O2

Exit: 0 on PASS, 1 on FAIL or error.
"""

import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent

# rv32 for sc0–sc2; sc3+ are out of scope for synthesis testing.
TARGET_BITS = {"sc0": 32, "sc1": 32, "sc2": 32}

# Objdump line: "   10: 00450513   addi  a0,a0,4"
# Capture the mnemonic (first token after the hex encoding column).
_INSN_RE = re.compile(r"^\s+[0-9a-f]+:\s+[0-9a-f]+\s+(\S+)", re.MULTILINE)


def find_tool(name: str) -> str:
    path = shutil.which(name)
    if path is None:
        sys.exit(f"error: tool not found on PATH: {name}")
    return path


def run(*cmd: str, **kwargs) -> subprocess.CompletedProcess:
    return subprocess.run(list(cmd), check=True, capture_output=True, text=True, **kwargs)


def compile_to_asm(gcc: str, src: Path, extra_flags: list[str]) -> str:
    with tempfile.NamedTemporaryFile(suffix=".s", delete=False) as f:
        out = f.name
    try:
        run(gcc, "-S", "-O1", "-ffreestanding", *extra_flags, "-o", out, str(src))
        return Path(out).read_text()
    except subprocess.CalledProcessError as e:
        sys.exit(f"compile error:\n{e.stderr.strip()}")
    finally:
        Path(out).unlink(missing_ok=True)


def assemble(as_: str, march: str, asm_text: str) -> Path:
    s = tempfile.NamedTemporaryFile(suffix=".s", delete=False)
    s.write(asm_text.encode())
    s.close()
    o = tempfile.NamedTemporaryFile(suffix=".o", delete=False)
    o.close()
    try:
        run(as_, f"-march={march}", "-o", o.name, s.name)
    except subprocess.CalledProcessError as e:
        Path(s.name).unlink(missing_ok=True)
        Path(o.name).unlink(missing_ok=True)
        sys.exit(f"assemble error:\n{e.stderr.strip()}")
    Path(s.name).unlink(missing_ok=True)
    return Path(o.name)


def disassemble_mnemonics(objdump: str, obj: Path) -> list[str]:
    try:
        result = run(objdump, "-M", "no-aliases", "-d", str(obj))
    except subprocess.CalledProcessError as e:
        sys.exit(f"objdump error:\n{e.stderr.strip()}")
    return _INSN_RE.findall(result.stdout)


def load_allowlist(path: Path) -> set[str]:
    if not path.exists():
        sys.exit(f"error: allowlist not found: {path}")
    return {
        line.strip()
        for line in path.read_text().splitlines()
        if line.strip() and not line.startswith("#")
    }


def main() -> None:
    parser = argparse.ArgumentParser(
        description="ISA compliance checker for rvscN GCC targets"
    )
    parser.add_argument("target", choices=sorted(TARGET_BITS), help="Target: sc0, sc1, sc2")
    parser.add_argument("source", type=Path, help="C source file")
    parser.add_argument("--compiler", help="GCC binary (default: rvscN-unknown-elf-gcc on PATH)")
    parser.add_argument("--allowlist", type=Path, help="Allowed-mnemonics file (default: <target>/instructions.txt)")
    parser.add_argument("--cflag", dest="cflags", action="append", default=[], metavar="FLAG", help="Extra compiler flag (repeatable)")
    args = parser.parse_args()

    bits = TARGET_BITS[args.target]
    binutils = f"riscv{bits}-none-elf"
    march = f"rv{bits}i"

    gcc     = args.compiler or find_tool(f"rv{args.target}-unknown-elf-gcc")
    as_     = find_tool(f"{binutils}-as")
    objdump = find_tool(f"{binutils}-objdump")

    allowlist_path = args.allowlist or (SCRIPT_DIR / args.target / "instructions.txt")
    allowed = load_allowlist(allowlist_path)

    label = f"{args.target}  {args.source.name}"
    print(f"[ compile ]  {label}")
    asm_text = compile_to_asm(gcc, args.source, args.cflags)

    print(f"[ assemble ] {label}")
    obj = assemble(as_, march, asm_text)

    print(f"[ check ]    {label}")
    mnemonics = disassemble_mnemonics(objdump, obj)
    obj.unlink(missing_ok=True)

    violations = sorted({m for m in mnemonics if m not in allowed})
    if violations:
        print(f"FAIL  {label}")
        for v in violations:
            print(f"  forbidden: {v}")
        sys.exit(1)
    else:
        print(f"PASS  {label}")


if __name__ == "__main__":
    main()
