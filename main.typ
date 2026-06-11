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

The main acknowledgements are directed to ...

// --- Abstract ---
#heading(level: 1, numbering: none, outlined: false)[Abstract]

This is the english abstract.

*Keywords*: GCC. RISC-V. Compiler. Educational processor.

// --- List of Abbreviations and Acronyms ---
#heading(level: 1, numbering: none)[List of Abbreviations and Acronyms]

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

// --- Table of Contents ---
#heading(level: 1, numbering: none)[TABLE OF CONTENTS]
#outline(title: none, indent: auto, depth: 3)

// --- Textual Elements Setup ---
#set page(numbering: "1")


= Introduction

== Motivation
// - Presents a brief state-of-the-art overview of the subject that will be the theme of the work,
// based on the consulted references.
// - Consulted works must be cited and referenced in the text.
// - Presents the context in which the work will be developed.

_Computer Organization and Design: RISC-V Edition_ by Patterson and Hennessy @patterson2020 is one of the most widely adopted references in undergraduate computer architecture courses worldwide. At the University of S~ao Paulo's Escola Polit'ecnica, the course PCS3225 --- Digital Systems 2 --- uses this textbook as its primary reference. Students follow its progression step by step, implementing a simplified RISC-V processor in Verilog and simulating it with Verilator.

The simplified single-cycle processor introduced in Chapter 4.4 of the book --- _A Simple Implementation Scheme_ --- supports only eight instructions: `lw`, `sw`, `beq`, `add`, `addi`, `sub`, `and`, and `or`. This restriction is deliberate and pedagogically motivated: it isolates the essential datapath and control concepts before more complex features are introduced. A subsequent homework assignment extends the processor with `lui` and `jalr`, enabling function calls. Both implementations are partial subsets of the RV32I base ISA @riscv-spec.

This restriction creates a practical barrier. The standard RISC-V GCC toolchain (`riscv32-unknown-elf-gcc`) targets the full RV32I base ISA @riscv-spec, which includes shift instructions, byte and halfword memory operations, multiple branch variants, and PC-relative addressing. Any C program compiled with this toolchain will emit instructions that the student-built processor cannot execute.

As a result, students are limited to running hand-written assembly or small programs provided by the professor. They cannot compile and run arbitrary C code on the processor they designed and built. This prevents them from connecting the hardware they implement to the software abstractions they use daily, and forecloses the pedagogical opportunity of observing how a compiler translates and optimizes C code into the primitive instructions their processor supports.

== Objective
// - Present the objective of the work in a precise and concise manner.
// - Should answer the question: What is the work?

This work develops eight progressive GCC compiler targets for the simplified RISC-V processors described in the Hennessy and Patterson textbook, enabling students of the PCS3225 course at USP to compile and run C programs on the processors they build in Verilog.

The specific objectives are:

+ Define eight GCC target triples (`rvsc0` through `rvsc7`), each corresponding to a stage in the incremental processor implementation described in the textbook.
+ Implement instruction synthesis in the GCC machine description so that each operation unsupported by a given target is transparently replaced by an equivalent sequence of supported instructions.
+ Validate that each target emits only the mnemonics its corresponding processor supports.
+ Verify behavioral correctness of the generated code using the Spike RISC-V ISA simulator.

== Rationale
// - Presents why the developed work is important (importance and necessity for society,
// comparison with relevant consulted works, etc.).
// - Consulted works must be cited and referenced in the text.
// - Should answer the question: Why is the work important?

The gap between restricted educational processors and real compiler toolchains is a known friction point in computer architecture education. Several tools and projects address parts of this problem but none address it fully. RARS (RISC-V Assembly and Runtime Simulator) #footnote[TODO: add @rars citation] provides an assembly-level environment for writing and running RISC-V programs but does not support C compilation. Academic projects such as Wildcat #footnote[TODO: add @wildcat2025 citation], BRISC-V #footnote[TODO: add @brisc2019 citation], and riscv-simple-sv implement pedagogical RISC-V processors in HDL, but all rely on the standard unmodified `riscv-gnu-toolchain`, which presupposes full RV32I support. None of them address the C compilation problem for processors with restricted instruction sets.

