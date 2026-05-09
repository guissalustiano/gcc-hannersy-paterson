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


// --- Table of Contents (Sumário) [cite: 2514] ---
#heading(level: 1, numbering: none)[SUMÁRIO]
#outline(title: none, indent: auto, depth: 3)

// --- Textual Elements Setup ---
#set page(numbering: "1")
  

= Introdução
// Contexto
- O livro de arquitetura de computadores do Hannersy e Paterson é usado amplamente em cursos de graduação, no brasil e mundo a fora
- O livro contem uma implementação simplificada do rv32i com caráter educativo

== Motivação
// - Apresenta o estado de arte resumido do assunto que será o tema do desenvolvimento
// do trabalho, elaborado com base nos trabalhos consultados.
// - Os trabalhos consultados devem estar citados e referenciados no texto.
// - Apresenta o contexto em que o trabalho será desenvolvido.
- Os alunos não conseguem rodar codigo C no seu processador, isso limita a sua execução a programas simples que são gerados manualmente pelos alunos
- Existe a oportunidade de introduzi-los ao compilador enquando eles veem parte do artefato gerado
- Eles tambem podem rodar programas reais e complexos

== Objetivo
// - Apresentar o objetivo do trabalho de forma precisa e concisa.
// - Deve responder à pergunta: O que é o trabalho?
O trabalho tem como objetivo o desenvolvimento de targets para o GCC.
Os targets foram projetados de maneira progressiva, partindo da implementação mais simples contida no livro e permitindo a complementação da implementação e aumentando o desempenho do programa.

== Justificativa
// - Apresenta porque o trabalho desenvolvido é importante (importância e necessidade para
// a sociedade, comparação com trabalhos relevantes consultados etc.).
// - Os trabalhos consultados devem estar citados e referenciados no texto.
// - Deve responder à pergunta: Por que o trabalho é importante?
Atualmente a unica forma de rodar programas no processador do livro é escrevendo seu proprio assembly (devido ao limite de instrucoes).
Esse trabalho busca permitir aos alunos rodarem qualquer programa C em seu proprio processador, dimindo o gap entre o que foi aprendido e programas do mundo real
Bem como permite a introdução do uso de compiladores, escrevendo código C, printando o assembly e observando na pratica as traducoes e otimizacoes realizadas


= Aspectos Conceituais
// - Define as seções representativas em função do trabalho.
// - Apresenta os conceitos empregados e a revisão da literatura.
// - Os trabalhos consultados devem estar citados e referenciados no texto.
== gcc
== risc-v
== hannersy e patterson architecture
- Tem um processador monociclo
ULAa 100% funcional
N tem unidade de controle, eh combinatoria para q alunos no 1st~2nd ano
mas n suporta todas as intrucoes do isntruction set


= Especificação de Requisitos
// Definir e descrever os requisitos do trabalho. O trabalho pode ser de desenvolvimento de
// sistema, melhoria de um sistema existente, definição de processo, técnicas, procedimentos, ou
// um outro tipo de trabalho acordado com o orientador.


== Monociclo implementation
- monocicle
- Barramento wishbone
- RAM memory:
  - 2 cycle read
  - 5 cycles write

Espaco de endereçamento:
- Boot: 0x200
- RAM: final do endereçamento
- Perifericos: 0xFC00000000
	- registrador unico para o led

== Monociclo - sc0

Apenas implementação basica do texto (cap 4.4) - fig 4.25
- lw
- sw
- beq
- add
- addi
- sub
- and
- or

=== Limitações
Dado a não existência de instruções que interajam com o PC, essa implementação não suporta funções que não possam ser inlinadas, falhando na compilacao.
- subrotina

// é possivel "voltar" usando beq
// talvez n devemos inline pois fica mais didatico de olhar o codigo


== Monociclo extendido - sc1
Suporta o minimo de intruções para suportar toda a linguagem C
- todas as instrucoes do sc0
- jalr
- lui

=== Limitacoes
- Não implementa auipc -> não funciona com programas muito longo pois n consegue fazer chamadas alem de XXX

== Monociclo sem fance e controle - sc2
Supporta todas as instruções do rv32i instruções de mem. ordering, csr acess e system

Target: `rvsc2`

