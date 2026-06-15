#let instituicao = [Universidade de São Paulo \ Escola Politécnica]
#let autor = "Guilherme Stabach Salustiano"
#let titulo = "GCC target for educational RISC-V processor"
#let local = "São Paulo"
#let data = "2026"
#let orientador = "Bruno de Carvalho Albertini"
#let programa = [Departamento de Engenharia de Computação e Sistemas Digitais (PCS)]

#set text(lang: "pt", region: "BR")

// --- Page Configuration [cite: 2775, 2779] ---
// A4 Paper, Margins: Top/Left 3cm, Bottom/Right 2cm (Mirrored for two-sided)
#set page(
  paper: "a4",
  margin: (inside: 3cm, outside: 2cm, top: 3cm, bottom: 2cm),
  numbering: "1",
)

// --- Text Configuration [cite: 2783, 2795] ---
// Arial (or similar sans-serif), Size 12, Justified, 1.5 Line Spacing
#set text(font: "Liberation Sans", size: 12pt, lang: "pt")
#set par(justify: true, leading: 1.5em, first-line-indent: 1.3cm)

// --- Headings Configuration [cite: 2695, 2788] ---
#set heading(numbering: "1.1")
#show heading: it => {
  // Spacing around headings (1.5 lines = approx 1.5em)
  pad(top: 1.5em, bottom: 1.5em, it)
}

// Chapter titles (Level 1) start on new odd pages (open right) [cite: 2694]
#show heading.where(level: 1): it => {
  pagebreak(weak: true, to: "odd")
  v(1.5em) // Space at top of mancha
  text(size: 12pt, weight: "bold", upper(it))
}

// --- Cover Page (Capa) [cite: 2163, 2795] ---
#{
  set page(numbering: none)
  align(center)[
    #text(weight: "bold")[#instituicao]
    #v(1fr)
    #text(weight: "bold")[#autor]
    #v(1fr)
    #text(weight: "bold", size: 14pt)[#titulo]
    #v(1fr)
    #v(1fr)
    #local \ #data
  ]
}


// --- Half-Title Page (Falsa Folha de Rosto) [cite: 2215] ---
#pagebreak()
#{
  set page(numbering: none)
  align(center)[
    #text(weight: "bold")[#autor]
    #v(1fr)
    #text(weight: "bold", size: 14pt)[#titulo]
    #v(1fr)
    #v(1fr)
  ]
}


// --- Title Page (Folha de Rosto) [cite: 2221, 2795] ---
  // --- Title Page (Folha de Rosto) [cite: 2221, 2795] ---
#pagebreak()
#{
  set page(numbering: none)
  align(center)[
    #text(weight: "bold")[#autor]
    #v(1fr)
    #text(weight: "bold", size: 14pt)[#titulo]
    #v(2cm)
  ]

  // Preamble aligned from middle to right [cite: 2790]
  grid(
    columns: (1fr, 1fr),
    [],
    align(left)[
      #set text(size: 12pt, weight: "regular")
      #set par(leading: 0.65em) // Single spacing for preamble
      Trabalho de conclusão de curso apresentado ao Departamento de Engenharia de Computação e Sistemas Digitais da Escola Politécnica da Universidade de São Paulo para obtenção do Título de Engenheiro.
      \ \
      Orientador: #orientador
    ]
  )

  v(1fr)
  align(center)[#local \ #data]
}

// --- Catalog Card (Ficha Catalográfica) [cite: 2263] ---
// Typically verso of title page
#pagebreak()
#{

  align(bottom + center)[
    #rect(width: 12.5cm, height: 7.5cm, stroke: 1pt)[
      #set text(size: 10pt)
      #set par(leading: 0.65em)
      #align(center)[Ficha Catalográfica]
      \
      #align(left)[
        #autor \
        #h(0.5cm) #titulo / #autor -- #local, #data. \
        #h(0.5cm) #context {
  counter(page).final().first()
} p. \ \
        #h(0.5cm) Trabalho de Formatura - Escola Politécnica da Universidade de São Paulo. Departamento de Engenharia de Computação e Sistemas Digitais \ \
        #h(0.5cm) 1. TODO
      ]
    ]
  ]
}

  // --- Approval Sheet (Folha de Aprovação) [cite: 3765] ---
  #pagebreak()
  #{
     align(center)[
      #text(weight: "bold")[#autor]
      #v(1fr)
      #text(weight: "bold", size: 14pt)[#titulo]
    ]
    v(1cm)
    align(right)[
      #block(width: 50%)[
        #set par(leading: 0.65em)
        Trabalho de Formatura - Escola Politécnica da Universidade de São Paulo. Departamento de Engenharia de Computação e Sistemas Digitais
      ]
    ]
    v(1cm)
    text("Aprovado em: ____/____/______")
    v(1cm)

    align(center)[
      #set par(leading: 0.65em)
      #line(length: 60%) \ #orientador (Orientador) \ PCS - USP
      #v(1cm)
      #line(length: 60%) \ Professor Convidado 1 \ PCS - USP
      #v(1cm)
      #line(length: 60%) \ Professor Convidado 2 \ PCS - USP
    ]
    v(1fr)
  }

// --- Dedicatória ---
#pagebreak()
#v(1fr)
#align(right)[
  #block(width: 60%)[
    #set text(style: "italic")
    Para que serve tantos codigos, se a vida nao é programada e as melhores coisas não tem logica.
  ]
]
// TODO

// --- Acknowledgements ---
#heading(level: 1, numbering: none, outlined: false)[Acknowledgements]

// TODO: fill acknowledgements
The main acknowledgements are directed to ...

// --- Resumo ---
#heading(level: 1, numbering: none, outlined: false)[Resumo]

// TODO: escrever o resumo em português

*Palavras-chave*: GCC. RISC-V. Compilador. Processador educacional.

// --- Abstract ---
#heading(level: 1, numbering: none, outlined: false)[Abstract]

This is the english abstract.

*Keywords*: GCC. RISC-V. Compiler. Educational processor.

// --- List of Abbreviations and Acronyms ---
#heading(level: 1, numbering: none, outlined: false)[List of Abbreviations and Acronyms]

#table(
  columns: (3cm, 1fr),
  stroke: none,
  inset: (y: 4pt),
  [*ABI*],    [_Application Binary Interface_],
  [*AMO*],    [_Atomic Memory Operation_],
  [*CSR*],    [_Control and Status Register_],
  [*ELF*],    [_Executable and Linkable Format_],
  [*GCC*],    [_GNU Compiler Collection_],
  [*GNU*],    [_GNU's Not Unix_],
  [*ISA*],    [_Instruction Set Architecture_],
  [*PIC*],    [_Position-Independent Code_],
  [*RISC*],   [_Reduced Instruction Set Computer_],
  [*RTL*],    [_Register Transfer Language_],
  [*RV32I*],  [RISC-V, integers, 32 bits],
  [*RV64I*],  [RISC-V, integers, 64 bits],
)

// --- List of Figures ---
#outline(title: [List of Figures], target: figure.where(kind: image))

// --- List of Tables ---
#outline(title: [List of Tables], target: figure.where(kind: table))

// --- Table of Contents ---
#heading(level: 1, numbering: none, outlined: false)[TABLE OF CONTENTS]
#outline(title: none, indent: auto, depth: 3)

// --- Textual Elements Setup ---
#set page(numbering: "1")


= Introduction

== Motivation
// - Presents a brief state-of-the-art overview of the subject that will be the theme of the work,
// based on the consulted references.
// - Consulted works must be cited and referenced in the text.
// - Presents the context in which the work will be developed.

_Computer Organization and Design: RISC-V Edition_ by Patterson and Hennessy @patterson2020 is one of the most widely adopted references in undergraduate computer architecture courses worldwide. At the University of São Paulo's Escola Politécnica, the course PCS3225 - Digital Systems 2 - uses this textbook as its primary reference. Students follow its progression step by step, implementing a simplified RISC-V processor in Verilog from book reference.

The simplified single-cycle processor introduced in Chapter 4.4 of the book - _A Simple Implementation Scheme_ - supports only eight instructions: `lw`, `sw`, `beq`, `add`, `addi`, `sub`, `and`, and `or`. This restriction is deliberate and pedagogically motivated: it isolates the essential datapath and control concepts before more complex features are introduced. A subsequent homework assignment extends the processor with `lui` and `jalr`, enabling function calls. Both implementations are partial subsets of the RV32I base ISA @riscv-spec.

This restriction creates a practical barrier. The standard RISC-V GCC toolchain (`riscv32-unknown-elf-gcc`) targets the full RV32I base ISA @riscv-spec, which includes shift instructions, byte and halfword memory operations, multiple branch variants, and PC-relative addressing. Any C program compiled with this toolchain will emit instructions that the student-built processor cannot execute.

As a result, students are limited to running hand-written assembly or small programs provided by the professor. They cannot compile and run arbitrary C code on the processor they designed and built. This prevents them from connecting the hardware they implement to the software abstractions they use daily, and forecloses the pedagogical opportunity of observing how a compiler translates and optimizes C code into the primitive instructions their processor supports.

== Objective
// - Present the objective of the work in a precise and concise manner.
// - Should answer the question: What is the work?

This work develops eight progressive GCC compiler targets for the simplified RISC-V processors described in the Hennessy and Patterson textbook, enabling students of the PCS3225 course at USP to compile and run C programs on the processors they build in Verilog.

The specific objectives are:

+ Define a minimal GCC target (`rvsc0`) matching the eight-instruction single-cycle processor described in Chapter 4.4 of the textbook, synthesizing all operations not natively supported by that processor.
+ Define a target (`rvsc1`) matching the course homework processor --- `rvsc0` extended with `lui` and `jalr` --- as the minimum instruction set capable of supporting the full C calling convention with synthesis.
+ Define six additional progressive targets (`rvsc2` through `rvsc7`), incrementally extending the supported instruction set from bare RV32I through RV64IMAFD, for students who wish to continue developing their processor beyond the course scope.
+ Synthesize every instruction not natively supported by a given target as an equivalent sequence of instructions that the target does support.

== Rationale
// - Presents why the developed work is important (importance and necessity for society,
// comparison with relevant consulted works, etc.).
// - Consulted works must be cited and referenced in the text.
// - Should answer the question: Why is the work important?

To the best of the authors' knowledge, no prior work addresses C compilation for intentionally restricted pedagogical RISC-V subsets. GCC's machine description framework @gcc-internals makes it possible to define a backend that synthesizes missing instructions transparently from the primitives the hardware does support. Applying this mechanism to pedagogical ISAs that deliberately omit standard instructions appears to be novel.

The ability to run a self-written C program on a processor the student designed and built closes a pedagogical loop that rarely closes in undergraduate education. Most courses treat hardware and software as adjacent subjects that never directly intersect. This work creates a complete vertical slice from C source to register-level execution on student hardware. Students can compile a function, inspect the output with `-S`, and observe concretely how the compiler synthesizes a shift operation from repeated additions, or a signed comparison from subtraction and bit manipulation — making the cost of each ISA restriction tangible rather than abstract.

