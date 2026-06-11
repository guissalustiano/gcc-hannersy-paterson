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

// --- Agradecimentos ---
#heading(level: 1, numbering: none, outlined: false)[Agradecimentos]

Os agradecimentos principais são direcionados a ...

// --- Resumo ---
#heading(level: 1, numbering: none, outlined: false)[Resumo]

O resumo deve ressaltar o objetivo, o método, os resultados e as
conclusões do documento. Deve ser escrito em parágrafo único, e
tipicamente é menor do que uma página.

*Palavras-chave*: GCC. RISC-V. Compilador. Processador educacional.

// --- Abstract ---
#heading(level: 1, numbering: none, outlined: false)[Abstract]

This is the english abstract.

*Keywords*: GCC. RISC-V. Compiler. Educational processor.

// --- Lista de Abreviaturas e Siglas ---
#heading(level: 1, numbering: none)[Lista de Abreviaturas e Siglas]

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
  [*RISC-V*], [_Reduced Instruction Set Computer -- Five_],
  [*RTL*],    [_Register Transfer Language_],
  [*RV32I*],  [RISC-V, inteiros, 32 bits],
  [*RV64I*],  [RISC-V, inteiros, 64 bits],
)

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

O trabalho busca desenvolver simplificações no backend do gcc de forma a suportar implementações simplificadas de um processador RISC-V, de forma a permitir implementações intermediarias funcionais. Para isso foram definidos 6 processadores com targets especiais que geram apenas o conjunto de instruções por eles suportado.

== rvsc0 - Monociclo básico
O rvsc0 é a implementação mais simples, um monociclo de 32 bits, com sua implementação descrita no Cap 4.4 do Hannersy e Patterson, A Simple Implementation Scheme


#quote[In this section, we look at what might be thought of as a simple implementation of our RISC-V subset. [...] This simple implementation covers load word (lw), store word (sw), branch if equal (beq), and the arithmetic-logical instructions add, sub, and, and or.]


// TODO: make it a table
Conforme mencionado no texto essa implementação suporta apenas as instruções:
- lw - load word
- sw - store word
- beq - branch if equal
- add - aritimetic add
- addi - arithmetic add with imediate
- sub - arithmetic subtraction
- and - bitwese and
- or - bitwise or

Assim sendo o compilador deve ser capaz de gerar apenas essas instruções para esse processador.

=== Limitações
Essa implementação não possui nenhuma interação com o PC, dessa forma não é possível adicionar suporte a subrotina recursivas, apenas static call. Nesse caso o compilador deve emitir um erro.

// é possivel "voltar" usando beq
// talvez n devemos inline pois fica mais didatico de olhar o codigo

=== Detalhes de implementação
Na implementação utilizada pelos alunos o processador tem acesso a uma RAM de 2 ciclos de leitura e 5 ciclos de escrita, um barramento wishbone. O espaço de endereçamento é como segue:
- Boot: 0x200
- RAM: final do endereçamento
- Perifericos: 0xFC00000000
	- registrador único para o led


== rvsc1 - Monociclo extendido
// TODO: check if lui is that much necessary
O rvsc1 estende o rvsc0 com as instruções load upper immediate (lui) e Jump and Link Register (jalr), e desta forma remover a limitação de funções recursivas do processador anterior.

Desta forma o instruction set completo do rvsc1 fica:
// TODO: make a table
- Herda do sc0: `lw`, `sw`, `beq`, `add`, `addi`, `sub`, `and`, `or`
- `jalr` — retorno de função e chamadas indiretas
- `lui` — carregamento de endereços absolutos (metade alta de 32 bits)

== rvsc2 - Monociclo sem fence e controle
O rvsc2 implementa todas as instruções do padrão rv32i exceto instruções de Memory Order, CSR Access e System. Por se tratar de um mono-ciclo single core as instruções de memory order podem ser retiradas sem perda de função /*rewrite*/, Da mesma forma as instruções de CSR e Systema foram retiradas por se tratar de intruções especificas do sistema operacional, sem uso para códigos simples bare metal.

