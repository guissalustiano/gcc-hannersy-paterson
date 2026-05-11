# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository layout

This project lives across two sibling directories:

| Path | Purpose |
|------|---------|
| `/home/salust/p/gcc/` | GCC fork — source, `main.typ` document, `sc-test/` |
| `/home/salust/p/build-rv-sc{1-7}/` | Out-of-tree build dirs, one per target |
| `/home/salust/p/gcc-hannersy-paterson/` | Claude working directory (this CLAUDE.md) |

**All source edits happen inside `/home/salust/p/gcc/`.**  The build dirs are never edited directly.

## Targets

Eight progressive RISC-V GCC target triples model the Hennessy-Patterson educational processor:

| Target | Triple | ISA | Notes |
|--------|--------|-----|-------|
| sc0 | `rvsc0-unknown-elf` | rv32i subset: `lw sw beq add addi sub and or` | no `jalr`, `lui`, `auipc` |
| sc1 | `rvsc1-unknown-elf` | sc0 + `jalr lui` | no `auipc`, no `fence`, no shifts; synthesizes `bne`, `sll` (const), `srl` (loop) |
| sc2 | `rvsc2-unknown-elf` | rv32i − `fence` | full control flow |
| sc3 | `rvsc3-unknown-elf` | rv32i | first target with `fence` |
| sc4 | `rvsc4-unknown-elf` | rv64i | 64-bit |
| sc5 | `rvsc5-unknown-elf` | rv64im | multiply/divide |
| sc6 | `rvsc6-unknown-elf` | rv64imfd_zicsr | floating point |
| sc7 | `rvsc7-unknown-elf` | rv64imafd_zicsr | atomics |

## Build workflow

Each target has its own build directory. Configure once, then iterate with `make all-gcc && make install-gcc` — **no binutils build is needed**.

```sh
# First-time configure for sc1
cd /home/salust/p/build-rv-sc1
../gcc/configure \
    --target=rvsc1-unknown-elf \
    --prefix=$(pwd)/install \
    --enable-languages=c \
    --with-newlib

# Build and install (repeat after source changes)
make all-gcc -j$(nproc) && make install-gcc
```

Replace `sc1` / `rvsc1` with the desired target number throughout.

## Testing

```sh
export PATH=/home/salust/p/build-rv-sc1/install/bin:$PATH

# Emit assembly and inspect
rvsc1-unknown-elf-gcc -S -O1 /home/salust/p/gcc/sc-test/sc1_shift.c -o /tmp/out.s
cat /tmp/out.s

# Verify absence of a native instruction (e.g., srl must not appear in sc1)
rvsc1-unknown-elf-gcc -S -O1 /home/salust/p/gcc/sc-test/sc1_srl.c -o - \
  | grep -E '^\s+srl' && echo FAIL || echo PASS

# Verify sc2 still uses native instruction
rvsc2-unknown-elf-gcc -S -O1 /home/salust/p/gcc/sc-test/sc1_srl.c -o - \
  | grep -E '^\s+srli\b' && echo PASS || echo FAIL
```

Test sources live in `/home/salust/p/gcc/sc-test/`.

## Document

`/home/salust/p/gcc/main.typ` is a Typst academic document (TCC at USP/Poli) describing each target's ISA, implementation, and test results. Compile with:

```sh
typst compile /home/salust/p/gcc/main.typ
```

## GCC backend architecture

The custom targets reuse the upstream RISC-V backend with three layers of configuration:

### 1. Target triple registration

- `gcc/config/config.sub` — normalises `rvscN-*` triples (pattern match, no CPU name needed).
- `gcc/config.gcc` — maps `rvscN-*-elf*` to `cpu_type=riscv`; sets default `--with-arch` and `--with-abi` per target; appends `riscv/rvscN.h` to `tm_file`.

### 2. Per-target header (`gcc/config/riscv/rvscN.h`)

Each header overrides `CC1_SPEC` to inject `-mno-*` flags automatically so users never need to pass them manually:

```c
// sc1 example
#define CC1_SPEC "%{!mfence:-mno-fence} %{!mauipc:-mno-auipc} %{!mshift:-mno-shift}"
```

### 3. Machine Description (`gcc/config/riscv/riscv.md`)

The core of all instruction synthesis. Key patterns:

- **`define_expand "<optab>si3"`** — handles all shift types via the `any_shift` code iterator. `(<CODE>) == ASHIFT/LSHIFTRT` are compile-time constants, so synthesis is selected per-code without duplicate pattern names.
  - sll synthesis (sc1): constant shift → N repeated `add` instructions (doubling).
  - srl synthesis (sc1): loop-based bit extraction using only `and`/`or`/`add`/`beq`; for variable shamt, a sub-loop computes `in_mask = 1 << shamt` via repeated `add`.
- **`define_insn "*<optab>si3"`** — guarded by `"TARGET_SHIFT"`; never reached for sc1 because the expand emits `DONE` first.
- **`define_insn "*branch<mode>"`** — bne synthesis: `beq a,b,skip; lui t1,%hi(L); addi t1,t1,%lo(L); jr t1; skip:`.
- **`define_insn "jump"`** — unconditional jump synthesis when `!TARGET_AUIPC`: `lui t1,%hi(L); addi t1,t1,%lo(L); jr t1` (needed for back-edges in synthesized loops).

### 4. Target options (`gcc/config/riscv/riscv.opt`)

Custom boolean flags added for this project:

| Flag | Variable | Effect when 0 |
|------|----------|----------------|
| `-mfence` | `TARGET_FENCE` | fence expand is a no-op |
| `-mauipc` | `TARGET_AUIPC` | PC-relative → absolute `lui+lo12`; calls → `lui+jalr` |
| `-mshift` | `TARGET_SHIFT` | native shift insns gated off; synthesis in expand |

All have `Init(1)` (enabled by default); disabled by `CC1_SPEC` in `rvscN.h`.

## Key invariants

- Never add synthesis code in a new `define_expand` with the same `<optab>` name — the iterator already generates e.g. `ashlsi3`. Put synthesis inside the existing expand body using `(<CODE>) == ASHIFT` guards.
- The `define_insn` condition (`"TARGET_SHIFT"`) and the `define_expand` synthesis path (`!TARGET_SHIFT`) must stay in sync — if synthesis fires and emits `DONE`, GCC never tries to match the insn.
- After editing `riscv.md` or `riscv.opt`, rebuild **all** target build dirs that share the same backend (`sc1`–`sc7`) before running cross-target sanity checks.