Furthermore, students interact with GCC — the dominant open-source compiler for embedded and systems software — rather than a pedagogical toy. The flags, ABI conventions, ELF output, and linker scripts they encounter are identical to those used in professional and research settings, giving the exercise relevance beyond the course itself.

== Document Organization

// TODO: review this after document is finished
The remainder of this monograph is organized as follows. Chapter 2 surveys related work. Chapter 3 presents the conceptual background, covering the GCC compilation framework, the RISC-V instruction set architecture, and the architecture of the Hennessy-Patterson educational processor. Chapter 4 describes the development method, including the specification, implementation, and testing phases followed for each target. Chapter 5 specifies the requirements for each of the eight targets, defining the allowed instruction sets and the synthesis obligations imposed on the compiler. Chapter 6 details the implementation, describing the instruction synthesis techniques developed inside the GCC machine description and the per-target configuration files. Chapter 7 presents the test results and discusses the validity and limitations of each target. Chapter 8 presents the conclusions, contributions, and directions for future work.


= Related Work

// TODO: discuss scope and coverage with advisor.
// Candidate areas:
// - Pedagogical RISC-V/MIPS simulators (Venus, RARS, SPIM, MARS) — operate at assembly level, no C compiler
// - GCC/LLVM backends for restricted embedded ISAs (AVR, MSP430, libgcc soft-float) — closest technical precedent
// - Custom GCC backends for research/academic ISAs (OpenRISC, PULP) — demonstrates backend extensibility
// - ISA subset selection in compiler research — design-time vs. this work's compile-time synthesis direction


= Conceptual Background
// - Defines the representative sections based on the work.
// - Presents the concepts used and the literature review.
// - Consulted works must be cited and referenced in the text.

== RISC-V

RISC-V is an open, royalty-free instruction set architecture belonging to the Reduced Instruction Set Computer (RISC) family @riscv-spec. RISC architectures favour a small number of simple, orthogonal instructions over a large set of complex ones: all computation operates on registers, memory is accessed exclusively through explicit load and store instructions, and instructions are fixed-width, which keeps decoding logic simple and regular. The name RISC-V denotes the fifth major RISC ISA developed at UC Berkeley. Unlike earlier RISC designs, RISC-V is fully open: anyone may implement it without a license. The ISA is organized as a small mandatory base plus a set of optional standard extensions, so implementors include only the features their application requires.

RISC-V uses six encoding formats --- R, I, S, B, U, and J --- chosen to minimise the number of distinct immediate-field positions a decoder must handle @riscv-spec.

The base integer ISA has 32 general-purpose registers, x0--x31. x0 is hardwired to the constant zero and reads as zero regardless of writes. The remaining registers are general-purpose; the ABI assigns mnemonic names: a0--a7 for function arguments and return values, ra for the return address, sp for the stack pointer, t0--t6 for caller-saved temporaries, and s0--s11 for callee-saved registers @riscv-spec.

The RV32I base ISA contains approximately 40 instructions organised into functional groups: integer arithmetic and logic (ADD, SUB, AND, OR, XOR, SLL, SRL, SRA and their immediate-operand forms ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI); loads and stores (LW, LH, LB and unsigned halfword/byte variants LHU, LBU; SW, SH, SB); conditional branches (BEQ, BNE, BLT, BGE, BLTU, BGEU); jumps (JAL and JALR); upper-immediate instructions (LUI and AUIPC); and environment/system instructions (ECALL, EBREAK, FENCE) @riscv-spec.

Beyond the base, RISC-V defines several standard extensions. The M extension adds integer multiply and divide (MUL, MULH, DIV, REM and variants). The A extension provides atomic memory operations (load-reserved/store-conditional pairs LR/SC and a family of AMO instructions). The F and D extensions add single- and double-precision IEEE 754 floating-point.

== Single-Cycle Processor Architecture

A single-cycle processor completes every instruction in exactly one clock cycle. The datapath consists of five principal components wired in sequence: an instruction memory that outputs the instruction at the current program counter (PC); a register file with two read ports and one write port; an arithmetic logic unit (ALU) that performs the operation selected by the control unit; a data memory for load and store operations; and a set of multiplexers that route operands and results under control of the control signals derived from the instruction opcode @patterson2020.

The control unit decodes the instruction's opcode field and drives the multiplexer select lines and the register file write-enable. For a given instruction set, each instruction class has a fixed set of control signals; the datapath itself does not change between instructions --- only the routing of values through the multiplexers changes. This regularity is what makes it tractable to add support for a new instruction: each addition requires extending the decode logic and, where necessary, adding a new datapath path or multiplexer input.

The critical path --- the longest combinational path from instruction memory output to the final register or memory write --- determines the maximum clock frequency. Because every instruction must complete within one cycle, the clock period is set by the slowest instruction. For an RV32I processor the critical path typically runs through instruction memory, the register file read ports, the ALU, data memory (for `lw`), and the register file write port.

== Hennessy-Patterson Educational Processor

_Computer Organization and Design: RISC-V Edition_ @patterson2020 uses a series of progressively more capable processor implementations to teach the relationship between instruction sets and hardware. Chapter 4.4, titled _A Simple Implementation Scheme_, introduces a single-cycle datapath that supports only eight instructions: `lw`, `sw`, `beq`, `add`, `addi`, `sub`, `and`, and `or`. This restriction is deliberate: with only eight instructions, the complete datapath and control unit fit on a single diagram and can be fully understood and implemented within a single lab exercise.

The datapath for this subset is purpose-built. There is an ALU path for R-type arithmetic (`add`, `sub`, `and`, `or`) and I-type arithmetic (`addi`); a memory path for `lw` and `sw`; and a branch comparator for `beq`. The processor has no hardware for PC-relative address computation (no AUIPC path), no mechanism to load a 20-bit upper immediate into a register (no LUI path), and no register-to-PC write path that also captures the return address (no JALR path). Executing any instruction outside the supported set produces undefined results.

== C Calling Convention and ABI

An Application Binary Interface (ABI) is the binary-level contract that allows separately compiled translation units to interoperate. It specifies which registers hold function arguments, which the caller must preserve across a call, which the callee must preserve, how the stack is laid out, and how values are returned. Code compiled by different compilers for the same ABI can be linked and executed together.

The RISC-V integer ABI partitions the 32 registers into four groups @riscv-psabi. Argument and return-value registers (a0--a7, i.e. x10--x17) pass the first eight integer arguments to a function and carry the return value back in a0 (and a1 for 64-bit values on RV32). Caller-saved temporaries (t0--t6, i.e. x5--x7 and x28--x31) may be freely overwritten by any callee; the caller must save them if their values are needed after a call. Callee-saved registers (s0--s11, i.e. x8--x9 and x18--x27) must be preserved across calls; a callee that uses them must save and restore them. Special-purpose registers are: ra (x1) the return address, sp (x2) the stack pointer, gp (x3) the global pointer, and tp (x4) the thread pointer.

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: left,
    [*Register*], [*ABI name*], [*Role*], [*Saved by*],
    [x0], [zero], [Hardwired zero], [---],
    [x1], [ra], [Return address], [Caller],
    [x2], [sp], [Stack pointer], [Callee],
    [x3], [gp], [Global pointer], [---],
    [x4], [tp], [Thread pointer], [---],
    [x5--x7], [t0--t2], [Temporaries], [Caller],
    [x8--x9], [s0--s1], [Saved registers], [Callee],
    [x10--x11], [a0--a1], [Args / return value], [Caller],
    [x12--x17], [a2--a7], [Arguments], [Caller],
    [x18--x27], [s2--s11], [Saved registers], [Callee],
    [x28--x31], [t3--t6], [Temporaries], [Caller],
  ),
  caption: [RISC-V integer register conventions @riscv-psabi],
)

The RISC-V stack grows downward. A typical stack frame contains, from high to low address: incoming arguments that did not fit in a0--a7, the saved return address, saved callee-saved registers, and local variables. The call sequence is: the caller loads arguments into a0--a7 (and pushes any extras onto the stack), then executes `jal ra, target` to jump to the callee and record the return address in ra. The callee saves ra and any s registers it uses, executes its body, places the result in a0, restores saved registers, and returns with `jalr x0, 0(ra)` (the `ret` pseudo-instruction). The stack pointer must be 16-byte aligned at every function entry and exit @riscv-psabi.

GCC emits ELF (Executable and Linkable Format) object files. The principal sections are `.text` (machine code), `.rodata` (read-only constants and string literals), `.data` (initialized global variables), and `.bss` (zero-initialized global variables). Relocation entries in the object file record every reference to a symbol whose address is not yet known; the linker fills these in when it combines object files. A linker script controls the memory layout: it assigns each section to an address range that matches the target processor's address map @riscv-psabi.

== GCC Compiler Architecture

The GNU Compiler Collection (GCC) is a portable, multi-language, multi-target compiler and the dominant toolchain for embedded and systems software @gcc-internals. It translates C (and other languages) to machine code through a sequence of intermediate representations that progressively lower the abstraction level.

The compilation pipeline proceeds as follows @gcc-internals. The language frontend parses source code and produces an abstract syntax tree (AST). The AST is lowered to GIMPLE, a high-level, language-independent, statement-level intermediate representation in static single-assignment (SSA) form. The middle-end applies target-independent optimisations to GIMPLE (constant folding, inlining, loop transformations, and others). GIMPLE is then lowered to RTL (Register Transfer Language), a low-level IR that models instructions as operations on pseudo-registers and memory. The backend operates on RTL to produce assembly.

The backend performs three main tasks @gcc-internals. Instruction selection pattern-matches RTL expressions against the target's machine description to select real instructions. Register allocation assigns the potentially unbounded set of pseudo-registers to the finite set of physical registers, inserting spill code where necessary. Instruction scheduling reorders instructions to hide pipeline latency and improve throughput; it is irrelevant for single-cycle processors, which have no pipeline and therefore no data hazards.

The core of a GCC backend is the machine description file (`.md`), which declaratively specifies the target's instruction set and expansion rules @gcc-internals. It contains two primary construct types:

- `define_insn` --- specifies a named RTL pattern, an assembly output template, and a predicate condition string that tests target capabilities. When the condition evaluates to false, the pattern is invisible to the instruction selector and will never be emitted.
- `define_expand` --- specifies a named operation that expands into an arbitrary sequence of RTL insns when the compiler needs to generate that operation. The expansion body may call `DONE` to signal that it has produced the complete implementation, preventing any fallthrough to a `define_insn`. Expansions are the mechanism used to synthesize complex operations from simpler ones.

Code iterators (such as `any_shift`) allow a single `define_expand` to cover multiple related operations (ASHIFT, LSHIFTRT, ASHIFTRT) in one body, with runtime-constant guards like `(<CODE>) == ASHIFT` selecting the appropriate synthesis path.

Target-specific command-line options are declared in a `.opt` file using GCC's option-description syntax @gcc-internals. Each declaration generates a C preprocessor macro that can be tested in `.md` condition strings and in C target-hook implementations. A per-target header file defines `CC1_SPEC`, a GCC macro evaluated when the driver invokes the compiler proper (`cc1`). It contains conditional option-injection rules of the form "if the user did not explicitly pass a flag, inject its negation." This mechanism makes a target self-configuring: users invoke the target-specific compiler without any manual flags, and the correct behaviour is activated automatically.


