# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository layout

Everything lives under `/home/salust/gcc/`:

| Path | Purpose |
|------|---------|
| `gcc/config/riscv/` | RISC-V backend — `riscv.md`, `riscv.opt`, `riscv.cc`, `rvscN.h` headers |
| `scw/` | Build/test workspace — one subdir per target (`sc0`–`sc7`) |
| `scw/sc1/build/` | Out-of-tree build dir for sc1 (configure once, rebuild repeatedly) |
| `scw/sc1/install/` | Installed toolchain (`rvsc1-unknown-elf-gcc`, etc.) |
| `scw/test/` | Test sources, `run_tests.py`, `startup32.S`, `link32.ld` |
| `main.typ` | Typst academic document (TCC at USP/Poli) |

**Source edits happen in `gcc/config/riscv/`.** Build dirs are never edited directly. Files actually modified for this project: `riscv.md`, `riscv.opt`, `riscv.cc` (constant pool hooks), `rvscN.h` headers, `gcc/config/config.gcc`, `gcc/config/config.sub`.

## Targets

Eight progressive RISC-V GCC target triples model the Hennessy-Patterson educational processor:

| Target | Triple | ISA | Notes |
|--------|--------|-----|-------|
| sc0 | `rvsc0-unknown-elf` | rv32i subset: `lw sw beq add addi sub and or` | no `jalr`, `lui`, `auipc`; **no function calls possible** — only single-function programs compile correctly |
| sc1 | `rvsc1-unknown-elf` | sc0 + `jalr lui` | no `auipc`/`fence`/shifts/xor/ori/andi/branches/byte+half loads+stores; all synthesized |
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

Two independent layers verify correctness.

### ISA compliance (`sc1_*.c` tests)

```sh
cd scw/sc1 && just test
# Runs run_tests.py: compiles every .c in scw/test/ with -S -O1,
# assembles with riscv32-none-elf-as, disassembles with
# riscv32-none-elf-objdump -M no-aliases (expands pseudo-instructions),
# and checks every mnemonic against instructions.txt.
```

The `-M no-aliases` flag is essential — it expands pseudos like `ret` to `jalr x0, 0(ra)` before the allowlist check, so forbidden instructions cannot pass disguised as pseudos.

`scw/sc1/instructions.txt` lists every mnemonic the sc1 compiler is allowed to emit. When adding a new synthesis, update this file if new pseudo-mnemonics appear in `-S` output.

### Behavioral tests (`behav_*.c` tests — rvsc1 only)

Each `behav_*.c` program is compiled by both `rvsc1-unknown-elf-gcc -O1` and the reference compiler `riscv32-none-elf-gcc -march=rv32i -O1`, then linked with `startup32.S` (bare-metal HTIF stub) and `link32.ld` and executed on Spike with `--isa=rv32i`. The test passes if both binaries produce the same exit code. Test programs return 0 on success and a distinct nonzero code per failing assertion.

rvsc0 behavioral tests cannot use the HTIF startup (which calls `main` via `jalr`). Instead rvsc0 test programs write the result directly to the `tohost` address via `sw` and spin with `beq x0, x0, .`.

For quick manual checks:

```sh
export PATH=/home/salust/gcc/scw/sc1/build/install/bin:$PATH

# Emit assembly and inspect
rvsc1-unknown-elf-gcc -S -O1 scw/test/sc1_shift.c -o /tmp/out.s

# Verify absence of a native instruction
rvsc1-unknown-elf-gcc -S -O1 scw/test/sc1_srl.c -o - \
  | grep -E '^\s+srl' && echo FAIL || echo PASS
```

## Document

`main.typ` is a Typst academic document (TCC at USP/Poli) — GCC 17.0.0 backend for educational RISC-V processors. Compile with:

```sh
typst compile main.typ
```

Chapter structure:
1. Introduction — motivation (PCS3225 course at USP), objectives, rationale
2. Related Work
3. Conceptual Background — RISC-V ISA, single-cycle processor, C ABI, GCC architecture
4. Development Method — study, requirements, synthesis derivation cycle, validation approach
5. Requirements Specification — allowed instruction sets per target, correctness requirements
6. Development — synthesis derivations (proofs + assembly), GCC implementation, known limitations
7. Results — ISA compliance tests, Spike behavioral differential tests, program size/performance data
8. Conclusion

