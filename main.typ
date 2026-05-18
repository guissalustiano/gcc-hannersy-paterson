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

Target: `rvsc1`

Flags equivalentes: `-march=rv32i -mabi=ilp32 -mno-fence -mno-auipc -mno-shift -mno-xor -mno-ori -mno-andi -mno-bne -mno-blt -mno-bge -mno-bltu -mno-bgeu -mno-byte -mno-half`

Suporta todas as instruções do sc0 mais as instruções mínimas para suporte a funções em C:

- Herda do sc0: `lw`, `sw`, `beq`, `add`, `addi`, `sub`, `and`, `or`
- `jalr` — retorno de função e chamadas indiretas
- `lui` — carregamento de endereços absolutos (metade alta de 32 bits)

=== Compilando o toolchain

```sh
../gcc/configure \
    --target=rvsc1-unknown-elf \
    --prefix=$(pwd)/install \
    --enable-languages=c \
    --with-newlib
```

=== Limitações

Não implementa `auipc` nem `jal`: o processador não tem acesso ao PC para aritmética de endereço. Consequentemente:

- Todo código deve ser carregado em endereço absoluto fixo (sem PIC).
- Chamadas de função são feitas via `lui`+`jalr` (endereço absoluto) em vez do pseudo `call` (que gera `auipc`+`jalr`, relaxado pelo linker para `jal`).
- Desvios incondicionais dentro de funções (laços, `if`/`else`) são sintetizados via `lui`+`jalr` em vez de `j label` (`jal x0, label`).
- Referências a símbolos globais usam `lui`+`lo12` em vez de `auipc`+`lo12`.

Não implementa cargas de byte ou meia-palavra (`lb`, `lbu`, `lh`, `lhu`): o hardware apenas suporta `lw` (word). O compilador sintetiza todas as quatro instruções via `lw` + alinhamento + extração de bits (ver @sc1-lb-synthesis).

==== Risco: registrador temporário nos saltos absolutos

A síntese `lui t1,%hi(L); jalr x0,t1,%lo(L)` consome um registrador temporário que, no caso normal (`j label`), não seria necessário. O compilador aloca esse registrador via a análise de pseudo-registradores do RTL, sem conflito com valores vivos — mas o código gerado é maior (8 bytes em vez de 4) e mais lento.

==== Síntese de bne

`bne a,b,L` é sintetizado via inversão da condição:

```asm
beq  a, b, skip
lui  t1, %hi(L)
addi t1, t1, %lo(L)
jr   t1
skip:
```

O custo é 16 bytes (4 instruções) contra 4 bytes de um `bne` nativo. O registrador `t1` é consumido como temporário, sem conflito com valores vivos.

==== Síntese de sll constante

`sll rd, rs, n` com deslocamento constante é sintetizado via `add` repetido — cada dobramento equivale a um deslocamento de um bit à esquerda:

```asm
; slli a0, a0, 3  (shift left by 3)
add a0, a0, a0     ; a0 = a0 << 1
add a0, a0, a0     ; a0 = a0 << 2
add a0, a0, a0     ; a0 = a0 << 3
```

O custo é `n` instruções `add` para um deslocamento de `n` bits.

==== Síntese de srl

`srl rd, rs1, rs2` é sintetizado extraindo cada bit de `rs1` da posição `shift` em diante e colocando-o na posição correspondente do resultado. O algoritmo usa apenas `and`, `or`, `add` e `beq`:

```c
result = 0; out_mask = 1; in_mask = 1 << shift;
while (in_mask != 0) {
    if ((rs1 & in_mask) != 0) result |= out_mask;
    out_mask <<= 1; in_mask <<= 1;
}
```

O custo é (32 − shift) iterações de ~7 instruções. Para `srl` variável, adiciona-se um loop de `shift` iterações para calcular `in_mask = 1 << shift`.

==== Síntese de sll variável

`sll rd, rs1, rs2` com deslocamento variável é sintetizado via laço de decremento: o valor é dobrado (`add rd, rd, rd`) exatamente `rs2 & 31` vezes.