= Development Method

This work followed an iterative process organized into four phases: a study phase to understand GCC's backend architecture, a requirements phase to define the instruction boundaries for each target, a per-synthesis implementation-and-test cycle that forms the core of the work, and a validation phase that confirms behavioral correctness on a reference simulator. Chapters 4, 5, and 6 describe the outputs of these phases in detail; this chapter describes the process itself.

== Study of GCC Internals

The first phase was a structured study of GCC's backend extension mechanisms. The entry point was the GCC Internals manual @gcc-internals, which documents the machine description language (`.md`), the option description system (`.opt`), and the role of per-target configuration headers. After establishing a conceptual model from the manual, the existing RISC-V backend --- `gcc/config/riscv/riscv.md`, `riscv.opt`, and `config.gcc` --- was examined as a working reference implementation.

Two diagnostic tools were central throughout the study and subsequent implementation phases. The `-S` flag causes GCC to emit assembly rather than an object file, making the compiler's instruction selection directly observable. The `-fdump-rtl-*` family of flags produces snapshots of GCC's internal Register Transfer Language (RTL) representation at each compilation stage; these were used to understand why a pattern matched or failed to match during instruction selection, and to verify that `define_expand` bodies fired at the correct point in the compilation pipeline.

== Requirements Specification

The requirements for each target were derived from two distinct sources, depending on the target tier.

For the two primary targets, the instruction boundaries are externally fixed. The rvsc0 instruction set is exactly the set supported by the single-cycle processor described in Chapter 4.4 of the Hennessy-Patterson textbook @patterson2020. The rvsc1 instruction set is rvsc0 extended with the minimum additions required to support the full C calling convention: `lui` (to materialize absolute addresses) and `jalr` (to perform indirect jumps and function returns). These were determined by analyzing the RISC-V ABI @riscv-psabi and identifying which operations a conforming C calling convention unavoidably requires.

For the remaining six targets (rvsc2--rvsc7), the instruction boundaries follow the natural extension hierarchy of the RISC-V specification @riscv-spec: from the RV32I base through 64-bit operations, integer multiply-divide, single- and double-precision floating-point, and atomic memory operations. No synthesis is required for these targets, as each progressively enables instructions already present in the upstream GCC backend; the contribution is the target triple registration and configuration.

The full requirements are specified in Chapter 4.

== Synthesis Derivation and Implementation

The rvsc0 and rvsc1 targets require GCC to synthesize every instruction outside the native set using only the instructions the processor supports. Each synthesis was developed through the following cycle, applied independently to each missing operation.

The process begins by identifying the missing operation — an instruction that GCC's middle-end may legally request but that the target processor does not support. The synthesis algorithm is then derived and expressed as C pseudocode, which serves both as a correctness argument and as an unambiguous specification of the target behavior. The pseudocode is then lifted directly into a `define_expand` body in `riscv.md`, using GCC's RTL emit helpers to generate the equivalent sequence of native instructions. Correctness of the expansion is confirmed in two steps: the `-S` output is inspected to verify that no forbidden mnemonics appear, and the resulting program is executed on the Spike RISC-V ISA simulator @spike to confirm that the synthesized sequence produces the same result as the original instruction would have.

This cycle was repeated for each operation that the compiler may emit for a bare-metal freestanding C program targeting rvsc0 or rvsc1. The derivations and the resulting implementation are described in Chapter 5.

== Validation

Validation addresses both correctness requirements stated in Chapter 4: ISA compliance and behavioral equivalence.

ISA compliance is verified structurally: the compiler is invoked with `-S` on a test program that exercises a specific operation, and the output is scanned for any mnemonic not in the target's allowed set. This check is automated by the `run_tests.py` script, which compiles each test file and compares the emitted mnemonics against an allowlist specific to the target.

Behavioral equivalence is verified by compiling representative C programs and executing the resulting ELF binaries on Spike. Because Spike implements the full RV32I ISA, it can execute sc1-compiled programs (whose synthesis sequences are all valid RV32I) and confirm that return values and memory state match the expected output. The test programs currently cover arithmetic operations, control flow, function calls, pointer manipulation, and integer comparisons; integration of the official RISC-V test suite is planned as future work.

Test results are presented in Chapter 6.

= Requirements Specification
// Define and describe the requirements of the work. The work may involve system development,
// improvement of an existing system, process definition, techniques, procedures, or
// another type of work agreed upon with the advisor.

This chapter defines the requirements for the eight GCC cross-compiler targets developed in this work. Each target is a modified GCC backend that accepts bare-metal freestanding C programs and produces machine code containing only the instructions supported by the corresponding educational processor.

== Scope

All targets compile *bare-metal freestanding C*: programs with no standard library and no operating system, producing an ELF binary as output.

== Correctness Requirements

Two independent correctness requirements apply to every target.

*ISA compliance*: the compiler must never emit an instruction whose opcode is not in the target's allowed set. This requirement is verifiable by inspecting the assembly output.

*Behavioral equivalence*: the compiled program must exhibit the same observable behavior as the source — the same return values, the same memory effects, and the same control flow — as if compiled for a processor that natively supports the full instruction set.


== rvsc0 — Basic Single-Cycle

The rvsc0 target corresponds to the eight-instruction single-cycle processor described in Chapter 4.4 of @patterson2020, _A Simple Implementation Scheme_:

#quote[In this section, we look at what might be thought of as a simple implementation of our RISC-V subset. [...] This simple implementation covers load word (lw), store word (sw), branch if equal (beq), and the arithmetic-logical instructions add, sub, and, and or.]

#figure(
  table(
    columns: (auto, 1fr),
    align: left,
    [*Mnemonic*], [*Description*],
    [`lw`],   [Load word],
    [`sw`],   [Store word],
    [`beq`],  [Branch if equal],
    [`add`],  [Add],
    [`addi`], [Add immediate],
    [`sub`],  [Subtract],
    [`and`],  [Bitwise AND],
    [`or`],   [Bitwise OR],
  ),
  caption: [rvsc0 native instruction set],
)

=== Limitations

The rvsc0 processor has no mechanism to write the program counter — it supports neither `jalr` nor any jump-and-link instruction. As a consequence, subroutine calls are architecturally impossible, and the set of C programs that can be compiled for rvsc0 is restricted accordingly. For all other C constructs, the compiler must produce correct behavior using only the native instruction set.

== rvsc1 — Extended Single-Cycle

The rvsc1 target extends rvsc0 with `lui` and `jalr`. These two instructions are the minimum addition that enables the full C calling convention: `lui` materializes 32-bit absolute addresses and `jalr` performs indirect jumps and encodes function returns via `jalr x0, 0(ra)`.

#figure(
  table(
    columns: (auto, 1fr),
    align: left,
    [*Mnemonic*], [*Description*],
    [`lw`],   [Load word],
    [`sw`],   [Store word],
    [`beq`],  [Branch if equal],
    [`add`],  [Add],
    [`addi`], [Add immediate],
    [`sub`],  [Subtract],
    [`and`],  [Bitwise AND],
    [`or`],   [Bitwise OR],
    [`lui`],  [Load upper immediate],
    [`jalr`], [Jump and link register],
  ),
  caption: [rvsc1 native instruction set],
)

With these ten instructions, the target must support the full C calling convention and general-purpose C programs.

== rvsc2 — Single-Cycle Without Fence and Control

The rvsc2 target implements the full RV32I base ISA with three groups of instructions excluded. Memory ordering instructions are unnecessary on a single-core single-cycle processor: omitting them is behavior-preserving. CSR access and system instructions require operating system support that is absent in the bare-metal environment.

#figure(
  table(
    columns: (auto, 1fr),
    align: left,
    [*Group*], [*Instructions*],
    [Integer arithmetic], [`add`, `sub`, `addi`, `and`, `andi`, `or`, `ori`, `xor`, `xori`, `sll`, `slli`, `srl`, `srli`, `sra`, `srai`],
    [Comparison],         [`slt`, `sltu`, `slti`, `sltiu`],
    [Loads],              [`lw`, `lh`, `lhu`, `lb`, `lbu`],
    [Stores],             [`sw`, `sh`, `sb`],
    [Branches],           [`beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`],
    [Jumps],              [`jal`, `jalr`],
    [Upper immediate],    [`lui`, `auipc`],
  ),
  caption: [rvsc2 native instruction set (RV32I base, excluding fence, CSR, and system groups)],
)

#figure(
  table(
    columns: (auto, 1fr),
    align: left,
    [*Treatment*], [*Instructions*],
    [Behaviorally equivalent],
      [`fence`, `fence.i`, `sfence.vma`],
    [Rejected],
      [`ecall`, `ebreak`, `sret`, `wfi`, CSR instructions (`csrrw`, `csrrs`, `csrrc`, `csrrwi`, `csrrsi`, `csrrci`)],
  ),
  caption: [rvsc2 instruction treatment],
)

== rvsc3 — Single-Cycle rv32i

The rvsc3 target implements the complete RV32I base integer ISA @riscv-spec, including the memory ordering, CSR access, and system instruction groups omitted from rvsc2. No instruction synthesis is required: every RV32I instruction is natively supported by the hardware.

#figure(
  table(
    columns: (auto, 1fr),
    align: left,
    [*Group*], [*Instructions*],
    [Integer arithmetic], [`add`, `sub`, `addi`, `and`, `andi`, `or`, `ori`, `xor`, `xori`, `sll`, `slli`, `srl`, `srli`, `sra`, `srai`],
    [Comparison],         [`slt`, `sltu`, `slti`, `sltiu`],
    [Loads],              [`lw`, `lh`, `lhu`, `lb`, `lbu`],
    [Stores],             [`sw`, `sh`, `sb`],
    [Branches],           [`beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`],
    [Jumps],              [`jal`, `jalr`],
    [Upper immediate],    [`lui`, `auipc`],
    [Memory ordering],    [`fence`, `fence.i`],
    [System],             [`ecall`, `ebreak`, `wfi`, `sret`],
    [CSR],                [`csrrw`, `csrrs`, `csrrc`, `csrrwi`, `csrrsi`, `csrrci`],
  ),
  caption: [rvsc3 native instruction set (complete RV32I)],
)

== rvsc4 — Single-Cycle rv64i

The rvsc4 target is a 64-bit processor implementing the full rv64i instruction set. In addition to all rvsc3 instructions, it natively supports:

- 64-bit memory operations: `ld`, `sd`, `lwu`
- Word operations with sign-extended 64-bit results: `addw`, `subw`, `addiw`, `sllw`, `srlw`, `sraw`, `slliw`, `srliw`, `sraiw`


The W-suffix variants operate on 32 bits and sign-extend the result to 64 bits, following the same convention as `addw`, `subw`, and the other W instructions from rvsc4.

== rvsc5 — Single-Cycle rv64im

The rvsc5 target extends rvsc4 with the M extension, adding native integer multiply and divide:

- Multiply: `mul`, `mulw`, `mulh`, `mulhu`, `mulhsu`
- Signed divide: `div`, `divw`
- Unsigned divide: `divu`, `divuw`
- Signed remainder: `rem`, `remw`
- Unsigned remainder: `remu`, `remuw`