Flags equivalentes: `-march=rv32i -mabi=ilp32 -mno-fence`

Instruction:
- add
- addi
- and
- andi
auipc
beq
bge
bgeu
blt
bltu
bne
jal
jalr
lb
lbu
lh
lhu
lui
lw
or
ori
sb
sh
sll
slli
slt
slti
sltiu
sltu
sra
srai
srl
srli
sub
sw
xor
xori

except:
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



== Monociclo rv32i - sc3

requisito:
o gcc n pode gerar nenhuma nop para intrucoes de desvio pois eh mono ciclo, logo n tem necessidade

== Monociclo rvi64 - sc4
Suporta todas as instrucoes do rvi64

== Monociclo rvi64 with multiplily - sc5
Suporta todas as instrucoes do sc4 e M extension
mul
mulh
mulhsu
mulhu
div
divu
rem
remu

==  Monociclo float point - sc6
support sc5 +
Suporta extensão float point, apenas o green card do hannersy e patterson
- float teve outras extensoes

Instruction:
fld, flw
fsc,fsw
fadd.s,fadd.c
fsub.s, fsub.d
fdiv.s, fdiv.d
fsqrt.s, fsqrt.d
fmadd.s, fmadd.d
fmsub.s, fmjsub.d
fmnadd.s, fmnadd.d
fsgnj.s, fsgnj.d
fsgnjn.s, fsgnjn.d
fsgnjx.s, fsgnjx.d
fmin.s, fmin.d
fmax.s, fmax.c
feq.s, feq.c
flt.s, flt.c
fle.s, fle.c
fclass.s, fclass.c
fmv.s.x, fmv.c.x
fmv.x.s, fmv.x.c
fcvt.c.s
fcvt.s.w, fcvt.d.w
fcvt.s.l, fcvt.c.wu
fcvt.s.wu, fcvt.c.wu
fcvt.w.s, scvt.l.c
fcvt.l.s, fcvt.l.c
fcvt.wu.s, fcvt.wu.c
fcvt.lu.s, fcvt.lu.d

== Monociclo atomico - sc7
Suporta atomico:

amoadd.w, amoadd.d
amoand.w, amoanc.d
amomax.w, amomax.d
amomaxu.w, amomaxu.c
amomin.w, amomon.c
amominu.w, amominu.d
amoor.w, amoor.d
amoswap.w, amoswap.d
amoxor.w, amoxor.d
lr.w, lr.d
sc.w,sc.d


= Método de Trabalho
// - Apresentar o processo de desenvolvimento do trabalho, através das suas fases (por
// exemplo, especificação de requisitos, projeto, implementação, testes). As fases
// dependem do tipo do sistema e devem ser definidas com o apoio do orientador.
// - O desenvolvimento detalhado das fases e seus resultados devem estar descritos nos
// capítulos seguintes e não no capítulo da Método de Trabalho.
// - Os trabalhos consultados devem estar citados e referenciados no texto.
- exploração e estudo do gcc
- especificação de requisitos
- implementacao
- testes
- analises e limitacoes

- emular todas as instrucoes

= Desenvolvimento

== Derivação de instruções
Buscando facilitar a implementação para os alunos o trabalho buscou reduzir o numero máximo de instruções.

=== Aritimeticas
==== not (R[rd] = ~R[rs1])

Since risc-v uses two's complement and $-x = ~x + 1$,
we get $~x = -x - 1$.

```asm
sub  rd, x0, rs1    # rd = -rs1
addi rd, rd, -1     # rd = -rs1 - 1 = ~rs1
```

==== xor (R[rd] = R[rs1] ^ R[rs2])

Using D'morgan

```asm
and t0, rs1, rs2    # t0 = rs1 & rs2
not t0              # t0 = ~(rs1 & rs2)
or  t2, rs1, rs2    # t2 = rs1 | rs2
and rd, t0, t2      # rd = ~(rs1 & rs2) & (rs1 | rs2) = rs1 ^ rs2
```

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


==== srl (R[rd] = R[rs1] >> R[rs2])

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

==== Bge - Branch greather than or equal

```asm
slt  t0, rs1, rs2 # t0 = 1 if rs1 <  rs2, else 0
beq  t0, x0, target 
```

==== Blt - Branch less than