```c
uint32_t sll(uint32_t rs1, uint32_t rs2) {
    uint32_t rd = rs1;
    for (uint32_t i = rs2 & 31; i != 0; i--)
        rd += rd;
    return rd;
}
```

```asm
# rd = rs1 << rs2
    andi  count, rs2, 31    # count = rs2 & 31
    mv    rd, rs1
    beq   count, x0, done
loop:
    add   rd, rd, rd        # rd <<= 1
    addi  count, count, -1
    beq   count, x0, done
    beq   x0, x0, loop
done:
```

O custo é até 31 iterações de ~5 instruções para shift máximo de 31 bits.

==== Síntese de sra

`sra rd, rs1, rs2` preserva o bit de sinal. A síntese executa primeiro `srl` e depois, se o bit 31 de `rs1` era 1, aplica extensão de sinal via OR de `sign_mask = 0xFFFFFFFF << (32 − shift)`.

```c
int32_t sra(int32_t rs1, uint32_t rs2) {
    uint32_t shift = rs2 & 31;
    uint32_t result = (uint32_t)srl((uint32_t)rs1, shift);
    if (shift == 0 || (rs1 >> 31) == 0) return result;
    uint32_t sign_mask = (uint32_t)(-1) << (32u - shift);
    return result | sign_mask;
}
```

Para deslocamento constante `n`, `sign_mask` é calculado em tempo de compilação:

```asm
; srai rd, rs1, 3  →  sign_mask = -1 << 29 = 0xE0000000
    and   t6, rs1, 0x80000000   # salva bit de sinal
    [srl  rd, rs1, 3]           # deslocamento lógico (síntese)
    beq   t6, x0, done          # positivo: srl == sra
    ori   rd, rd, 0xE0000000    # OR sign_mask
done:
```

Para deslocamento variável, `sign_mask` é construído em tempo de execução via laço de deslocamento à esquerda de `-1`:

```asm
# sra rd, rs1, rs2
    and   t6, rs1, 0x80000000   # bit de sinal (antes do srl)
    [srl  rd, rs1, rs2]         # deslocamento lógico (síntese)
    beq   t6, x0, done          # positivo: srl == sra
    andi  shift, rs2, 31
    beq   shift, x0, done       # shift==0 mod 32: sem extensão
    neg   n, shift
    addi  n, n, 32              # n = 32 - shift
    li    sign_mask, -1         # 0xFFFFFFFF
ext_sll:
    add   sign_mask, sign_mask, sign_mask
    addi  n, n, -1
    beq   n, x0, apply
    beq   x0, x0, ext_sll
apply:
    or    rd, rd, sign_mask
done:
```

==== Síntese de not

`not rd, rs1` (pseudo-instrução `xori rd, rs1, -1`) é sintetizada via negação aritmética seguida de decremento:

```asm
; not rd, rs1  →  ~x = -x - 1
neg   rd, rs1    # rd = -rs1  (sub rd, x0, rs1)
addi  rd, rd, -1 # rd = -rs1 - 1 = ~rs1
```

A identidade algébrica usada é `~x = −x − 1`, válida para inteiros em complemento de dois. O custo é 2 instruções (`sub` + `addi`), contra 1 instrução `xori` nativa.

==== Síntese de xor

`xor rd, rs1, rs2` é sintetizado via identidade de De Morgan: `a ^ b = ~(a & b) & (a | b)`. A negação intermediária é implementada com a síntese de `not` já definida:

```asm
; xor rd, rs1, rs2
and   t0, rs1, rs2   # t0 = rs1 & rs2
or    t1, rs1, rs2   # t1 = rs1 | rs2
neg   t0, t0         # t0 = -(rs1 & rs2)
addi  t0, t0, -1     # t0 = ~(rs1 & rs2)
and   rd, t0, t1     # rd = ~(rs1&rs2) & (rs1|rs2) = rs1 ^ rs2
```

O custo é 5 instruções para operandos registro. Com `-mno-ori` ativo (sc1), `xori rd, rs1, imm` sintetiza `ori` como `li`+`or`, resultando em 6 instruções no total.

==== Síntese de ori

`ori rd, rs1, imm` é sintetizado carregando o imediato em um registrador temporário e usando `or` registro-registro:

```asm
; ori rd, rs1, imm
li    t, imm         # t = imm  (addi t, x0, imm para pequenos; lui+addi para grandes)
or    rd, rs1, t     # rd = rs1 | t
```

O custo é 2 instruções (`li` + `or`) contra 1 instrução `ori` nativa. Para evitar que o passe `combine` do GCC reinsira o imediato diretamente no padrão `or`, a alternativa imediata do `define_insn` é desabilitada via atributo `enabled` quando `!TARGET_ORI`.

==== Síntese de andi

`andi rd, rs1, imm` é sintetizado carregando o imediato em um registrador temporário e usando `and` registro-registro:

```asm
; andi rd, rs1, imm
li    t, imm         # t = imm  (addi t, x0, imm para pequenos; lui+addi para grandes)
and   rd, rs1, t     # rd = rs1 & t
```

O custo é 2 instruções (`li` + `and`) contra 1 instrução `andi` nativa. A alternativa imediata do `define_insn "*and<mode>3"` é desabilitada via atributo `enabled` quando `!TARGET_ANDI`, impedindo que o passe `combine` reinsira o imediato.

Um caso especial é a instrução de zero-extension `andi rd, rs, 0xff`, emitida pelo padrão `*zero_extendqi<SUPERQI:mode>2_internal` para converter um byte em inteiro. Esse padrão tem alternativa própria (não passa pelo `and<mode>3` expand) e é tratado por um `define_insn_and_split "*zero_extendqisi2_noandi"` que toma prioridade sobre o padrão andi quando `!TARGET_ANDI`. Após reload, o split gera:

```asm
; (unsigned char) rs  →  rd = rs & 0xff
li    rd, 255        # rd = 0xff  (reutiliza rd como temporário; early-clobber garante rd ≠ rs)
and   rd, rs, rd     # rd = rs & 0xff
```

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

Target: `rvsc3`

Flags equivalentes: `-march=rv32i -mabi=ilp32`

Suporta todas as instruções do sc2 mais `fence`.
CSR, system e `fence.i` não são emitidos pelo GCC para programas C normais.

requisito:
o gcc n pode gerar nenhuma nop para intrucoes de desvio pois eh mono ciclo, logo n tem necessidade

=== NOPs em processadores pipeline e RISC-V

Em processadores com pipeline, ao avaliar se um desvio condicional é tomado, o processador já buscou e começou a decodificar as instruções seguintes, criando um _hazard_ de controle:

```asm
beq  t0, x0, target   # decisão do desvio ainda não conhecida
add  t1, t2, t3       # já está no pipeline!
```

Duas soluções clássicas existem:

1. _Stall do pipeline_ — o hardware congela até o desvio ser resolvido, desperdiçando ciclos.
2. _Branch delay slot_ — a ISA define arquiteturalmente que a instrução imediatamente após o desvio sempre executa. O compilador é responsável por preencher esse slot com uma instrução útil ou, quando não há nenhuma, com um `nop`. O MIPS adota essa abordagem.

O RISC-V eliminou deliberadamente os branch delay slots, deixando o hazard de controle como responsabilidade exclusiva do hardware (stall ou predição de desvio). Essa decisão é documentada no manual da ISA @riscv-spec. // TODO: citar também Patterson & Waterman "The RISC-V Reader" cap. 2 após validar referência
O compilador não emite nenhum `nop` especial após desvios — `beq` é simplesmente `beq`:

```asm
// MIPS: delay slot é parte do contrato arquitetural
beq  $t0, $zero, target
nop                        // obrigatório (ou instrução útil)

// RISC-V: sem delay slot, hardware trata o hazard
beq  t0, x0, target
add  t1, t2, t3            // instrução seguinte normal, sem semântica especial
```

Como o processador educacional deste trabalho é _monociclo_ — cada instrução completa atomicamente antes da próxima começar — não existe pipeline, não existem hazards de controle e, portanto, não existe branch delay slot. O requisito do target sc3 é garantir que o GCC não emita tais NOPs, o que para RISC-V já é o comportamento natural do backend.

=== Compilando o toolchain

