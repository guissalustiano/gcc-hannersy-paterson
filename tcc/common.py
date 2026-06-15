"""Shared utilities for rvscN ISA compliance validation."""

import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

# "   10: 00450513   addi  a0,a0,4"  →  captures "addi"
_INSN_RE = re.compile(r"^\s+[0-9a-f]+:\s+[0-9a-f]+\s+(\S+)", re.MULTILINE)


def find_tool(name: str) -> str:
    path = shutil.which(name)
    if path is None:
        sys.exit(f"error: tool not found on PATH: {name}")
    return path


def _run(*cmd: str) -> subprocess.CompletedProcess:
    return subprocess.run(list(cmd), check=True, capture_output=True, text=True)


def compile_to_asm(compiler: str, src: Path, cflags: list[str]) -> str:
    out = Path(tempfile.mktemp(suffix=".s"))
    try:
        try:
            _run(compiler, "-S", "-O1", "-ffreestanding", *cflags, "-o", str(out), str(src))
        except subprocess.CalledProcessError as e:
            sys.exit(f"compile error ({src.name}):\n{e.stderr.strip()}")
        return out.read_text()
    finally:
        out.unlink(missing_ok=True)


def assemble(assembler: str, march: str, asm_text: str) -> Path:
    s = Path(tempfile.mktemp(suffix=".s"))
    o = Path(tempfile.mktemp(suffix=".o"))
    s.write_text(asm_text)
    try:
        try:
            _run(assembler, f"-march={march}", "-o", str(o), str(s))
        except subprocess.CalledProcessError as e:
            o.unlink(missing_ok=True)
            sys.exit(f"assemble error:\n{e.stderr.strip()}")
    finally:
        s.unlink(missing_ok=True)
    return o


def disassemble_mnemonics(objdump: str, obj: Path) -> list[str]:
    try:
        result = _run(objdump, "-M", "no-aliases", "-d", str(obj))
    except subprocess.CalledProcessError as e:
        sys.exit(f"objdump error:\n{e.stderr.strip()}")
    return _INSN_RE.findall(result.stdout)


def validate_source(
    compiler: str,
    assembler: str,
    objdump: str,
    march: str,
    src: Path,
    allowed: set[str],
    cflags: list[str],
) -> tuple[bool, list[str]]:
    asm = compile_to_asm(compiler, src, cflags)
    obj = assemble(assembler, march, asm)
    try:
        mnemonics = disassemble_mnemonics(objdump, obj)
    finally:
        obj.unlink(missing_ok=True)
    violations = sorted({m for m in mnemonics if m not in allowed})
    return not violations, violations