== rvsc6 — Single-Cycle Floating-Point

The rvsc6 target extends rvsc5 with the complete F (single-precision) and D (double-precision) floating-point extensions as defined in @riscv-spec, supporting all arithmetic, memory, conversion, and comparison instructions for both precisions.

Loads/stores:
- `flw`, `fsw` — single precision
- `fld`, `fsd` — double precision

Arithmetic:
- `fadd.s`, `fadd.d`, `fsub.s`, `fsub.d`, `fmul.s`, `fmul.d`, `fdiv.s`, `fdiv.d`, `fsqrt.s`, `fsqrt.d`

Fused multiply-add:
- `fmadd.s`, `fmadd.d`, `fmsub.s`, `fmsub.d`, `fnmadd.s`, `fnmadd.d`, `fnmsub.s`, `fnmsub.d`

Sign, minimum, and maximum:
- `fsgnj.s`, `fsgnj.d`, `fsgnjn.s`, `fsgnjn.d`, `fsgnjx.s`, `fsgnjx.d`
- `fmin.s`, `fmin.d`, `fmax.s`, `fmax.d`

Comparison and classification:
- `feq.s`, `feq.d`, `flt.s`, `flt.d`, `fle.s`, `fle.d`
- `fclass.s`, `fclass.d`

Move between integer and FP registers:
- `fmv.w.x`, `fmv.x.w` — single (rv32 and rv64)
- `fmv.d.x`, `fmv.x.d` — double (rv64)

Conversions (rv64):
- `fcvt.s.w`, `fcvt.s.wu`, `fcvt.s.l`, `fcvt.s.lu` — int → single
- `fcvt.w.s`, `fcvt.wu.s`, `fcvt.l.s`, `fcvt.lu.s` — single → int
- `fcvt.d.w`, `fcvt.d.wu`, `fcvt.d.l`, `fcvt.d.lu` — int → double
- `fcvt.w.d`, `fcvt.wu.d`, `fcvt.l.d`, `fcvt.lu.d` — double → int
- `fcvt.s.d`, `fcvt.d.s` — conversion between single and double

== rvsc7 — Single-Cycle Atomic

The rvsc7 target extends rvsc6 with the A extension (atomic memory operations), implementing the full rv64imafd instruction set @riscv-spec. The `.w` variants operate on 32 bits (sign-extended to 64); the `.d` variants operate on 64 bits.

Load-reserved and store-conditional:
- `lr.w`, `lr.d` — load-reserved
- `sc.w`, `sc.d` — store-conditional

AMO (atomic memory operations):
- `amoadd.w`, `amoadd.d` — atomic add
- `amoand.w`, `amoand.d` — atomic AND
- `amoor.w`, `amoor.d` — atomic OR
- `amoxor.w`, `amoxor.d` — atomic XOR
- `amoswap.w`, `amoswap.d` — atomic swap
- `amomax.w`, `amomax.d` — atomic signed maximum
- `amomaxu.w`, `amomaxu.d` — atomic unsigned maximum
- `amomin.w`, `amomin.d` — atomic signed minimum
- `amominu.w`, `amominu.d` — atomic unsigned minimum

= Development

The rvsc0 and rvsc1 targets restrict the instruction set available to the compiler (Chapter 4 specifies the complete native instruction set for each target). Every C construct the compiler may emit must be realized using only those native instructions; for every excluded instruction, GCC synthesizes an equivalent sequence at compile time. This chapter presents the tools and infrastructure used, the mathematical derivation and proof of each synthesis, the GCC implementation that makes the process transparent to the programmer, and the known limitations of each target.

== Technologies Used

=== GCC 17.0.0

The custom targets are implemented as a backend extension to GCC 17.0.0. GCC is chosen because it is the dominant open-source compiler for embedded and systems software and because its machine description framework provides a declarative mechanism for defining instruction synthesis rules that is already present in the upstream RISC-V backend. The following files in the GCC source tree were modified or added:

#figure(
  table(
    columns: (auto, 1fr),
    align: left,
    [*File*], [*Role*],
    [`gcc/config/riscv/riscv.md`],  [Machine description: synthesis patterns and native instruction guards],
    [`gcc/config/riscv/riscv.opt`], [Option declarations: per-synthesis boolean flags],
    [`gcc/config/riscv/riscv.cc`],  [Target hooks: constant pool handling for LUI synthesis],
    [`gcc/config/riscv/rvscN.h`],   [Per-target headers: `CC1_SPEC` injecting `-mno-*` flags automatically],
    [`gcc/config/config.gcc`],      [Triple mapping: `rvscN-*-elf*` to `cpu_type=riscv`],
    [`gcc/config/config.sub`],      [Triple normalisation: recognises `rvscN` as a valid CPU name],
  ),
  caption: [GCC source files modified or added for this project],
)

=== GNU Binutils (riscv32/64-none-elf)

The upstream GNU binutils cross toolchain is used without modification as the assembler and linker. The binutils triple differs from the compiler triple: `riscv32-none-elf` for rvsc0--rvsc3 and `riscv64-none-elf` for rvsc4--rvsc7. This separation is possible because the assembler accepts the full RISC-V instruction set --- the ISA restriction lives entirely in the GCC backend, not in the assembler. The `objdump -M no-aliases` flag is used in the test suite to expand pseudo-instructions to their real opcodes before checking for forbidden mnemonics.

=== Spike 1.1.1-dev

Spike is the official RISC-V ISA reference simulator @spike. It implements the full RV64IMAFD instruction set, making it suitable as the behavioral oracle: a binary compiled by `rvsc1-unknown-elf-gcc` contains only valid RV32I instructions (the synthesis sequences are themselves valid RV32I), so Spike can execute it and report the correct result. Spike is invoked with `--isa=rv32i` for rvsc0--rvsc3 tests, and with `--log-commits` to count retired instructions for performance measurements.

== Synthesis Derivations <sc1-synthesis>

*Assembly notation.* In the listings below, `rd`, `rs1`, and `rs2` denote the canonical destination and source registers. Registers `t0`–`t5` are temporaries chosen for readability. In the actual GCC machine description, all temporaries are allocated as pseudo-registers via `gen_reg_rtx(SImode)`; the register allocator maps them to physical registers, resolving aliasing conflicts automatically. The bracket notation `[op ...]` marks an instruction that is itself synthesized — its expansion is defined in the subsection that covers that operation.

=== Arithmetic

Arithmetic synthesis operations assign values only to registers and carry no memory side-effects; they can be replaced by equivalent sequences without additional constraints.

==== Bitwise NOT <sc1-not>

The standard RISC-V pseudo-instruction `not rd, rs1` expands to `xori rd, rs1, -1`. Neither sc0 nor sc1 include `xori`, so a different derivation is required.

*Proof.* In two's complement, negation satisfies $-x = ~x + 1$ for all $x$. Rearranging: $~x = -x - 1$. Both subtraction from zero (`sub rd, x0, rs1`) and decrement by one (`addi rd, rd, -1`) are available in sc0 and sc1. $square$

```asm
sub  rd, x0, rs1    # rd = -rs1
addi rd, rd, -1     # rd = -rs1 - 1 = ~rs1
```

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    stroke: none,
    inset: (y: 4pt),
    [*Static instructions*], [*Extra registers*], [*Applies to*],
    [2], [0], [rvsc0, rvsc1],
  ),
  caption: [Cost summary for NOT synthesis],
)

==== xor (R[rd] = R[rs1] ^ R[rs2]) <sc1-xor>

Neither sc0 nor sc1 include `xor` or `xori`.

*Proof.* The De Morgan identity $a \^ b = ~(a & b) & (a | b)$ holds for all bits $a, b in {0, 1}$, as the following truth table confirms:

#figure(
  table(
    columns: 6,
    align: center,
    [$a$], [$b$], [$a & b$], [$~(a & b)$], [$a | b$], [$~(a & b) & (a | b)$],
    [0], [0], [0], [1], [0], [0],
    [0], [1], [0], [1], [1], [1],
    [1], [0], [0], [1], [1], [1],
    [1], [1], [1], [0], [1], [0],
  ),
  caption: [Truth table establishing $~(a & b) & (a | b) = a \^ b$],
)

The right-hand column matches $a \^ b$ in every row. Since the identity holds for each bit independently, it holds for all 32-bit words. $square$

Using the derived `[not]` from @sc1-not:

```asm
and   t0, rs1, rs2  # t0 = rs1 & rs2
[not  t0, t0]       # t0 = ~(rs1 & rs2)  — 2 insns (Section 5.1.1)
or    rd, rs1, rs2  # rd = rs1 | rs2
and   rd, t0, rd    # rd = ~(rs1 & rs2) & (rs1 | rs2) = rs1 ^ rs2
```

#figure(
  table(
    columns: (1fr, 1fr, 1fr, 1fr),
    stroke: none,
    inset: (y: 4pt),
    [*Listing*], [*With [not] expanded*], [*Extra registers*], [*Applies to*],
    [4 insns], [6 insns], [1 (t0)], [rvsc0, rvsc1],
  ),
  caption: [Cost summary for XOR synthesis],
)

==== Shifts: SLL, SRL, SRA <sc1-shifts>

Neither sc0 nor sc1 include any shift instruction. All three variants are synthesized from `add`, `addi`, `sub`, and `beq`.

*Note on shift-count range.* The C standard (ISO C11 §6.5.7) states that shifting a 32-bit value by a count equal to or greater than 32 is undefined behavior; a conforming C program never triggers this case. The synthesis sequences nonetheless mask the shift count to the range $[0, 31]$ via `and t, rs2, 31`, matching the hardware behavior of native RV32I shift instructions. The synthesis therefore agrees with native hardware on all defined inputs and produces the same result on undefined inputs.

===== Logical Left Shift (SLL) <sc1-sll>

`sll rd, rs1, rs2` computes $"rd" = "rs1" << "rs2"$ (zero-fill from the right).

*Proof by induction.* Let $"sll"(x, n)$ denote $x$ left-shifted by $n$ positions. Claim: $"sll"(x, n) = x dot 2^n$ (modulo $2^32$).

- _Base case_ $(n = 0)$: $"sll"(x, 0) = x = x dot 2^0$. $checkmark$
- _Inductive step_: Assume $"sll"(x, n) = x dot 2^n$. Then $"sll"(x, n+1) = "sll"(x, n) + "sll"(x, n) = 2 dot x dot 2^n = x dot 2^(n+1)$. $checkmark$

The synthesis implements this recursion as a count-down loop in which each iteration doubles `rd` via `add rd, rd, rd`. $square$

```c
uint32_t sll(uint32_t rs1, uint32_t rs2) {
    rs2 &= 31u;           // C11 §6.5.7: mask to [0, 31]
    uint32_t rd = rs1;
    for (uint32_t i = 0; i < rs2; i++) rd += rd;
    return rd;
}
```

```asm
# rd = rs1 << rs2
    add   t1, rs2, x0    # t1 = rs2 (save shift count; rd may alias rs2)
    add   rd, rs1, x0    # rd = rs1
    beq   t1, x0, done   # if rs2 == 0, no shift needed
loop:
    add   rd, rd, rd     # rd <<= 1
    addi  t1, t1, -1
    beq   t1, x0, done
    beq   x0, x0, loop
done:
```