To the best of the authors' knowledge, no prior work creates restricted GCC backends for pedagogical RISC-V subsets. The approach taken here --- modifying the GCC RISC-V backend's `riscv.md` expand bodies to synthesize missing instructions from available ones @gcc-internals --- is novel in the context of pedagogical toolchains. It allows a standard C program to be compiled correctly for a processor with, for example, no shift instructions, no `bne`, and no PC-relative addressing, by transparently emitting equivalent sequences of the primitive operations the hardware does support.

Beyond enabling C compilation, the generated assembly has direct educational value. Students can compile a C function, inspect the output with `-S`, and observe concretely how the compiler synthesizes a shift operation from repeated additions, or a signed comparison from subtraction and bit manipulation. This bridges the gap between the hardware they implement and the software abstractions they encounter in other courses.

== Document Organization

The remainder of this monograph is organized as follows. Chapter 2 presents the conceptual background, covering the GCC compilation framework, the RISC-V instruction set architecture, and the architecture of the Hennessy-Patterson educational processor. Chapter 3 describes the development method, including the specification, implementation, and testing phases followed for each target. Chapter 4 specifies the requirements for each of the eight targets, defining the allowed instruction sets and the synthesis obligations imposed on the compiler. Chapter 5 details the implementation, describing the instruction synthesis techniques developed inside the GCC machine description and the per-target configuration files. Chapter 6 presents the test results and discusses the validity and limitations of each target. Chapter 7 presents the conclusions, contributions, and directions for future work.


= Conceptual Background
// - Defines the representative sections based on the work.
// - Presents the concepts used and the literature review.
// - Consulted works must be cited and referenced in the text.
== GCC
== RISC-V
== Hennessy and Patterson Architecture
- Has a single-cycle processor
- Fully functional ALU
- No control unit — combinational logic, suitable for 1st/2nd year students
- Does not support the full instruction set


= Requirements Specification
// Define and describe the requirements of the work. The work may involve system development,
// improvement of an existing system, process definition, techniques, procedures, or
// another type of work agreed upon with the advisor.

This work aims to develop simplifications in the GCC backend to support simplified implementations of a RISC-V processor, enabling intermediate functional implementations. To this end, six processors are defined with special targets that emit only the instruction set they support.

== rvsc0 - Basic Single-Cycle
The rvsc0 is the simplest implementation, a 32-bit single-cycle processor, described in Chapter 4.4 of Hennessy and Patterson, A Simple Implementation Scheme.


#quote[In this section, we look at what might be thought of as a simple implementation of our RISC-V subset. [...] This simple implementation covers load word (lw), store word (sw), branch if equal (beq), and the arithmetic-logical instructions add, sub, and, and or.]


// TODO: make it a table
As mentioned in the textbook, this implementation supports only the following instructions:
- lw - load word
- sw - store word
- beq - branch if equal
- add - arithmetic add
- addi - arithmetic add with immediate
- sub - arithmetic subtraction
- and - bitwise and
- or - bitwise or

Therefore, the compiler must be capable of emitting only these instructions for this processor.

=== Limitations
This implementation has no interaction with the PC, so it is not possible to support recursive subroutines — only static calls. In this case, the compiler must emit an error.

// it is possible to "return" using beq
// perhaps we should not inline, as it is more instructive to inspect the code

=== Implementation Details
In the student implementation the processor has access to RAM with 2 read cycles and 5 write cycles over a Wishbone bus. The address space is as follows:
- Boot: 0x200
- RAM: end of address space
- Peripherals: 0xFC00000000
	- single register for the LED


== rvsc1 - Extended Single-Cycle
// TODO: check if lui is that much necessary
The rvsc1 extends rvsc0 with load upper immediate (`lui`) and Jump and Link Register (`jalr`), thereby removing the recursive function limitation of the previous processor.