Assim sendo a ISA deste processador é:
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

Com a excessao das seguintes instrucoes:
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

== rvsc3 - Monociclo rv32i
O rvsc3 suporta todas as instruções do sc2 mais as instruções Memory Order, CSR Access e System, supportando assim o set inteiro do sc3.

// TODO: 
// explain NOPs em processadores pipeline e RISC-V
// explain that we are generating this target to make easies to progress on that

== rvsc4 - Monociclo rvi64
O sc4 é um monociclo de 64bits com o conjunto inteiro de instruções do rv64i.

Além das instruções implementadas pelo sc3, ele conta com:
- Memória 64 bits: `ld`, `sd`, `lwu`
- Operações em word com resultado estendido a 64 bits (sufixo W): `addw`, `subw`, `addiw`, `sllw`, `srlw`, `sraw`, `slliw`, `srliw`, `sraiw`

== rvsc5 - Monociclo rvi64 com multiplicação
Suporta todas as instruções do sc4 mais a extensão M (multiplicação e divisão inteira):

- Multiplicação: `mul`, `mulw`, `mulh`, `mulhu`, `mulhsu`
- Divisão assinada: `div`, `divw`
- Divisão não-assinada: `divu`, `divuw`
- Resto assinado: `rem`, `remw`
- Resto não-assinado: `remu`, `remuw`

As variantes com sufixo W operam em 32 bits e estendem o resultado a 64 bits por sinal, seguindo a mesma convenção de `addw`, `subw` e demais instruções W do sc4.

Suportando assim o isa rv32im.

== rvsc6 - Monociclo float point

Suporta todas as instruções do sc5 mais as extensões F (single) e D (double) de ponto flutuante, conforme o green card do H&P.

Loads/stores:
- `flw`, `fsw` — single precision
- `fld`, `fsd` — double precision

Aritmética:
- `fadd.s`, `fadd.d`, `fsub.s`, `fsub.d`, `fmul.s`, `fmul.d`, `fdiv.s`, `fdiv.d`, `fsqrt.s`, `fsqrt.d`

Multiply-add fusionado:
- `fmadd.s`, `fmadd.d`, `fmsub.s`, `fmsub.d`, `fnmadd.s`, `fnmadd.d`, `fnmsub.s`, `fnmsub.d`

Sinal, mínimo e máximo:
- `fsgnj.s`, `fsgnj.d`, `fsgnjn.s`, `fsgnjn.d`, `fsgnjx.s`, `fsgnjx.d`
- `fmin.s`, `fmin.d`, `fmax.s`, `fmax.d`

Comparação e classificação:
- `feq.s`, `feq.d`, `flt.s`, `flt.d`, `fle.s`, `fle.d`
- `fclass.s`, `fclass.d`

Move entre registradores inteiros e FP:
- `fmv.w.x`, `fmv.x.w` — single (rv32 e rv64)
- `fmv.d.x`, `fmv.x.d` — double (rv64)

Conversões (rv64):
- `fcvt.s.w`, `fcvt.s.wu`, `fcvt.s.l`, `fcvt.s.lu` — int → single
- `fcvt.w.s`, `fcvt.wu.s`, `fcvt.l.s`, `fcvt.lu.s` — single → int
- `fcvt.d.w`, `fcvt.d.wu`, `fcvt.d.l`, `fcvt.d.lu` — int → double
- `fcvt.w.d`, `fcvt.wu.d`, `fcvt.l.d`, `fcvt.lu.d` — double → int
- `fcvt.s.d`, `fcvt.d.s` — conversão entre single e double

Eh importante notar que as extensoes FD foram revisadas e adicionadas novas operacoes, por motivos didaticos esse processador implementa apenas aquelas presentes no livro.
// TODO: precisa de fontes e talvez citas quais foram as operacoes novas?