Let $b$ denote the masked shift amount. The loop executes $b$ iterations of 4 instructions each, with 3 setup instructions.

#figure(
  table(
    columns: (1fr, 1fr, 1fr, 1fr),
    stroke: none,
    inset: (y: 4pt),
    [*Formula*], [*Min (b=0)*], [*Max (b=31)*], [*Extra registers*],
    [$3 + 4b$], [3], [127], [1 (t1)],
  ),
  caption: [Cost summary for SLL synthesis],
)


===== Logical Right Shift (SRL) <sc1-srl>

`srl rd, rs1, rs2` computes $"rd" = "rs1" >> "rs2"$ (zero-fill from the left). A right shift cannot be synthesized by repeated halving, because integer division by two would floor rather than truncate, producing incorrect results for odd values. Instead, output bit $i$ is copied from input bit $i + s$ using two single-bit masks that scan upward together.

*Proof of correctness.* The algorithm maintains `out_mask` (scanning output bits from 0 upward) and `in_mask` (scanning input bits from $s$ upward). At each step, if `x & in_mask ≠ 0`, input bit $i+s$ is set and the algorithm sets `result |= out_mask`. Both masks then advance (`<<= 1`). The loop terminates when `in_mask` overflows past bit 31 (becoming 0), meaning all input positions at or above $s$ have been processed. Output bits 0 through $31 - s$ are set from the corresponding input bits; bits above $31 - s$ are never set (their input positions have overflowed), correctly implementing zero-fill. $square$

```c
uint32_t srl(uint32_t x, uint32_t shift) {
    shift = shift & 31u;      // C11 §6.5.7: mask to [0, 31]
    uint32_t result   = 0;
    uint32_t out_mask = 1u;
    uint32_t in_mask  = 1u << shift;   // [sll]
    while (in_mask != 0) {
        if ((x & in_mask) != 0) result |= out_mask;
        out_mask <<= 1;   // [sll]
        in_mask  <<= 1;   // [sll]
    }
    return result;
}
```

In assembly using only the available instruction set:

```asm
# rd = rs1 >> rs2 (logical shift right)
    addi  t0, x0, 31
    and   t3, rs2, t0    # t3 = shift & 31
    add   t5, rs1, x0    # t5 = rs1 (save before rd is zeroed; fixes rd/rs1 aliasing)
    addi  rd, x0, 0      # result = 0
    addi  t1, x0, 1      # out_mask = 1
    addi  t2, x0, 1      # in_mask = 1
    # compute in_mask = 1 << shift  (derived sll)
    beq   t3, x0, loop   # if shift == 0, in_mask is already 1
    add   t4, t3, x0     # t4 = shift (sll counter)
sll_in:
    add   t2, t2, t2     # in_mask <<= 1
    addi  t4, t4, -1
    beq   t4, x0, loop
    beq   x0, x0, sll_in
loop:
    beq   t2, x0, done   # if in_mask == 0, all bits processed
    and   t4, t5, t2     # t4 = rs1 & in_mask  (use saved t5)
    beq   t4, x0, skip   # if bit is 0, skip
    or    rd, rd, t1     # result |= out_mask
skip:
    add   t1, t1, t1     # out_mask <<= 1
    add   t2, t2, t2     # in_mask <<= 1
    beq   x0, x0, loop
done:
```

The main loop runs $(32 - s)$ iterations where $s$ is the masked shift amount; each iteration costs 4–5 instructions. Initialization and the `in_mask` pre-shift add overhead proportional to $s$.

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    stroke: none,
    inset: (y: 4pt),
    [*Worst case*], [*Extra registers*], [*Applies to*],
    [~170 insns], [5 (t0–t5)], [rvsc0, rvsc1],
  ),
  caption: [Cost summary for SRL synthesis],
)

===== Arithmetic Right Shift (SRA) <sc1-sra>

`sra rd, rs1, rs2` computes the arithmetic right shift: identical to `srl` but vacated upper bits are filled with the sign bit rather than zero.

*Proof.* Let $s$ be the masked shift count and $b_{31}$ the sign bit of `rs1`. Arithmetic right shift sets output bit $i$ to input bit $\min(i+s, 31)$. For $i \leq 31-s$ this equals the `srl` result. For $i > 31-s$, all upper bits equal $b_{31}$.

If $b_{31} = 0$, the `srl` result already has all upper bits zero; no correction is needed.

If $b_{31} = 1$, the upper $s$ bits must be 1. The mask $(-1) << (32 - s)$ has exactly the top $s$ bits set, since $-1$ in two's complement is all-ones, and left-shifting by $k$ clears the low $k$ bits. OR-ing this mask into the `srl` result sets the upper $s$ bits correctly. $square$

```c
uint32_t sra(uint32_t x, uint32_t shift) {
    shift = shift & 31u;
    uint32_t result = srl(x, shift);
    if (shift == 0 || (x >> 31) == 0) return result;
    // OR in the top 'shift' bits: left-shifting -1 leaves exactly those bits set
    uint32_t sign_mask = (uint32_t)(-1) << (32u - shift);
    return result | sign_mask;
}
```

```asm
# rd = rs1 >>_s rs2 (arithmetic shift right)

    # Step 1: check sign bit of rs1 BEFORE srl (avoids rd/rs1 aliasing)
    addi  t0, x0, 1
    addi  t3, x0, 31
sign_sll:
    add   t0, t0, t0
    addi  t3, t3, -1
    beq   t3, x0, sign_check
    beq   x0, x0, sign_sll
sign_check:              # t0 = 0x80000000
    and   t6, rs1, t0   # t6 = sign bit (saved in t6; srl uses t0–t5)

    # Step 2: logical right shift
    [srl  rd, rs1, rs2]  # rd = srl(rs1, rs2)

    beq   t6, x0, done  # positive → no sign extension needed

    # Step 3: re-mask shift; early exit if shift == 0 mod 32
    addi  t0, x0, 31
    and   t3, rs2, t0   # t3 = shift & 31 (fixes unmasked-rs2 bug for rs2 > 31)
    beq   t3, x0, done  # shift == 0 mod 32 → sra(x, 0) = x

    # Step 4: sign_mask = -1 << (32 - shift)
    addi  t2, x0, -1    # t2 = 0xFFFFFFFF
    addi  t4, x0, 32
    sub   t4, t4, t3    # t4 = 32 - (shift & 31)
ext_sll:
    add   t2, t2, t2    # t2 <<= 1
    addi  t4, t4, -1
    beq   t4, x0, apply
    beq   x0, x0, ext_sll
apply:
    or    rd, rd, t2
done:
```

*Cost*: One full `[srl]` expansion plus ~25 instructions for sign-bit extraction and sign-mask construction; worst case approximately 200 instructions; 6 extra registers.

=== Comparisons <sc1-comparisons>

==== SLT and SLTU <sc1-slt>

`slt rd, rs1, rs2` sets `rd = 1` if `rs1 < rs2` (signed comparison), else `rd = 0`. Neither sc0 nor sc1 include `slt` or `slti`.

*Proof.* Let `diff = rs1 - rs2` (32-bit two's complement). Without overflow, the sign bit of `diff` correctly indicates the comparison: `diff[31] = 1` iff `rs1 < rs2`. Signed overflow occurs when the operands have different signs and the result has the same sign as `rs2`. The expression $"overflow" = ("rs1" xor "rs2") & ("rs1" xor "diff")$ has MSB 1 exactly when overflow occurred. XOR-ing `diff` with `overflow` flips the sign bit iff overflow occurred, yielding the corrected result. Verification by case analysis on the sign bits of $a = "rs1"$ and $b = "rs2"$:

- $(a >= 0, b >= 0)$: subtraction cannot overflow; $"overflow"[31] = 0$; result = `diff[31]`. Correct.
- $(a < 0, b < 0)$: same analysis. Correct.
- $(a >= 0, b < 0)$: $a >= b$ always; result must be 0. If overflow: `diff[31] = 1` (wrong). $(a xor b)[31] = 1$ (signs differ); $(a xor "diff")[31] = 1$; so $"overflow"[31] = 1$ and $"corrected"[31] = 1 xor 1 = 0$. Correct.
- $(a < 0, b >= 0)$: $a < b$ always; result must be 1. If underflow: `diff[31] = 0` (wrong); $"overflow"[31] = 1$; $"corrected"[31] = 0 xor 1 = 1$. Correct. If no underflow: `diff[31] = 1`; $"overflow"[31] = 0$; $"corrected"[31] = 1$. Correct. $square$

```c
uint32_t slt(uint32_t a, uint32_t b) {
    uint32_t diff      = a - b;
    uint32_t overflow  = (a ^ b) & (a ^ diff);   // MSB = 1 iff signed overflow
    uint32_t corrected = diff ^ overflow;

    return corrected >> 31;
}
```

```asm
sub   t0, rs1, rs2   # diff = rs1 - rs2
[xor  t1, rs1, rs2]  # t1 = rs1 ^ rs2  (derived)
[xor  t2, rs1, t0]   # t2 = rs1 ^ diff  (derived)
and   t1, t1, t2     # overflow = (rs1^rs2) & (rs1^diff)
[xor  t0, t0, t1]    # corrected = diff ^ overflow  (derived)
[srl  rd,  t0, 31]   # rd = corrected >> 31  (derived)
```

`sltu rd, rs1, rs2` performs the same comparison treating both operands as unsigned.

*Proof.* `rs1 < rs2` (unsigned) iff the subtraction `rs1 - rs2` generates a borrow at the MSB. A borrow is _generated_ at bit $i$ when `rs1[i] = 0` and `rs2[i] = 1`, captured by `~rs1 & rs2`. A borrow is _propagated_ when `rs1[i] = rs2[i]` and a borrow arrived from below, captured by `~(rs1 ^ rs2) & diff`. The MSB of their union is 1 iff `rs1 < rs2` (unsigned). $square$

```c
uint32_t sltu(uint32_t a, uint32_t b) {
    uint32_t diff   = a - b;
    uint32_t borrow = (~a & b) | (~(a ^ b) & diff);
    return borrow >> 31;
}
```

```asm
sub   t0, rs1, rs2   # diff = rs1 - rs2
[not  t1, rs1]       # t1 = ~rs1  (derived)
and   t2, t1, rs2    # t2 = ~rs1 & rs2  (borrow generated)
[xor  t3, rs1, rs2]  # t3 = rs1 ^ rs2  (derived)
[not  t3, t3]        # t3 = ~(rs1 ^ rs2)  (derived)
and   t3, t3, t0     # t3 = ~(rs1^rs2) & diff  (borrow propagated)
or    t2, t2, t3     # borrow = generated | propagated
[srl  rd,  t2, 31]   # rd = borrow >> 31  (derived)
```

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    stroke: none,
    inset: (y: 4pt),
    [*Operation*], [*Approx. instructions (full expansion)*], [*Extra registers*],
    [`slt`], [~60], [3 (t0–t2)],
    [`sltu`], [~70], [4 (t0–t3)],
  ),
  caption: [Cost summary for SLT and SLTU synthesis],
)