The complete instruction set of rvsc1 is:
// TODO: make a table
- Inherited from sc0: `lw`, `sw`, `beq`, `add`, `addi`, `sub`, `and`, `or`
- `jalr` — function return and indirect calls
- `lui` — loading absolute addresses (upper 20 bits of a 32-bit value)

== rvsc2 - Single-Cycle Without Fence and Control
The rvsc2 implements all rv32i instructions except Memory Order, CSR Access, and System instructions. Being a single-core single-cycle processor, memory ordering instructions can be removed without loss of functionality. Likewise, CSR and System instructions were removed as they are OS-specific and have no use in simple bare-metal code.

The ISA of this processor is therefore:
// TODO: make a table
- add
- addi
- and
- andi
- auipc
- beq
- bge
- bgeu
- blt
- bltu
- bne
- jal
- jalr
- lb
- lbu
- lh
- lhu
- lui
- lw
- or
- ori
- sb
- sh
- sll
- slli
- slt
- slti
- sltiu
- sltu
- sra
- srai
- srl
- srli
- sub
- sw
- xor
- xori

With the exception of the following instructions:
- Memory Order:
  - `fence`   - Instruction fence
  - `fence.i` - Fence
  - `sfence.vma` - Address Transalation Fence
- CSR Access:
  - `CSRRWI` - CSR Read/Write Immediate
  - `CSRRSI` - CSR Read/Set Immediate
  - `CSRRCI` - CSR Read/Clear Immediate
  - `CSRRW`  - CSR Read/Write
  - `CSRRS`  - CSR Read/Set
  - `CSRRC`  - CSR Read/Clear
- System:
  - `ECALL` - Enviroemnt Call
  - `EBREAK` - Enviroment Breakpoint
  - `SRET` - Supervisior Exception Return
  - `WFI` - Wait for Interrupt

== rvsc3 - Single-Cycle rv32i
The rvsc3 supports all sc2 instructions plus Memory Order, CSR Access, and System instructions, thus implementing the full rv32i instruction set.

// TODO:
// explain NOPs in pipeline processors and RISC-V
// explain that we are generating this target to make it easier to progress from here

== rvsc4 - Single-Cycle rv64i
The sc4 is a 64-bit single-cycle processor with the full rv64i instruction set.

In addition to the sc3 instructions, it includes:
- 64-bit memory operations: `ld`, `sd`, `lwu`
- Word operations with sign-extended 64-bit results (W suffix): `addw`, `subw`, `addiw`, `sllw`, `srlw`, `sraw`, `slliw`, `srliw`, `sraiw`

== rvsc5 - Single-Cycle rv64i with Multiply
Supports all sc4 instructions plus the M extension (integer multiply and divide):

- Multiply: `mul`, `mulw`, `mulh`, `mulhu`, `mulhsu`
- Signed divide: `div`, `divw`
- Unsigned divide: `divu`, `divuw`
- Signed remainder: `rem`, `remw`
- Unsigned remainder: `remu`, `remuw`

The W-suffix variants operate on 32 bits and sign-extend the result to 64 bits, following the same convention as `addw`, `subw`, and the other W instructions from sc4.

This implements the rv64im ISA.

== rvsc6 - Single-Cycle Floating-Point

Supports all sc5 instructions plus the F (single-precision) and D (double-precision) floating-point extensions, as defined in the H&P green card.

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

It is important to note that the FD extensions have been revised and new operations have been added; for pedagogical reasons this processor implements only those present in the textbook.
// TODO: needs sources and perhaps a citation for which operations are new


== rvsc7 - Single-Cycle Atomic
Supports all sc6 instructions plus the A extension (atomic memory operations), implementing the rv64imafd_zicsr instruction set.
The `.w` variants operate on 32 bits (sign-extended to 64); the `.d` variants operate on 64 bits.

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

