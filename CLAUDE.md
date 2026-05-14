# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository layout

Everything lives under `/home/salust/gcc/`:

| Path | Purpose |
|------|---------|
| `gcc/config/riscv/` | RISC-V backend — `riscv.md`, `riscv.opt`, `rvscN.h` headers |
| `scw/` | Build/test workspace — one subdir per target (`sc0`–`sc7`) |
| `scw/sc1/build/` | Out-of-tree build dir for sc1 (configure once, rebuild repeatedly) |
| `scw/sc1/install/` | Installed toolchain (`rvsc1-unknown-elf-gcc`, etc.) |
| `scw/test/` | Test sources and `run_tests.py` |
| `main.typ` | Typst academic document (TCC at USP/Poli) |

**Source edits happen in `gcc/config/riscv/`.** Build dirs are never edited directly.

## Targets

Eight progressive RISC-V GCC target triples model the Hennessy-Patterson educational processor:

| Target | Triple | ISA | Notes |
|--------|--------|-----|-------|
| sc0 | `rvsc0-unknown-elf` | rv32i subset: `lw sw beq add addi sub and or` | no `jalr`, `lui`, `auipc` |
| sc1 | `rvsc1-unknown-elf` | sc0 + `jalr lui` | no `auipc`/`fence`/shifts/xor/ori/andi; all synthesized |
| sc2 | `rvsc2-unknown-elf` | rv32i − `fence` | full control flow |
| sc3 | `rvsc3-unknown-elf` | rv32i | first target with `fence` |
| sc4 | `rvsc4-unknown-elf` | rv64i | 64-bit |
| sc5 | `rvsc5-unknown-elf` | rv64im | multiply/divide |
| sc6 | `rvsc6-unknown-elf` | rv64imfd_zicsr | floating point |
| sc7 | `rvsc7-unknown-elf` | rv64imafd_zicsr | atomics |

## Build workflow

Each target has its own subdirectory under `scw/` with a `justfile`. Configure once, then iterate — **no binutils build is needed**.

```sh
# First-time configure for sc1
cd scw/sc1 && just configure

# Build and install (repeat after source changes)
cd scw/sc1 && just build install

# Or explicitly with make
cd scw/sc1/build && make all-gcc -j$(nproc) && make install-gcc
```

Replace `sc1` with the desired target number throughout.

## Testing

```sh
cd scw/sc1 && just test
# Runs run_tests.py: compiles every .c in scw/test/ with -S -O1
# and verifies all emitted mnemonics appear in instructions.txt.
```

For quick manual checks:

```sh
export PATH=/home/salust/gcc/scw/sc1/build/install/bin:$PATH

# Emit assembly and inspect
rvsc1-unknown-elf-gcc -S -O1 scw/test/sc1_shift.c -o /tmp/out.s

# Verify absence of a native instruction
rvsc1-unknown-elf-gcc -S -O1 scw/test/sc1_srl.c -o - \
  | grep -E '^\s+srl' && echo FAIL || echo PASS
```

`scw/sc1/instructions.txt` lists every mnemonic the sc1 compiler is allowed to emit.
When adding a new synthesis, update this file if new pseudo-instructions appear in `-S` output.

## Document

`main.typ` is a Typst academic document (TCC at USP/Poli) describing each target's ISA, implementation, and test results. Compile with:

```sh
typst compile main.typ
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

- **`define_expand "<optab>si3"`** — handles all shift types via the `any_shift` code iterator. `(<CODE>) == ASHIFT/LSHIFTRT/ASHIFTRT` are compile-time constants, so all three shift syntheses live in the same expand body with `if ((<CODE>) == ...)` guards. Never add a duplicate `define_expand` with the same name.
  - `ASHIFT` const (sc1): N repeated `add rd, rd, rd` instructions.
  - `ASHIFT` variable (sc1): count-down loop of `add rd, rd, rd`.
  - `LSHIFTRT` (sc1): loop-based bit extraction via `and`/`or`/`add`/`beq`; a sub-loop computes `in_mask = 1 << shamt`.
  - `ASHIFTRT` (sc1): same srl loop inlined, then if sign bit was set, OR in `sign_mask = -1 << (32 − shift)`.
- **`define_expand "<optab>si3"` (logic)** — `and3`/`ior3`/`xor3` share one expand with `(<CODE>) ==` guards:
  - `XOR` (sc1): De Morgan — `~(a & b) & (a | b)`.
  - `IOR` immediate (sc1): `li t, imm; or rd, rs, t`.
  - `AND` immediate (sc1): `li t, imm; and rd, rs, t`.
- **`define_insn_and_split "*zero_extendqisi2_noandi"`** — handles `andi rd, rs, 0xff` when `!TARGET_ANDI`; splits after reload as `li rd, 255; and rd, rs, rd` with early-clobber to ensure `rd ≠ rs`.
- **`define_insn "*branch<mode>"`** — bne synthesis: `beq a,b,skip; lui t1,%hi(L); addi t1,t1,%lo(L); jr t1; skip:`.
- **`define_insn "jump"`** — unconditional jump synthesis when `!TARGET_AUIPC`: `lui t1,%hi(L); addi t1,t1,%lo(L); jr t1` (needed for back-edges in synthesized loops).
- **`one_cmplsi2` (not)** — when `!TARGET_XOR`: `sub rd, x0, rs; addi rd, rd, -1` (identity `~x = −x − 1`).

### 4. Target options (`gcc/config/riscv/riscv.opt`)

Custom boolean flags added for this project:

| Flag | Variable | Effect when 0 |
|------|----------|----------------|
| `-mfence` | `TARGET_FENCE` | `fence`/`fence.i` expands are no-ops |
| `-mauipc` | `TARGET_AUIPC` | PC-relative → absolute `lui+lo12`; calls → `lui+jalr` |
| `-mshift` | `TARGET_SHIFT` | native `sll`/`srl`/`sra` gated off; synthesis in expand |
| `-mxor` | `TARGET_XOR` | `xor` → De Morgan; `not`/`xori rd,rs,-1` → `sub+addi` |
| `-mori` | `TARGET_ORI` | `ori` → `li t, imm; or` |
| `-mandi` | `TARGET_ANDI` | `andi` → `li t, imm; and`; zero-extend byte handled by special split |
| `-mbne` | `TARGET_BNE` | `bne` → `beq+skip+lui+addi+jr` |

All have `Init(1)` (enabled by default); the `rvscN.h` header disables the appropriate flags via `CC1_SPEC`.

## Key invariants

- Never add synthesis code in a new `define_expand` with the same `<optab>` name — the iterator already generates e.g. `ashlsi3`. Put synthesis inside the existing expand body using `(<CODE>) == ASHIFT` guards.
- The `define_insn` condition (`"TARGET_SHIFT"`) and the `define_expand` synthesis path (`!TARGET_SHIFT`) must stay in sync — if synthesis fires and emits `DONE`, GCC never tries to match the insn.
- After editing `riscv.md` or `riscv.opt`, rebuild **all** target build dirs that share the same backend (`sc1`–`sc7`) before running cross-target sanity checks.

## Adding a new sc1 synthesis

1. **Add the flag** to `gcc/config/riscv/riscv.opt`:
   ```
   mfoo
   Target Var(TARGET_FOO) Init(1)
   Enable foo instruction (-mno-foo synthesizes via ...).
   ```

2. **Disable by default** in `gcc/config/riscv/rvsc1.h` `CC1_SPEC`:
   ```c
   #define CC1_SPEC "... %{!mfoo:-mno-foo}"
   ```

3. **Add the synthesis** inside the relevant `define_expand` in `riscv.md`, guarded by `!TARGET_FOO`. Call `DONE` at the end to prevent GCC from falling through to the native insn match.

4. **Gate the native insn** — add `&& TARGET_FOO` to the condition string of the corresponding `define_insn` so it is never selected when synthesis is active.

5. **Write a test** in `scw/test/sc1_foo.c` and add any new pseudo-mnemonics to `scw/sc1/instructions.txt`.

6. **Rebuild and test**:
   ```sh
   cd scw/sc1 && just build install test
   ```

### Emit helpers in riscv.md expand bodies

| Goal | RTL helper |
|------|-----------|
| Move a register | `emit_move_insn (dst, src)` |
| Load a small constant | `emit_move_insn (dst, GEN_INT (n))` or `const0_rtx` / `const1_rtx` / `constm1_rtx` |
| Load any 32-bit constant | `emit_move_insn (dst, gen_int_mode (val, SImode))` |
| `add rd, rs1, rs2` | `emit_insn (gen_addsi3 (rd, rs1, rs2))` |
| `and rd, rs1, rs2` | `emit_insn (gen_andsi3 (rd, rs1, rs2))` |
| `or  rd, rs1, rs2` | `emit_insn (gen_iorsi3 (rd, rs1, rs2))` |
| `sub rd, rs1, rs2` | `emit_insn (gen_subsi3 (rd, rs1, rs2))` |
| Conditional branch | `emit_cmp_and_jump_insns (a, b, EQ/NE, NULL_RTX, SImode, 0, label, profile_probability::uninitialized ())` |
| Unconditional branch | `emit_jump_insn (gen_jump (label)); emit_barrier ()` |
| Define a label target | `rtx lbl = gen_label_rtx (); ... emit_label (lbl)` |
| Allocate a temp reg | `rtx t = gen_reg_rtx (SImode)` |
| Force QI operand to SI | `gen_lowpart (SImode, operands[2])` (needed for shift count) |