== rvsc7 - Monociclo atômico
Suporta todas as instruções do sc6 mais a extensão A (operações atômicas sobre memória), implementando o conjunto rv64imsfa.
As variantes `.w` operam em 32 bits (sign-extend para 64); as variantes `.d` operam em 64 bits.

Load-reserved e store-conditional:
- `lr.w`, `lr.d` — load-reserved
- `sc.w`, `sc.d` — store-conditional

AMO (atomic memory operations):
- `amoadd.w`, `amoadd.d` — adição atômica
- `amoand.w`, `amoand.d` — AND atômico
- `amoor.w`, `amoor.d` — OR atômico
- `amoxor.w`, `amoxor.d` — XOR atômico
- `amoswap.w`, `amoswap.d` — swap atômico
- `amomax.w`, `amomax.d` — máximo assinado atômico
- `amomaxu.w`, `amomaxu.d` — máximo não-assinado atômico
- `amomin.w`, `amomin.d` — mínimo assinado atômico
- `amominu.w`, `amominu.d` — mínimo não-assinado atômico

// TODO: checar se tem divergencia da ultima extensa para a implementada no livro

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
Usando apenas as instruções de RVSC1 podemos realizar todo as funcionalidades necessárias para a linguagem C, a abordagem escolhida foi substituir a emissão da instrução suprimida quando possivel. Em casos em que não há uma substituição direta a alteração tem que ser feita /* descobrir como */.
// TODO: discuss about use extra register and how this is applied and inpact 


=== Aritimeticas

Operações aritméticas apenas atribuem valores para novos registradores, podendo ser totalmente substituídas por funções equivalentes.

==== not (R[rd] = ~R[rs1])

O `not` é implementado no risc-v como uma pseudo instrução, sendo implementado com `xor`, como o xor será mais custoso conforme visto na próxima sessão, buscou-se implementa-lo a partir da instrução `sub`.  

A arquitetura usa complemento de dois, assim sendo $-x = ~x + 1$, assim sendo podemos derivar a negação a partir da instrução de subtração implementada no nosso hardware com $~x = -x - 1$.

Em assembly:

```asm
sub  rd, x0, rs1    # rd = -rs1
addi rd, rd, -1     # rd = -rs1 - 1 = ~rs1
```

Assim sendo a operação de negação leva duas instruções e usa o mesmo numero de registradores

==== xor (R[rd] = R[rs1] ^ R[rs2])

A função `xor` as conjunctive normal form is

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
Para o shift left, a solução encontrada foi percorrer os bits e sobrencreve-los na nova posição usando bit manipulation. O código em C que implementa isso segue abaixo.

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