// TODO: check for divergence between the latest extension spec and the version implemented in the textbook

= Development Method
// - Present the development process of the work through its phases (e.g., requirements
// specification, design, implementation, testing). The phases depend on the type of system
// and should be defined with the advisor's guidance.
// - The detailed development of the phases and their results should be described in the
// subsequent chapters, not in this chapter.
// - Consulted works must be cited and referenced in the text.
- exploration and study of GCC
- requirements specification
- implementation
- testing
- analysis and limitations

- emulate all instructions

= Desenvolvimento

== Instruction Derivation
Using only the RVSC1 instruction set, all functionality required by the C language can be achieved. The chosen approach was to replace the emission of an unsupported instruction with an equivalent sequence whenever possible. In cases where no direct substitution exists, the change must be made at a different level /* to be investigated */.
// TODO: discuss about use extra register and how this is applied and impact


=== Arithmetic

Arithmetic operations only assign values to new registers and can be fully replaced by equivalent sequences.

==== not (R[rd] = ~R[rs1])

The `not` instruction is implemented in RISC-V as a pseudo-instruction using `xor`. Since `xor` is more expensive, as shown in the next section, `not` is instead derived from the `sub` instruction.

The architecture uses two's complement, so $-x = ~x + 1$, meaning we can derive negation from subtraction as $~x = -x - 1$.

In assembly:

```asm
sub  rd, x0, rs1    # rd = -rs1
addi rd, rd, -1     # rd = -rs1 - 1 = ~rs1
```

The negation operation therefore costs two instructions and uses the same number of registers.

==== xor (R[rd] = R[rs1] ^ R[rs2])

The conjunctive normal form of `xor` is

$a \^ b = (~a | ~b) & (a | b)$

As not cost 2 instruction, we can reduce the number of not's using D'morgan in the first factor

$a \^ b = ~(a & b) & (a | b)$

Which can be expressed in assembly as


```asm
and t0, rs1, rs2    # t0 = rs1 & rs2
not t0              # t0 = ~(rs1 & rs2)
or  t2, rs1, rs2    # t2 = rs1 | rs2
and rd, t0, t2      # rd = ~(rs1 & rs2) & (rs1 | rs2) = rs1 ^ rs2
```

With the `not` replacement the real assembly output will be:

```asm
and t0, rs1, rs2    # t0 = rs1 & rs2
sub  t0, x0, t0     # t0 = -(rs1 & rs2)
addi t0, t0, -1     # t0 = ~(rs1 & rs2)
or  rd, rs1, rs2    # t2 = rs1 | rs2
and rd, t0, rd      # rd = ~(rs1 & rs2) & (rs1 | rs2) = rs1 ^ rs2
```

So the xor costs now 6 instructions and requires a extra register.

==== sll (R[rd] = R[rs1] << R[rs2])

Since $x << y = x * 2^y = x * 2 * 2 * 2 * ... * 2$ and $x * 2 = x + x$.
This requires $y$ adds for the operation.

The C implementation would be

```c
  uint32_t sll(uint32_t rs1, uint32_t rs2) {
    uint32_t rd = rs1;
    for (uint32_t i = 0; i < rs2; i++) {
      rd += rd;
    }
    return rd;
  }
```

And in assembly:

```asm
# rd = rs1 << rs2
    add   t1, rs2, x0    # t1 = rs2 (save shift count before rd may alias rs2)
    add   rd, rs1, x0    # rd = rs1
    beq   t1, x0, done   # if rs2 == 0, no shift needed
loop:
    add   rd, rd, rd     # rd = rd * 2  (rd <<= 1)
    addi  t1, t1, -1     # decrement counter
    beq   t1, x0, done   # if counter == 0, done
    beq   x0, x0, loop   # unconditional branch back (x0 == x0 always)
done:
```

So the instruction take $3 + 4*b$, where $b$ is the shift number, which in 32bits architecture can be at most 32, so the worst case here is 131 instructions.