```sh
../gcc/configure \
    --target=rvsc3-unknown-elf \
    --prefix=$(pwd)/install \
    --enable-languages=c \
    --with-newlib
```

== Monociclo rvi64 - sc4

Target: `rvsc4`

Flags equivalentes: `-march=rv64i -mabi=lp64`

Suporta todas as instruções do sc3 mais as instruções exclusivas do rv64i:

- Memória 64 bits: `ld`, `sd`, `lwu`
- Operações em word com resultado estendido a 64 bits (sufixo W): `addw`, `subw`, `addiw`, `sllw`, `srlw`, `sraw`, `slliw`, `srliw`, `sraiw`

=== Compilando o toolchain

```sh
../gcc/configure \
    --target=rvsc4-unknown-elf \
    --prefix=$(pwd)/install \
    --enable-languages=c \
    --with-newlib
```

== Monociclo rvi64 com multiplicação - sc5

Target: `rvsc5`

Flags equivalentes: `-march=rv64im -mabi=lp64`

Suporta todas as instruções do sc4 mais a extensão M (multiplicação e divisão inteira):

- Multiplicação: `mul`, `mulw`, `mulh`, `mulhu`, `mulhsu`
- Divisão assinada: `div`, `divw`
- Divisão não-assinada: `divu`, `divuw`
- Resto assinado: `rem`, `remw`
- Resto não-assinado: `remu`, `remuw`

As variantes com sufixo W operam em 32 bits e estendem o resultado a 64 bits por sinal, seguindo a mesma convenção de `addw`, `subw` e demais instruções W do sc4.

=== Compilando o toolchain

```sh
../gcc/configure \
    --target=rvsc5-unknown-elf \
    --prefix=$(pwd)/install \
    --enable-languages=c \
    --with-newlib
```

== Monociclo float point - sc6

Target: `rvsc6`

Flags equivalentes: `-march=rv64imfd_zicsr -mabi=lp64d`

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

=== Limitação: garantia de instrução

O flag `-march=rv64imfd_zicsr` informa ao GCC quais instruções ele _pode_ emitir — não impede a emissão de tudo dentro das extensões habilitadas. Em particular, `Zicsr` está no march porque a especificação RISC-V 20191213 exige quando F/D estão presentes (para o registrador `fcsr`), mas isso significa que o GCC _pode_ emitir instruções CSR (`csrrw`, `csrrs`, etc.) se o programa usar tratamento de exceções de ponto flutuante (`fesetround`, `feclearexcept`, `-ftrapping-math`).

Para programas de alunos típicos (aritmética FP sem tratamento de exceções), o GCC não emite instruções CSR. Porém, a garantia não é absoluta — se um aluno usar a API `<fenv.h>`, instruções CSR serão geradas. Uma solução completa exigiria uma opção `-mno-csr` análoga ao `-mno-fence`, guardando todos os padrões CSR no backend RISC-V. Isso está pendente de investigação.

=== Compilando o toolchain

```sh
../gcc/configure \
    --target=rvsc6-unknown-elf \
    --prefix=$(pwd)/install \
    --enable-languages=c \
    --with-newlib
```

== Monociclo atômico - sc7

Target: `rvsc7`

Flags equivalentes: `-march=rv64imafd_zicsr -mabi=lp64d`

Suporta todas as instruções do sc6 mais a extensão A (operações atômicas sobre memória).
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

=== Compilando o toolchain

```sh
../gcc/configure \
    --target=rvsc7-unknown-elf \
    --prefix=$(pwd)/install \
    --enable-languages=c \
    --with-newlib
```


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

Implementado via flag `-mno-slt` (`TARGET_SLT = 0`) no expand `cstore<GPR:mode>4` de `riscv.md`.
As variantes GE/GT/LE são reduzidas a LT com troca de operandos e/ou inversão (`1 - result`).
O intercept em `@cbranch<mode>4` garante que os padrões de síntese de `blt`/`bge` em `*branch<mode>` nunca emitem `slt` como string de asm direta.

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

Implementado junto com `slt` pelo mesmo flag `-mno-slt`. A síntese do GCC expande
`not` via `sub x0, rs; addi -1` e `xor` via De Morgan, produzindo apenas `sub`, `and`, `or`, `addi`.

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

