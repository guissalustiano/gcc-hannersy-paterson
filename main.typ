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
- Needs to mask correct value

==== LH
- Needs to mask correct value

==== LHU
- Needs to mask correct value

==== LBU
- Needs to mask correct value

=== Store

==== SB
- Load, mask build, store

==== SH
- Load, mask build, store

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