==== BNE <sc1-bne>

`bne rs1, rs2, target` jumps iff `rs1 ≠ rs2`.

*Equivalence.* `rs1 ≠ rs2` iff `rs1 - rs2 ≠ 0`. If the difference is zero, `beq` falls through (skip the jump); otherwise an unconditional `beq x0, x0, target` is taken.

```asm
sub  t0, rs1, rs2
beq  t0, x0, skip    # rs1 == rs2: skip
beq  x0, x0, target  # unconditional jump
skip:
```

*Cost*: 3 instructions; 1 extra register.

==== BLT, BGE, BLTU, BGEU <sc1-ordered-branches>

Each ordered branch is synthesized using `[slt]` or `[sltu]` followed by a `beq` or `bne` test.

*Equivalence.* A "branch if less-than" is equivalent to computing the comparison into a register and branching on that register being nonzero; "branch if greater-than-or-equal" branches when the comparison is zero (i.e., the "not less-than" case).

#figure(
  table(
    columns: (auto, auto, 1fr),
    align: left,
    [*Branch*], [*Condition*], [*Synthesis*],
    [`blt rs1, rs2, L`],  [`rs1 < rs2` (signed)],    [`[slt t, rs1, rs2]`; `bne t, x0, L`],
    [`bge rs1, rs2, L`],  [`rs1 >= rs2` (signed)],   [`[slt t, rs1, rs2]`; `beq t, x0, L`],
    [`bltu rs1, rs2, L`], [`rs1 < rs2` (unsigned)],  [`[sltu t, rs1, rs2]`; `bne t, x0, L`],
    [`bgeu rs1, rs2, L`], [`rs1 >= rs2` (unsigned)], [`[sltu t, rs1, rs2]`; `beq t, x0, L`],
  ),
  caption: [Ordered branch syntheses via `[slt]` and `[sltu]`],
)

=== Immediate Variants <sc1-immediates>

The instructions `andi`, `ori`, `xori`, `slli`, `srli`, `srai`, `slti`, and `sltiu` encode a register together with a 12-bit signed immediate. Neither sc0 nor sc1 support any of these forms. Each is synthesized by loading the immediate into a temporary register via `addi` and calling the corresponding register–register variant:

```asm
# Example: andi rd, rs1, imm  →
addi  t0, x0, imm
and   rd, rs1, t0
```

Since `addi` encodes 12-bit signed immediates (range −2048 to 2047) and all of these instruction forms share the same I-type 12-bit field, every immediate fits directly.

*Cost*: 1 extra `addi` instruction and 1 extra register per immediate variant.

=== Loads <sc1-loads>

==== LUI (rvsc0 only) <sc0-lui>

`lui rd, imm20` sets `rd = imm20 << 12`. The instruction is native in rvsc1; synthesis is required only for rvsc0. Since rvsc0 also lacks `jalr`, function calls are impossible; LUI synthesis is primarily needed to materialize large constants or absolute memory addresses.

*Derivation.* Since `addi` encodes only 12-bit signed immediates (range −2048 to 2047), a 20-bit immediate cannot be loaded in one instruction. Splitting $"imm20"$ into two 10-bit halves $"hi" = "imm20"[19:10]$ and $"lo" = "imm20"[9:0]$ (each in $[0, 1023]$):

$ "rd" = "imm20" << 12 = (("hi" << 10) | "lo") << 12 $

===== Approach 1: addi + derived sll

```asm
addi  rd, x0, hi     # rd = upper 10 bits of imm20  (fits in addi: 0–1023)
[sll  rd, rd, 10]    # rd = hi << 10
addi  t0, x0, lo     # t0 = lower 10 bits of imm20  (fits in addi: 0–1023)
or    rd, rd, t0     # rd = (hi << 10) | lo  = imm20
[sll  rd, rd, 12]    # rd = imm20 << 12
```

The assembler computes `hi` and `lo` from the symbol address at link time.

===== Approach 2: constant pool (lw from ROM)

Since the LUI immediate is always known at link time, the linker can store the full 32-bit value (`imm20 << 12`) in a constant pool at the end of ROM and replace the entire sequence with a single load.

```asm
lw    rd, pool_entry(x0)  # rd = *(pool_entry)  where pool_entry holds imm20 << 12
```

This requires that `pool_entry` fits in a 12-bit signed offset from `x0` (address < 2048), which holds for the short programs typical of the educational processor.

#figure(
  table(
    columns: 3,
    [*Approach*], [*Instructions*], [*Memory reads*],
    [addi + sll], [~5], [0],
    [lw from pool], [1], [1],
  ),
  caption: [Comparison of LUI synthesis approaches for rvsc0],
)

*Implementation choice.* Approach 2 (constant pool via `lw`) was selected: it produces a single instruction at each use site and avoids the shift instructions that rvsc0 does not support natively. The constraint it imposes --- every pool entry must reside within the 12-bit signed offset range of `x0`, i.e., below address 2048 --- is met by the rvsc0 linker script, which places `.text` at address 0 and the constant pool immediately after. Programs that fit within the first 2 KB of ROM always satisfy this constraint.

==== LB, LBU, LH, LHU <sc1-lb-synthesis>

Since sc1 supports only `lw` (32-bit word loads), every byte or halfword load is synthesized in four steps: align the address to a word boundary, load the word, extract the target unit by shift, and sign-extend or zero-extend.

*Proof of correctness.* The expression `addr & ~3u` clears the two low-order bits, yielding the address of the word that contains the byte or halfword at `addr`. The unit's position within the word is `addr & MASK` (MASK = 3 for bytes, 2 for halfwords), and its bit offset is `(addr & MASK) * 8` (values 0, 8, 16, 24 for bytes; 0 or 16 for halfwords). Right-shifting the word by this amount moves the target unit to bits $[N-1:0]$ where $N$ is 8 or 16. A subsequent shift pair of $32-N$ bits — left then right — isolates the unit and performs either sign extension (arithmetic right shift, for `lb`/`lh`) or zero extension (logical right shift, for `lbu`/`lhu`). This is correct for any address alignment because the memory model is little-endian and the bit offset exactly encodes the unit's position within the word. $square$

This algorithm is emitted at runtime — it does not assume the offset is constant at compile time.

```c
/* Common algorithm for lb/lbu/lh/lhu */
uint32_t aligned = addr & ~3u;          // word-aligned: addr & -4
uint32_t word    = lw(aligned);         // lw 0(aligned)
uint32_t unit_off = addr & MASK;        // MASK = 3 for byte, 2 for halfword
uint32_t bit_off  = unit_off * 8;       // least-significant bit position
uint32_t shifted  = word >> bit_off;    // [srl] extracts unit to bits [N:0]
// lbu/lhu: zero-extend via symmetric shift
uint32_t result   = (shifted << BITS) >> BITS;  // logical: [srl]
// lb/lh:  sign-extend via arithmetic shift
int32_t  result   = (int32_t)(shifted << BITS) >> BITS;  // arithmetic: [sra]
// BITS = 24 for byte (QImode), 16 for halfword (HImode)
```

```asm
# lb rd, 0(rs1)  (address in rs1, byte_pos unknown at compile-time)
addi  t0, x0, -4
and   t0, rs1, t0         # t0 = rs1 & -4  (word-aligned)
lw    t1, 0(t0)           # t1 = word containing the byte
addi  t0, x0, 3
and   t0, rs1, t0         # t0 = rs1 & 3  (byte position: 0–3)
[sll  t0, t0, 3]          # t0 = byte_pos * 8  (bit offset)
[srl  t1, t1, t0]         # t1 >>= bit_off  (byte in bits [7:0])
[sll  t1, t1, 24]         # t1 <<= 24  (byte in bits [31:24])
[sra  rd,  t1, 24]        # rd >>= 24  (sign-extend → lb)
                          # use [srl] in the last step for lbu (zero-extend)

# lh rd, 0(rs1)  — identical but MASK = 2, BITS = 16
addi  t0, x0, -4
and   t0, rs1, t0         # word-aligned
lw    t1, 0(t0)
addi  t0, x0, 2
and   t0, rs1, t0         # t0 = rs1 & 2  (0 or 2: which halfword)
[sll  t0, t0, 3]          # t0 = half_pos * 8  (0 or 16)
[srl  t1, t1, t0]         # halfword in bits [15:0]
[sll  t1, t1, 16]
[sra  rd,  t1, 16]        # sign-extend → lh  (srl for lhu)
```

Since sc1 shifts are themselves synthesized via `add`/`beq` loops, each byte load expands to approximately 70–80 instructions. This cost is intentional: it makes the value of native `lb`/`lbu` instructions tangible to the student building the processor.

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    stroke: none,
    inset: (y: 4pt),
    [*Operation*], [*Approx. instructions*], [*Extra registers*],
    [`lb`, `lbu`], [~70–80], [2 (t0, t1)],
    [`lh`, `lhu`], [~70–80], [2 (t0, t1)],
  ),
  caption: [Cost summary for LB, LBU, LH, and LHU synthesis],
)

=== Stores <sc1-stores>

==== SB and SH <sc1-sb>

A byte store (`sb`) or halfword store (`sh`) is implemented as a read-modify-write: load the word containing the target location, clear the target bits, insert the new value, and write back. The bit offset is computed at runtime since the base address is unknown at compile time.

*Proof of correctness.* Let `word` be the current word at the aligned address, `mask` the bit-field covering the target unit (e.g., `0xFF << shift` for a byte), and `val` the new value to write. The expression $("word" & ~"mask") | ("val" & "mask")$ replaces exactly the target bits with `val` while preserving all others. For each bit $i$: if `mask[i] = 1`, then `(word & ~mask)[i] = 0` and `(val & mask)[i] = val[i]`, yielding `val[i]`; if `mask[i] = 0`, then `(val & mask)[i] = 0` and `(word & ~mask)[i] = word[i]`, yielding `word[i]`. $square$

A byte store is implemented as:

```c
void sb(uint8_t *addr, uint32_t rs2) {
    uint32_t aligned_addr  = (uint32_t)addr & ~3u;   // addr & -4
    uint32_t byte_pos      = (uint32_t)addr & 3u;    // runtime: 0–3
    uint32_t shift         = byte_pos * 8u;           // runtime: 0,8,16,24
    uint32_t old_word      = *(uint32_t *)aligned_addr;     // lw
    uint32_t byte_mask     = 0xFFu << shift;                // [sll] runtime shift
    uint32_t new_byte      = (rs2 & 0xFFu) << shift;        // [sll] runtime shift
    uint32_t new_word      = (old_word & ~byte_mask) | new_byte;
    *(uint32_t *)aligned_addr = new_word;                    // sw
}
```