`slti rd, rs1, imm` and `sltiu rd, rs1, imm` compare a register against an integer literal.
Synthesis (`-mno-slti`): load the immediate into a temporary register, then use the register form.

```asm
li    t, imm          # load immediate into register
slt   rd, rs1, t      # slti rd, rs1, imm  →  slt rd, rs1, t
sltu  rd, rs1, t      # sltiu rd, rs1, imm →  sltu rd, rs1, t
```

This synthesis fires only when `TARGET_SLT && !TARGET_SLTI` (native `slt`/`sltu` available but not the immediate forms).
When `!TARGET_SLT`, the immediate is handled automatically by the full sub/xor/and/lshr synthesis path via `force_reg`.

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

=== Ausência de NOPs em instruções de desvio

Para garantir que o GCC não emite `nop` após instruções de desvio, o teste inspeciona o assembly gerado para um conjunto de funções com desvios condicionais e incondicionais.

O script verifica que nenhuma instrução `nop` aparece imediatamente após qualquer desvio (`beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`, `jal`, `jalr`):

```sh
# Compila e gera assembly
rvsc3-unknown-elf-gcc -S -O1 branch_test.c -o branch_test.s

# Falha se qualquer nop seguir imediatamente um desvio
awk '/^[[:space:]]*(beq|bne|blt|bge|bltu|bgeu|jal|jalr)/ { branch=1; next }
     branch && /^[[:space:]]*nop/ { print "FAIL: nop after branch at line " NR; exit 1 }
     { branch=0 }' branch_test.s
```

O teste cobre: `if/else`, `for`, `while`, `do-while`, chamadas de função e retornos.

=== Ausência de auipc em sc1

Para validar que o target sc1 não emite `auipc` — instrução não implementada no hardware — dois casos são testados: aritmética simples e chamada de função.

==== Aritmética simples

```c
// test/sc1_add.c
int add(int a, int b) { return a + b; }
```

```sh
rvsc1-unknown-elf-gcc -S -O1 test/sc1_add.c -o sc1_add.s

grep auipc sc1_add.s && echo FAIL || echo PASS
```

O assembly gerado contém apenas `addi`, `lw`, `sw` e `jr ra` — todos suportados pelo sc1.

==== Chamada de função

```c
// test/sc1_call.c
int foo(int x);
int bar(int x) { return foo(x + 1); }
```

```sh
rvsc1-unknown-elf-gcc -S -O1 test/sc1_call.c -o sc1_call.s

grep auipc sc1_call.s && echo FAIL || echo PASS
```

O assembly gerado usa endereçamento absoluto via `lui`+`jalr` em vez do pseudo `call` (que o montador expandiria para `auipc`+`jalr`):

```asm
lui   a5,%hi(foo)
addi  t1,a5,%lo(foo)
jalr  t1
```

Como a sequência `lui`+`jalr` não corresponde ao padrão `auipc`+`jalr`, o linker não a relaxa para `jal`, garantindo que essa instrução também não seja emitida.

=== Ausência de jal em sc1

Para validar que o target sc1 não emite `jal` (desvio incondicional PC-relativo) em laços ou caminhos de controle:

```c
// test/sc1_loop.c
int sum(int n) {
    int s = 0;
    for (int i = 0; i < n; i++) s += i;
    return s;
}
```

```sh
rvsc1-unknown-elf-gcc -S -O1 test/sc1_loop.c -o sc1_loop.s

grep -E '^\s+(j|jal)\b' sc1_loop.s && echo FAIL || echo PASS
```

O assembly gerado usa `lui`+`addi`+`jr` para saltos incondicionais em vez de `j label`:

```asm
lui   t1,%hi(.L2)
addi  t1,t1,%lo(.L2)
jr    t1
```

=== Ausência de bne em sc1

Para validar que o target sc1 não emite `bne` nativa em desvios condicionais:

```c
// test/sc1_branch.c
int neq(int a, int b) {
    if (a != b) return 1;
    return 0;
}
```