```asm
slt  t0, rs1, rs2      # t0 = 1 if rs1 < rs2, else 0
bne  t0, x0, target 
```

==== Bgeu

```asm
sltu  t0, rs1, rs2 # t0 = 1 if rs1 <  rs2, else 0
beq  t0, x0, target 
```

==== Bltu

```asm
sltu  t0, rs1, rs2      # t0 = 1 if rs1 < rs2, else 0
bne  t0, x0, target 
```

=== Imediate 
- (ORI, ANDI, SLLI, SRAI, SRLI, XORI, SLTI, SLTIU)
Only uses ADDI to load a value to a temporary register and call non imediate operation

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

==== LB

Since the processor only provides word-level memory access (`lw`), a byte load is emulated in three steps: load the containing word, shift the target byte to bit 31, then arithmetic-right-shift by 24 to sign-extend it into the full register.

Because `offset` is a compile-time constant, `byte_pos = offset & 3` (0, 1, 2, or 3) is also known at compile time, so all shift amounts are constants.

```c
int32_t lb(uint32_t base, int32_t offset) {
    uint32_t addr          = base + offset;
    uint32_t aligned_addr  = addr & ~3u;           // round down to word boundary
    uint32_t word          = *(uint32_t *)aligned_addr;     // lw
    uint32_t byte_pos      = addr & 3u;            // 0‥3: which byte within word
    uint32_t left_shift    = (3u - byte_pos) * 8u; // bits to move target byte → bit 31
    uint32_t raised        = word << left_shift;   // sll: target byte now at [31:24]
    int32_t  result        = (int32_t)raised >> 24; // sra: sign-extend back to [7:0]
    return result;
}
```

```asm
# lb rd, offset(rs1)   (byte_pos = offset & 3, compile-time constant: 0–3)
lw    t0, (offset & ~3)(rs1)        # load containing word
[sll  t0, t0, (3 - byte_pos) * 8]  # move target byte to bits [31:24]
[sra  rd,  t0, 24]                  # arithmetic right-shift → sign-extends byte
```

==== LBU

Identical to LB but uses a logical (unsigned) right-shift to zero-extend instead of sign-extend.

```c
uint32_t lbu(uint32_t base, int32_t offset) {
    uint32_t addr          = base + offset;
    uint32_t aligned_addr  = addr & ~3u;
    uint32_t word          = *(uint32_t *)aligned_addr;      // lw
    uint32_t byte_pos      = addr & 3u;
    uint32_t left_shift    = (3u - byte_pos) * 8u;
    uint32_t raised        = word << left_shift;             // sll: target byte → [31:24]
    uint32_t result        = raised >> 24u;                  // srl: zero-extend to [7:0]
    return result;
}
```

```asm
# lbu rd, offset(rs1)   (byte_pos = offset & 3, compile-time constant: 0–3)
lw    t0, (offset & ~3)(rs1)        # load containing word
[sll  t0, t0, (3 - byte_pos) * 8]  # move target byte to bits [31:24]
[srl  rd,  t0, 24]                  # logical right-shift → zero-extends byte
```

==== LH

Halfwords are 2-byte aligned, so `hw_pos = (offset >> 1) & 1` is 0 or 1 (compile-time constant). Shifting the target halfword to bits [31:16] and then arithmetic-right-shifting by 16 produces a sign-extended result in one unified sequence.

```c
int32_t lh(uint32_t base, int32_t offset) {
    uint32_t addr          = base + offset;
    uint32_t aligned_addr  = addr & ~3u;
    uint32_t word          = *(uint32_t *)aligned_addr;      // lw
    uint32_t hw_pos        = (addr >> 1u) & 1u;  // 0 or 1: which halfword within word
    uint32_t left_shift    = (1u - hw_pos) * 16u; // bits to move target halfword → bit 31
    uint32_t raised        = word << left_shift;             // sll: target hw → [31:16]
    int32_t  result        = (int32_t)raised >> 16;          // sra: sign-extend to [15:0]
    return result;
}
```

```asm
# lh rd, offset(rs1)   (hw_pos = (offset >> 1) & 1, compile-time constant: 0 or 1)
lw    t0, (offset & ~3)(rs1)        # load containing word
[sll  t0, t0, (1 - hw_pos) * 16]   # move target halfword to bits [31:16]
[sra  rd,  t0, 16]                  # arithmetic right-shift → sign-extends halfword
```

