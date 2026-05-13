#!/usr/bin/env python3
"""run_tests.py <target-triple> <instructions-file>

Compiles every .c in the sc-test directory with -S -O1 and verifies that
all emitted instruction mnemonics appear in the target's allowed list.
"""

import re
import shutil
import subprocess
import sys
from pathlib import Path

SRCDIR = Path(__file__).parent


def compile_to_asm(gcc: str, src: Path) -> str | None:
    result = subprocess.run(
        [gcc, "-S", "-O1", str(src), "-o", "-"],
        capture_output=True, text=True,
    )
    return result.stdout if result.returncode == 0 else None


def extract_mnemonics(asm: str) -> set[str]:
    mnemonics = set()
    for line in asm.splitlines():
        m = re.match(r"^\s+([a-zA-Z][a-zA-Z0-9.]*)", line)
        if m:
            mnemonics.add(m.group(1))
    return mnemonics


def load_allowed(path: Path) -> set[str]:
    allowed = set()
    for line in path.read_text().splitlines():
        word = line.split("#")[0].strip()
        if word:
            allowed.add(word)
    return allowed


def main():
    if len(sys.argv) != 3:
        sys.exit(f"usage: {sys.argv[0]} <target-triple> <instructions-file>")

    target, instructions_path = sys.argv[1], Path(sys.argv[2])
    gcc = f"{target}-gcc"

    if not shutil.which(gcc):
        print(f"SKIP  {target}: {gcc} not on PATH (build and install first)")
        sys.exit(0)

    allowed = load_allowed(instructions_path)
    sources = sorted(SRCDIR.glob("*.c"))

    print(f"Testing {target}")
    print("-" * 40)

    passed, failed = 0, 0
    for src in sources:
        asm = compile_to_asm(gcc, src)
        if asm is None:
            print(f"FAIL  {src.name}  (compile error)")
            failed += 1
            continue

        unexpected = extract_mnemonics(asm) - allowed
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