// shift = shift & 31u; is something related with C spec, needs to check and it's worth to mention.
Em assembly usando apenas o conjunto de intrucoes temos:

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
# com -mno-slt: sintetiza slt em t0, depois beq t0, x0, target
[slt t0, rs1, rs2]  # t0 = 1 if rs1 < rs2, else 0  (derived)
beq  t0, x0, target
```

==== Blt - Branch less than

```asm
# com -mno-slt: sintetiza slt em t0, depois bne t0, x0, target
[slt t0, rs1, rs2]  # t0 = 1 if rs1 < rs2, else 0  (derived)
bne  t0, x0, target
```

==== Bgeu

```asm
# com -mno-slt: sintetiza sltu em t0, depois beq t0, x0, target
[sltu t0, rs1, rs2]  # t0 = 1 if rs1 < rs2 (unsigned), else 0  (derived)
beq  t0, x0, target
```

==== Bltu

```asm
# com -mno-slt: sintetiza sltu em t0, depois bne t0, x0, target
[sltu t0, rs1, rs2]  # t0 = 1 if rs1 < rs2 (unsigned), else 0  (derived)
bne  t0, x0, target
```

=== Imediate
- (ORI, ANDI, SLLI, SRAI, SRLI, XORI, SLTI, SLTIU)
Only uses ADDI to load a value to a temporary register and call non imediate operation

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

Como o processador suporta apenas `lw`, toda carga de byte ou meia-palavra é sintetizada em quatro etapas: alinhar o endereço à word, carregar a word, extrair a unidade alvo por deslocamento lógico à direita, e finalmente estender por sinal (`sra`) ou por zero (`srl`). Esse algoritmo é emitido em tempo de execução — não pressupõe que o offset seja constante em tempo de compilação.

```c
/* Algoritmo comum a lb/lbu/lh/lhu */
uint32_t aligned = addr & ~3u;          // word alinhada: addr & -4
uint32_t word    = lw(aligned);         // lw 0(aligned)
uint32_t unit_off = addr & MASK;        // MASK = 3 para byte, 2 para meia-palavra
uint32_t bit_off  = unit_off * 8;       // posição do bit menos significativo
uint32_t shifted  = word >> bit_off;    // [srl] extrai a unidade para bits [N:0]
// lbu/lhu: zero-extend via deslocamento simétrico
uint32_t result   = (shifted << BITS) >> BITS;  // lógico: [srl]
// lb/lh:  sign-extend via deslocamento aritmético
int32_t  result   = (int32_t)(shifted << BITS) >> BITS;  // aritmético: [sra]
// BITS = 24 para byte (QImode), 16 para meia-palavra (HImode)
```

```asm
# lb rd, 0(rs1)  (endereço em rs1, byte_pos desconhecido em compile-time)
addi  t0, x0, -4
and   t0, rs1, t0         # t0 = rs1 & -4  (word alinhada)
lw    t1, 0(t0)           # t1 = word contendo o byte
addi  t0, x0, 3
and   t0, rs1, t0         # t0 = rs1 & 3  (posição do byte: 0–3)
[sll  t0, t0, 3]          # t0 = byte_pos * 8  (deslocamento em bits)
[srl  t1, t1, t0]         # t1 >>= bit_off  (byte em bits [7:0])
[sll  t1, t1, 24]         # t1 <<= 24  (byte em bits [31:24])
[sra  rd,  t1, 24]        # rd >>= 24  (extensão por sinal → lb)
                          # use [srl] no último passo para lbu (extensão por zero)

# lh rd, 0(rs1)  — idêntico mas MASK = 2, BITS = 16
addi  t0, x0, -4
and   t0, rs1, t0         # word alinhada
lw    t1, 0(t0)
addi  t0, x0, 2
and   t0, rs1, t0         # t0 = rs1 & 2  (0 ou 2: qual meia-palavra)
[sll  t0, t0, 3]          # t0 = half_pos * 8  (0 ou 16)
[srl  t1, t1, t0]         # meia-palavra em bits [15:0]
[sll  t1, t1, 16]
[sra  rd,  t1, 16]        # extensão por sinal → lh  (srl para lhu)
```

Como os shifts em sc1 são sintetizados via laços de `add`/`beq`, o custo total de uma carga de byte chega a ~70–80 instruções. O custo elevado é intencional: evidencia para os alunos o valor de ter `lb`/`lbu` como instruções nativas.

=== Store

==== SB

Um store de byte é implementado como uma operação leitura-modificação-escrita (_read-modify-write_): carregar a word que contém o byte alvo, apagar os bits do byte, inserir o novo valor e guardar de volta. Como o ponteiro base é desconhecido em tempo de compilação, o deslocamento em bits é calculado em tempo de execução.

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
# sb rs2, 0(rs1)   — endereço em rs1, posição do byte desconhecida em compile-time
li    t0, -4
and   t3, rs1, t0           # t3 = rs1 & -4  (word alinhada)
li    t0, 3
and   t0, rs1, t0           # t0 = rs1 & 3  (byte_pos: 0–3)
add   t0, t0, t0            # \
add   t0, t0, t0            #  t0 = byte_pos * 8  (shift em bits; sll sintetizado)
add   t0, t0, t0            # /
lw    t1, 0(t3)             # t1 = old word
li    t2, 255               # t2 = 0xFF
[sll  t2, t2, t0]           # t2 = 0xFF << shift  (máscara; sll variável sintetizado)
not   t2, t2                # t2 = ~máscara  (sintetizado)
and   t1, t1, t2            # t1 = old_word & ~máscara  (apaga byte alvo)
li    t2, 255
and   t2, rs2, t2           # t2 = rs2 & 0xFF  (isola byte de entrada)
[sll  t2, t2, t0]           # t2 = byte_valor << shift  (posiciona; sll variável sintetizado)
or    t1, t1, t2            # t1 = palavra com byte inserido
sw    t1, 0(t3)             # armazena de volta
```