```asm
# sb rs2, 0(rs1)   — address in rs1, byte position unknown at compile-time
addi  t0, x0, -4
and   t3, rs1, t0           # t3 = rs1 & -4  (word-aligned)
addi  t0, x0, 3
and   t0, rs1, t0           # t0 = rs1 & 3  (byte_pos: 0–3)
add   t0, t0, t0            # \
add   t0, t0, t0            #  t0 = byte_pos * 8  (constant-3 sll; no loop needed)
add   t0, t0, t0            # /
lw    t1, 0(t3)             # t1 = old word
addi  t2, x0, 255           # t2 = 0xFF
[sll  t2, t2, t0]           # t2 = 0xFF << shift  (mask)
[not  t2, t2]               # t2 = ~mask  — 2 insns (Section 5.2.1)
and   t1, t1, t2            # t1 = old_word & ~mask  (clear target byte)
addi  t2, x0, 255
and   t2, rs2, t2           # t2 = rs2 & 0xFF  (isolate input byte)
[sll  t2, t2, t0]           # t2 = byte_value << shift
or    t1, t1, t2            # t1 = word with byte inserted
sw    t1, 0(t3)             # write back
```

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    stroke: none,
    inset: (y: 4pt),
    [*Extra memory ops*], [*Approx. instructions (full expansion)*], [*Extra registers*],
    [1 lw + 1 sw], [~100], [3 (t0–t2)],
  ),
  caption: [Cost summary for SB synthesis],
)

The `sh` synthesis follows the same read-modify-write pattern as `sb`, with `MASK = 2` and mask constant `0xFFFF`. Since `0xFFFF` exceeds the 12-bit `addi` range, it is materialized via `lui 0x10; addi -1`.

```c
void sh(uint16_t *addr, uint32_t rs2) {
    uint32_t aligned = (uint32_t)addr & ~3u;
    uint32_t shift   = ((uint32_t)addr & 2u) * 8u;   // runtime: 0 or 16
    uint32_t word    = *(uint32_t *)aligned;
    uint32_t mask    = 0xFFFFu << shift;
    uint32_t new_w   = (word & ~mask) | ((rs2 & 0xFFFFu) << shift);
    *(uint32_t *)aligned = new_w;
}
```

```asm
# sh rs2, 0(rs1)
addi  t0, x0, -4
and   t3, rs1, t0           # t3 = rs1 & -4  (word-aligned)
addi  t0, x0, 2
and   t0, rs1, t0           # t0 = rs1 & 2  (hw_pos: 0 or 2)
add   t0, t0, t0            # \
add   t0, t0, t0            #  t0 = hw_pos * 8  (0 or 16; constant-3 sll)
add   t0, t0, t0            # /
lw    t1, 0(t3)             # t1 = old word
lui   t2, 0x10              # \
addi  t2, t2, -1            #  t2 = 0xFFFF
[sll  t2, t2, t0]           # t2 = 0xFFFF << shift  (mask)
[not  t2, t2]               # t2 = ~mask  — 2 insns (Section 5.2.1)
and   t1, t1, t2            # t1 = old_word & ~mask
lui   t2, 0x10
addi  t2, t2, -1            # t2 = 0xFFFF
and   t2, rs2, t2           # t2 = rs2 & 0xFFFF
[sll  t2, t2, t0]           # t2 = hw_value << shift
or    t1, t1, t2            # t1 = word with halfword inserted
sw    t1, 0(t3)             # write back
```

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    stroke: none,
    inset: (y: 4pt),
    [*Extra memory ops*], [*Approx. instructions (full expansion)*], [*Extra registers*],
    [1 lw + 1 sw], [~105], [3 (t0–t2)],
  ),
  caption: [Cost summary for SH synthesis],
)

=== Control Flow <sc1-jump>

==== JAL <sc1-jal>

`jal ra, target` saves the return address (`PC + 4`) into `ra` and jumps to `target`. rvsc1 does not support `auipc`-based PC-relative addressing; `jal` must therefore be synthesized from `lui`, `addi`, and `jalr`.

*Equivalence.* The semantics of `jal ra, target` are: $"ra" <- "PC" + 4$; $"PC" <- "target"$. Since `lui`+`addi` can materialize any 32-bit absolute address, the two effects can be split: materialize the return address into `ra` before the jump, then jump to `target` via `jalr`.

```asm
# jal ra, target  →
lui   ra,  %hi(back)       # ra[31:12] = upper bits of (PC+4)
addi  ra,  ra, %lo(back)   # ra = PC+4
lui   t0,  %hi(target)
addi  t0,  t0, %lo(target)
jalr  x0,  0(t0)           # PC ← target; ra already holds return address
back:
```

*Cost*: 5 instructions per call site; 1 extra register (`t0`).

== GCC Implementation <sc1-gcc-impl>

=== Target Flags <sc1-flags>

Each synthesized instruction corresponds to a Boolean flag declared in `gcc/config/riscv/riscv.opt`. When a flag is zero, the corresponding `define_insn` condition evaluates to false (suppressing native instruction emission) while the `define_expand` synthesis path fires and calls `DONE`. @tbl-flags lists all flags added for this project.

#figure(
  table(
    columns: (auto, auto, auto),
    align: left,
    [*Flag*], [*Macro*], [*Disabled for*],
    [`-mfence`],  [`TARGET_FENCE`],  [rvsc0, rvsc1, rvsc2],
    [`-mauipc`],  [`TARGET_AUIPC`],  [rvsc0, rvsc1],
    [`-mshift`],  [`TARGET_SHIFT`],  [rvsc0, rvsc1],
    [`-mxor`],    [`TARGET_XOR`],    [rvsc0, rvsc1],
    [`-mori`],    [`TARGET_ORI`],    [rvsc0, rvsc1],
    [`-mandi`],   [`TARGET_ANDI`],   [rvsc0, rvsc1],
    [`-mbne`],    [`TARGET_BNE`],    [rvsc0, rvsc1],
    [`-mslt`],    [`TARGET_SLT`],    [rvsc0, rvsc1],
    [`-mslti`],   [`TARGET_SLTI`],   [rvsc0, rvsc1],
    [`-mblt`],    [`TARGET_BLT`],    [rvsc0, rvsc1],
    [`-mbge`],    [`TARGET_BGE`],    [rvsc0, rvsc1],
    [`-mbltu`],   [`TARGET_BLTU`],   [rvsc0, rvsc1],
    [`-mbgeu`],   [`TARGET_BGEU`],   [rvsc0, rvsc1],
    [`-mbyte`],   [`TARGET_BYTE`],   [rvsc0, rvsc1],
    [`-mhalf`],   [`TARGET_HALF`],   [rvsc0, rvsc1],
  ),
  caption: [Target option flags added for this project],
) <tbl-flags>

All flags have `Init(1)` (enabled by default). The per-target header (`rvscN.h`) disables the appropriate subset via `CC1_SPEC`.

=== Machine Description Patterns <sc1-md>

The GCC machine description (`riscv.md`) uses two complementary constructs per synthesized operation: a `define_insn` guarded by `TARGET_XYZ` that emits the native instruction when the flag is enabled, and a `define_expand` guarded by `!TARGET_XYZ` that emits the synthesis sequence and calls `DONE`, preventing GCC from falling through to the native insn. The XOR synthesis illustrates the pattern:

```scheme
;; Native XOR — emitted only when TARGET_XOR is true
(define_insn "xorsi3"
  [(set (match_operand:SI 0 "register_operand" "=r")
        (xor:SI (match_operand:SI 1 "register_operand" "r")
                (match_operand:SI 2 "register_operand" "r")))]
  "TARGET_XOR"
  "xor\t%0,%1,%2")

;; XOR synthesis — fires when !TARGET_XOR
(define_expand "xorsi3"
  [(set (match_operand:SI 0 "register_operand")
        (xor:SI (match_operand:SI 1 "register_operand")
                (match_operand:SI 2 "register_operand")))]
  "!TARGET_XOR"
{
  rtx t0 = gen_reg_rtx (SImode);
  emit_insn (gen_andsi3 (t0, operands[1], operands[2]));
  emit_insn (gen_one_cmplsi2 (t0, t0));      /* [not] */
  emit_insn (gen_iorsi3 (operands[0], operands[1], operands[2]));
  emit_insn (gen_andsi3 (operands[0], t0, operands[0]));
  DONE;
})
```

The `DONE` call signals that the expansion body has fully handled the operation; GCC does not attempt to match the `define_insn` afterwards.

=== Worked Example: XOR in C to Assembly <sc1-example>

The following traces how `unsigned f(unsigned a, unsigned b) { return a ^ b; }` is compiled by `rvsc1-unknown-elf-gcc -S -O1`:

+ *Frontend*: parses `a ^ b` to an AST `XOR_EXPR` node.
+ *GIMPLE*: `_1 = a ^ b; return _1;` — language-independent SSA form.
+ *RTL lowering*: GCC attempts to emit `xorsi3`. `TARGET_XOR` is 0 (rvsc1 disables XOR), so the `define_expand` synthesis body fires.
+ *Expansion*: the body allocates a pseudo-register, emits `andsi3`, `one_cmplsi2`, `iorsi3`, and `andsi3` into the RTL stream, then calls `DONE`.
+ *Register allocation*: GCC maps pseudo-registers to physical registers (`a0`, `a1`, `t0`) such that no `xor` instruction appears.
+ *Assembly output*: inspecting the result with `grep xor` returns empty; only `and`, `sub`, `addi`, and `or` appear — all native sc1 instructions.

=== Target Registration <sc1-registration>

Each target triple `rvscN-unknown-elf` is registered in two files:

- `gcc/config/config.sub` normalises the CPU name pattern `rvscN`, allowing GCC's driver to recognize the triple.
- `gcc/config.gcc` maps `rvscN-*-elf*` to `cpu_type=riscv`, sets the default architecture and ABI (`--with-arch=rv32i --with-abi=ilp32` for sc0 and sc1), and appends `riscv/rvscN.h` to `tm_file`.

The per-target header defines `CC1_SPEC` to inject flags automatically:

```c
// rvsc1.h
#define CC1_SPEC \
  "%{!mfence:-mno-fence}  %{!mauipc:-mno-auipc} %{!mshift:-mno-shift}" \
  " %{!mxor:-mno-xor}     %{!mori:-mno-ori}      %{!mandi:-mno-andi}"  \
  " %{!mbne:-mno-bne}     %{!mslt:-mno-slt}      %{!mslti:-mno-slti}"  \
  " %{!mblt:-mno-blt}     %{!mbge:-mno-bge}                          "  \
  " %{!mbltu:-mno-bltu}   %{!mbgeu:-mno-bgeu}                        "  \
  " %{!mbyte:-mno-byte}   %{!mhalf:-mno-half}"
```

The construct `%{!mfoo:-mno-foo}` reads: "if the user did not pass `-mfoo`, inject `-mno-foo`." A user invoking `rvsc1-unknown-elf-gcc program.c` passes no manual flags; the driver inserts the complete synthesis-enabling set automatically. The toolchain is built with a standard configure invocation using the target triple:

// TODO: add the build instructions, not sure if here
```sh
../gcc/configure \
    --target=rvsc1-unknown-elf \
    --prefix=$(pwd)/install \
    --enable-languages=c
```

== Known Limitations

=== rvsc0: No Function Calls