```sh
rvsc1-unknown-elf-gcc -S -O0 test/sc1_branch.c -o sc1_branch.s

grep -E '^\s+bne\b' sc1_branch.s && echo FAIL || echo PASS
```

O assembly gerado usa `beq`+`lui`+`addi`+`jr` em vez de `bne`:

```asm
beq  a4,a5,.L2
li   a5,1
lui  t1,%hi(.L3)
addi t1,t1,%lo(.L3)
jr   t1
.L2:
```

=== Síntese de sll em sc1

Para validar que o target sc1 não emite `sll`/`slli` mas usa `add` para deslocamentos constantes:

```c
// test/sc1_shift.c
int shift3(int x) { return x << 3; }
```

```sh
rvsc1-unknown-elf-gcc -S -O1 test/sc1_shift.c -o sc1_shift.s

grep -E '^\s+sll' sc1_shift.s && echo FAIL || echo PASS
```

O assembly gerado usa três `add` em vez de `slli`:

```asm
add a0, a0, a0
add a0, a0, a0
add a0, a0, a0
```

=== Síntese de srl em sc1

Para validar que o target sc1 não emite `srl`/`srli` mas usa o loop de extração de bits:

```c
// test/sc1_srl.c
unsigned shr3(unsigned x) { return x >> 3; }
```

```sh
rvsc1-unknown-elf-gcc -S -O1 test/sc1_srl.c -o sc1_srl.s

grep -E '^\s+srl' sc1_srl.s && echo FAIL || echo PASS
```

O assembly gerado usa `and`, `or`, `add` e `beq` em vez de `srli`:

```asm
li   a5,8       # in_mask = 1 << 3
li   a3,1       # out_mask = 1
li   a0,0       # result = 0
.L2:
beq  a5,zero,.L4
and  a2,a4,a5
beq  a2,zero,.L3
or   a0,a0,a3
.L3:
add  a3,a3,a3
add  a5,a5,a5
...
```

=== Síntese de sll variável em sc1

Para validar que o target sc1 não emite `sll` para deslocamentos com operando variável:

```c
// test/sc1_sll_var.c
int sll_var(int x, int n) { return x << n; }
```

```sh
rvsc1-unknown-elf-gcc -S -O1 test/sc1_sll_var.c -o sc1_sll_var.s

grep -E '^\s+sll' sc1_sll_var.s && echo FAIL || echo PASS
```

O assembly gerado usa `li`+`and`+`add`+`beq` em vez de `sll` (com `andi` também sintetizado):

```asm
li    a5,31
and   a1,a1,a5     # andi sintetizado: a1 &= 31
beq   a1,zero,.Ldone
.Lloop:
    add   a0,a0,a0
    addi  a1,a1,-1
    beq   a1,zero,.Ldone
    ...
.Ldone:
```

=== Síntese de sra em sc1

Para validar que o target sc1 não emite `sra`/`srai` mas usa `srl` seguido de extensão de sinal:

```c
// test/sc1_sra.c
int sra3(int x) { return x >> 3; }         // constante
int sra_var(int x, int n) { return x >> n; } // variável
```

```sh
rvsc1-unknown-elf-gcc -S -O1 test/sc1_sra.c -o sc1_sra.s

grep -E '^\s+sra' sc1_sra.s && echo FAIL || echo PASS
```

Para `sra3`, o assembly gerado usa a síntese de `srl` seguida de OR com a constante `0xE0000000` (`-1 << 29`):

```asm
li    a4,-2147483648   # 0x80000000: máscara do bit de sinal
and   a3,a0,a4         # a3 = bit de sinal
li    a0,0             # result = 0
li    a2,1             # out_mask = 1
li    a4,8             # in_mask = 1 << 3
.L2:                   # loop srl
    beq   a4,zero,.L4
    and   a1,a5,a4
    beq   a1,zero,.L3
    or    a0,a0,a2
.L3:
    add   a2,a2,a2
    add   a4,a4,a4
    ...
.L4:
    beq   a3,zero,.L5  # positivo: srl == sra
    li    a5,-536870912 # 0xE0000000 = -1 << 29
    or    a0,a0,a5     # extensão de sinal
.L5:
```

=== Síntese de not em sc1