==== LHU

```c
uint32_t lhu(uint32_t base, int32_t offset) {
    uint32_t addr          = base + offset;
    uint32_t aligned_addr  = addr & ~3u;
    uint32_t word          = *(uint32_t *)aligned_addr;      // lw
    uint32_t hw_pos        = (addr >> 1u) & 1u;
    uint32_t left_shift    = (1u - hw_pos) * 16u;
    uint32_t raised        = word << left_shift;             // sll: target hw → [31:16]
    uint32_t result        = raised >> 16u;                  // srl: zero-extend to [15:0]
    return result;
}
```

```asm
# lhu rd, offset(rs1)   (hw_pos = (offset >> 1) & 1, compile-time constant: 0 or 1)
lw    t0, (offset & ~3)(rs1)        # load containing word
[sll  t0, t0, (1 - hw_pos) * 16]   # move target halfword to bits [31:16]
[srl  rd,  t0, 16]                  # logical right-shift → zero-extends halfword
```

=== Store

==== SB

A byte store is a read-modify-write: load the containing word, clear the target byte lane, insert the new byte, store back. All shift amounts are compile-time constants derived from `byte_pos = offset & 3`.

```c
void sb(uint32_t base, int32_t offset, uint32_t rs2) {
    uint32_t addr          = base + offset;
    uint32_t aligned_addr  = addr & ~3u;
    uint32_t byte_pos      = addr & 3u;
    uint32_t shift         = byte_pos * 8u;
    uint32_t old_word      = *(uint32_t *)aligned_addr;      // lw
    uint32_t new_byte      = (rs2 & 0xFFu) << shift;         // sll: position new byte
    uint32_t byte_mask     = 0xFFu << shift;                 // sll: mask at same position
    uint32_t cleared_word  = old_word & ~byte_mask;          // and: erase target lane
    uint32_t new_word      = cleared_word | new_byte;        // or:  insert new byte
    *(uint32_t *)aligned_addr = new_word;                    // sw
}
```

```asm
# sb rs2, offset(rs1)   (byte_pos = offset & 3, compile-time constant: 0–3)
lw    t0, (offset & ~3)(rs1)        # t0 = old word
addi  t1, x0, 255                   # t1 = 0xFF
and   t2, rs2, t1                   # t2 = rs2 & 0xFF  (isolate low byte)
[sll  t2, t2, byte_pos * 8]         # position new byte
[sll  t1, t1, byte_pos * 8]         # position byte mask
not   t1, t1                        # t1 = ~mask  (derived)
and   t0, t0, t1                    # clear target lane in old word
or    t0, t0, t2                    # insert new byte
sw    t0, (offset & ~3)(rs1)        # store back
```

Each SB costs one `lw` (2 cycles) plus one `sw` (5 cycles) = 7 memory cycles.

==== SH

Same read-modify-write pattern as SB but for 16-bit halfwords. `hw_pos = (offset >> 1) & 1` is 0 or 1. Constructing 0xFFFF uses `addi + sll + addi` since the value exceeds the 12-bit immediate range.

```c
void sh(uint32_t base, int32_t offset, uint32_t rs2) {
    uint32_t addr          = base + offset;
    uint32_t aligned_addr  = addr & ~3u;
    uint32_t hw_pos        = (addr >> 1u) & 1u;
    uint32_t shift         = hw_pos * 16u;
    uint32_t old_word      = *(uint32_t *)aligned_addr;      // lw
    uint32_t new_hw        = (rs2 & 0xFFFFu) << shift;       // sll: position new halfword
    uint32_t hw_mask       = 0xFFFFu << shift;               // sll: mask at same position
    uint32_t cleared_word  = old_word & ~hw_mask;            // and: erase target lane
    uint32_t new_word      = cleared_word | new_hw;          // or:  insert new halfword
    *(uint32_t *)aligned_addr = new_word;                    // sw
}
```