// TODO: talk about c, what happen if a << 33 in a 31 architecture. I think is UB, but need to check.


==== srl (R[rd] = R[rs1] >> R[rs2])
For the logical right shift, the solution is to iterate over the bits and write each one to its new position using bit manipulation. The C implementation is shown below.

```c
uint32_t srl(uint32_t x, uint32_t shift) {
    shift = shift & 31u;
    uint32_t result   = 0;
    uint32_t out_mask = 1u;
    uint32_t in_mask  = 1u << shift;
    while (in_mask != 0) {
        if ((x & in_mask) != 0) {
            result = result | out_mask;
        }
        out_mask = out_mask << 1;
        in_mask  = in_mask  << 1;
    }
    return result;
}
```

// shift = shift & 31u; is related to the C spec — worth verifying and mentioning.
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

==== sra (R[rd] = R[rs1] >> R[rs2])

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

=== Branch

==== slt

- need to handle overflow
- slt(a, b) = ((a XOR b) < 0) ? (a < 0) : ((a - b) < 0)

```c
uint32_t slt(uint32_t a, uint32_t b) {
    uint32_t diff      = a - b;
    uint32_t overflow  = (a ^ b) & (a ^ diff);   // MSB = 1 iff signed overflow
    uint32_t corrected = diff ^ overflow;        // fix sign bit when it lied

    return corrected >> 31;
}
```

```asm
sub  t0, rs1, rs2   # diff      = rs1 - rs2
xor  t1, rs1, rs2   # t1        = rs1 ^ rs2          (derived)
xor  t2, rs1, t0    # t2        = rs1 ^ diff          (derived)
and  t1, t1, t2     # overflow  = (rs1^rs2) & (rs1^diff)
xor  t0, t0, t1     # corrected = diff ^ overflow     (derived; t1,t2 now free)
[srl rd,  t0, 31]   # rd        = corrected >> 31     (derived)
```

==== sltu

```c
uint32_t sltu(uint32_t a, uint32_t b) {
    uint32_t diff   = a - b;
    // borrow generated where a=0,b=1; propagated where a==b and diff borrows from below
    uint32_t borrow = (~a & b) | (~(a ^ b) & diff);
    return borrow >> 31;
}
```

```asm
sub   t0, rs1, rs2   # diff      = rs1 - rs2
not   t1, rs1        # t1        = ~rs1               (derived)
and   t2, t1, rs2    # t2        = ~rs1 & rs2         (borrow generated)
xor   t3, rs1, rs2   # t3        = rs1 ^ rs2          (derived)
not   t3, t3         # t3        = ~(rs1 ^ rs2)       (derived)
and   t3, t3, t0     # t3        = ~(rs1^rs2) & diff  (borrow propagated)
or    t2, t2, t3     # borrow    = generated | propagated
[srl  rd,  t2, 31]   # rd        = borrow >> 31       (derived)
```


==== Bne

```asm
sub  t0, rs1, rs2
beq  t0, x0, skip    # rs1 == rs2, skip the jump
beq  x0, x0, target
skip:
```

==== Bge - Branch greater than or equal

```asm
# with -mno-slt: synthesize slt into t0, then beq t0, x0, target
[slt t0, rs1, rs2]  # t0 = 1 if rs1 < rs2, else 0  (derived)
beq  t0, x0, target
```

==== Blt - Branch less than

```asm
# with -mno-slt: synthesize slt into t0, then bne t0, x0, target
[slt t0, rs1, rs2]  # t0 = 1 if rs1 < rs2, else 0  (derived)
bne  t0, x0, target
```

==== Bgeu

```asm
# with -mno-slt: synthesize sltu into t0, then beq t0, x0, target
[sltu t0, rs1, rs2]  # t0 = 1 if rs1 < rs2 (unsigned), else 0  (derived)
beq  t0, x0, target
```

==== Bltu

```asm
# with -mno-slt: synthesize sltu into t0, then bne t0, x0, target
[sltu t0, rs1, rs2]  # t0 = 1 if rs1 < rs2 (unsigned), else 0  (derived)
bne  t0, x0, target
```