## GCC backend architecture

The custom targets reuse the upstream RISC-V backend with three layers of configuration:

### 1. Target triple registration

- `gcc/config/config.sub` — normalises `rvscN-*` triples (pattern match, no CPU name needed).
- `gcc/config.gcc` — maps `rvscN-*-elf*` to `cpu_type=riscv`; sets default `--with-arch` and `--with-abi` per target; appends `riscv/rvscN.h` to `tm_file`.

### 2. Per-target header (`gcc/config/riscv/rvscN.h`)

Each header overrides `CC1_SPEC` to inject `-mno-*` flags automatically so users never need to pass them manually:

```c
// sc1 example
#define CC1_SPEC "%{!mfence:-mno-fence} %{!mauipc:-mno-auipc} %{!mshift:-mno-shift}" \
  " %{!mslt:-mno-slt} ..."
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
- **`zero_extendhi<GPR:mode>2` expand** — when `!TARGET_HALF && MEM_P`: synthesizes `lhu` as `addr&-4 → lw word → (addr&2)<<3 → lshr → (<<16)>>16` (logical).
- **`zero_extendqi<SUPERQI:mode>2` expand** — when `!TARGET_BYTE && MEM_P`: synthesizes `lbu` identically but using byte mask `addr&3` and shift of 24.
- **`extend<SHORT:mode><SUPERQI:mode>2` expand** — when `!TARGET_BYTE` (QI) or `!TARGET_HALF` (HI) and MEM_P: synthesizes `lb`/`lh` like the unsigned forms but uses `ashr` for sign extension.
- **`movhi` expand** — when `!TARGET_HALF && MEM_P(operands[0])`: synthesizes `sh` as read-modify-write: `addr&-4 → lw word → (addr&2)<<3 → mask 0xFFFF<<bit_off → word &= ~mask → val&0xFFFF<<bit_off → word |= val → sw`. Uses `gen_lowpart(SImode, force_reg(HImode, src))` for the value; the resulting paradoxical subreg is handled by the `*zero_extendhi<GPR:mode>2` split.
- **`movqi` expand** — when `!TARGET_BYTE && MEM_P(operands[0])`: synthesizes `sb` identically but using byte mask `addr&3` and mask `0xFF`.
- **`define_insn_and_split "*zero_extendhi<GPR:mode>2"`** — split body (post-reload) branches on `TARGET_SHIFT`: if set, uses the original `ashift+lshiftrt` by 16; if not (sc1), loads 0xFFFF into `operands[0]` and emits `and op0, src_SI, op0`. Uses `gen_rtx_REG(<GPR:MODE>mode, REGNO(operands[1]))` to access the physical register without creating a new pseudo (which is forbidden post-reload).
- **`define_insn_and_split "*zero_extendqisi2_noandi"`** — handles `andi rd, rs, 0xff` when `!TARGET_ANDI`; splits after reload as `li rd, 255; and rd, rs, rd` with early-clobber to ensure `rd ≠ rs`.
- **`define_insn "*branch<mode>"`** — bne synthesis: `beq a,b,skip; lui t1,%hi(L); addi t1,t1,%lo(L); jr t1; skip:`.
- **`define_insn "jump"`** — unconditional jump synthesis when `!TARGET_AUIPC`: `lui t1,%hi(L); addi t1,t1,%lo(L); jr t1` (needed for back-edges in synthesized loops).
- **`one_cmplsi2` (not)** — when `!TARGET_XOR`: `sub rd, x0, rs; addi rd, rd, -1` (identity `~x = −x − 1`).
- **LUI synthesis (rvsc0)** — `lui` is native in sc1+; for rvsc0 it is synthesized via constant pool: the 32-bit value is stored in `.rodata` at link time and loaded with `lw rd, pool_entry(x0)`. This requires the pool to live within 12-bit signed range of x0 (address < 2048), which the rvsc0 linker script guarantees. The constant pool target hook lives in `riscv.cc`.
- **JAL synthesis (rvsc1)** — `jal ra, target` synthesized as: `lui ra, %hi(back); addi ra, ra, %lo(back); lui t0, %hi(target); addi t0, t0, %lo(target); jalr x0, 0(t0); back:`. Cost: 5 instructions, 1 extra register. `auipc` is absent in sc1, so the return address is materialized as an absolute label.
- **`cstore<GPR:mode>4` expand** — when `TARGET_SLT && !TARGET_SLTI && CONST_INT_P(operands[3])`: calls `force_reg` to load the immediate into a register before `riscv_expand_int_scc`, preventing `slti`/`sltiu` emission. When `!TARGET_SLT && SImode`: synthesizes all ordered comparisons (LT, LTU, GE, GEU, GT, GTU, LE, LEU) before calling `riscv_expand_int_scc`. GT/LE/GTU/LEU are reduced to LT/LTU by swapping operands; GE/GEU/LE/LEU invert the result using `sub rd, one, result` (avoids XOR→zero_extract→ashift split that fails with `!TARGET_SHIFT`). `slt` synthesis: `sub diff, a, b; xor t1, a, b; xor t2, a, diff; and t1, t1, t2; xor diff, diff, t1; lshr rd, diff, 31`. `sltu` synthesis: `sub diff, a, b; not t1, a; and t2, t1, b; xor t3, a, b; not t3, t3; and t3, t3, diff; or t2, t2, t3; lshr rd, t2, 31`.
- **`@cbranch<mode>4` expand** — when `!TARGET_SLT && SImode && code ≠ EQ/NE`: emits the same slt/sltu synthesis into a temp register, then calls `riscv_expand_conditional_branch` with `NE` (for LT/LTU/GT/GTU) or `EQ` (for GE/GEU/LE/LEU) so the branch tests `tmp != 0` or `tmp == 0`. This intercepts before `*branch<mode>` so its raw `"slt\t..."` asm templates are never reached with `!TARGET_SLT`.

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
| `-mslt` | `TARGET_SLT` | `slt`/`sltu` → synthesized via sub/xor/and/lshr; `blt`/`bge`/`bltu`/`bgeu` branches use synthesized comparison + `beq`/`bne` |
| `-mslti` | `TARGET_SLTI` | `slti`/`sltiu` → `li t, imm; slt/sltu rd, rs, t` (fires only when `TARGET_SLT && !TARGET_SLTI`; when `!TARGET_SLT`, immediates are handled by the full synthesis path) |
| `-mblt` | `TARGET_BLT` | `blt` → synthesized comparison+`beq+jump` (when `TARGET_SLT`: `slt+beq+jump`) |
| `-mbge` | `TARGET_BGE` | `bge` → synthesized comparison+`beq` (when `TARGET_SLT`: `slt+beq`) |
| `-mbltu` | `TARGET_BLTU` | `bltu` → synthesized comparison+`beq+jump` (when `TARGET_SLT`: `sltu+beq+jump`) |
| `-mbgeu` | `TARGET_BGEU` | `bgeu` → synthesized comparison+`beq` (when `TARGET_SLT`: `sltu+beq`) |
| `-mbyte` | `TARGET_BYTE` | `lb`/`lbu` → `lw`+align+extract; `sb` → `lw`+clear+insert+`sw`; `-mno-byte` synthesizes all via `lw`+shift |
| `-mhalf` | `TARGET_HALF` | `lh`/`lhu` → `lw`+align+extract; `sh` → `lw`+clear+insert+`sw`; `-mno-half` synthesizes all via `lw`+shift |

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
| Logical right shift | `emit_insn (gen_lshrsi3 (rd, rs, cnt))` |
| Arithmetic right shift | `emit_insn (gen_ashrsi3 (rd, rs, cnt))` |
| Left shift | `emit_insn (gen_ashlsi3 (rd, rs, cnt))` |
| Load from pointer in reg | `emit_move_insn (dst, gen_rtx_MEM (SImode, ptr_reg))` |
| Get address from MEM | `XEXP (operands[1], 0)` — raw address RTL (pass to `force_reg`) |