Cada `sb` custa um `lw` (2 ciclos) mais um `sw` (5 ciclos) = 7 ciclos de memória, mais a sequência de síntese de shifts variáveis.

==== SH

Mesmo padrão de leitura-modificação-escrita do `sb`, mas para meia-palavra de 16 bits. A posição da meia-palavra na word (`addr & 2`, que resulta em 0 ou 2) e o deslocamento em bits (0 ou 16) são calculados em tempo de execução. O valor 0xFFFF é materializado com `lui + addi` (excede o imediato de 12 bits).

```c
void sh(uint16_t *addr, uint32_t rs2) {
    uint32_t aligned_addr = (uint32_t)addr & ~3u;    // addr & -4
    uint32_t hw_pos       = (uint32_t)addr & 2u;     // runtime: 0 ou 2
    uint32_t shift        = hw_pos * 8u;              // runtime: 0 ou 16
    uint32_t old_word     = *(uint32_t *)aligned_addr;      // lw
    uint32_t hw_mask      = 0xFFFFu << shift;               // [sll] runtime shift
    uint32_t new_hw       = (rs2 & 0xFFFFu) << shift;       // [sll] runtime shift
    uint32_t new_word     = (old_word & ~hw_mask) | new_hw;
    *(uint32_t *)aligned_addr = new_word;                    // sw
}
```

```asm
# sh rs2, 0(rs1)   — endereço em rs1, posição da meia-palavra desconhecida em compile-time
li    t0, -4
and   t3, rs1, t0           # t3 = rs1 & -4  (word alinhada)
li    t0, 2
and   t0, rs1, t0           # t0 = rs1 & 2  (hw_pos: 0 ou 2)
add   t0, t0, t0            # \
add   t0, t0, t0            #  t0 = hw_pos * 8  (shift em bits: 0 ou 16; sll sintetizado)
add   t0, t0, t0            # /
lw    t1, 0(t3)             # t1 = old word
li    t2, 65535             # t2 = 0xFFFF  (lui 0x10 + addi -1)
[sll  t2, t2, t0]           # t2 = 0xFFFF << shift  (máscara; sll variável sintetizado)
not   t2, t2                # t2 = ~máscara  (sintetizado)
and   t1, t1, t2            # t1 = old_word & ~máscara  (apaga meia-palavra alvo)
li    t2, 65535
and   t2, rs2, t2           # t2 = rs2 & 0xFFFF  (isola meia-palavra de entrada)
[sll  t2, t2, t0]           # t2 = hw_valor << shift  (posiciona; sll variável sintetizado)
or    t1, t1, t2            # t1 = palavra com meia-palavra inserida
sw    t1, 0(t3)             # armazena de volta
```

Cada `sh` custa um `lw` (2 ciclos) mais um `sw` (5 ciclos) = 7 ciclos de memória, mais a sequência de síntese de shifts variáveis.

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

#bibliography("refs.bib", style: "ieee")

= Apendice
=== Samples