Para validar que o target sc1 não emite `not`/`xori` mas usa `neg` + `addi`:

```c
// test/sc1_not.c
int f(int x) { return ~x; }
```

```sh
rvsc1-unknown-elf-gcc -S -O1 test/sc1_not.c -o sc1_not.s

grep -E '^\s+(not|xori)\b' sc1_not.s && echo FAIL || echo PASS
```

O assembly gerado usa `neg` (`sub a0,x0,a0`) e `addi` em vez de `xori`:

```asm
neg   a0, a0     # a0 = -a0
addi  a0, a0, -1 # a0 = ~a0
```

=== Síntese de xor em sc1

Para validar que o target sc1 não emite `xor`/`xori` mas usa a síntese via De Morgan:

```c
// test/sc1_xor.c
int xor_reg(int a, int b) { return a ^ b; }
int xor_imm(int a)         { return a ^ 5; }
```

```sh
rvsc1-unknown-elf-gcc -S -O1 test/sc1_xor.c -o sc1_xor.s

grep -E '^\s+(xor|xori)\b' sc1_xor.s && echo FAIL || echo PASS
```

Para `xor_reg`, o assembly gerado usa a sequência `and`/`or`/`neg`/`addi`/`and`:

```asm
and   a5, a0, a1   # a5 = a & b
or    a0, a0, a1   # a0 = a | b
neg   a5, a5       # a5 = -(a & b)
addi  a5, a5, -1   # a5 = ~(a & b)
and   a0, a5, a0   # a0 = ~(a&b) & (a|b) = a ^ b
```

Para `xor_imm` com constante 5, tanto `andi` quanto `ori` são sintetizados (pois `-mno-andi` e `-mno-ori` estão ativos). O compilador carrega o imediato uma única vez num temporário e reutiliza-o para ambos:

```asm
li    a4, 5        # a4 = 5
and   a5, a0, a4   # a5 = a & 5  (andi sintetizado)
or    a0, a0, a4   # a0 = a | 5  (ori sintetizado)
neg   a5, a5       # a5 = -(a & 5)
addi  a5, a5, -1   # a5 = ~(a & 5)
and   a0, a5, a0   # a0 = ~(a&5) & (a|5) = a ^ 5
```

=== Síntese de andi em sc1

Para validar que o target sc1 não emite `andi` mas usa `li`+`and`:

```c
// test/sc1_andi.c
int andi_test(int a) { return a & 5; }
int and_reg(int a, int b) { return a & b; }
```

```sh
rvsc1-unknown-elf-gcc -S -O1 test/sc1_andi.c -o sc1_andi.s

grep -E '^\s+andi\b' sc1_andi.s && echo FAIL || echo PASS
```

`andi_test` usa `li`+`and` em vez de `andi`; `and_reg` mantém `and` nativo:

```asm
; andi_test
li    a5, 5        # a5 = 5
and   a0, a0, a5   # a0 = a & 5

; and_reg
and   a0, a0, a1   # a0 = a & b  (inalterado)
```

=== Síntese de ori em sc1

Para validar que o target sc1 não emite `ori` mas usa `li`+`or`:

```c
// test/sc1_ori.c
int ori_test(int a) { return a | 5; }
int or_reg(int a, int b) { return a | b; }
```

```sh
rvsc1-unknown-elf-gcc -S -O1 test/sc1_ori.c -o sc1_ori.s

grep -E '^\s+ori\b' sc1_ori.s && echo FAIL || echo PASS
```

`ori_test` usa `li`+`or` em vez de `ori`; `or_reg` mantém `or` nativo:

```asm
; ori_test
li    a5, 5        # a5 = 5
or    a0, a0, a5   # a0 = a | 5

; or_reg
or    a0, a0, a1   # a0 = a | b  (inalterado)
```

=== Síntese de lb/lbu/lh/lhu em sc1

Para validar que o target sc1 não emite `lb`, `lbu`, `lh` ou `lhu` — instruções não implementadas no hardware — quatro testes verificam que cada carga de byte ou meia-palavra é substituída por uma sequência baseada em `lw`:

```c
// test/sc1_lbu.c
int test_lbu(unsigned char *p) { return *p; }

// test/sc1_lb.c
int test_lb(char *p) { return *p; }

// test/sc1_lhu.c
int test_lhu(unsigned short *p) { return *p; }

// test/sc1_lh.c
int test_lh(short *p) { return *p; }
```

```sh
for insn in lbu lb lhu lh; do
  rvsc1-unknown-elf-gcc -S -O1 test/sc1_${insn}.c -o - \
    | grep -E "^\s+${insn}\b" && echo FAIL || echo PASS
done
```

O assembly gerado para `test_lbu` começa com o alinhamento do endereço e a carga da word:

```asm
li    a5, -4
and   a5, a0, a5          # a5 = addr & -4  (word alinhada)
lw    a1, 0(a5)           # a1 = word contendo o byte
li    a5, 3
and   a0, a0, a5          # a0 = addr & 3  (posição do byte)
add   a0, a0, a0          # \
add   a0, a0, a0          #  sll a0, a0, 3  (posição em bits)
add   a0, a0, a0          # /
# ... srl loop (extrai byte) ...
# ... sll/srl 24 (zero-extends byte) ...
```

Nenhum dos quatro casos emite as instruções proibidas; todos passam nos testes de síntese.

=== Síntese de sb/sh em sc1

Para validar que o target sc1 não emite `sb` nem `sh` — instruções não implementadas no hardware — dois testes verificam que cada store de byte ou meia-palavra é substituído por uma sequência de leitura-modificação-escrita baseada em `lw`+`sw`:

```c
// test/sc1_sb.c
void test_sb(char *p, int v) { *p = v; }
void test_sb_offset(char *p, int v) { p[2] = v; }

// test/sc1_sh.c
void test_sh(short *p, int v) { *p = v; }
void test_sh_offset(short *p, int v) { p[1] = v; }
```

```sh
for insn in sb sh; do
  rvsc1-unknown-elf-gcc -S -O1 test/sc1_${insn}.c -o - \
    | grep -E "^\s+${insn}\b" && echo FAIL || echo PASS
done
```

O assembly gerado para `test_sb` usa apenas instruções sc1 — note o padrão leitura-modificação-escrita com shifts variáveis sintetizados:

```asm
li    a5, -4
and   a3, a0, a5          # a3 = addr & -4  (word alinhada)
li    a5, 3
and   a0, a0, a5          # a0 = addr & 3  (byte_pos)
add   a0, a0, a0          # \
add   a0, a0, a0          #  a0 = byte_pos * 8  (sll constante sintetizado)
add   a0, a0, a0          # /
lw    a4, 0(a3)           # a4 = old word
li    a5, 255
[sll  a5, a5, a0]         # máscara = 0xFF << shift  (sll variável sintetizado)
not   a5, a5              # ~máscara
and   a4, a4, a5          # apaga byte alvo
li    a5, 255
and   a5, a1, a5          # isola byte de entrada
[sll  a5, a5, a0]         # posiciona valor
or    a4, a4, a5          # insere byte
sw    a4, 0(a3)           # armazena de volta
```

Nenhum dos dois casos emite `sb` ou `sh`; ambos passam nos testes de síntese.

=== Ausência de fence em sc2

Para validar que o target sc2 suprime corretamente a instrução `fence`, o teste compila `test/fence.c` e inspeciona o assembly gerado para a função `barrier`.

```c
#include <stdatomic.h>
atomic_int x;
void barrier(void) { atomic_thread_fence(memory_order_seq_cst); }
int load(void)     { return atomic_load(&x); }
void store(int v)  { atomic_store(&x, v); }
```

O script verifica que nenhuma instrução `fence` é emitida pelo compilador:

```sh
rvsc2-unknown-elf-gcc -S -O1 test/fence.c -o fence.s

# Falha se qualquer fence aparecer no assembly (excluindo comentários)
grep -v '^\s*#' fence.s | grep -w 'fence' && echo FAIL || echo PASS
```

Com `TARGET_FENCE = 0`, o padrão `mem_thread_fence` em `sync.md` executa `DONE` imediatamente sem emitir nenhuma instrução, de modo que `barrier` se reduz a um retorno vazio.

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