```asm
# sh rs2, offset(rs1)   (hw_pos = (offset >> 1) & 1, compile-time constant: 0 or 1)
lw    t0, (offset & ~3)(rs1)        # t0 = old word
addi  t1, x0, 1
[sll  t1, t1, 16]                   # t1 = 0x10000
addi  t1, t1, -1                    # t1 = 0xFFFF
and   t2, rs2, t1                   # t2 = rs2 & 0xFFFF  (isolate low halfword)
[sll  t2, t2, hw_pos * 16]          # position new halfword
[sll  t1, t1, hw_pos * 16]          # position halfword mask
not   t1, t1                        # t1 = ~mask  (derived)
and   t0, t0, t1                    # clear target lane in old word
or    t0, t0, t2                    # insert new halfword
sw    t0, (offset & ~3)(rs1)        # store back
```

Each SH costs one `lw` (2 cycles) plus one `sw` (5 cycles) = 7 memory cycles.

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

=== GCC Machine Description Files

=== GCC flags and target configuration

Each target (sc0–sc7) is exposed as a named GCC target triple of the form `rv-scN-unknown-elf`, allowing students to invoke the compiler without memorising flag combinations.
For sc2 specifically, the corresponding triple is `rvsc2-unknown-elf`, and the compiler is invoked as:

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

==== The `-mno-fence` option

The standard rv32i base ISA includes three memory-ordering instructions (`fence`, `fence.i`, `sfence.vma`) and several CSR and system instructions that the educational processor hardware does not implement.
A new boolean option `mfence` is added to `gcc/config/riscv/riscv.opt`:

```
mfence
Target Var(TARGET_FENCE) Init(1)
Enable fence instruction emission (-mno-fence suppresses all fence instructions).
```

`Init(1)` leaves fence enabled for all other RISC-V targets.
`-mno-fence` sets `TARGET_FENCE` to 0.

The only place in the RISC-V backend that emits fence RTL under ordinary C compilation is the `mem_thread_fence` pattern in `gcc/config/riscv/sync.md`.
A single early-exit guard is added at the top of its body:

```
if (!TARGET_FENCE)
  DONE;
```

When `TARGET_FENCE` is 0, the expand completes immediately without emitting any insn, making every `__atomic_thread_fence()` call a no-op at the RTL level.
CSR access instructions (`csrrw`, `csrrs`, etc.) and system instructions (`ecall`, `ebreak`, etc.) are never emitted by GCC for standard C programs; no additional suppression is needed.

==== Custom target triple

Registering a separate triple (`rvsc2-unknown-elf`) rather than relying on runtime flags ensures:
- Students cannot accidentally omit a required flag.
- The default specs (linker script, start files, library paths) are already correct for the educational memory map.
- Different sc targets can coexist in the same toolchain installation via multilib.

Three changes to `gcc/config.gcc` wire up the new triple:

+ The early cpu-type block is extended to recognise `rvsc2*` and set `cpu_type=riscv`, activating the RISC-V backend.
+ A new OS block `rvsc2-*-elf*` sets `tm_file` to include `riscv/rvsc2.h` and reuses the standard `riscv/t-riscv` build rules.
+ The target-defaults block is extended to match `rvsc2-*-*` triples, hardcode `xlen=32`, and pre-fill `with_arch=rv32i` and `with_abi=ilp32` when not overridden at configure time.

`gcc/config/riscv/rvsc2.h` is the spec header for the new target.
It inherits all ELF defaults from `riscv/elf.h` and adds a single `CC1_SPEC` override:

```c
#include "elf.h"

#undef CC1_SPEC
#define CC1_SPEC "%{!mfence:-mno-fence}"
```

`CC1_SPEC` is expanded by the GCC driver before invoking the compiler proper.
The `%{!mfence:...}` condition injects `-mno-fence` unless the user explicitly passed `-mfence`, ensuring `TARGET_FENCE` is always 0 for this target by default.

= Results

== Testes

=== Validating asm
- generate only for 

=== Validating result
- Stone risc-v (sem syscall)
- RISC-v official test implementation
- Qemu baremetal
- rocket 
- so o sc0 a sc2
- monociclo
- so o sc0 e sc1

== Program size

== Program performance
In instruction
- Ciclo de instrucao ou ciclo de clock
- Processador tem memoria que deixa mais lento

== Discussion
- Mostrar que o compilador n gera o asm que o target n supporta
- E eh suficientemente amplo

= Conclusion

= References

= Apendice
=== Samples