The rvsc0 processor supports neither `jalr` nor `jal`. Functions cannot be called or returned from in rvsc0-compiled code: the compiler has no instruction with which to perform an indirect jump while saving the return address. As a consequence, only single-function C programs --- programs where all control flow remains within `main()` and no other function is invoked --- can be compiled for rvsc0. Any C source that contains a call to a function other than `main` will either fail at link time or produce incorrect control flow at runtime.

=== rvsc1: Function Body Size Limit

The only native conditional branch in rvsc1 is `beq`, which has a ±4 KB PC-relative offset range (12-bit signed immediate). For branch targets that exceed this range, the GCC backend emits a long form:

```asm
beq  rs1, rs2, skip        # short branch: skip the jump if condition holds
lui  t1, %hi(target)
addi t1, t1, %lo(target)
jr   t1                    # absolute jump to target
skip:
```

This long form is itself valid rvsc1 code, so correctness is preserved. However, the long form for the inverted branch (`bne`) chains through the `bne` synthesis (which uses `beq`), so individual function bodies should remain under approximately 4 KB of machine code --- roughly 1 000 synthesized instructions --- to avoid triggering branch relaxation in unexpected cases. Typical educational programs are well within this limit.

=== rvsc0 and rvsc1: No 64-bit Integers or Floating Point

Both targets compile freestanding bare-metal C without a C standard library or a compiler support library (libgcc). The C types `long long`, `unsigned long long`, `float`, and `double` are syntactically accepted by the compiler but will fail at link time if the required helper routines (`__muldi3`, `__addsf3`, etc.) are not available. These types are not in scope for this project and are not tested.

// TODO: investigate libgcc compilation

= Results

== Tests

Two independent test layers verify the two correctness requirements stated in Chapter 4: ISA compliance and behavioral equivalence.

=== ISA Compliance Tests

ISA compliance is verified by `run_tests.py`. For every `.c` file in `scw/test/`, the script compiles the program with `-S -O1`, assembles the output with `riscv32-none-elf-as`, disassembles the resulting object with `riscv32-none-elf-objdump -M no-aliases`, and checks every mnemonic in the disassembly against the per-target allowlist in `instructions.txt`. The `-M no-aliases` flag is essential: it expands pseudo-instructions to their underlying real opcodes before the check, so a pseudo such as `ret` (which expands to `jalr x0, 0(ra)`) cannot pass undetected for a target that forbids `jalr`.

#figure(
  table(
    columns: (auto, auto, 1fr),
    align: left,
    [*Test file*], [*Targets*], [*Operations exercised*],
    [`sc1_not.c`],         [rvsc0, rvsc1], [Bitwise NOT (`~`)],
    [`sc1_xor.c`],         [rvsc0, rvsc1], [XOR register and immediate],
    [`sc1_shift.c`],       [rvsc0, rvsc1], [SLL, SRL, SRA with constant counts],
    [`sc1_sll_var.c`],     [rvsc0, rvsc1], [SLL with variable shift count],
    [`sc1_srl.c`],         [rvsc0, rvsc1], [SRL with variable shift count],
    [`sc1_sra.c`],         [rvsc0, rvsc1], [SRA with variable shift count],
    [`sc1_slt.c`],         [rvsc0, rvsc1], [SLT and SLTU],
    [`sc1_andi.c`],        [rvsc0, rvsc1], [ANDI (immediate AND)],
    [`sc1_ori.c`],         [rvsc0, rvsc1], [ORI (immediate OR)],
    [`sc1_branch.c`],      [rvsc0, rvsc1], [BNE, BLT, BGE, BLTU, BGEU],
    [`sc1_lb.c`],          [rvsc0, rvsc1], [LB (signed byte load)],
    [`sc1_lbu.c`],         [rvsc0, rvsc1], [LBU (unsigned byte load)],
    [`sc1_lh.c`],          [rvsc0, rvsc1], [LH (signed halfword load)],
    [`sc1_lhu.c`],         [rvsc0, rvsc1], [LHU (unsigned halfword load)],
    [`sc1_sb.c`],          [rvsc0, rvsc1], [SB (byte store)],
    [`sc1_sh.c`],          [rvsc0, rvsc1], [SH (halfword store)],
    [`sc1_call.c`],        [rvsc1],        [Function call (JAL synthesis)],
    [`sc1_loop.c`],        [rvsc1],        [Loop with synthesized branch],
    [`sc1_add.c`],         [rvsc0, rvsc1], [ADD and ADDI (native, regression)],
    [`fence.c`],           [rvsc2],        [FENCE absent from output],
  ),
  caption: [ISA compliance test files and the operations they cover],
)

=== Behavioral Tests --- rvsc1

Behavioral equivalence for rvsc1 is verified by differential testing against a standard upstream cross-compiler. For each `behav_*.c` test file, the program is compiled with both `rvsc1-unknown-elf-gcc -O1` and the reference compiler `riscv32-none-elf-gcc -march=rv32i -O1`. Both outputs are assembled with `riscv32-none-elf-as`, linked with the same bare-metal HTIF startup (`startup32.S`) and linker script (`link32.ld`), and executed on Spike with `--isa=rv32i`. The test passes if and only if both binaries produce the same exit code.

The HTIF startup calls `main()`, captures its return value, writes `(return_value << 1) | 1` to the `tohost` memory address, and spins. Spike reads `tohost` and exits with the return value. Test programs return 0 on success and a distinct nonzero error code for each failing assertion, so a mismatch between the two exit codes pinpoints the failing case.

#figure(
  table(
    columns: (auto, 1fr),
    align: left,
    [*Test file*], [*Operations exercised*],
    [`behav_not.c`],         [Bitwise NOT],
    [`behav_xor.c`],         [XOR register and immediate],
    [`behav_shift_const.c`], [SLL, SRL, SRA with constant counts],
    [`behav_shift_var.c`],   [SLL, SRL, SRA with variable shift counts],
    [`behav_andi.c`],        [ANDI],
    [`behav_ori.c`],         [ORI],
    [`behav_bne.c`],         [BNE],
    [`behav_branch.c`],      [BLT, BGE, BLTU, BGEU],
    [`behav_lb.c`],          [LB],
    [`behav_lbu.c`],         [LBU],
    [`behav_lh.c`],          [LH],
    [`behav_lhu.c`],         [LHU],
    [`behav_sb.c`],          [SB],
    [`behav_sh.c`],          [SH],
    [`behav_call.c`],        [Function call and return],
    // TODO: add behav_slt.c and behav_sra.c
  ),
  caption: [Behavioral test files for rvsc1 differential testing],
)

=== Behavioral Tests --- rvsc0

rvsc0 has no `jalr` instruction, so the standard HTIF startup (which uses `call main`, expanding to `jalr`) cannot be used. Instead, rvsc0 test programs are structured so that `main()` writes its result directly to the `tohost` memory address via `sw` and then spins with `beq x0, x0, .`. The written value follows the same HTIF encoding as the rvsc1 tests. For differential testing, the same C source is compiled with `riscv32-none-elf-gcc` with the identical `tohost`-writing structure, and the two Spike exit codes are compared.

=== rvsc2 --- Fence Mnemonic Check

For rvsc2, only ISA compliance needs to be verified: the `fence` mnemonic must be absent from the output. This is confirmed by `fence.c`, which contains a C construct that would emit `fence` on a full RV32I target. The ISA compliance script (`run_tests.py`) checks that neither `fence` nor `fence.i` appears in the disassembly. No behavioral testing is required because the remainder of the rvsc2 instruction set is identical to rvsc3 (full RV32I), whose correctness is already established by the upstream GCC test suite.

=== rvsc3 and Above

No testing is performed for rvsc3 through rvsc7. These targets contain no synthesis code: they only enable flags that correspond to instructions already present in the upstream RISC-V backend. Their correctness follows from the correctness of the upstream backend and the GCC test suite.

== Program Size

Each synthesized instruction expands into a sequence of native instructions, increasing the static size of the compiled binary. The expansion ratio --- the number of native instructions emitted divided by the number of instructions a full-ISA compiler would emit --- quantifies the cost of each missing hardware instruction.

Synthesis sequences fall into two categories. _Constant-length_ expansions always emit the same number of instructions regardless of operand values: NOT expands to 2 instructions, XOR to 6 (counting the NOT it calls), and each immediate variant (ANDI, ORI) adds 1 instruction. _Variable-length_ expansions depend on runtime values: SLL, SRL, and SRA use count-down loops whose length is proportional to the shift amount, with worst-case counts of 127, ~170, and ~200 instructions respectively for a shift of 31.

// TODO [DATA REQUIRED]
// Run rvsc0, rvsc1, and rvsc3 compilers on the programs below and count instructions:
//   riscv32-none-elf-objdump -d <elf> | grep -c '^\s\+[0-9a-f]\+:'
//
// Programs: behav_xor.c, behav_shift_var.c (compiled with shift amount 8), behav_sb.c
// Table columns: Program | rvsc3 instructions (native) | rvsc1 instructions (synthesized) | expansion ratio
//
// Replace this TODO block with the populated table.

== Program Performance

Since the target processor is single-cycle, every instruction retires in exactly one clock cycle (ignoring memory latency, which is implementation-dependent). Instruction count therefore equals clock cycle count for programs that access only register operands. Memory operations add latency that depends on the specific hardware implementation.

Dynamic instruction counts are measured by running each compiled binary on Spike with `--log-commits` and counting the number of retired-instruction log lines. Variable-length syntheses are measured across a range of operand values to characterise their runtime behavior.

For SLL with a shift amount $b$, the synthesis loop executes $b$ iterations of 4 instructions each plus 3 setup instructions, giving a total retired instruction count of $3 + 4b$. This predicts:

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: left,
    [*Shift amount*], [*Predicted (3+4b)*], [*rvsc3 (native)*], [*rvsc1 (measured)*],
    [0],  [3],   [1], [TODO],
    [1],  [7],   [1], [TODO],
    [8],  [35],  [1], [TODO],
    [16], [67],  [1], [TODO],
    [31], [127], [1], [TODO],
  ),
  caption: [SLL retired instruction counts: predicted vs. measured],
)

// TODO [DATA REQUIRED]
// Run the same programs as in the Program Size section.
// Command: spike --log-commits --isa=rv32i <elf> 2>&1 | grep -c '^[0-9]'
// Table columns: Program | rvsc3 cycles | rvsc1 cycles | overhead ratio
//
// Replace the SLL TODO values above and add a second table for xor and sb programs.

== Discussion

// TODO [after data is collected]: ~3 paragraphs:
// 1. ISA compliance: the compiler never emits a forbidden mnemonic, as confirmed
//    by every ISA compliance test passing. The use of objdump -M no-aliases ensures
//    pseudo-instructions are fully expanded before the check.
// 2. Behavioral equivalence: rvsc1 synthesized programs produce the same exit codes
//    as reference RV32I binaries on Spike across all differential tests. rvsc0 programs
//    produce the same tohost values as the reference for single-function programs.
// 3. Performance cost: quantify overhead from the tables above. Note that for typical
//    educational programs (small shift amounts, few byte operations) the overhead is
//    modest and predictable. The pedagogical value is that students can observe the
//    concrete cost of each ISA restriction by comparing -S output between rvsc1 and rvsc3.

= Conclusion

= References

#bibliography("refs.bib", style: "ieee")