=== Immediate
- (ORI, ANDI, SLLI, SRAI, SRLI, XORI, SLTI, SLTIU)
Only uses ADDI to load a value into a temporary register and then call the non-immediate variant.

==== SLTI / SLTIU


```asm
li    t, imm          # load immediate into register
slt   rd, rs1, t      # slti rd, rs1, imm  →  slt rd, rs1, t
sltu  rd, rs1, t      # sltiu rd, rs1, imm →  sltu rd, rs1, t
```


=== Load

==== LUI

`lui rd, imm20` sets `rd = imm20 << 12`, placing a 20-bit value in the upper bits of a register.
Two derivation strategies are considered; which one GCC can produce is left for future investigation.

===== Approach 1: addi + derived sll

Since `addi` only encodes 12-bit signed immediates (range −2048 to 2047), a 20-bit immediate cannot be loaded in one instruction.
Split `imm20` into two 10-bit halves that each fit safely in a positive `addi` immediate (0–1023), reconstruct the value with `or`, then shift left by 12.

```
imm20 = hi × 2^10 + lo       where hi = imm20[19:10],  lo = imm20[9:0]
rd    = imm20 << 12  =  (hi << 22) | (lo << 12)
```

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

#table(
  columns: 3,
  [*Approach*], [*Instructions*], [*Memory reads*],
  [addi + sll], [~5], [0],
  [lw from pool], [1], [1],
)

==== LB, LBU, LH, LHU <sc1-lb-synthesis>

Since the processor only supports `lw`, every byte or halfword load is synthesized in four steps: align the address to a word boundary, load the word, extract the target unit by logical right shift, and finally sign-extend (`sra`) or zero-extend (`srl`). This algorithm is emitted at runtime — it does not assume the offset is constant at compile time.

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

Since shifts in sc1 are synthesized via `add`/`beq` loops, the total cost of a byte load reaches ~70–80 instructions. The high cost is intentional: it demonstrates to students the value of having `lb`/`lbu` as native instructions.

=== Store

==== SB

A byte store is implemented as a read-modify-write operation: load the word containing the target byte, clear the byte's bits, insert the new value, and write back. Since the base pointer is unknown at compile time, the bit offset is computed at runtime.

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
li    t0, -4
and   t3, rs1, t0           # t3 = rs1 & -4  (word-aligned)
li    t0, 3
and   t0, rs1, t0           # t0 = rs1 & 3  (byte_pos: 0–3)
add   t0, t0, t0            # \
add   t0, t0, t0            #  t0 = byte_pos * 8  (bit shift; synthesized sll)
add   t0, t0, t0            # /
lw    t1, 0(t3)             # t1 = old word
li    t2, 255               # t2 = 0xFF
[sll  t2, t2, t0]           # t2 = 0xFF << shift  (mask; synthesized variable sll)
not   t2, t2                # t2 = ~mask  (synthesized)
and   t1, t1, t2            # t1 = old_word & ~mask  (clear target byte)
li    t2, 255
and   t2, rs2, t2           # t2 = rs2 & 0xFF  (isolate input byte)
[sll  t2, t2, t0]           # t2 = byte_value << shift  (position; synthesized variable sll)
or    t1, t1, t2            # t1 = word with byte inserted
sw    t1, 0(t3)             # write back
```

Each `sb` costs one `lw` (2 cycles) plus one `sw` (5 cycles) = 7 memory cycles, plus the variable-shift synthesis sequence.

==== SH

Same read-modify-write pattern as `sb`, but for a 16-bit halfword. The halfword position within the word (`addr & 2`, yielding 0 or 2) and the bit offset (0 or 16) are computed at runtime. The constant 0xFFFF is materialized with `lui + addi` (it exceeds the 12-bit immediate range).

```c
void sh(uint16_t *addr, uint32_t rs2) {
    uint32_t aligned_addr = (uint32_t)addr & ~3u;    // addr & -4
    uint32_t hw_pos       = (uint32_t)addr & 2u;     // runtime: 0 or 2
    uint32_t shift        = hw_pos * 8u;              // runtime: 0 or 16
    uint32_t old_word     = *(uint32_t *)aligned_addr;      // lw
    uint32_t hw_mask      = 0xFFFFu << shift;               // [sll] runtime shift
    uint32_t new_hw       = (rs2 & 0xFFFFu) << shift;       // [sll] runtime shift
    uint32_t new_word     = (old_word & ~hw_mask) | new_hw;
    *(uint32_t *)aligned_addr = new_word;                    // sw
}
```

```asm
# sh rs2, 0(rs1)   — address in rs1, halfword position unknown at compile-time
li    t0, -4
and   t3, rs1, t0           # t3 = rs1 & -4  (word-aligned)
li    t0, 2
and   t0, rs1, t0           # t0 = rs1 & 2  (hw_pos: 0 or 2)
add   t0, t0, t0            # \
add   t0, t0, t0            #  t0 = hw_pos * 8  (bit shift: 0 or 16; synthesized sll)
add   t0, t0, t0            # /
lw    t1, 0(t3)             # t1 = old word
li    t2, 65535             # t2 = 0xFFFF  (lui 0x10 + addi -1)
[sll  t2, t2, t0]           # t2 = 0xFFFF << shift  (mask; synthesized variable sll)
not   t2, t2                # t2 = ~mask  (synthesized)
and   t1, t1, t2            # t1 = old_word & ~mask  (clear target halfword)
li    t2, 65535
and   t2, rs2, t2           # t2 = rs2 & 0xFFFF  (isolate input halfword)
[sll  t2, t2, t0]           # t2 = hw_value << shift  (position; synthesized variable sll)
or    t1, t1, t2            # t1 = word with halfword inserted
sw    t1, 0(t3)             # write back
```

Each `sh` costs one `lw` (2 cycles) plus one `sw` (5 cycles) = 7 memory cycles, plus the variable-shift synthesis sequence.

=== Jump

==== JAL
jalr + lui + label after calll

So instead
```asm
li  a0, 3
jal ra, double

ebreak  # stop execution

double:
    add  a0, a0, a0
    jalr zero, 0(ra)
```

we will need

```asm
    li      a0, 3
    li      ra, back_double1     # assembler: lui ra, %hi(...); addi ra, ra, %lo(...)
    li      t0, double           # same expansion
    jalr    zero, 0(t0)
back_double1:
    ebreak

double:
    add     a0, a0, a0
    jalr    zero, 0(ra)
```



== Implementation

=== GCC overfiev

- GCC architecture
- GCC backends and targets

=== GCC Machine Description Files

- Explain what are machine description
- Explain where is the changes
- Give some examples

=== GCC flags and target configuration

- List all flags create for each implementation
- Show how this flags are configured


```sh
rvsc2-unknown-elf-gcc program.c -o program
```

This is equivalent to:

```sh
riscv32-unknown-elf-gcc program.c -o program \
    -march=rv32i -mabi=ilp32 \
    -mno-fence
```

==== Building the toolchain

```sh
../gcc/configure \
    --target=rvsc2-unknown-elf \
    --prefix=$(pwd)/install \
    --enable-languages=c
```

= Results

== Tests

=== Validating ASM
- generate only for



=== Validating Result
- Stone RISC-V (no syscall)
- RISC-V official test implementation
- QEMU baremetal
- Rocket
- only sc0 to sc2
- single-cycle
- only sc0 and sc1

== Program Size

== Program Performance
In instructions
- Instruction cycle or clock cycle
- Processor has memory that slows it down

== Discussion
- Show that the compiler does not emit instructions unsupported by the target
- And is sufficiently broad

= Conclusion

= References

#bibliography("refs.bib", style: "ieee")

= Appendix
=== Samples
