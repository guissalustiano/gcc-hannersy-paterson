;; Machine description for RISC-V for GNU compiler.
;; Copyright (C) 2011-2026 Free Software Foundation, Inc.
;; Contributed by Andrew Waterman (andrew@sifive.com).
;; Based on MIPS target for GNU compiler.

;; This file is part of GCC.

;; GCC is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; GCC is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GCC; see the file COPYING3.  If not see
;; <http://www.gnu.org/licenses/>.


;; Keep this list and the one above riscv_print_operand in sync.
;; The special asm out single letter directives following a '%' are:
;; h -- Print the high-part relocation associated with OP, after stripping
;;	  any outermost HIGH.
;; R -- Print the low-part relocation associated with OP.
;; C -- Print the integer branch condition for comparison OP.
;; A -- Print the atomic operation suffix for memory model OP.
;; F -- Print a FENCE if the memory model requires a release.
;; z -- Print x0 if OP is zero, otherwise print OP normally.
;; i -- Print i if the operand is not a register.
;; S -- Print shift-index of single-bit mask OP.
;; T -- Print shift-index of inverted single-bit mask OP.
;; ~ -- Print w if TARGET_64BIT is true; otherwise not print anything.

(define_c_enum "unspec" [
  ;; Override return address for exception handling.
  UNSPEC_EH_RETURN

  ;; Symbolic accesses.  The order of this list must match that of
  ;; enum riscv_symbol_type in riscv-protos.h.
  UNSPEC_ADDRESS_FIRST
  UNSPEC_FORCE_FOR_MEM
  UNSPEC_PCREL
  UNSPEC_LOAD_GOT
  UNSPEC_TLS
  UNSPEC_TLS_LE
  UNSPEC_TLS_IE
  UNSPEC_TLS_GD
  UNSPEC_TLSDESC
  ;; High part of PC-relative address.
  UNSPEC_AUIPC

  ;; Floating-point unspecs.
  UNSPEC_FLT_QUIET
  UNSPEC_FLE_QUIET
  UNSPEC_COPYSIGN
  UNSPEC_FMV_X_W
  UNSPEC_FMVH_X_D
  UNSPEC_RINT
  UNSPEC_ROUND
  UNSPEC_FLOOR
  UNSPEC_CEIL
  UNSPEC_BTRUNC
  UNSPEC_ROUNDEVEN
  UNSPEC_NEARBYINT
  UNSPEC_LRINT
  UNSPEC_FMIN
  UNSPEC_FMAX
  UNSPEC_FMINM
  UNSPEC_FMAXM
  UNSPEC_FCLASS

  ;; Stack tie
  UNSPEC_TIE

  ;; OR-COMBINE
  UNSPEC_ORC_B

  ;; Zbc unspecs
  UNSPEC_CLMUL
  UNSPEC_CLMULH
  UNSPEC_CLMULR

  ;; the calling convention of callee
  UNSPEC_CALLEE_CC

  ;; String unspecs
  UNSPEC_STRLEN

  ;; Workaround for HFmode and BFmode without hardware extension
  UNSPEC_FMV_FP16_X

  ;; XTheadFmv moves
  UNSPEC_XTHEADFMV
  UNSPEC_XTHEADFMV_HW

  ;; CRC unspecs
  UNSPEC_CRC
  UNSPEC_CRC_REV

  ;; Stack Smash Protector
  UNSPEC_SSP_SET
  UNSPEC_SSP_TEST
])

(define_c_enum "unspecv" [
  ;; Register save and restore.
  UNSPECV_GPR_SAVE
  UNSPECV_GPR_RESTORE

  ;; Floating-point unspecs.
  UNSPECV_FRCSR
  UNSPECV_FSCSR
  UNSPECV_FRFLAGS
  UNSPECV_FSFLAGS
  UNSPECV_FSNVSNAN

  ;; Interrupt handler instructions.
  UNSPECV_MRET
  UNSPECV_SRET
  UNSPECV_MNRET

  ;; Blockage and synchronization.
  UNSPECV_BLOCKAGE
  UNSPECV_FENCE
  UNSPECV_FENCE_I

  ;; CMO instructions.
  UNSPECV_CLEAN
  UNSPECV_FLUSH
  UNSPECV_INVAL
  UNSPECV_ZERO
  UNSPECV_PREI

  ;; Zihintpause unspec
  UNSPECV_PAUSE

  ;; ZICFISS
  UNSPECV_SSPUSH
  UNSPECV_SSPOPCHK
  UNSPECV_SSRDP
  UNSPECV_SSP

  ;; ZICFILP
  UNSPECV_LPAD
  UNSPECV_SETLPL
  UNSPECV_LPAD_ALIGN
  UNSPECV_SET_GUARDED

  ;; XTheadInt unspec
  UNSPECV_XTHEADINT_PUSH
  UNSPECV_XTHEADINT_POP
])

(define_constants
  [(RETURN_ADDR_REGNUM		1)
   (SP_REGNUM 			2)
   (GP_REGNUM 			3)
   (TP_REGNUM			4)
   (T0_REGNUM			5)
   (T1_REGNUM			6)
   (T2_REGNUM			7)
   (S0_REGNUM			8)
   (S1_REGNUM			9)
   (A0_REGNUM			10)
   (A1_REGNUM			11)
   (S2_REGNUM			18)
   (S3_REGNUM			19)
   (S4_REGNUM			20)
   (S5_REGNUM			21)
   (S6_REGNUM			22)
   (S7_REGNUM			23)
   (S8_REGNUM			24)
   (S9_REGNUM			25)
   (S10_REGNUM			26)
   (S11_REGNUM			27)

   (NORMAL_RETURN		0)
   (SIBCALL_RETURN		1)
   (EXCEPTION_RETURN		2)
   (VL_REGNUM			66)
   (VTYPE_REGNUM		67)
   (VXRM_REGNUM			68)
   (FRM_REGNUM			69)
])

(include "predicates.md")
(include "constraints.md")
(include "iterators.md")

;; ....................
;;
;;	Attributes
;;
;; ....................

(define_attr "got" "unset,xgot_high,load"
  (const_string "unset"))

;; Classification of moves, extensions and truncations.  Most values
;; are as for "type" (see below) but there are also the following
;; move-specific values:
;;
;; andi		a single ANDI instruction
;; shift_shift	a shift left followed by a shift right
;;
;; This attribute is used to determine the instruction's length and
;; scheduling type.  For doubleword moves, the attribute always describes
;; the split instructions; in some cases, it is more appropriate for the
;; scheduling type to be "multi" instead.
(define_attr "move_type"
  "unknown,load,fpload,store,fpstore,mtc,mfc,move,fmove,
   const,logical,arith,andi,shift_shift,rdvlenb"
  (const_string "unknown"))

;; Main data type used by the insn
(define_attr "mode" "unknown,none,QI,HI,SI,DI,TI,HF,BF,SF,DF,TF,
  RVVMF64BI,RVVMF32BI,RVVMF16BI,RVVMF8BI,RVVMF4BI,RVVMF2BI,RVVM1BI,
  RVVM8QI,RVVM4QI,RVVM2QI,RVVM1QI,RVVMF2QI,RVVMF4QI,RVVMF8QI,
  RVVM8HI,RVVM4HI,RVVM2HI,RVVM1HI,RVVMF2HI,RVVMF4HI,
  RVVM8BF,RVVM4BF,RVVM2BF,RVVM1BF,RVVMF2BF,RVVMF4BF,
  RVVM8HF,RVVM4HF,RVVM2HF,RVVM1HF,RVVMF2HF,RVVMF4HF,
  RVVM8SI,RVVM4SI,RVVM2SI,RVVM1SI,RVVMF2SI,
  RVVM8SF,RVVM4SF,RVVM2SF,RVVM1SF,RVVMF2SF,
  RVVM8DI,RVVM4DI,RVVM2DI,RVVM1DI,
  RVVM8DF,RVVM4DF,RVVM2DF,RVVM1DF,
  RVVM1x8QI,RVVMF2x8QI,RVVMF4x8QI,RVVMF8x8QI,
  RVVM1x7QI,RVVMF2x7QI,RVVMF4x7QI,RVVMF8x7QI,
  RVVM1x6QI,RVVMF2x6QI,RVVMF4x6QI,RVVMF8x6QI,
  RVVM1x5QI,RVVMF2x5QI,RVVMF4x5QI,RVVMF8x5QI,
  RVVM2x4QI,RVVM1x4QI,RVVMF2x4QI,RVVMF4x4QI,RVVMF8x4QI,
  RVVM2x3QI,RVVM1x3QI,RVVMF2x3QI,RVVMF4x3QI,RVVMF8x3QI,
  RVVM4x2QI,RVVM2x2QI,RVVM1x2QI,RVVMF2x2QI,RVVMF4x2QI,RVVMF8x2QI,
  RVVM1x8HI,RVVMF2x8HI,RVVMF4x8HI,
  RVVM1x7HI,RVVMF2x7HI,RVVMF4x7HI,
  RVVM1x6HI,RVVMF2x6HI,RVVMF4x6HI,
  RVVM1x5HI,RVVMF2x5HI,RVVMF4x5HI,
  RVVM2x4HI,RVVM1x4HI,RVVMF2x4HI,RVVMF4x4HI,
  RVVM2x3HI,RVVM1x3HI,RVVMF2x3HI,RVVMF4x3HI,
  RVVM4x2HI,RVVM2x2HI,RVVM1x2HI,RVVMF2x2HI,RVVMF4x2HI,
  RVVM1x8BF,RVVMF2x8BF,RVVMF4x8BF,RVVM1x7BF,RVVMF2x7BF,
  RVVMF4x7BF,RVVM1x6BF,RVVMF2x6BF,RVVMF4x6BF,RVVM1x5BF,
  RVVMF2x5BF,RVVMF4x5BF,RVVM2x4BF,RVVM1x4BF,RVVMF2x4BF,
  RVVMF4x4BF,RVVM2x3BF,RVVM1x3BF,RVVMF2x3BF,RVVMF4x3BF,
  RVVM4x2BF,RVVM2x2BF,RVVM1x2BF,RVVMF2x2BF,RVVMF4x2BF,
  RVVM1x8HF,RVVMF2x8HF,RVVMF4x8HF,RVVM1x7HF,RVVMF2x7HF,
  RVVMF4x7HF,RVVM1x6HF,RVVMF2x6HF,RVVMF4x6HF,RVVM1x5HF,
  RVVMF2x5HF,RVVMF4x5HF,RVVM2x4HF,RVVM1x4HF,RVVMF2x4HF,
  RVVMF4x4HF,RVVM2x3HF,RVVM1x3HF,RVVMF2x3HF,RVVMF4x3HF,
  RVVM4x2HF,RVVM2x2HF,RVVM1x2HF,RVVMF2x2HF,RVVMF4x2HF,
  RVVM1x8SI,RVVMF2x8SI,
  RVVM1x7SI,RVVMF2x7SI,
  RVVM1x6SI,RVVMF2x6SI,
  RVVM1x5SI,RVVMF2x5SI,
  RVVM2x4SI,RVVM1x4SI,RVVMF2x4SI,
  RVVM2x3SI,RVVM1x3SI,RVVMF2x3SI,
  RVVM4x2SI,RVVM2x2SI,RVVM1x2SI,RVVMF2x2SI,
  RVVM1x8SF,RVVMF2x8SF,RVVM1x7SF,RVVMF2x7SF,
  RVVM1x6SF,RVVMF2x6SF,RVVM1x5SF,RVVMF2x5SF,
  RVVM2x4SF,RVVM1x4SF,RVVMF2x4SF,RVVM2x3SF,
  RVVM1x3SF,RVVMF2x3SF,RVVM4x2SF,RVVM2x2SF,
  RVVM1x2SF,RVVMF2x2SF,
  RVVM1x8DI,RVVM1x7DI,RVVM1x6DI,RVVM1x5DI,
  RVVM2x4DI,RVVM1x4DI,RVVM2x3DI,RVVM1x3DI,
  RVVM4x2DI,RVVM2x2DI,RVVM1x2DI,RVVM1x8DF,
  RVVM1x7DF,RVVM1x6DF,RVVM1x5DF,RVVM2x4DF,
  RVVM1x4DF,RVVM2x3DF,RVVM1x3DF,RVVM4x2DF,
  RVVM2x2DF,RVVM1x2DF,
  V1QI,V2QI,V4QI,V8QI,V16QI,V32QI,V64QI,V128QI,V256QI,V512QI,V1024QI,V2048QI,V4096QI,
  V1HI,V2HI,V4HI,V8HI,V16HI,V32HI,V64HI,V128HI,V256HI,V512HI,V1024HI,V2048HI,
  V1SI,V2SI,V4SI,V8SI,V16SI,V32SI,V64SI,V128SI,V256SI,V512SI,V1024SI,
  V1DI,V2DI,V4DI,V8DI,V16DI,V32DI,V64DI,V128DI,V256DI,V512DI,
  V1HF,V2HF,V4HF,V8HF,V16HF,V32HF,V64HF,V128HF,V256HF,V512HF,V1024HF,V2048HF,
  V1BF,V2BF,V4BF,V8BF,V16BF,V32BF,V64BF,V128BF,V256BF,V512BF,V1024BF,V2048BF,
  V1SF,V2SF,V4SF,V8SF,V16SF,V32SF,V64SF,V128SF,V256SF,V512SF,V1024SF,
  V1DF,V2DF,V4DF,V8DF,V16DF,V32DF,V64DF,V128DF,V256DF,V512DF,
  V1BI,V2BI,V4BI,V8BI,V16BI,V32BI,V64BI,V128BI,V256BI,V512BI,V1024BI,V2048BI,V4096BI"
  (const_string "unknown"))

;; True if the main data type is twice the size of a word.
(define_attr "dword_mode" "no,yes"
  (cond [(and (eq_attr "mode" "DI,DF")
	      (eq (symbol_ref "TARGET_64BIT") (const_int 0)))
	 (const_string "yes")

	 (and (eq_attr "mode" "TI,TF")
	      (ne (symbol_ref "TARGET_64BIT") (const_int 0)))
	 (const_string "yes")]
	(const_string "no")))

;; ISA attributes.
(define_attr "ext" "base,f,d,vector"
  (const_string "base"))

;; True if the extension is enabled.
(define_attr "ext_enabled" "no,yes"
  (cond [(eq_attr "ext" "base")
	 (const_string "yes")

	 (and (eq_attr "ext" "f")
	      (match_test "TARGET_HARD_FLOAT"))
	 (const_string "yes")

	 (and (eq_attr "ext" "d")
	      (match_test "TARGET_DOUBLE_FLOAT"))
	 (const_string "yes")

	 (and (eq_attr "ext" "vector")
	      (match_test "TARGET_VECTOR"))
	 (const_string "yes")
	]
	(const_string "no")))

;; Classification of each insn.
;; branch	conditional branch
;; jump		unconditional direct jump
;; jalr		unconditional indirect jump
;; ret		various returns, no arguments
;; call		unconditional call
;; load		load instruction(s)
;; fpload	floating point load
;; store	store instruction(s)
;; fpstore	floating point store
;; mtc		transfer to coprocessor
;; mfc		transfer from coprocessor
;; const	load constant
;; arith	integer arithmetic instructions
;; logical      integer logical instructions
;; shift	integer shift instructions
;; slt		set less than instructions
;; imul		integer multiply
;; idiv		integer divide
;; move		integer register move (addi rd, rs1, 0)
;; fmove	floating point register move
;; fadd		floating point add/subtract
;; fmul		floating point multiply
;; fmadd	floating point multiply-add
;; fdiv		floating point divide
;; fcmp		floating point compare
;; fcvt		floating point convert
;; fcvt_i2f	integer to floating point convert
;; fcvt_f2i	floating point to integer convert
;; fsqrt	floating point square root
;; multi	multiword sequence (or user asm statements)
;; auipc	integer addition to PC
;; sfb_alu  SFB ALU instruction
;; nop		no operation
;; trap		trap instruction
;; ghost	an instruction that produces no real code
;; bitmanip	bit manipulation instructions
;; clmul    clmul, clmulh, clmulr
;; rotate   rotation instructions
;; atomic   atomic instructions
;; condmove	conditional moves
;; crypto cryptography instructions
;; mvpair    zc move pair instructions
;; zicond    zicond instructions
;; Classification of RVV instructions which will be added to each RVV .md pattern and used by scheduler.
;; rdvlenb     vector byte length vlenb csrr read
;; rdvl        vector length vl csrr read
;; wrvxrm      vector fixed-point rounding mode write
;; wrfrm       vector floating-point rounding mode write
;; vsetvl      vector configuration-setting instrucions
;; 7. Vector Loads and Stores
;; vlde        vector unit-stride load instructions
;; vste        vector unit-stride store instructions
;; vldm        vector unit-stride mask load instructions
;; vstm        vector unit-stride mask store instructions
;; vlds        vector strided load instructions
;; vsts        vector strided store instructions
;; vldux       vector unordered indexed load instructions
;; vldox       vector ordered indexed load instructions
;; vstux       vector unordered indexed store instructions
;; vstox       vector ordered indexed store instructions
;; vldff       vector unit-stride fault-only-first load instructions
;; vldr        vector whole register load instructions
;; vstr        vector whole register store instructions
;; vlsegde     vector segment unit-stride load instructions
;; vssegte     vector segment unit-stride store instructions
;; vlsegds     vector segment strided load instructions
;; vssegts     vector segment strided store instructions
;; vlsegdux    vector segment unordered indexed load instructions
;; vlsegdox    vector segment ordered indexed load instructions
;; vssegtux    vector segment unordered indexed store instructions
;; vssegtox    vector segment ordered indexed store instructions
;; vlsegdff    vector segment unit-stride fault-only-first load instructions
;; 11. Vector integer arithmetic instructions
;; vialu       vector single-width integer add and subtract and logical nstructions
;; viwalu      vector widening integer add/subtract
;; vext        vector integer extension
;; vicalu      vector arithmetic with carry or borrow instructions
;; vshift      vector single-width bit shift instructions
;; vnshift     vector narrowing integer shift instructions
;; viminmax    vector integer min/max instructions
;; vicmp       vector integer comparison instructions
;; vimul       vector single-width integer multiply instructions
;; vidiv       vector single-width integer divide instructions
;; viwmul      vector widening integer multiply instructions
;; vimuladd    vector single-width integer multiply-add instructions
;; viwmuladd   vector widening integer multiply-add instructions
;; vimerge     vector integer merge instructions
;; vimov       vector integer move vector instructions
;; 12. Vector fixed-point arithmetic instructions
;; vsalu       vector single-width saturating add and subtract and logical instructions
;; vaalu       vector single-width averaging add and subtract and logical instructions
;; vsmul       vector single-width fractional multiply with rounding and saturation instructions
;; vsshift     vector single-width scaling shift instructions
;; vnclip      vector narrowing fixed-point clip instructions
;; 13. Vector floating-point instructions
;; vfalu       vector single-width floating-point add/subtract instructions
;; vfwalu      vector widening floating-point add/subtract instructions
;; vfmul       vector single-width floating-point multiply instructions
;; vfdiv       vector single-width floating-point divide instructions
;; vfwmul      vector widening floating-point multiply instructions
;; vfmuladd    vector single-width floating-point multiply-add instructions
;; vfwmuladd   vector widening floating-point multiply-add instructions
;; vfsqrt      vector floating-point square-root instructions
;; vfrecp      vector floating-point reciprocal square-root instructions
;; vfminmax    vector floating-point min/max instructions
;; vfcmp       vector floating-point comparison instructions
;; vfsgnj      vector floating-point sign-injection instructions
;; vfclass     vector floating-point classify instruction
;; vfmerge     vector floating-point merge instruction
;; vfmov       vector floating-point move instruction
;; vfcvtitof   vector single-width integer to floating-point instruction
;; vfcvtftoi   vector single-width floating-point to integer instruction
;; vfwcvtitof  vector widening integer to floating-point instruction
;; vfwcvtftoi  vector widening floating-point to integer instruction
;; vfwcvtftof  vector widening floating-point to floating-point instruction
;; vfncvtitof  vector narrowing integer to floating-point instruction
;; vfncvtftoi  vector narrowing floating-point to integer instruction
;; vfncvtftof  vector narrowing floating-point to floating-point instruction
;; 14. Vector reduction operations
;; vired       vector single-width integer reduction instructions
;; viwred      vector widening integer reduction instructions
;; vfredu      vector single-width floating-point un-ordered reduction instruction
;; vfredo      vector single-width floating-point ordered reduction instruction
;; vfwredu     vector widening floating-point un-ordered reduction instruction
;; vfwredo     vector widening floating-point ordered reduction instruction
;; 15. Vector mask instructions
;; vmalu       vector mask-register logical instructions
;; vmpop       vector mask population count
;; vmffs       vector find-first-set mask bit
;; vmsfs       vector set mask bit
;; vmiota      vector iota
;; vmidx       vector element index instruction
;; 16. Vector permutation instructions
;; vimovvx      integer scalar move instructions
;; vimovxv      integer scalar move instructions
;; vfmovvf      floating-point scalar move instructions
;; vfmovfv      floating-point scalar move instructions
;; vslideup     vector slide instructions
;; vslidedown   vector slide instructions
;; vislide1up   vector slide instructions
;; vislide1down vector slide instructions
;; vfslide1up   vector slide instructions
;; vfslide1down vector slide instructions
;; vgather      vector register gather instructions
;; vcompress    vector compress instruction
;; vmov         whole vector register move
;; vector       unknown vector instruction
;; 17. Crypto Vector instructions
;; vandn        crypto vector bitwise and-not instructions
;; vbrev        crypto vector reverse bits in elements instructions
;; vbrev8       crypto vector reverse bits in bytes instructions
;; vrev8        crypto vector reverse bytes instructions
;; vclz         crypto vector count leading Zeros instructions
;; vctz         crypto vector count lrailing Zeros instructions
;; vrol         crypto vector rotate left instructions
;; vror         crypto vector rotate right instructions
;; vwsll        crypto vector widening shift left logical instructions
;; vclmul       crypto vector carry-less multiply - return low half instructions
;; vclmulh      crypto vector carry-less multiply - return high half instructions
;; vghsh        crypto vector add-multiply over GHASH Galois-Field instructions
;; vgmul        crypto vector multiply over GHASH Galois-Field instrumctions
;; vaesef       crypto vector AES final-round encryption instructions
;; vaesem       crypto vector AES middle-round encryption instructions
;; vaesdf       crypto vector AES final-round decryption instructions
;; vaesdm       crypto vector AES middle-round decryption instructions
;; vaeskf1      crypto vector AES-128 Forward KeySchedule generation instructions
;; vaeskf2      crypto vector AES-256 Forward KeySchedule generation instructions
;; vaesz        crypto vector AES round zero encryption/decryption instructions
;; vsha2ms      crypto vector SHA-2 message schedule instructions
;; vsha2ch      crypto vector SHA-2 two rounds of compression instructions
;; vsha2cl      crypto vector SHA-2 two rounds of compression instructions
;; vsm4k        crypto vector SM4 KeyExpansion instructions
;; vsm4r        crypto vector SM4 Rounds instructions
;; vsm3me       crypto vector SM3 Message Expansion instructions
;; vsm3c        crypto vector SM3 Compression instructions
;; 18.Vector BF16 instrctions
;; vfncvtbf16  vector narrowing single floating-point to brain floating-point instruction
;; vfwcvtbf16  vector widening brain floating-point to single floating-point instruction
;; vfwmaccbf16  vector BF16 widening multiply-accumulate
;; SiFive custom extension instrctions
;; sf_vqmacc      vector matrix integer multiply-add instructions
;; sf_vfnrclip     vector fp32 to int8 ranged clip instructions
;; sf_vc vector coprocessor interface without side effect
;; sf_vc_se vector coprocessor interface with side effect
(define_attr "type"
  "unknown,branch,jump,jalr,ret,call,load,fpload,store,fpstore,
   mtc,mfc,const,arith,logical,shift,slt,imul,idiv,move,fmove,fadd,fmul,
   fmadd,fdiv,fcmp,fcvt,fcvt_i2f,fcvt_f2i,fsqrt,multi,auipc,sfb_alu,nop,trap,
   ghost,bitmanip,rotate,clmul,min,max,minu,maxu,clz,ctz,cpop,
   atomic,condmove,crypto,mvpair,zicond,rdvlenb,rdvl,wrvxrm,wrfrm,
   rdfrm,vsetvl,vsetvl_pre,vlde,vste,vldm,vstm,vlds,vsts,
   vldux,vldox,vstux,vstox,vldff,vldr,vstr,
   vlsegde,vssegte,vlsegds,vssegts,vlsegdux,vlsegdox,vssegtux,vssegtox,vlsegdff,
   vialu,viwalu,vext,vicalu,vshift,vnshift,vicmp,viminmax,
   vimul,vidiv,viwmul,vimuladd,sf_vqmacc,viwmuladd,vimerge,vimov,
   vsalu,vaalu,vsmul,vsshift,vnclip,sf_vfnrclip,
   vfalu,vfwalu,vfmul,vfdiv,vfwmul,vfmuladd,vfwmuladd,vfsqrt,vfrecp,
   vfcmp,vfminmax,vfsgnj,vfclass,vfmerge,vfmov,
   vfcvtitof,vfcvtftoi,vfwcvtitof,vfwcvtftoi,
   vfwcvtftof,vfncvtitof,vfncvtftoi,vfncvtftof,
   vired,viwred,vfredu,vfredo,vfwredu,vfwredo,
   vmalu,vmpop,vmffs,vmsfs,vmiota,vmidx,vimovvx,vimovxv,vfmovvf,vfmovfv,
   vslideup,vslidedown,vislide1up,vislide1down,vfslide1up,vfslide1down,
   vgather,vcompress,vmov,vector,vandn,vbrev,vbrev8,vrev8,vclz,vctz,vcpop,vrol,vror,vwsll,
   vclmul,vclmulh,vghsh,vgmul,vaesef,vaesem,vaesdf,vaesdm,vaeskf1,vaeskf2,vaesz,
   vsha2ms,vsha2ch,vsha2cl,vsm4k,vsm4r,vsm3me,vsm3c,vfncvtbf16,vfwcvtbf16,vfwmaccbf16,
   sf_vc,sf_vc_se"
  (cond [(eq_attr "got" "load") (const_string "load")

	 ;; If a doubleword move uses these expensive instructions,
	 ;; it is usually better to schedule them in the same way
	 ;; as the singleword form, rather than as "multi".
	 (eq_attr "move_type" "load") (const_string "load")
	 (eq_attr "move_type" "fpload") (const_string "fpload")
	 (eq_attr "move_type" "store") (const_string "store")
	 (eq_attr "move_type" "fpstore") (const_string "fpstore")
	 (eq_attr "move_type" "mtc") (const_string "mtc")
	 (eq_attr "move_type" "mfc") (const_string "mfc")

	 ;; These types of move are always single insns.
	 (eq_attr "move_type" "fmove") (const_string "fmove")
	 (eq_attr "move_type" "arith") (const_string "arith")
	 (eq_attr "move_type" "logical") (const_string "logical")
	 (eq_attr "move_type" "andi") (const_string "logical")

	 ;; These types of move are always split.
	 (eq_attr "move_type" "shift_shift")
	   (const_string "multi")

	 ;; These types of move are split for doubleword modes only.
	 (and (eq_attr "move_type" "move,const")
	      (eq_attr "dword_mode" "yes"))
	   (const_string "multi")
	 (eq_attr "move_type" "move") (const_string "move")
	 (eq_attr "move_type" "const") (const_string "const")
	 (eq_attr "move_type" "rdvlenb") (const_string "rdvlenb")]
	(const_string "unknown")))

;; True if the float point vector is disabled.
(define_attr "fp_vector_disabled" "no,yes"
  (cond [
    (and (eq_attr "type" "vfmov,vfalu,vfmul,vfdiv,
			  vfwalu,vfwmul,vfmuladd,vfwmuladd,
			  vfsqrt,vfrecp,vfminmax,vfsgnj,vfcmp,
			  vfclass,vfmerge,
			  vfncvtitof,vfwcvtftoi,vfcvtftoi,vfcvtitof,
			  vfredo,vfredu,vfwredo,vfwredu,
			  vfslide1up,vfslide1down")
	 (and (eq_attr "mode" "RVVM8HF,RVVM4HF,RVVM2HF,RVVM1HF,RVVMF2HF,RVVMF4HF")
	      (match_test "!TARGET_ZVFH")))
    (const_string "yes")

    ;; The mode records as QI for the FP16 <=> INT8 instruction.
    (and (eq_attr "type" "vfncvtftoi,vfwcvtitof")
	 (and (eq_attr "mode" "RVVM4QI,RVVM2QI,RVVM1QI,RVVMF2QI,RVVMF4QI,RVVMF8QI")
	      (match_test "!TARGET_ZVFH")))
    (const_string "yes")
  ]
  (const_string "no")))

;; This attribute marks the alternatives not matching the constraints
;; described in spec as disabled.
(define_attr "spec_restriction" "none,thv,rvv"
  (const_string "none"))

(define_attr "spec_restriction_disabled" "no,yes"
  (cond [(eq_attr "spec_restriction" "none")
	 (const_string "no")

	 (and (eq_attr "spec_restriction" "thv")
	      (match_test "TARGET_XTHEADVECTOR"))
	 (const_string "yes")

	 (and (eq_attr "spec_restriction" "rvv")
	      (match_test "TARGET_VECTOR && !TARGET_XTHEADVECTOR"))
	 (const_string "yes")
	]
       (const_string "no")))

;; Attribute to control enable or disable instructions.
(define_attr "enabled" "no,yes"
  (cond [
    (eq_attr "ext_enabled" "no")
    (const_string "no")

    (eq_attr "fp_vector_disabled" "yes")
    (const_string "no")

    (eq_attr "spec_restriction_disabled" "yes")
    (const_string "no")
  ]
  (const_string "yes")))

;; Length of instruction in bytes.
(define_attr "length" ""
   (cond [
	  ;; sc0 (!TARGET_LUI): lui is unavailable; jumps and branches use
	  ;; PC-relative beq exclusively.  Programs are single-function and short,
	  ;; so all targets fit in the 12-bit beq range.
	  ;; Unconditional jump: beq zero,zero,L (4 B).
	  ;; NE branch: beq a,b,1f; beq zero,zero,L; 1: (8 B).
	  ;; EQ branch: beq a,b,L (4 B) — native instruction, always short.
	  (and (eq_attr "type" "jump")
	       (match_test "!TARGET_LUI"))
	  (const_int 4)

	  (and (eq_attr "type" "branch")
	       (match_test "!TARGET_LUI && GET_CODE (operands[1]) == NE"))
	  (const_int 8)

	  (and (eq_attr "type" "branch")
	       (match_test "!TARGET_LUI && GET_CODE (operands[1]) == EQ"))
	  (const_int 4)

	  ;; When !TARGET_AUIPC (sc1), jal and bne are unavailable so the assembler
	  ;; cannot relax branches.  GCC must emit full expansions itself.
	  ;;
	  ;; NE branch: always beq+lui+addi+jr (16 B).  The short form using
	  ;; beq+beq_zero is unreliable: GCC branch-shortening can converge at a
	  ;; size where the internal beq zero,zero lands out of assembler range.
	  ;; EQ branch: short (<= +-4KB) -> single beq (4 B);
	  ;;            long             -> beq+beq_zero+lui+addi+jr (20 B).
	  (and (eq_attr "type" "branch")
	       (match_test "!TARGET_AUIPC && GET_CODE (operands[1]) == NE"))
	  (const_int 16)

	  (and (eq_attr "type" "branch")
	       (match_test "!TARGET_AUIPC && GET_CODE (operands[1]) == EQ"))
	  (if_then_else (and (le (minus (match_dup 0) (pc)) (const_int 4088))
			     (le (minus (pc) (match_dup 0)) (const_int 4092)))
			(const_int 4)
			(const_int 20))

	  ;; Branches further than +/- 1 MiB require three instructions.
	  ;; Branches further than +/- 4 KiB require two instructions.
	  (eq_attr "type" "branch")
	  (if_then_else (and (le (minus (match_dup 0) (pc))
				 (const_int 4088))
			     (le (minus (pc) (match_dup 0))
				 (const_int 4092)))
			(const_int 4)
			(if_then_else (and (le (minus (match_dup 0) (pc))
					       (const_int 1048568))
					   (le (minus (pc) (match_dup 0))
					       (const_int 1048572)))
				      (const_int 8)
				      (const_int 12)))

	  ;; Jumps further than +/- 1 MiB require two instructions.
	  ;; Also, jumps that cross section boundaries (e.g., from hot to cold
	  ;; section when -freorder-blocks-and-partition is used) require two
	  ;; instructions because the linker may place the sections far apart.
	  ;;
	  ;; When !TARGET_AUIPC, all jumps are synthesised as lui+addi+jr (12 B)
	  ;; regardless of distance, so GCC correctly estimates branch ranges.
	  (eq_attr "type" "jump")
	  (if_then_else (match_test "!TARGET_AUIPC")
			(const_int 12)
			(if_then_else (match_test "CROSSING_JUMP_P (insn)")
				      (const_int 8)
				      (if_then_else (and (le (minus (match_dup 0) (pc))
							     (const_int 1048568))
						         (le (minus (pc) (match_dup 0))
							     (const_int 1048572)))
						    (const_int 4)
						    (const_int 8))))

	  ;; When !TARGET_AUIPC, symbolic calls use lui+addi+jalr (12 B).
	  ;; Otherwise AUIPC+JALR (8 B), linker may relax to JAL (4 B).
	  (eq_attr "type" "call")
	  (if_then_else (match_test "!TARGET_AUIPC")
			(const_int 12)
			(const_int 8))

	  ;; "Ghost" instructions occupy no space.
	  (eq_attr "type" "ghost") (const_int 0)

	  (eq_attr "got" "load") (const_int 8)

	  ;; SHIFT_SHIFTs are decomposed into two separate instructions.
	  (eq_attr "move_type" "shift_shift")
		(const_int 8)

	  ;; Check for doubleword moves that are decomposed into two
	  ;; instructions.
	  (and (eq_attr "move_type" "mtc,mfc,move")
	       (eq_attr "dword_mode" "yes"))
	  (const_int 8)

	  ;; Doubleword CONST{,N} moves are split into two word
	  ;; CONST{,N} moves.
	  (and (eq_attr "move_type" "const")
	       (eq_attr "dword_mode" "yes"))
	  (symbol_ref "riscv_split_const_insns (operands[1]) * 4")

	  ;; Otherwise, constants, loads and stores are handled by external
	  ;; routines.
	  (eq_attr "move_type" "load,fpload")
	  (symbol_ref "riscv_load_store_insns (operands[1], insn) * 4")
	  (eq_attr "move_type" "store,fpstore")
	  (symbol_ref "riscv_load_store_insns (operands[0], insn) * 4")
	  ] (const_int 4)))

;; Is copying of this instruction disallowed?
(define_attr "cannot_copy" "no,yes" (const_string "no"))

;; Microarchitectures we know how to tune for.
;; Keep this in sync with enum riscv_microarchitecture.
(define_attr "tune"
  "generic,sifive_7,sifive_p400,sifive_p600,xiangshan,generic_ooo,mips_p8700,
   tt_ascalon_d8,andes_25_series,andes_23_series,andes_45_series,spacemit_x60,
   arcv_rmx100,arcv_rhx100"
  (const (symbol_ref "((enum attr_tune) riscv_microarchitecture)")))

;; Describe a user's asm statement.
(define_asm_attributes
  [(set_attr "type" "multi")])

;; Ghost instructions produce no real code and introduce no hazards.
;; They exist purely to express an effect on dataflow.
(define_insn_reservation "ghost" 0
  (eq_attr "type" "ghost")
  "nothing")

;;
;;  ....................
;;
;;	ADDITION
;;
;;  ....................
;;

(define_insn "add<mode>3"
  [(set (match_operand:ANYF            0 "register_operand" "=f")
	(plus:ANYF (match_operand:ANYF 1 "register_operand" " f")
		   (match_operand:ANYF 2 "register_operand" " f")))]
  "TARGET_HARD_FLOAT || TARGET_ZFINX"
  "fadd.<fmt>\t%0,%1,%2"
  [(set_attr "type" "fadd")
   (set_attr "mode" "<UNITMODE>")])

(define_expand "addptr<mode>3"
  [(set (match_operand:X 	 0 "register_operand")
        (plus:X (match_operand:X 1 "register_operand")
                (match_operand 	 2 "const_int_operand")))]
  ""
{
  gcc_assert (CONST_INT_P (operands[2]));
  bool status = synthesize_add (operands);

  if (!SMALL_OPERAND (INTVAL (operands[2])))
    {
      gcc_assert (status);
      DONE;
    }
})

(define_insn "*addsi3"
  [(set (match_operand:SI          0 "register_operand" "=r,r")
	(plus:SI (match_operand:SI 1 "register_operand" " r,r")
		 (match_operand:SI 2 "arith_operand"    " r,I")))]
  ""
  "add%i2%~\t%0,%1,%2"
  [(set_attr "type" "arith")
   (set_attr "mode" "SI")])

(define_expand "addsi3"
  [(set (match_operand:SI          0 "register_operand")
	(plus:SI (match_operand:SI 1 "register_operand")
		 (match_operand:SI 2 "reg_or_const_int_operand")))]
  ""
{
  /* We may be able to find a faster sequence, if so, then we are
     done.  Otherwise let expansion continue normally.  */
  if (CONST_INT_P (operands[2])
      && ((!TARGET_64BIT && synthesize_add (operands))
	  || (TARGET_64BIT && synthesize_add_extended (operands))))
    DONE;

  /* Constants have already been handled already.  */
  if (TARGET_64BIT)
    {
      rtx tdest = gen_reg_rtx (DImode);
      emit_insn (gen_addsi3_extended (tdest, operands[1], operands[2]));
      tdest = gen_lowpart (SImode, tdest);
      SUBREG_PROMOTED_VAR_P (tdest) = 1;
      SUBREG_PROMOTED_SET (tdest, SRP_SIGNED);
      emit_move_insn (operands[0], tdest);
      DONE;
    }

})

(define_expand "adddi3"
  [(set (match_operand:DI          0 "register_operand")
	(plus:DI (match_operand:DI 1 "register_operand")
		 (match_operand:DI 2 "reg_or_const_int_operand")))]
  "TARGET_64BIT"
{
  /* We may be able to find a faster sequence, if so, then we are
     done.  Otherwise let expansion continue normally.  */
  if (CONST_INT_P (operands[2]) && synthesize_add (operands))
    DONE;
})

(define_insn "*adddi3"
  [(set (match_operand:DI          0 "register_operand" "=r,r")
	(plus:DI (match_operand:DI 1 "register_operand" " r,r")
		 (match_operand:DI 2 "arith_operand"    " r,I")))]
  "TARGET_64BIT"
  "add%i2\t%0,%1,%2"
  [(set_attr "type" "arith")
   (set_attr "mode" "DI")])

(define_expand "addv<mode>4"
  [(set (match_operand:GPR           0 "register_operand" "=r,r")
	(plus:GPR (match_operand:GPR 1 "register_operand" " r,r")
		  (match_operand:GPR 2 "arith_operand"    " r,I")))
   (label_ref (match_operand 3 "" ""))]
  ""
{
  if (TARGET_64BIT && <MODE>mode == SImode)
    {
      rtx t3 = gen_reg_rtx (DImode);
      rtx t4 = gen_reg_rtx (DImode);
      rtx t5 = gen_reg_rtx (DImode);
      rtx t6 = gen_reg_rtx (DImode);

      emit_insn (gen_addsi3_extended (t6, operands[1], operands[2]));
      t4 = convert_modes (DImode, SImode, operands[1], false);
      t5 = convert_modes (DImode, SImode, operands[2], false);
      emit_insn (gen_adddi3 (t3, t4, t5));
      rtx t7 = gen_lowpart (SImode, t6);
      SUBREG_PROMOTED_VAR_P (t7) = 1;
      SUBREG_PROMOTED_SET (t7, SRP_SIGNED);
      emit_move_insn (operands[0], t7);

      riscv_expand_conditional_branch (operands[3], NE, t6, t3);
    }
  else
    {
      rtx t3 = gen_reg_rtx (<MODE>mode);
      rtx t4 = gen_reg_rtx (<MODE>mode);

      emit_insn (gen_add3_insn (operands[0], operands[1], operands[2]));
      rtx cmp1 = gen_rtx_LT (<MODE>mode, operands[2], const0_rtx);
      emit_insn (gen_cstore<mode>4 (t3, cmp1, operands[2], const0_rtx));
      rtx cmp2 = gen_rtx_LT (<MODE>mode, operands[0], operands[1]);

      emit_insn (gen_cstore<mode>4 (t4, cmp2, operands[0], operands[1]));
      riscv_expand_conditional_branch (operands[3], NE, t3, t4);
    }
  DONE;
})

(define_expand "uaddv<mode>4"
  [(set (match_operand:GPR           0 "register_operand" "=r,r")
	(plus:GPR (match_operand:GPR 1 "register_operand" " r,r")
		  (match_operand:GPR 2 "arith_operand"    " r,I")))
   (label_ref (match_operand 3 "" ""))]
  ""
{
  if (TARGET_64BIT && <MODE>mode == SImode)
    {
      rtx t3 = gen_reg_rtx (DImode);
      rtx t4 = gen_reg_rtx (DImode);

      t3 = convert_modes (DImode, SImode, operands[1], 0);
      emit_insn (gen_addsi3_extended (t4, operands[1], operands[2]));
      rtx t5 = gen_lowpart (SImode, t4);
      SUBREG_PROMOTED_VAR_P (t5) = 1;
      SUBREG_PROMOTED_SET (t5, SRP_SIGNED);
      emit_move_insn (operands[0], t5);

      riscv_expand_conditional_branch (operands[3], LTU, t4, t3);
    }
  else
    {
      emit_insn (gen_add3_insn (operands[0], operands[1], operands[2]));
      rtx cond = gen_rtx_LTU (VOIDmode, operands[0], operands[1]);
      emit_jump_insn (gen_cbranch4 (<MODE>mode, cond, operands[0],
				    operands[1], operands[3]));
    }

  DONE;
})

(define_insn "addsi3_extended"
  [(set (match_operand:DI               0 "register_operand" "=r,r")
	(sign_extend:DI
	     (plus:SI (match_operand:SI 1 "register_operand" " r,r")
		      (match_operand:SI 2 "arith_operand"    " r,I"))))]
  "TARGET_64BIT"
  "add%i2w\t%0,%1,%2"
  [(set_attr "type" "arith")
   (set_attr "mode" "SI")])

(define_insn "*addsi3_extended2"
  [(set (match_operand:DI                       0 "register_operand" "=r,r")
	(sign_extend:DI
	  (match_operator:SI 3 "subreg_lowpart_operator"
	     [(plus:DI (match_operand:DI 1 "register_operand" " r,r")
		       (match_operand:DI 2 "arith_operand"    " r,I"))])))]
  "TARGET_64BIT"
  "add%i2w\t%0,%1,%2"
  [(set_attr "type" "arith")
   (set_attr "mode" "SI")])

;; Transform (X & C1) + C2 into (X | ~C1) - (-C2 | ~C1)
;; Where C1 is not a LUI operand, but ~C1 is a LUI operand

(define_insn_and_split "*lui_constraint<X:mode>_and_to_or"
  [(set (match_operand:X 0 "register_operand" "=r")
	(plus:X (and:X (match_operand:X 1 "register_operand" "r")
		       (match_operand 2 "const_int_operand"))
		(match_operand 3 "const_int_operand")))
   (clobber (match_scratch:X 4 "=&r"))]
  "(LUI_OPERAND (~INTVAL (operands[2]))
    && ((INTVAL (operands[2]) & (-INTVAL (operands[3])))
	== (-INTVAL (operands[3])))
    && riscv_const_insns (operands[3], false)
    && (riscv_const_insns (GEN_INT (~INTVAL (operands[2])
				    | -INTVAL (operands[3])), false)
	<= riscv_const_insns (operands[3], false)))"
  "#"
  "&& reload_completed"
  [(const_int 0)]
  {
    operands[5] = GEN_INT (~INTVAL (operands[2]));
    operands[6] = GEN_INT ((~INTVAL (operands[2])) | (-INTVAL (operands[3])));

    /* This is always a LUI operand, so it's safe to just emit.  */
    emit_move_insn (operands[4], operands[5]);

    rtx x = gen_rtx_IOR (word_mode, operands[1], operands[4]);
    emit_move_insn (operands[0], x);

    /* This may require multiple steps to synthesize.  */
    riscv_emit_move (operands[4], operands[6]);
    x = gen_rtx_MINUS (word_mode, operands[0], operands[4]);
    emit_move_insn (operands[0], x);
  }
  [(set_attr "type" "arith")])

;;
;;  ....................
;;
;;	SUBTRACTION
;;
;;  ....................
;;

(define_insn "sub<mode>3"
  [(set (match_operand:ANYF             0 "register_operand" "=f")
	(minus:ANYF (match_operand:ANYF 1 "register_operand" " f")
		    (match_operand:ANYF 2 "register_operand" " f")))]
  "TARGET_HARD_FLOAT || TARGET_ZFINX"
  "fsub.<fmt>\t%0,%1,%2"
  [(set_attr "type" "fadd")
   (set_attr "mode" "<UNITMODE>")])

(define_insn "subdi3"
  [(set (match_operand:DI 0            "register_operand" "= r")
	(minus:DI (match_operand:DI 1  "reg_or_0_operand" " rJ")
		   (match_operand:DI 2 "register_operand" "  r")))]
  "TARGET_64BIT"
  "sub\t%0,%z1,%2"
  [(set_attr "type" "arith")
   (set_attr "mode" "DI")])

(define_insn "*subsi3"
  [(set (match_operand:SI           0 "register_operand" "= r")
	(minus:SI (match_operand:SI 1 "reg_or_0_operand" " rJ")
		  (match_operand:SI 2 "register_operand" "  r")))]
  ""
  "sub%~\t%0,%z1,%2"
  [(set_attr "type" "arith")
   (set_attr "mode" "SI")])

(define_expand "subsi3"
  [(set (match_operand:SI           0 "register_operand" "= r")
       (minus:SI (match_operand:SI 1 "reg_or_0_operand" " rJ")
                 (match_operand:SI 2 "register_operand" "  r")))]
  ""
{
  if (TARGET_64BIT)
    {
      rtx t = gen_reg_rtx (DImode);
      emit_insn (gen_subsi3_extended (t, operands[1], operands[2]));
      t = gen_lowpart (SImode, t);
      SUBREG_PROMOTED_VAR_P (t) = 1;
      SUBREG_PROMOTED_SET (t, SRP_SIGNED);
      emit_move_insn (operands[0], t);
      DONE;
    }
})

(define_expand "subv<mode>4"
  [(set (match_operand:GPR            0 "register_operand" "= r")
	(minus:GPR (match_operand:GPR 1 "reg_or_0_operand" " rJ")
		   (match_operand:GPR 2 "register_operand" "  r")))
   (label_ref (match_operand 3 "" ""))]
  ""
{
  if (TARGET_64BIT && <MODE>mode == SImode)
    {
      rtx t3 = gen_reg_rtx (DImode);
      rtx t4 = gen_reg_rtx (DImode);
      rtx t5 = gen_reg_rtx (DImode);
      rtx t6 = gen_reg_rtx (DImode);

      emit_insn (gen_subsi3_extended (t6, operands[1], operands[2]));
      t4 = convert_modes (DImode, SImode, operands[1], false);
      t5 = convert_modes (DImode, SImode, operands[2], false);
      emit_insn (gen_subdi3 (t3, t4, t5));
      rtx t7 = gen_lowpart (SImode, t6);
      SUBREG_PROMOTED_VAR_P (t7) = 1;
      SUBREG_PROMOTED_SET (t7, SRP_SIGNED);
      emit_move_insn (operands[0], t7);

      riscv_expand_conditional_branch (operands[3], NE, t6, t3);
    }
  else
    {
      rtx t3 = gen_reg_rtx (<MODE>mode);
      rtx t4 = gen_reg_rtx (<MODE>mode);

      emit_insn (gen_sub3_insn (operands[0], operands[1], operands[2]));

      rtx cmp1 = gen_rtx_LT (<MODE>mode, operands[2], const0_rtx);
      emit_insn (gen_cstore<mode>4 (t3, cmp1, operands[2], const0_rtx));

      rtx cmp2 = gen_rtx_LT (<MODE>mode, operands[1], operands[0]);
      emit_insn (gen_cstore<mode>4 (t4, cmp2, operands[1], operands[0]));

      riscv_expand_conditional_branch (operands[3], NE, t3, t4);
    }

  DONE;
})

(define_expand "usubv<mode>4"
  [(set (match_operand:GPR            0 "register_operand" "= r")
	(minus:GPR (match_operand:GPR 1 "reg_or_0_operand" " rJ")
		   (match_operand:GPR 2 "register_operand" "  r")))
   (label_ref (match_operand 3 "" ""))]
  ""
{
  if (TARGET_64BIT && <MODE>mode == SImode)
    {
      rtx t3 = gen_reg_rtx (DImode);
      rtx t4 = gen_reg_rtx (DImode);

      t3 = convert_modes (DImode, SImode, operands[1], false);
      emit_insn (gen_subsi3_extended (t4, operands[1], operands[2]));
      rtx t5 = gen_lowpart (SImode, t4);
      SUBREG_PROMOTED_VAR_P (t5) = 1;
      SUBREG_PROMOTED_SET (t5, SRP_SIGNED);
      emit_move_insn (operands[0], t5);

      riscv_expand_conditional_branch (operands[3], LTU, t3, t4);
    }
  else
    {
      emit_insn (gen_sub3_insn (operands[0], operands[1], operands[2]));
      rtx cond = gen_rtx_LTU (VOIDmode, operands[1], operands[0]);
      emit_jump_insn (gen_cbranch4 (<MODE>mode, cond, operands[1],
				    operands[0], operands[3]));
    }

  DONE;
})


(define_insn "subsi3_extended"
  [(set (match_operand:DI               0 "register_operand" "= r")
	(sign_extend:DI
	    (minus:SI (match_operand:SI 1 "reg_or_0_operand" " rJ")
		      (match_operand:SI 2 "register_operand" "  r"))))]
  "TARGET_64BIT"
  "subw\t%0,%z1,%2"
  [(set_attr "type" "arith")
   (set_attr "mode" "SI")])

(define_insn "*subsi3_extended2"
  [(set (match_operand:DI                        0 "register_operand" "= r")
	(sign_extend:DI
	  (match_operator:SI 3 "subreg_lowpart_operator"
	    [(minus:DI (match_operand:DI 1 "reg_or_0_operand" " rJ")
		       (match_operand:DI 2 "register_operand" "  r"))])))]
  "TARGET_64BIT"
  "subw\t%0,%z1,%2"
  [(set_attr "type" "arith")
   (set_attr "mode" "SI")])

(define_insn "negdi2"
  [(set (match_operand:DI         0 "register_operand" "=r")
	(neg:DI (match_operand:DI 1 "register_operand" " r")))]
  "TARGET_64BIT"
  "neg\t%0,%1"
  [(set_attr "type" "arith")
   (set_attr "mode" "DI")])

(define_insn "*negsi2"
  [(set (match_operand:SI         0 "register_operand" "=r")
	(neg:SI (match_operand:SI 1 "register_operand" " r")))]
  ""
  "neg%~\t%0,%1"
  [(set_attr "type" "arith")
   (set_attr "mode" "SI")])

(define_expand "negsi2"
  [(set (match_operand:SI         0 "register_operand" "=r")
	(neg:SI (match_operand:SI 1 "register_operand" " r")))]
  ""
{
  if (TARGET_64BIT)
    {
      rtx t = gen_reg_rtx (DImode);
      emit_insn (gen_negsi2_extended (t, operands[1]));
      t = gen_lowpart (SImode, t);
      SUBREG_PROMOTED_VAR_P (t) = 1;
      SUBREG_PROMOTED_SET (t, SRP_SIGNED);
      emit_move_insn (operands[0], t);
      DONE;
    }
})

(define_insn "negsi2_extended"
  [(set (match_operand:DI          0 "register_operand" "=r")
	(sign_extend:DI
	 (neg:SI (match_operand:SI 1 "register_operand" " r"))))]
  "TARGET_64BIT"
  "negw\t%0,%1"
  [(set_attr "type" "arith")
   (set_attr "mode" "SI")])

(define_insn "*negsi2_extended2"
  [(set (match_operand:DI                     0 "register_operand" "=r")
	(sign_extend:DI
	 (match_operator:SI 2 "subreg_lowpart_operator"
	   [(neg:DI (match_operand:DI 1 "register_operand" " r"))])))]
  "TARGET_64BIT"
  "negw\t%0,%1"
  [(set_attr "type" "arith")
   (set_attr "mode" "SI")])

;;
;;  ....................
;;
;;	MULTIPLICATION
;;
;;  ....................
;;

(define_insn "mul<mode>3"
  [(set (match_operand:ANYF               0 "register_operand" "=f")
	(mult:ANYF (match_operand:ANYF    1 "register_operand" " f")
		      (match_operand:ANYF 2 "register_operand" " f")))]
  "TARGET_HARD_FLOAT  || TARGET_ZFINX"
  "fmul.<fmt>\t%0,%1,%2"
  [(set_attr "type" "fmul")
   (set_attr "mode" "<UNITMODE>")])

(define_insn "*mulsi3"
  [(set (match_operand:SI          0 "register_operand" "=r")
	(mult:SI (match_operand:SI 1 "register_operand" " r")
		 (match_operand:SI 2 "register_operand" " r")))]
  "TARGET_ZMMUL || TARGET_MUL"
  "mul%~\t%0,%1,%2"
  [(set_attr "type" "imul")
   (set_attr "mode" "SI")])

(define_expand "mulsi3"
  [(set (match_operand:SI          0 "register_operand" "=r")
       (mult:SI (match_operand:SI 1 "register_operand" " r")
                (match_operand:SI 2 "register_operand" " r")))]
  "TARGET_ZMMUL || TARGET_MUL"
{
  if (TARGET_64BIT)
    {
      rtx t = gen_reg_rtx (DImode);
      emit_insn (gen_mulsi3_extended (t, operands[1], operands[2]));
      t = gen_lowpart (SImode, t);
      SUBREG_PROMOTED_VAR_P (t) = 1;
      SUBREG_PROMOTED_SET (t, SRP_SIGNED);
      emit_move_insn (operands[0], t);
      DONE;
    }
})

(define_insn "muldi3"
  [(set (match_operand:DI          0 "register_operand" "=r")
	(mult:DI (match_operand:DI 1 "register_operand" " r")
		 (match_operand:DI 2 "register_operand" " r")))]
  "(TARGET_ZMMUL || TARGET_MUL) && TARGET_64BIT"
  "mul\t%0,%1,%2"
  [(set_attr "type" "imul")
   (set_attr "mode" "DI")])

(define_expand "mulv<mode>4"
  [(set (match_operand:GPR           0 "register_operand" "=r")
	(mult:GPR (match_operand:GPR 1 "register_operand" " r")
		  (match_operand:GPR 2 "register_operand" " r")))
   (label_ref (match_operand 3 "" ""))]
  "TARGET_ZMMUL || TARGET_MUL"
{
  if (TARGET_64BIT && <MODE>mode == SImode)
    {
      rtx t3 = gen_reg_rtx (DImode);
      rtx t4 = gen_reg_rtx (DImode);
      rtx t5 = gen_reg_rtx (DImode);
      rtx t6 = gen_reg_rtx (DImode);

      t4 = convert_modes (DImode, SImode, operands[1], false);
      t5 = convert_modes (DImode, SImode, operands[2], false);
      emit_insn (gen_muldi3 (t3, t4, t5));

      emit_move_insn (operands[0], gen_lowpart (SImode, t3));
      t6 = convert_modes (DImode, SImode, operands[0], false);

      riscv_expand_conditional_branch (operands[3], NE, t6, t3);
    }
  else
    {
      rtx hp = gen_reg_rtx (<MODE>mode);
      rtx lp = gen_reg_rtx (<MODE>mode);

      emit_insn (gen_smul<mode>3_highpart (hp, operands[1], operands[2]));
      emit_insn (gen_mul<mode>3 (operands[0], operands[1], operands[2]));
      riscv_emit_binary (ASHIFTRT, lp, operands[0],
			 GEN_INT (BITS_PER_WORD - 1));

      riscv_expand_conditional_branch (operands[3], NE, hp, lp);
    }

  DONE;
})

(define_expand "umulv<mode>4"
  [(set (match_operand:GPR           0 "register_operand" "=r")
	(mult:GPR (match_operand:GPR 1 "register_operand" " r")
		  (match_operand:GPR 2 "register_operand" " r")))
   (label_ref (match_operand 3 "" ""))]
  "TARGET_ZMMUL || TARGET_MUL"
{
  if (TARGET_64BIT && <MODE>mode == SImode)
    {
      rtx t3 = gen_reg_rtx (DImode);
      rtx t4 = gen_reg_rtx (DImode);
      rtx t5 = gen_reg_rtx (DImode);
      rtx t6 = gen_reg_rtx (DImode);
      rtx t7 = gen_reg_rtx (DImode);
      rtx t8 = gen_reg_rtx (DImode);

      t3 = convert_modes (DImode, SImode, operands[1], false);
      t4 = convert_modes (DImode, SImode, operands[2], false);

      emit_insn (gen_ashldi3 (t5, t3, GEN_INT (32)));
      emit_insn (gen_ashldi3 (t6, t4, GEN_INT (32)));
      emit_insn (gen_umuldi3_highpart (t7, t5, t6));
      emit_move_insn (operands[0], gen_lowpart (SImode, t7));
      emit_insn (gen_lshrdi3 (t8, t7, GEN_INT (32)));

      riscv_expand_conditional_branch (operands[3], NE, t8, const0_rtx);
    }
  else
    {
      rtx hp = gen_reg_rtx (<MODE>mode);

      emit_insn (gen_umul<mode>3_highpart (hp, operands[1], operands[2]));
      emit_insn (gen_mul<mode>3 (operands[0], operands[1], operands[2]));

      riscv_expand_conditional_branch (operands[3], NE, hp, const0_rtx);
    }

  DONE;
})

(define_insn "mulsi3_extended"
  [(set (match_operand:DI              0 "register_operand" "=r")
	(sign_extend:DI
	    (mult:SI (match_operand:SI 1 "register_operand" " r")
		     (match_operand:SI 2 "register_operand" " r"))))]
  "(TARGET_ZMMUL || TARGET_MUL) && TARGET_64BIT"
  "mulw\t%0,%1,%2"
  [(set_attr "type" "imul")
   (set_attr "mode" "SI")])

(define_insn "*mulsi3_extended2"
  [(set (match_operand:DI                       0 "register_operand" "=r")
	(sign_extend:DI
	  (match_operator:SI 3 "subreg_lowpart_operator"
	    [(mult:DI (match_operand:DI 1 "register_operand" " r")
		      (match_operand:DI 2 "register_operand" " r"))])))]
  "(TARGET_ZMMUL || TARGET_MUL) && TARGET_64BIT"
  "mulw\t%0,%1,%2"
  [(set_attr "type" "imul")
   (set_attr "mode" "SI")])

;;
;;  ........................
;;
;;	MULTIPLICATION HIGH-PART
;;
;;  ........................
;;


(define_expand "<u>mulditi3"
  [(set (match_operand:TI                         0 "register_operand")
	(mult:TI (any_extend:TI (match_operand:DI 1 "register_operand"))
		 (any_extend:TI (match_operand:DI 2 "register_operand"))))]
  "(TARGET_ZMMUL || TARGET_MUL) && TARGET_64BIT"
{
  rtx low = gen_reg_rtx (DImode);
  emit_insn (gen_muldi3 (low, operands[1], operands[2]));

  rtx high = gen_reg_rtx (DImode);
  emit_insn (gen_<su>muldi3_highpart (high, operands[1], operands[2]));

  emit_move_insn (gen_lowpart (DImode, operands[0]), low);
  emit_move_insn (gen_highpart (DImode, operands[0]), high);
  DONE;
})

(define_insn "<su>muldi3_highpart"
  [(set (match_operand:DI                0 "register_operand" "=r")
	(truncate:DI
	  (lshiftrt:TI
	    (mult:TI (any_extend:TI
		       (match_operand:DI 1 "register_operand" " r"))
		     (any_extend:TI
		       (match_operand:DI 2 "register_operand" " r")))
	    (const_int 64))))]
  "(TARGET_ZMMUL || TARGET_MUL) && TARGET_64BIT"
  "mulh<u>\t%0,%1,%2"
  [(set_attr "type" "imul")
   (set_attr "mode" "DI")])

(define_expand "usmulditi3"
  [(set (match_operand:TI                          0 "register_operand")
	(mult:TI (zero_extend:TI (match_operand:DI 1 "register_operand"))
		 (sign_extend:TI (match_operand:DI 2 "register_operand"))))]
  "(TARGET_ZMMUL || TARGET_MUL) && TARGET_64BIT"
{
  rtx low = gen_reg_rtx (DImode);
  emit_insn (gen_muldi3 (low, operands[1], operands[2]));

  rtx high = gen_reg_rtx (DImode);
  emit_insn (gen_usmuldi3_highpart (high, operands[1], operands[2]));

  emit_move_insn (gen_lowpart (DImode, operands[0]), low);
  emit_move_insn (gen_highpart (DImode, operands[0]), high);
  DONE;
})

(define_insn "usmuldi3_highpart"
  [(set (match_operand:DI                0 "register_operand" "=r")
	(truncate:DI
	  (lshiftrt:TI
	    (mult:TI (zero_extend:TI
		       (match_operand:DI 1 "register_operand"  "r"))
		     (sign_extend:TI
		       (match_operand:DI 2 "register_operand" " r")))
	    (const_int 64))))]
  "(TARGET_ZMMUL || TARGET_MUL) && TARGET_64BIT"
  "mulhsu\t%0,%2,%1"
  [(set_attr "type" "imul")
   (set_attr "mode" "DI")])

(define_expand "<u>mulsidi3"
  [(set (match_operand:DI            0 "register_operand" "=r")
	(mult:DI (any_extend:DI
		   (match_operand:SI 1 "register_operand" " r"))
		 (any_extend:DI
		   (match_operand:SI 2 "register_operand" " r"))))]
  "(TARGET_ZMMUL || TARGET_MUL) && !TARGET_64BIT"
{
  rtx temp = gen_reg_rtx (SImode);
  riscv_emit_binary (MULT, temp, operands[1], operands[2]);
  emit_insn (gen_<su>mulsi3_highpart (riscv_subword (operands[0], true),
				     operands[1], operands[2]));
  emit_insn (gen_movsi (riscv_subword (operands[0], false), temp));
  DONE;
})

(define_insn "<su>mulsi3_highpart"
  [(set (match_operand:SI                0 "register_operand" "=r")
	(truncate:SI
	  (lshiftrt:DI
	    (mult:DI (any_extend:DI
		       (match_operand:SI 1 "register_operand" " r"))
		     (any_extend:DI
		       (match_operand:SI 2 "register_operand" " r")))
	    (const_int 32))))]
  "(TARGET_ZMMUL || TARGET_MUL) && !TARGET_64BIT"
  "mulh<u>\t%0,%1,%2"
  [(set_attr "type" "imul")
   (set_attr "mode" "SI")])


(define_expand "usmulsidi3"
  [(set (match_operand:DI            0 "register_operand" "=r")
	(mult:DI (zero_extend:DI
		   (match_operand:SI 1 "register_operand" " r"))
		 (sign_extend:DI
		   (match_operand:SI 2 "register_operand" " r"))))]
  "(TARGET_ZMMUL || TARGET_MUL) && !TARGET_64BIT"
{
  rtx temp = gen_reg_rtx (SImode);
  riscv_emit_binary (MULT, temp, operands[1], operands[2]);
  emit_insn (gen_usmulsi3_highpart (riscv_subword (operands[0], true),
				     operands[1], operands[2]));
  emit_insn (gen_movsi (riscv_subword (operands[0], false), temp));
  DONE;
})

(define_insn "usmulsi3_highpart"
  [(set (match_operand:SI                0 "register_operand" "=r")
	(truncate:SI
	  (lshiftrt:DI
	    (mult:DI (zero_extend:DI
		       (match_operand:SI 1 "register_operand" " r"))
		     (sign_extend:DI
		       (match_operand:SI 2 "register_operand" " r")))
	    (const_int 32))))]
  "(TARGET_ZMMUL || TARGET_MUL) && !TARGET_64BIT"
  "mulhsu\t%0,%2,%1"
  [(set_attr "type" "imul")
   (set_attr "mode" "SI")])

;;
;;  ....................
;;
;;	DIVISION and REMAINDER
;;
;;  ....................
;;

(define_insn "*<optab>si3"
  [(set (match_operand:SI             0 "register_operand" "=r")
	(any_div:SI (match_operand:SI 1 "register_operand" " r")
		    (match_operand:SI 2 "register_operand" " r")))]
  "TARGET_DIV"
  "<insn>%i2%~\t%0,%1,%2"
  [(set_attr "type" "idiv")
   (set_attr "mode" "SI")])

(define_expand "<optab>si3"
  [(set (match_operand:SI             0 "register_operand" "=r")
       (any_div:SI (match_operand:SI 1 "register_operand" " r")
                   (match_operand:SI 2 "register_operand" " r")))]
  "TARGET_DIV"
{
  if (TARGET_64BIT)
    {
      rtx t = gen_reg_rtx (DImode);
      emit_insn (gen_<optab>si3_extended (t, operands[1], operands[2]));
      t = gen_lowpart (SImode, t);
      SUBREG_PROMOTED_VAR_P (t) = 1;
      SUBREG_PROMOTED_SET (t, SRP_SIGNED);
      emit_move_insn (operands[0], t);
      DONE;
    }
})

(define_insn "<optab>di3"
  [(set (match_operand:DI             0 "register_operand" "=r")
	(any_div:DI (match_operand:DI 1 "register_operand" " r")
		    (match_operand:DI 2 "register_operand" " r")))]
  "TARGET_DIV && TARGET_64BIT"
  "<insn>%i2\t%0,%1,%2"
  [(set_attr "type" "idiv")
   (set_attr "mode" "DI")])

(define_expand "<u>divmod<mode>4"
  [(parallel
     [(set (match_operand:GPR 0 "register_operand")
           (only_div:GPR (match_operand:GPR 1 "register_operand")
                         (match_operand:GPR 2 "register_operand")))
      (set (match_operand:GPR 3 "register_operand")
           (<paired_mod>:GPR (match_dup 1) (match_dup 2)))])]
  "TARGET_DIV && riscv_use_divmod_expander ()"
  {
      rtx tmp = gen_reg_rtx (<MODE>mode);
      emit_insn (gen_<u>div<GPR:mode>3 (operands[0], operands[1], operands[2]));
      emit_insn (gen_mul<GPR:mode>3 (tmp, operands[0], operands[2]));
      emit_insn (gen_sub<GPR:mode>3 (operands[3], operands[1], tmp));
      DONE;
  })

(define_insn "<optab>si3_extended"
  [(set (match_operand:DI                 0 "register_operand" "=r")
	(sign_extend:DI
	    (any_div:SI (match_operand:SI 1 "register_operand" " r")
			(match_operand:SI 2 "register_operand" " r"))))]
  "TARGET_DIV && TARGET_64BIT"
  "<insn>%i2w\t%0,%1,%2"
  [(set_attr "type" "idiv")
   (set_attr "mode" "DI")])

(define_insn "div<mode>3"
  [(set (match_operand:ANYF           0 "register_operand" "=f")
	(div:ANYF (match_operand:ANYF 1 "register_operand" " f")
		  (match_operand:ANYF 2 "register_operand" " f")))]
  "(TARGET_HARD_FLOAT || TARGET_ZFINX) && TARGET_FDIV"
  "fdiv.<fmt>\t%0,%1,%2"
  [(set_attr "type" "fdiv")
   (set_attr "mode" "<UNITMODE>")])

;;
;;  ....................
;;
;;	SQUARE ROOT
;;
;;  ....................

(define_insn "sqrt<mode>2"
  [(set (match_operand:ANYF            0 "register_operand" "=f")
	(sqrt:ANYF (match_operand:ANYF 1 "register_operand" " f")))]
  "(TARGET_HARD_FLOAT || TARGET_ZFINX) && TARGET_FDIV"
{
    return "fsqrt.<fmt>\t%0,%1";
}
  [(set_attr "type" "fsqrt")
   (set_attr "mode" "<UNITMODE>")])

;; Floating point multiply accumulate instructions.

;; a * b + c
(define_insn "fma<mode>4"
  [(set (match_operand:ANYF           0 "register_operand" "=f")
	(fma:ANYF (match_operand:ANYF 1 "register_operand" " f")
		  (match_operand:ANYF 2 "register_operand" " f")
		  (match_operand:ANYF 3 "register_operand" " f")))]
  "TARGET_HARD_FLOAT || TARGET_ZFINX"
  "fmadd.<fmt>\t%0,%1,%2,%3"
  [(set_attr "type" "fmadd")
   (set_attr "mode" "<UNITMODE>")])

;; a * b - c
(define_insn "fms<mode>4"
  [(set (match_operand:ANYF                     0 "register_operand" "=f")
	(fma:ANYF (match_operand:ANYF           1 "register_operand" " f")
		  (match_operand:ANYF           2 "register_operand" " f")
		  (neg:ANYF (match_operand:ANYF 3 "register_operand" " f"))))]
  "TARGET_HARD_FLOAT  || TARGET_ZFINX"
  "fmsub.<fmt>\t%0,%1,%2,%3"
  [(set_attr "type" "fmadd")
   (set_attr "mode" "<UNITMODE>")])

;; -a * b - c
(define_insn "fnms<mode>4"
  [(set (match_operand:ANYF               0 "register_operand" "=f")
	(fma:ANYF
	    (neg:ANYF (match_operand:ANYF 1 "register_operand" " f"))
	    (match_operand:ANYF           2 "register_operand" " f")
	    (neg:ANYF (match_operand:ANYF 3 "register_operand" " f"))))]
  "TARGET_HARD_FLOAT  || TARGET_ZFINX"
  "fnmadd.<fmt>\t%0,%1,%2,%3"
  [(set_attr "type" "fmadd")
   (set_attr "mode" "<UNITMODE>")])

;; -a * b + c
(define_insn "fnma<mode>4"
  [(set (match_operand:ANYF               0 "register_operand" "=f")
	(fma:ANYF
	    (neg:ANYF (match_operand:ANYF 1 "register_operand" " f"))
	    (match_operand:ANYF           2 "register_operand" " f")
	    (match_operand:ANYF           3 "register_operand" " f")))]
  "TARGET_HARD_FLOAT || TARGET_ZFINX"
  "fnmsub.<fmt>\t%0,%1,%2,%3"
  [(set_attr "type" "fmadd")
   (set_attr "mode" "<UNITMODE>")])

;; -(-a * b - c), modulo signed zeros
(define_insn "*fma<mode>4"
  [(set (match_operand:ANYF                   0 "register_operand" "=f")
	(neg:ANYF
	    (fma:ANYF
		(neg:ANYF (match_operand:ANYF 1 "register_operand" " f"))
		(match_operand:ANYF           2 "register_operand" " f")
		(neg:ANYF (match_operand:ANYF 3 "register_operand" " f")))))]
  "(TARGET_HARD_FLOAT || TARGET_ZFINX) && !HONOR_SIGNED_ZEROS (<MODE>mode)"
  "fmadd.<fmt>\t%0,%1,%2,%3"
  [(set_attr "type" "fmadd")
   (set_attr "mode" "<UNITMODE>")])

;; -(-a * b + c), modulo signed zeros
(define_insn "*fms<mode>4"
  [(set (match_operand:ANYF                   0 "register_operand" "=f")
	(neg:ANYF
	    (fma:ANYF
		(neg:ANYF (match_operand:ANYF 1 "register_operand" " f"))
		(match_operand:ANYF           2 "register_operand" " f")
		(match_operand:ANYF           3 "register_operand" " f"))))]
  "(TARGET_HARD_FLOAT || TARGET_ZFINX) && !HONOR_SIGNED_ZEROS (<MODE>mode)"
  "fmsub.<fmt>\t%0,%1,%2,%3"
  [(set_attr "type" "fmadd")
   (set_attr "mode" "<UNITMODE>")])

;; -(a * b + c), modulo signed zeros
(define_insn "*fnms<mode>4"
  [(set (match_operand:ANYF         0 "register_operand" "=f")
	(neg:ANYF
	    (fma:ANYF
		(match_operand:ANYF 1 "register_operand" " f")
		(match_operand:ANYF 2 "register_operand" " f")
		(match_operand:ANYF 3 "register_operand" " f"))))]
  "(TARGET_HARD_FLOAT || TARGET_ZFINX) && !HONOR_SIGNED_ZEROS (<MODE>mode)"
  "fnmadd.<fmt>\t%0,%1,%2,%3"
  [(set_attr "type" "fmadd")
   (set_attr "mode" "<UNITMODE>")])

;; -(a * b - c), modulo signed zeros
(define_insn "*fnma<mode>4"
  [(set (match_operand:ANYF                   0 "register_operand" "=f")
	(neg:ANYF
	    (fma:ANYF
		(match_operand:ANYF           1 "register_operand" " f")
		(match_operand:ANYF           2 "register_operand" " f")
		(neg:ANYF (match_operand:ANYF 3 "register_operand" " f")))))]
  "(TARGET_HARD_FLOAT || TARGET_ZFINX) && !HONOR_SIGNED_ZEROS (<MODE>mode)"
  "fnmsub.<fmt>\t%0,%1,%2,%3"
  [(set_attr "type" "fmadd")
   (set_attr "mode" "<UNITMODE>")])

;;
;;  ....................
;;
;;	SIGN INJECTION
;;
;;  ....................

(define_insn "abs<mode>2"
  [(set (match_operand:ANYF           0 "register_operand" "=f")
	(abs:ANYF (match_operand:ANYF 1 "register_operand" " f")))]
  "TARGET_HARD_FLOAT || TARGET_ZFINX"
  "fabs.<fmt>\t%0,%1"
  [(set_attr "type" "fmove")
   (set_attr "mode" "<UNITMODE>")])

(define_insn "copysign<mode>3"
  [(set (match_operand:ANYF 0 "register_operand"               "=f")
	(unspec:ANYF [(match_operand:ANYF 1 "register_operand" " f")
		      (match_operand:ANYF 2 "register_operand" " f")]
		     UNSPEC_COPYSIGN))]
  "TARGET_HARD_FLOAT || TARGET_ZFINX"
  "fsgnj.<fmt>\t%0,%1,%2"
  [(set_attr "type" "fmove")
   (set_attr "mode" "<UNITMODE>")])

(define_insn "neg<mode>2"
  [(set (match_operand:ANYF           0 "register_operand" "=f")
	(neg:ANYF (match_operand:ANYF 1 "register_operand" " f")))]
  "TARGET_HARD_FLOAT || TARGET_ZFINX"
  "fneg.<fmt>\t%0,%1"
  [(set_attr "type" "fmove")
   (set_attr "mode" "<UNITMODE>")])

;;
;;  ....................
;;
;;	MIN/MAX
;;
;;  ....................

(define_insn "fminm<mode>3"
  [(set (match_operand:ANYF                    0 "register_operand" "=f")
	(unspec:ANYF [(use (match_operand:ANYF 1 "register_operand" " f"))
		      (use (match_operand:ANYF 2 "register_operand" " f"))]
		     UNSPEC_FMINM))]
  "TARGET_HARD_FLOAT && TARGET_ZFA"
  "fminm.<fmt>\t%0,%1,%2"
  [(set_attr "type" "fmove")
   (set_attr "mode" "<UNITMODE>")])

(define_insn "fmaxm<mode>3"
  [(set (match_operand:ANYF                    0 "register_operand" "=f")
	(unspec:ANYF [(use (match_operand:ANYF 1 "register_operand" " f"))
		      (use (match_operand:ANYF 2 "register_operand" " f"))]
		     UNSPEC_FMAXM))]
  "TARGET_HARD_FLOAT && TARGET_ZFA"
  "fmaxm.<fmt>\t%0,%1,%2"
  [(set_attr "type" "fmove")
   (set_attr "mode" "<UNITMODE>")])

(define_insn "fmin<mode>3"
  [(set (match_operand:ANYF                    0 "register_operand" "=f")
	(unspec:ANYF [(use (match_operand:ANYF 1 "register_operand" " f"))
		      (use (match_operand:ANYF 2 "register_operand" " f"))]
		     UNSPEC_FMIN))]
  "(TARGET_HARD_FLOAT || TARGET_ZFINX) && !HONOR_SNANS (<MODE>mode)"
  "fmin.<fmt>\t%0,%1,%2"
  [(set_attr "type" "fmove")
   (set_attr "mode" "<UNITMODE>")])

(define_insn "fmax<mode>3"
  [(set (match_operand:ANYF                    0 "register_operand" "=f")
	(unspec:ANYF [(use (match_operand:ANYF 1 "register_operand" " f"))
		      (use (match_operand:ANYF 2 "register_operand" " f"))]
		     UNSPEC_FMAX))]
  "(TARGET_HARD_FLOAT || TARGET_ZFINX) && !HONOR_SNANS (<MODE>mode)"
  "fmax.<fmt>\t%0,%1,%2"
  [(set_attr "type" "fmove")
   (set_attr "mode" "<UNITMODE>")])

(define_insn "smin<mode>3"
  [(set (match_operand:ANYF            0 "register_operand" "=f")
	(smin:ANYF (match_operand:ANYF 1 "register_operand" " f")
		   (match_operand:ANYF 2 "register_operand" " f")))]
  "TARGET_HARD_FLOAT || TARGET_ZFINX"
  "fmin.<fmt>\t%0,%1,%2"
  [(set_attr "type" "fmove")
   (set_attr "mode" "<UNITMODE>")])

(define_insn "smax<mode>3"
  [(set (match_operand:ANYF            0 "register_operand" "=f")
	(smax:ANYF (match_operand:ANYF 1 "register_operand" " f")
		   (match_operand:ANYF 2 "register_operand" " f")))]
  "TARGET_HARD_FLOAT || TARGET_ZFINX"
  "fmax.<fmt>\t%0,%1,%2"
  [(set_attr "type" "fmove")
   (set_attr "mode" "<UNITMODE>")])

;;
;;  ....................
;;
;;	LOGICAL
;;
;;  ....................
;;

;; For RV64, we don't expose the SImode operations to the rtl expanders,
;; but SImode versions exist for combine.

(define_expand "and<mode>3"
  [(set (match_operand:X                0 "register_operand")
        (and:X (match_operand:X 1 "register_operand")
	       (match_operand:X 2 "reg_or_const_int_operand")))]
  ""
{
  /* sc1 synthesis: andi rd, rs, imm → li t, imm; and rd, rs, t */
  if (!TARGET_ANDI && CONST_INT_P (operands[2]))
    operands[2] = force_reg (<MODE>mode, operands[2]);
  if (CONST_INT_P (operands[2]) && synthesize_and (operands))
    DONE;
})

(define_insn "*and<mode>3"
  [(set (match_operand:X                0 "register_operand" "=r,r")
	(and:X (match_operand:X 1 "register_operand" "%r,r")
		       (match_operand:X 2 "arith_operand"    " r,I")))]
  ""
  "and%i2\t%0,%1,%2"
  [(set_attr "type" "logical")
   (set_attr "mode" "<MODE>")
   (set_attr_alternative "enabled"
     [(const_string "yes")
      (if_then_else (match_test "TARGET_ANDI")
        (const_string "yes") (const_string "no"))])])

;; When we construct constants we may want to twiddle a single bit
;; by generating an IOR.  But the constant likely doesn't fit
;; arith_operand.  So the generic code will reload the constant into
;; a register.  Post-reload we won't have the chance to squash things
;; back into a Zbs insn.
;;
;; So indirect through a define_expand.  That allows us to have a
;; predicate that conditionally accepts single bit constants without
;; putting the details of Zbs instructions in here.
(define_expand "<optab><mode>3"
  [(set (match_operand:X 0 "register_operand")
	(any_or:X (match_operand:X 1 "register_operand" "")
		   (match_operand:X 2 "reg_or_const_int_operand" "")))]
  ""

{
  /* sc1 synthesis: a ^ b = (a | b) - (a & b).
     Using sub instead of NOT avoids an instruction-scheduling hazard:
     the old ~(a&b)&(a|b) form has no data edge between the OR and the
     negation of AND, so RTL optimisers reorder them and the register
     allocator then aliases neg to op1's register, corrupting ab_ior. */
  if ((<CODE>) == XOR && !TARGET_XOR)
    {
      rtx op1    = operands[1];
      rtx op2    = REG_P (operands[2]) ? operands[2]
				       : force_reg (SImode, operands[2]);
      rtx ab_and = gen_reg_rtx (SImode);
      rtx ab_ior = gen_reg_rtx (SImode);
      emit_insn (gen_andsi3 (ab_and, op1, op2));
      emit_insn (gen_iorsi3 (ab_ior, op1, op2));
      emit_insn (gen_subsi3 (operands[0], ab_ior, ab_and));
      DONE;
    }
  /* sc1 synthesis: ori rd, rs, imm → li t, imm; or rd, rs, t */
  if ((<CODE>) == IOR && !TARGET_ORI && CONST_INT_P (operands[2]))
    operands[2] = force_reg (<MODE>mode, operands[2]);
  /* If synthesis of the logical op is successful, then no further code
     generation is necessary.  Else just generate code normally.  */
  if (CONST_INT_P (operands[2]) && synthesize_ior_xor (<OPTAB>, operands))
    DONE;
})

(define_insn "*<optab><mode>3"
  [(set (match_operand:X                0 "register_operand" "=r,r")
	(any_or:X (match_operand:X 1 "register_operand" "%r,r")
		       (match_operand:X 2 "arith_operand"    " r,I")))]
  "TARGET_XOR || (<CODE>) == IOR"
  "<insn>%i2\t%0,%1,%2"
  [(set_attr "type" "logical")
   (set_attr "mode" "<MODE>")
   (set_attr_alternative "enabled"
     [(const_string "yes")
      (if_then_else
        (match_test "(<CODE>) == IOR ? TARGET_ORI : TARGET_XOR")
        (const_string "yes") (const_string "no"))])])

(define_insn "*<optab>si3_internal"
  [(set (match_operand:SI                 0 "register_operand" "=r,r")
	(any_bitwise:SI (match_operand:SI 1 "register_operand" "%r,r")
			(match_operand:SI 2 "arith_operand"    " r,I")))]
  "TARGET_64BIT"
  "<insn>%i2\t%0,%1,%2"
  [(set_attr "type" "logical")
   (set_attr "mode" "SI")])

(define_expand "one_cmpl<mode>2"
  [(set (match_operand:X 0 "register_operand")
	(not:X (match_operand:X 1 "register_operand")))]
  ""
{
  if (!TARGET_XOR)
    {
      /* sc1 synthesis: ~x = -x - 1  (sub x0,rs then addi -1). */
      rtx tmp = gen_reg_rtx (SImode);
      emit_insn (gen_subsi3 (tmp, const0_rtx, operands[1]));
      emit_insn (gen_addsi3 (operands[0], tmp, GEN_INT (-1)));
      DONE;
    }
})

(define_insn "*one_cmpl<mode>2"
  [(set (match_operand:X        0 "register_operand" "=r")
	(not:X (match_operand:X 1 "register_operand" " r")))]
  "TARGET_XOR"
  "not\t%0,%1"
  [(set_attr "type" "logical")
   (set_attr "mode" "<MODE>")])

(define_insn "*one_cmplsi2_internal"
  [(set (match_operand:SI         0 "register_operand" "=r")
	(not:SI (match_operand:SI 1 "register_operand" " r")))]
  "TARGET_64BIT"
  "not\t%0,%1"
  [(set_attr "type" "logical")
   (set_attr "mode" "SI")])

;;
;;  ....................
;;
;;	TRUNCATION
;;
;;  ....................

(define_insn "truncdfsf2"
  [(set (match_operand:SF     0 "register_operand" "=f")
	(float_truncate:SF
	    (match_operand:DF 1 "register_operand" " f")))]
  "TARGET_DOUBLE_FLOAT || TARGET_ZDINX"
  "fcvt.s.d\t%0,%1"
  [(set_attr "type" "fcvt")
   (set_attr "mode" "SF")])

(define_insn "truncsfhf2"
  [(set (match_operand:HF     0 "register_operand" "=f")
       (float_truncate:HF
           (match_operand:SF 1 "register_operand" " f")))]
  "TARGET_ZFHMIN || TARGET_ZHINXMIN"
  "fcvt.h.s\t%0,%1"
  [(set_attr "type" "fcvt")
   (set_attr "mode" "HF")])

(define_insn "truncdfhf2"
  [(set (match_operand:HF     0 "register_operand" "=f")
       (float_truncate:HF
           (match_operand:DF 1 "register_operand" " f")))]
  "(TARGET_ZFHMIN && TARGET_DOUBLE_FLOAT) ||
   (TARGET_ZHINXMIN && TARGET_ZDINX)"
  "fcvt.h.d\t%0,%1"
  [(set_attr "type" "fcvt")
   (set_attr "mode" "HF")])

(define_insn "truncsfbf2"
  [(set (match_operand:BF    0 "register_operand" "=f")
	(float_truncate:BF
	   (match_operand:SF 1 "register_operand" " f")))]
  "TARGET_ZFBFMIN || TARGET_XANDESBFHCVT"
{
  if (TARGET_ZFBFMIN)
    return "fcvt.bf16.s\t%0,%1";
  else
    return "nds.fcvt.bf16.s\t%0,%1";
}
  [(set_attr "type" "fcvt")
   (set_attr "mode" "BF")])

;; The conversion of HF/DF/TF to BF needs to be done with SF if there is a
;; chance to generate at least one instruction, otherwise just using
;; libfunc __trunc[h|d|t]fbf2.
(define_expand "trunc<mode>bf2"
  [(set (match_operand:BF	0 "register_operand" "=f")
	(float_truncate:BF
	   (match_operand:FBF	1 "register_operand" " f")))]
  "TARGET_ZFBFMIN"
  {
    convert_move (operands[0],
		  convert_modes (SFmode, <MODE>mode, operands[1], 0), 0);
    DONE;
  }
  [(set_attr "type" "fcvt")
   (set_attr "mode" "BF")])

;;
;;  ....................
;;
;;	ZERO EXTENSION
;;
;;  ....................

;; Extension insns.

(define_expand "zero_extendsidi2"
  [(set (match_operand:DI 0 "register_operand")
	(zero_extend:DI (match_operand:SI 1 "nonimmediate_operand")))]
  "TARGET_64BIT"
{
  if (SUBREG_P (operands[1]) && SUBREG_PROMOTED_VAR_P (operands[1])
      && SUBREG_PROMOTED_UNSIGNED_P (operands[1]))
    {
      emit_insn (gen_movdi (operands[0], SUBREG_REG (operands[1])));
      DONE;
    }
})

(define_insn_and_split "*zero_extendsidi2_internal"
  [(set (match_operand:DI     0 "register_operand"     "=r,r")
	(zero_extend:DI
	    (match_operand:SI 1 "nonimmediate_operand" " r,m")))]
  "TARGET_64BIT && !TARGET_ZBA && !TARGET_XTHEADBB && !TARGET_XTHEADMEMIDX
   && !TARGET_XANDESPERF
   && !(REG_P (operands[1]) && VL_REG_P (REGNO (operands[1])))"
  "@
   #
   lwu\t%0,%1"
  "&& reload_completed
   && REG_P (operands[1])
   && !paradoxical_subreg_p (operands[0])"
  [(set (match_dup 0)
	(ashift:DI (match_dup 1) (const_int 32)))
   (set (match_dup 0)
	(lshiftrt:DI (match_dup 0) (const_int 32)))]
  { operands[1] = gen_lowpart (DImode, operands[1]); }
  [(set_attr "move_type" "shift_shift,load")
   (set_attr "type" "load")
   (set_attr "mode" "DI")])

(define_expand "zero_extendhi<GPR:mode>2"
  [(set (match_operand:GPR    0 "register_operand")
	(zero_extend:GPR
	    (match_operand:HI 1 "nonimmediate_operand")))]
  ""
{
  /* sc1 synthesis: lhu addr → lw word, extract halfword, zero-extend */
  if (!TARGET_HALF && MEM_P (operands[1]))
    {
      rtx addr = force_reg (SImode, XEXP (operands[1], 0));
      rtx t_neg4 = gen_reg_rtx (SImode);
      emit_move_insn (t_neg4, GEN_INT (-4));
      rtx t_aligned = gen_reg_rtx (SImode);
      emit_insn (gen_andsi3 (t_aligned, addr, t_neg4));
      rtx t_word = gen_reg_rtx (SImode);
      emit_move_insn (t_word, gen_rtx_MEM (SImode, t_aligned));
      rtx t2 = gen_reg_rtx (SImode);
      emit_move_insn (t2, GEN_INT (2));
      rtx t_half_off = gen_reg_rtx (SImode);
      emit_insn (gen_andsi3 (t_half_off, addr, t2));
      rtx t_bit_off = gen_reg_rtx (SImode);
      emit_insn (gen_ashlsi3 (t_bit_off, t_half_off, GEN_INT (3)));
      rtx t_shifted = gen_reg_rtx (SImode);
      emit_insn (gen_lshrsi3 (t_shifted, t_word, t_bit_off));
      rtx t_tmp = gen_reg_rtx (SImode);
      emit_insn (gen_ashlsi3 (t_tmp, t_shifted, GEN_INT (16)));
      emit_insn (gen_lshrsi3 (operands[0], t_tmp, GEN_INT (16)));
      DONE;
    }
  /* sc1 synthesis for subreg:HI (reg:OI N) M sources: extract the aligned
     SI word with fresh pseudos so that after vregs the subreg becomes a
     plain lw (valid on sc1).  Plain reg:HI sources are handled by the
     post-reload split below — doing it there avoids paradoxical-subreg
     spill hazards that arise when the HI pseudo is stack-allocated.  */
  if (!TARGET_HALF && SUBREG_P (operands[1]))
    {
      unsigned HOST_WIDE_INT boff
	= SUBREG_BYTE (operands[1]).to_constant ();
      rtx si_sub = gen_rtx_SUBREG (SImode, SUBREG_REG (operands[1]),
				   boff & ~(unsigned HOST_WIDE_INT) 3);
      rtx src_si = force_reg (SImode, si_sub);

      rtx tdest = gen_reg_rtx (SImode);
      if (boff & 2)
	{
	  /* Halfword is in the upper 16 bits; lshr 16 zero-extends.  */
	  emit_insn (gen_lshrsi3 (tdest, src_si, GEN_INT (16)));
	}
      else if (TARGET_SHIFT)
	{
	  emit_insn (gen_ashlsi3 (tdest, src_si, GEN_INT (16)));
	  emit_insn (gen_lshrsi3 (tdest, tdest, GEN_INT (16)));
	}
      else
	{
	  rtx mask = gen_reg_rtx (SImode);
	  if (!TARGET_LUI)
	    riscv_emit_const_no_lui (SImode, mask, 0xFFFF);
	  else
	    emit_move_insn (mask, gen_int_mode (0xFFFF, SImode));
	  emit_insn (gen_andsi3 (tdest, src_si, mask));
	}
      emit_move_insn (operands[0], gen_lowpart (<GPR:MODE>mode, tdest));
      DONE;
    }
  /* Plain reg:HI sources: expand-time synthesis avoids post-reload
     complications with gen_and3 needing new pseudos for !TARGET_ANDI.
     gen_lowpart(SImode, HI_reg) creates a paradoxical subreg that reload
     handles correctly (widens load when spilled).  */
  if (!TARGET_HALF && !MEM_P (operands[1]) && !SUBREG_P (operands[1]))
    {
      rtx src_si = gen_lowpart (SImode, operands[1]);
      rtx tdest = gen_reg_rtx (SImode);
      if (TARGET_SHIFT)
	{
	  emit_insn (gen_ashlsi3 (tdest, src_si, GEN_INT (16)));
	  emit_insn (gen_lshrsi3 (tdest, tdest, GEN_INT (16)));
	}
      else
	{
	  rtx mask = gen_reg_rtx (SImode);
	  if (!TARGET_LUI)
	    riscv_emit_const_no_lui (SImode, mask, 0xFFFF);
	  else
	    emit_move_insn (mask, gen_int_mode (0xFFFF, SImode));
	  emit_insn (gen_andsi3 (tdest, src_si, mask));
	}
      emit_move_insn (operands[0], gen_lowpart (<GPR:MODE>mode, tdest));
      DONE;
    }
})

(define_insn_and_split "*zero_extendhi<GPR:mode>2"
  [(set (match_operand:GPR    0 "register_operand"       "=&r, &r")
	(zero_extend:GPR
	    (match_operand:HI 1 "nonimmediate_operand"   "   r,  m")))]
  "!TARGET_ZBB && !TARGET_XTHEADBB && !TARGET_XTHEADMEMIDX
   && !TARGET_XANDESPERF && TARGET_HALF"
  {
    switch (which_alternative)
      {
      case 0: return "#";
      case 1: return "lhu\t%0,%1";
      default: gcc_unreachable ();
      }
  }
  /* reg/subreg->reg post-reload: combine may create (zero_extend:SI
     (subreg:HI (reg:SI N) 0)) from (and:SI N 0xFFFF); =&r ensures
     op0 != op1.  Accept any non-MEM source (REG or SUBREG).
     We avoid which_alternative here because it is not reliably set
     when try_split is called from some passes.  */
  "&& !MEM_P (operands[1])
   && reload_completed
   && !paradoxical_subreg_p (operands[0])"
  [(const_int 0)]
  {
    /* Get the underlying hard register as GPR-mode regardless of
       whether operands[1] is REG or SUBREG.  For a subreg such as
       (subreg:HI (reg:SI N) 0) this gives the full SI register,
       which is safe: the AND/shift below discards the upper bits.
       SUBREG_BYTE != 0 only arises with TARGET_SHIFT (sc2+) and is
       handled by the lshiftrt path.  */
    rtx src;
    unsigned HOST_WIDE_INT boff = 0;
    if (SUBREG_P (operands[1]))
      {
	boff = SUBREG_BYTE (operands[1]).to_constant ();
	src = gen_rtx_REG (<GPR:MODE>mode,
			   REGNO (SUBREG_REG (operands[1])));
      }
    else
      src = gen_rtx_REG (<GPR:MODE>mode, REGNO (operands[1]));

    if (boff != 0)
      {
	/* Upper halfword: one logical right shift zero-extends.  */
	emit_insn (gen_rtx_SET (operands[0],
				gen_rtx_LSHIFTRT (<GPR:MODE>mode,
						  src, GEN_INT (16))));
      }
    else if (TARGET_SHIFT)
      {
	rtx sh = GEN_INT (GET_MODE_BITSIZE (<GPR:MODE>mode) - 16);
	emit_insn (gen_rtx_SET (operands[0],
				gen_rtx_ASHIFT (<GPR:MODE>mode, src, sh)));
	emit_insn (gen_rtx_SET (operands[0],
				gen_rtx_LSHIFTRT (<GPR:MODE>mode,
						  operands[0], sh)));
      }
    else if (!TARGET_LUI)
      {
	/* sc0: post-reload, can't create pseudos or pool entries.
	   riscv_emit_const_no_lui writes only into operands[0].  */
	riscv_emit_const_no_lui (<GPR:MODE>mode, operands[0], 0xFFFF);
	emit_insn (gen_and<GPR:mode>3 (operands[0], src, operands[0]));
      }
    else
      {
	/* !TARGET_SHIFT (sc1): load mask into output then AND.
	   =&r guarantees operands[0] != the underlying source reg.  */
	emit_move_insn (operands[0], GEN_INT (0xFFFF));
	emit_insn (gen_and<GPR:mode>3 (operands[0], src, operands[0]));
      }
    DONE;
  }
  [(set_attr "move_type" "shift_shift,load")
   (set_attr "type" "load")
   (set_attr "mode" "<GPR:MODE>")])

;; sc1: !TARGET_HALF counterpart of the pattern above.  Operand 1 is
;; deliberately restricted to register_operand (no "m" alternative at
;; all): the movhi expand above already intercepts every genuine
;; source-level MEM operand at expand time, synthesizing the lw+shift+
;; mask sequence itself with fresh pseudos while they're still legal to
;; create.  A memory alternative here would instead be reachable only as
;; an LRA spill escape valve -- and LRA's alternative costing picks a
;; constraint-string-compatible memory alternative without re-checking
;; this insn's overall C condition, producing a (zero_extend (mem ...))
;; under !TARGET_HALF that can never be split post-reload (see the
;; *movhi_internal / pr108789.c mul() comment above movhi_internal_noload
;; for the same bug class).  Omitting the alternative forces LRA to
;; reload the HImode value into a register first, through
;; movhi_internal_noload's already post-reload-safe "r,m" alternative,
;; before this pattern ever sees it.
(define_insn_and_split "*zero_extendhi<GPR:mode>2_noload"
  [(set (match_operand:GPR    0 "register_operand"     "=&r")
	(zero_extend:GPR
	    (match_operand:HI 1 "register_operand"     "   r")))]
  "!TARGET_ZBB && !TARGET_XTHEADBB && !TARGET_XTHEADMEMIDX
   && !TARGET_XANDESPERF && !TARGET_HALF"
  "#"
  "&& reload_completed && !paradoxical_subreg_p (operands[0])"
  [(const_int 0)]
  {
    /* Same synthesis as the TARGET_HALF pattern's non-MEM split above;
       see its comment for the boff/TARGET_SHIFT/TARGET_LUI rationale.  */
    rtx src;
    unsigned HOST_WIDE_INT boff = 0;
    if (SUBREG_P (operands[1]))
      {
	boff = SUBREG_BYTE (operands[1]).to_constant ();
	src = gen_rtx_REG (<GPR:MODE>mode,
			   REGNO (SUBREG_REG (operands[1])));
      }
    else
      src = gen_rtx_REG (<GPR:MODE>mode, REGNO (operands[1]));

    if (boff != 0)
      {
	emit_insn (gen_rtx_SET (operands[0],
				gen_rtx_LSHIFTRT (<GPR:MODE>mode,
						  src, GEN_INT (16))));
      }
    else if (TARGET_SHIFT)
      {
	rtx sh = GEN_INT (GET_MODE_BITSIZE (<GPR:MODE>mode) - 16);
	emit_insn (gen_rtx_SET (operands[0],
				gen_rtx_ASHIFT (<GPR:MODE>mode, src, sh)));
	emit_insn (gen_rtx_SET (operands[0],
				gen_rtx_LSHIFTRT (<GPR:MODE>mode,
						  operands[0], sh)));
      }
    else if (!TARGET_LUI)
      {
	riscv_emit_const_no_lui (<GPR:MODE>mode, operands[0], 0xFFFF);
	emit_insn (gen_and<GPR:mode>3 (operands[0], src, operands[0]));
      }
    else
      {
	emit_move_insn (operands[0], GEN_INT (0xFFFF));
	emit_insn (gen_and<GPR:mode>3 (operands[0], src, operands[0]));
      }
    DONE;
  }
  [(set_attr "move_type" "shift_shift")
   (set_attr "type" "load")
   (set_attr "mode" "<GPR:MODE>")])

(define_expand "zero_extendqi<SUPERQI:mode>2"
  [(set (match_operand:SUPERQI    0 "register_operand")
	(zero_extend:SUPERQI
	    (match_operand:QI 1 "nonimmediate_operand")))]
  ""
{
  /* sc1 synthesis: lbu addr → lw word, extract byte, zero-extend.
     Check MEM BEFORE the word_mode reshape: emit_move_insn does not call
     define_expand, so delegating to it with (zero_extend:SI (mem:QI)) would
     leave an unrecognizable insn when !TARGET_BYTE.  */
  if (!TARGET_BYTE && MEM_P (operands[1]))
    {
      rtx addr = force_reg (SImode, XEXP (operands[1], 0));
      rtx t_neg4 = gen_reg_rtx (SImode);
      emit_move_insn (t_neg4, GEN_INT (-4));
      rtx t_aligned = gen_reg_rtx (SImode);
      emit_insn (gen_andsi3 (t_aligned, addr, t_neg4));
      rtx t_word = gen_reg_rtx (SImode);
      emit_move_insn (t_word, gen_rtx_MEM (SImode, t_aligned));
      rtx t3 = gen_reg_rtx (SImode);
      emit_move_insn (t3, GEN_INT (3));
      rtx t_byte_off = gen_reg_rtx (SImode);
      emit_insn (gen_andsi3 (t_byte_off, addr, t3));
      rtx t_bit_off = gen_reg_rtx (SImode);
      emit_insn (gen_ashlsi3 (t_bit_off, t_byte_off, GEN_INT (3)));
      rtx t_shifted = gen_reg_rtx (SImode);
      emit_insn (gen_lshrsi3 (t_shifted, t_word, t_bit_off));
      rtx tdest = gen_reg_rtx (SImode);
      emit_insn (gen_ashlsi3 (tdest, t_shifted, GEN_INT (24)));
      emit_insn (gen_lshrsi3 (tdest, tdest, GEN_INT (24)));
      /* For sub-word destinations, wrap the SI result in a promoted subreg. */
      if (<SUPERQI:MODE>mode != word_mode)
	{
	  rtx res = gen_lowpart (<SUPERQI:MODE>mode, tdest);
	  SUBREG_PROMOTED_VAR_P (res) = 1;
	  SUBREG_PROMOTED_SET (res, SRP_UNSIGNED);
	  emit_move_insn (operands[0], res);
	}
      else
	emit_move_insn (operands[0], tdest);
      DONE;
    }
  /* For sub-word destinations with non-MEM (register) source, load to a full
     word first for better CSE of memory references.  */
  if (<SUPERQI:MODE>mode != word_mode)
    {
      rtx tdest = gen_reg_rtx (word_mode);
      emit_move_insn (tdest, gen_rtx_ZERO_EXTEND (word_mode, operands[1]));
      tdest = gen_lowpart (<SUPERQI:MODE>mode, tdest);
      SUBREG_PROMOTED_VAR_P (tdest) = 1;
      SUBREG_PROMOTED_SET (tdest, SRP_UNSIGNED);
      emit_move_insn (operands[0], tdest);
      DONE;
    }
})

/* sc1 synthesis: andi rd, rs, 0xff → li rd, 0xff; and rd, rs, rd.
   Must appear before *zero_extendqi<SUPERQI:mode>2_internal so that GCC
   prefers this split over the andi alternative when !TARGET_ANDI.  */
(define_insn_and_split "*zero_extendqisi2_noandi"
  [(set (match_operand:SI 0 "register_operand"   "=&r")
        (zero_extend:SI
            (match_operand:QI 1 "register_operand" "  r")))]
  "!TARGET_XTHEADMEMIDX && !TARGET_ANDI"
  "#"
  "&& reload_completed"
  [(set (match_dup 0) (const_int 255))
   (set (match_dup 0) (and:SI (match_dup 1) (match_dup 0)))]
  { operands[1] = gen_lowpart (SImode, operands[1]); }
  [(set_attr "move_type" "shift_shift")
   (set_attr "type" "arith")
   (set_attr "mode" "SI")])

(define_insn "*zero_extendqi<SUPERQI:mode>2_internal"
  [(set (match_operand:SUPERQI 0 "register_operand"    "=r,r")
	(zero_extend:SUPERQI
	    (match_operand:QI 1 "nonimmediate_operand" " r,Bq")))]
  "!TARGET_XTHEADMEMIDX && (!MEM_P (operands[1]) || TARGET_BYTE)"
  "@
   andi\t%0,%1,0xff
   lbu\t%0,%1"
  [(set_attr "move_type" "andi,load")
   (set_attr "type" "arith,load")
   (set_attr "mode" "<SUPERQI:MODE>")])

;;
;;  ....................
;;
;;	SIGN EXTENSION
;;
;;  ....................

(define_expand "extendsidi2"
  [(set (match_operand:DI     0 "register_operand"     "=r,r")
	(sign_extend:DI
	    (match_operand:SI 1 "nonimmediate_operand" " r,m")))]
  "TARGET_64BIT"
{
  if (SUBREG_P (operands[1]) && SUBREG_PROMOTED_VAR_P (operands[1])
      && SUBREG_PROMOTED_SIGNED_P (operands[1]))
    {
      emit_insn (gen_movdi (operands[0], SUBREG_REG (operands[1])));
      DONE;
    }
})

(define_insn "*extendsidi2_internal"
  [(set (match_operand:DI     0 "register_operand"     "=r,r")
	(sign_extend:DI
	    (match_operand:SI 1 "nonimmediate_operand" " r,m")))]
  "TARGET_64BIT && !TARGET_XTHEADMEMIDX && !TARGET_XANDESPERF"
  "@
   sext.w\t%0,%1
   lw\t%0,%1"
  [(set_attr "move_type" "move,load")
   (set_attr "type" "move,load")
   (set_attr "mode" "DI")])

(define_expand "extend<SHORT:mode><SUPERQI:mode>2"
  [(set (match_operand:SUPERQI 0 "register_operand")
	(sign_extend:SUPERQI (match_operand:SHORT 1 "nonimmediate_operand")))]
  ""
{
  /* sc1 synthesis: lb/lh addr → lw word, extract byte/halfword, sign-extend.
     Check MEM BEFORE the word_mode reshape: emit_move_insn does not call
     define_expand, so delegating to it with (sign_extend:SI (mem:QI)) would
     leave an unrecognizable insn when !TARGET_BYTE.  */
  if (MEM_P (operands[1])
      && ((<SHORT:MODE>mode == QImode && !TARGET_BYTE)
	  || (<SHORT:MODE>mode == HImode && !TARGET_HALF)))
    {
      int shift_bits = GET_MODE_BITSIZE (SImode)
		       - GET_MODE_BITSIZE (<SHORT:MODE>mode);
      rtx addr = force_reg (SImode, XEXP (operands[1], 0));
      rtx t_neg4 = gen_reg_rtx (SImode);
      emit_move_insn (t_neg4, GEN_INT (-4));
      rtx t_aligned = gen_reg_rtx (SImode);
      emit_insn (gen_andsi3 (t_aligned, addr, t_neg4));
      rtx t_word = gen_reg_rtx (SImode);
      emit_move_insn (t_word, gen_rtx_MEM (SImode, t_aligned));
      rtx t_mask = gen_reg_rtx (SImode);
      emit_move_insn (t_mask,
		      GEN_INT (<SHORT:MODE>mode == QImode ? 3 : 2));
      rtx t_unit_off = gen_reg_rtx (SImode);
      emit_insn (gen_andsi3 (t_unit_off, addr, t_mask));
      rtx t_bit_off = gen_reg_rtx (SImode);
      emit_insn (gen_ashlsi3 (t_bit_off, t_unit_off, GEN_INT (3)));
      rtx t_shifted = gen_reg_rtx (SImode);
      emit_insn (gen_lshrsi3 (t_shifted, t_word, t_bit_off));
      rtx tdest = gen_reg_rtx (SImode);
      emit_insn (gen_ashlsi3 (tdest, t_shifted, GEN_INT (shift_bits)));
      emit_insn (gen_ashrsi3 (tdest, tdest, GEN_INT (shift_bits)));
      /* For sub-word destinations, wrap the SI result in a promoted subreg. */
      if (<SUPERQI:MODE>mode != word_mode)
	{
	  rtx res = gen_lowpart (<SUPERQI:MODE>mode, tdest);
	  SUBREG_PROMOTED_VAR_P (res) = 1;
	  SUBREG_PROMOTED_SET (res, SRP_SIGNED);
	  emit_move_insn (operands[0], res);
	}
      else
	emit_move_insn (operands[0], tdest);
      DONE;
    }
  /* For sub-word destinations with non-MEM source, load to a full word
     first for better CSE.  */
  if (<SUPERQI:MODE>mode != word_mode)
    {
      rtx tdest = gen_reg_rtx (word_mode);
      emit_move_insn (tdest, gen_rtx_SIGN_EXTEND (word_mode, operands[1]));
      tdest = gen_lowpart (<SUPERQI:MODE>mode, tdest);
      SUBREG_PROMOTED_VAR_P (tdest) = 1;
      SUBREG_PROMOTED_SET (tdest, SRP_SIGNED);
      emit_move_insn (operands[0], tdest);
      DONE;
    }
  /* sc1: sign extend from QI/HI register (or subreg) without shifts.
     Branchless formula: result = zero_ext + 2*(-(zero_ext & sign_bit))
     where zero_ext = src & mask.  Uses only and/sub/add.  */
  if (!TARGET_SHIFT
      && !MEM_P (operands[1])
      && ((<SHORT:MODE>mode == QImode && !TARGET_BYTE)
	  || (<SHORT:MODE>mode == HImode && !TARGET_HALF)))
    {
      int narrow = GET_MODE_BITSIZE (<SHORT:MODE>mode);
      rtx src = gen_lowpart (SImode, operands[1]);
      HOST_WIDE_INT mask_val = ((HOST_WIDE_INT)1 << narrow) - 1;
      HOST_WIDE_INT sign_val = (HOST_WIDE_INT)1 << (narrow - 1);
      /* sc0 (!TARGET_LUI): all non-SMALL_OPERAND constants go through the
	 constant pool, which is placed in low memory for ISA tests but at
	 0x80000000+ for behavioural tests.  Build large constants via
	 doublings so no CONST_INT is ever injected into the RTL.  */
      rtx t1 = gen_reg_rtx (SImode);
      if (!TARGET_LUI && !SMALL_OPERAND (mask_val))
	{
	  rtx t_mask = gen_reg_rtx (SImode);
	  riscv_emit_const_no_lui (SImode, t_mask, mask_val);
	  emit_insn (gen_andsi3 (t1, src, t_mask));
	}
      else
	emit_insn (gen_andsi3 (t1, src, gen_int_mode (mask_val, SImode)));
      rtx t2 = gen_reg_rtx (SImode);
      if (!TARGET_LUI && !SMALL_OPERAND (sign_val))
	{
	  rtx t_sign = gen_reg_rtx (SImode);
	  riscv_emit_const_no_lui (SImode, t_sign, sign_val);
	  emit_insn (gen_andsi3 (t2, t1, t_sign));
	}
      else
	emit_insn (gen_andsi3 (t2, t1, gen_int_mode (sign_val, SImode)));
      rtx t3 = gen_reg_rtx (SImode);
      emit_insn (gen_subsi3 (t3, const0_rtx, t2));
      rtx t4 = gen_reg_rtx (SImode);
      emit_insn (gen_addsi3 (t4, t3, t3));
      emit_insn (gen_addsi3 (operands[0], t1, t4));
      DONE;
    }
})

(define_insn_and_split "*extend<SHORT:mode><SUPERQI:mode>2"
  [(set (match_operand:SUPERQI   0 "register_operand"     "=r,r")
	(sign_extend:SUPERQI
	    (match_operand:SHORT 1 "nonimmediate_operand" " r,Bs")))]
  "!TARGET_ZBB && !TARGET_XTHEADBB && !TARGET_XTHEADMEMIDX
   && !TARGET_XANDESPERF
   && (!MEM_P (operands[1])
       || (<SHORT:MODE>mode == HImode ? TARGET_HALF : TARGET_BYTE))
   && (MEM_P (operands[1]) || TARGET_SHIFT)"
  "@
   #
   l<SHORT:size>\t%0,%1"
  "&& reload_completed && TARGET_SHIFT
   && REG_P (operands[1])
   && !paradoxical_subreg_p (operands[0])"
  [(set (match_dup 0) (ashift:SI (match_dup 1) (match_dup 2)))
   (set (match_dup 0) (ashiftrt:SI (match_dup 0) (match_dup 2)))]
{
  operands[0] = gen_lowpart (SImode, operands[0]);
  operands[1] = gen_lowpart (SImode, operands[1]);
  operands[2] = GEN_INT (GET_MODE_BITSIZE (SImode)
			 - GET_MODE_BITSIZE (<SHORT:MODE>mode));
}
  [(set_attr "move_type" "shift_shift,load")
   (set_attr "type" "load")
   (set_attr "mode" "SI")])

(define_insn "extendhfsf2"
  [(set (match_operand:SF     0 "register_operand" "=f")
       (float_extend:SF
           (match_operand:HF 1 "register_operand" " f")))]
  "TARGET_ZFHMIN || TARGET_ZHINXMIN"
  "fcvt.s.h\t%0,%1"
  [(set_attr "type" "fcvt")
   (set_attr "mode" "SF")])

(define_insn "extendbfsf2"
  [(set (match_operand:SF    0 "register_operand" "=f")
	(float_extend:SF
	   (match_operand:BF 1 "register_operand" " f")))]
  "TARGET_ZFBFMIN || TARGET_XANDESBFHCVT"
{
  if (TARGET_ZFBFMIN)
    return "fcvt.s.bf16\t%0,%1";
  else
    return "nds.fcvt.s.bf16\t%0,%1";
}
  [(set_attr "type" "fcvt")
   (set_attr "mode" "SF")])

(define_insn "extendsfdf2"
  [(set (match_operand:DF     0 "register_operand" "=f")
	(float_extend:DF
	    (match_operand:SF 1 "register_operand" " f")))]
  "TARGET_DOUBLE_FLOAT || TARGET_ZDINX"
  "fcvt.d.s\t%0,%1"
  [(set_attr "type" "fcvt")
   (set_attr "mode" "DF")])

(define_insn "extendhfdf2"
  [(set (match_operand:DF     0 "register_operand" "=f")
       (float_extend:DF
           (match_operand:HF 1 "register_operand" " f")))]
  "(TARGET_ZFHMIN && TARGET_DOUBLE_FLOAT) ||
   (TARGET_ZHINXMIN && TARGET_ZDINX)"
  "fcvt.d.h\t%0,%1"
  [(set_attr "type" "fcvt")
   (set_attr "mode" "DF")])

;; 16-bit floating point moves
(define_expand "mov<mode>"
  [(set (match_operand:HFBF 0 "")
	(match_operand:HFBF 1 ""))]
  ""
{
  if (riscv_legitimize_move (<MODE>mode, operands[0], operands[1]))
    DONE;
})

(define_insn "*mov<mode>_hardfloat"
  [(set (match_operand:HFBF 0 "nonimmediate_operand" "=f,   f,f,f,m,m,*f,*r,  *r,*r,*m")
	(match_operand:HFBF 1 "move_operand"	     " f,zfli,G,m,f,G,*r,*f,*G*r,*m,*r"))]
  "((TARGET_ZFHMIN && <MODE>mode == HFmode)
    || (TARGET_ZFBFMIN && <MODE>mode == BFmode))
   && (register_operand (operands[0], <MODE>mode)
       || reg_or_0_operand (operands[1], <MODE>mode))"
  { return riscv_output_move (operands[0], operands[1]); }
  [(set_attr "move_type" "fmove,fmove,mtc,fpload,fpstore,store,mtc,mfc,move,load,store")
   (set_attr "type" "fmove,fmove,mtc,fpload,fpstore,store,mtc,mfc,move,load,store")
   (set_attr "mode" "<MODE>")])

(define_insn "*mov<mode>_softfloat"
  [(set (match_operand:HFBF 0 "nonimmediate_operand" "=f, r,r,m,*f,*r")
	(match_operand:HFBF 1 "move_operand"	     " f,Gr,m,r,*r,*f"))]
  "((!TARGET_ZFHMIN && <MODE>mode == HFmode) || (<MODE>mode == BFmode))
   && (register_operand (operands[0], <MODE>mode)
       || reg_or_0_operand (operands[1], <MODE>mode))"
  { return riscv_output_move (operands[0], operands[1]); }
  [(set_attr "move_type" "fmove,move,load,store,mtc,mfc")
   (set_attr "type" "fmove,move,load,store,mtc,mfc")
   (set_attr "mode" "<MODE>")])

(define_insn "*mov<HFBF:mode>_softfloat_boxing"
  [(set (match_operand:HFBF 0 "register_operand"	    "=f")
	(unspec:HFBF [(match_operand:X 1 "register_operand" " r")]
	 UNSPEC_FMV_FP16_X))]
  "!TARGET_ZFHMIN"
  "fmv.w.x\t%0,%1"
  [(set_attr "type" "fmove")
   (set_attr "mode" "SF")])

;;
;;  ....................
;;
;;	CONVERSIONS
;;
;;  ....................

(define_expand "<fix_uns>_trunc<ANYF:mode>si2"
  [(set (match_operand:SI      0 "register_operand" "=r")
	(fix_ops:SI
	    (match_operand:ANYF 1 "register_operand" " f")))]
  "TARGET_HARD_FLOAT || TARGET_ZFINX"
{
  if (TARGET_64BIT)
    {
      rtx t = gen_reg_rtx (DImode);
      emit_insn (gen_<fix_uns>_trunc<ANYF:mode>si2_sext (t, operands[1]));
      t = gen_lowpart (SImode, t);
      SUBREG_PROMOTED_VAR_P (t) = 1;
      SUBREG_PROMOTED_SET (t, SRP_SIGNED);
      emit_move_insn (operands[0], t);
      DONE;
    }
})

(define_insn "*<fix_uns>_trunc<ANYF:mode>si2"
  [(set (match_operand:SI      0 "register_operand" "=r")
	(fix_ops:SI
	    (match_operand:ANYF 1 "register_operand" " f")))]
  "TARGET_HARD_FLOAT || TARGET_ZFINX"
  "fcvt.w<u>.<ANYF:fmt> %0,%1,rtz"
  [(set_attr "type" "fcvt_f2i")
   (set_attr "mode" "<ANYF:MODE>")])

(define_insn "<fix_uns>_trunc<ANYF:mode>si2_sext"
  [(set (match_operand:DI      0 "register_operand" "=r")
  (sign_extend:DI (fix_ops:SI
	    (match_operand:ANYF 1 "register_operand" " f"))))]
  "TARGET_64BIT && (TARGET_HARD_FLOAT || TARGET_ZFINX)"
  "fcvt.w<u>.<ANYF:fmt> %0,%1,rtz"
  [(set_attr "type" "fcvt_f2i")
   (set_attr "mode" "<ANYF:MODE>")])

(define_insn "<fix_uns>_trunc<ANYF:mode>di2"
  [(set (match_operand:DI      0 "register_operand" "=r")
	(fix_ops:DI
	    (match_operand:ANYF 1 "register_operand" " f")))]
  "TARGET_64BIT && (TARGET_HARD_FLOAT || TARGET_ZFINX)"
  "fcvt.l<u>.<ANYF:fmt> %0,%1,rtz"
  [(set_attr "type" "fcvt_f2i")
   (set_attr "mode" "<ANYF:MODE>")])

(define_insn "float<GPR:mode><ANYF:mode>2"
  [(set (match_operand:ANYF    0 "register_operand" "= f")
	(float:ANYF
	    (match_operand:GPR 1 "reg_or_0_operand" " rJ")))]
  "TARGET_HARD_FLOAT || TARGET_ZFINX"
  "fcvt.<ANYF:fmt>.<GPR:ifmt>\t%0,%z1"
  [(set_attr "type" "fcvt_i2f")
   (set_attr "mode" "<ANYF:MODE>")])

(define_insn "floatuns<GPR:mode><ANYF:mode>2"
  [(set (match_operand:ANYF    0 "register_operand" "= f")
	(unsigned_float:ANYF
	    (match_operand:GPR 1 "reg_or_0_operand" " rJ")))]
  "TARGET_HARD_FLOAT || TARGET_ZFINX"
  "fcvt.<ANYF:fmt>.<GPR:ifmt>u\t%0,%z1"
  [(set_attr "type" "fcvt_i2f")
   (set_attr "mode" "<ANYF:MODE>")])

(define_expand "lrint<ANYF:mode>si2"
  [(set (match_operand:SI       0 "register_operand" "=r")
	(unspec:SI
	    [(match_operand:ANYF 1 "register_operand" " f")]
	    UNSPEC_LRINT))]
  "TARGET_HARD_FLOAT || TARGET_ZFINX"
{
  if (TARGET_64BIT)
    {
      rtx t = gen_reg_rtx (DImode);
      emit_insn (gen_lrint<ANYF:mode>si2_sext (t, operands[1]));
      t = gen_lowpart (SImode, t);
      SUBREG_PROMOTED_VAR_P (t) = 1;
      SUBREG_PROMOTED_SET (t, SRP_SIGNED);
      emit_move_insn (operands[0], t);
      DONE;
    }
})

(define_insn "*lrint<ANYF:mode>si2"
  [(set (match_operand:SI       0 "register_operand" "=r")
	(unspec:SI
	    [(match_operand:ANYF 1 "register_operand" " f")]
	    UNSPEC_LRINT))]
  "TARGET_HARD_FLOAT || TARGET_ZFINX"
  "fcvt.w.<ANYF:fmt> %0,%1,dyn"
  [(set_attr "type" "fcvt_f2i")
   (set_attr "mode" "<ANYF:MODE>")])

(define_insn "lrint<ANYF:mode>si2_sext"
  [(set (match_operand:DI       0 "register_operand" "=r")
  (sign_extend:DI (unspec:SI
	    [(match_operand:ANYF 1 "register_operand" " f")]
	    UNSPEC_LRINT)))]
  "TARGET_64BIT && (TARGET_HARD_FLOAT || TARGET_ZFINX)"
  "fcvt.w.<ANYF:fmt> %0,%1,dyn"
  [(set_attr "type" "fcvt_f2i")
   (set_attr "mode" "<ANYF:MODE>")])

(define_insn "lrint<ANYF:mode>di2"
  [(set (match_operand:DI       0 "register_operand" "=r")
	(unspec:DI
	    [(match_operand:ANYF 1 "register_operand" " f")]
	    UNSPEC_LRINT))]
  "TARGET_64BIT && (TARGET_HARD_FLOAT || TARGET_ZFINX)"
  "fcvt.l.<ANYF:fmt> %0,%1,dyn"
  [(set_attr "type" "fcvt_f2i")
   (set_attr "mode" "<ANYF:MODE>")])

(define_expand "l<round_pattern><ANYF:mode>si2"
  [(set (match_operand:SI       0 "register_operand" "=r")
	(unspec:SI
	    [(match_operand:ANYF 1 "register_operand" " f")]
    ROUND))]
  "TARGET_HARD_FLOAT || TARGET_ZFINX"
{
  if (TARGET_64BIT)
    {
      rtx t = gen_reg_rtx (DImode);
      emit_insn (gen_l<round_pattern><ANYF:mode>si2_sext (t, operands[1]));
      t = gen_lowpart (SImode, t);
      SUBREG_PROMOTED_VAR_P (t) = 1;
      SUBREG_PROMOTED_SET (t, SRP_SIGNED);
      emit_move_insn (operands[0], t);
      DONE;
    }
})

(define_insn "*l<round_pattern><ANYF:mode>si2"
  [(set (match_operand:SI       0 "register_operand" "=r")
	(unspec:SI
	    [(match_operand:ANYF 1 "register_operand" " f")]
    ROUND))]
  "TARGET_HARD_FLOAT || TARGET_ZFINX"
  "fcvt.w.<ANYF:fmt> %0,%1,<round_rm>"
  [(set_attr "type" "fcvt_f2i")
   (set_attr "mode" "<ANYF:MODE>")])

(define_insn "l<round_pattern><ANYF:mode>si2_sext"
  [(set (match_operand:DI       0 "register_operand" "=r")
	 (sign_extend:DI (unspec:SI
			     [(match_operand:ANYF 1 "register_operand" " f")]
		      ROUND)))]
  "TARGET_64BIT && (TARGET_HARD_FLOAT || TARGET_ZFINX)"
  "fcvt.w.<ANYF:fmt> %0,%1,<round_rm>"
  [(set_attr "type" "fcvt_f2i")
   (set_attr "mode" "<ANYF:MODE>")])

(define_insn "l<round_pattern><ANYF:mode>di2"
  [(set (match_operand:DI       0 "register_operand" "=r")
	(unspec:DI
	    [(match_operand:ANYF 1 "register_operand" " f")]
    ROUND))]
  "TARGET_64BIT && (TARGET_HARD_FLOAT || TARGET_ZFINX)"
  "fcvt.l.<ANYF:fmt> %0,%1,<round_rm>"
  [(set_attr "type" "fcvt_f2i")
   (set_attr "mode" "<ANYF:MODE>")])

;; There are a couple non-obvious restrictions to be aware of.
;;
;; We'll do a FP-INT conversion in the sequence.  But we don't
;; have a .l (64bit) variant of those instructions for rv32.
;; To preserve proper semantics we must reject DFmode inputs
;; for rv32 unless Zfa is enabled.
;;
;; The ANYF iterator allows HFmode.  We don't have all the
;; necessary patterns defined for HFmode.  So restrict HFmode
;; to TARGET_ZFA.
(define_expand "<round_pattern><ANYF:mode>2"
  [(set (match_operand:ANYF     0 "register_operand" "=f")
	(unspec:ANYF
	    [(match_operand:ANYF 1 "register_operand" " f")]
	ROUND))]
  "(TARGET_HARD_FLOAT
    && (TARGET_ZFA || flag_fp_int_builtin_inexact || !flag_trapping_math)
    && (TARGET_ZFA || TARGET_64BIT || <ANYF:MODE>mode != DFmode)
    && (TARGET_ZFA || <ANYF:MODE>mode != HFmode))"
{
  if (TARGET_ZFA)
    emit_insn (gen_<round_pattern><ANYF:mode>_zfa2 (operands[0],
                                                    operands[1]));
  else
    {
      rtx reg;
      rtx label1 = gen_label_rtx ();
      rtx label2 = gen_label_rtx ();
      rtx label3 = gen_label_rtx ();
      rtx end_label = gen_label_rtx ();
      rtx abs_reg = gen_reg_rtx (<ANYF:MODE>mode);
      rtx coeff_reg = gen_reg_rtx (<ANYF:MODE>mode);
      rtx tmp_reg = gen_reg_rtx (<ANYF:MODE>mode);

      riscv_emit_move (tmp_reg, operands[1]);

      if (flag_trapping_math)
	{
	  /* Check if the input is a NaN.  */
	  riscv_expand_conditional_branch (label1, EQ,
					   operands[1], operands[1]);

	  emit_jump_insn (gen_jump (label3));
	  emit_barrier ();

	  emit_label (label1);
	}

      riscv_emit_move (coeff_reg,
		       riscv_vector::get_fp_rounding_coefficient (<ANYF:MODE>mode));
      emit_insn (gen_abs<ANYF:mode>2 (abs_reg, operands[1]));

      riscv_expand_conditional_branch (label2, LT, abs_reg, coeff_reg);

      emit_jump_insn (gen_jump (end_label));
      emit_barrier ();

      emit_label (label2);
      switch (<ANYF:MODE>mode)
	{
	case SFmode:
	  reg = gen_reg_rtx (SImode);
	  emit_insn (gen_l<round_pattern>sfsi2 (reg, operands[1]));
	  emit_insn (gen_floatsisf2 (abs_reg, reg));
	  break;
	case DFmode:
	  reg = gen_reg_rtx (DImode);
	  emit_insn (gen_l<round_pattern>dfdi2 (reg, operands[1]));
	  emit_insn (gen_floatdidf2 (abs_reg, reg));
	  break;
	default:
	  gcc_unreachable ();
	}

      emit_insn (gen_copysign<ANYF:mode>3 (tmp_reg, abs_reg, operands[1]));

      emit_jump_insn (gen_jump (end_label));
      emit_barrier ();

      if (flag_trapping_math)
	{
	  emit_label (label3);
	  /* Generate a qNaN from an sNaN if needed.  */
	  emit_insn (gen_add<ANYF:mode>3 (tmp_reg, operands[1], operands[1]));
	}

      emit_label (end_label);
      riscv_emit_move (operands[0], tmp_reg);
    }

  DONE;
})

(define_insn "<round_pattern><ANYF:mode>_zfa2"
  [(set (match_operand:ANYF     0 "register_operand" "=f")
	(unspec:ANYF
	    [(match_operand:ANYF 1 "register_operand" " f")]
	ROUND))]
  "TARGET_HARD_FLOAT && TARGET_ZFA"
  "fround.<ANYF:fmt>\t%0,%1,<round_rm>"
  [(set_attr "type" "fcvt")
   (set_attr "mode" "<ANYF:MODE>")])

(define_insn "rint<ANYF:mode>2"
  [(set (match_operand:ANYF     0 "register_operand" "=f")
	(unspec:ANYF
	    [(match_operand:ANYF 1 "register_operand" " f")]
	UNSPEC_RINT))]
  "TARGET_HARD_FLOAT && TARGET_ZFA"
  "froundnx.<ANYF:fmt>\t%0,%1"
  [(set_attr "type" "fcvt")
   (set_attr "mode" "<ANYF:MODE>")])

;;
;;  ....................
;;
;;	DATA MOVEMENT
;;
;;  ....................

;; Lower-level instructions for loading an address from the GOT.
;; We could use MEMs, but an unspec gives more optimization
;; opportunities.

(define_insn "got_load<mode>"
   [(set (match_operand:P      0 "register_operand" "=r")
	 (unspec:P
	     [(match_operand:P 1 "symbolic_operand" "")]
	     UNSPEC_LOAD_GOT))]
  ""
  "la\t%0,%1"
   [(set_attr "got" "load")
    (set_attr "type" "load")
    (set_attr "mode" "<MODE>")])

(define_insn "tls_add_tp_le<mode>"
  [(set (match_operand:P      0 "register_operand" "=r")
	(unspec:P
	    [(match_operand:P 1 "register_operand" "r")
	     (match_operand:P 2 "register_operand" "r")
	     (match_operand:P 3 "symbolic_operand" "")]
	    UNSPEC_TLS_LE))]
  ""
  "add\t%0,%1,%2,%%tprel_add(%3)"
  [(set_attr "type" "arith")
   (set_attr "mode" "<MODE>")])

(define_insn "got_load_tls_gd<mode>"
  [(set (match_operand:P      0 "register_operand" "=r")
	(unspec:P
	    [(match_operand:P 1 "symbolic_operand" "")]
	    UNSPEC_TLS_GD))]
  ""
  "la.tls.gd\t%0,%1"
  [(set_attr "got" "load")
   (set_attr "type" "load")
   (set_attr "mode" "<MODE>")])

(define_insn "got_load_tls_ie<mode>"
  [(set (match_operand:P      0 "register_operand" "=r")
	(unspec:P
	    [(match_operand:P 1 "symbolic_operand" "")]
	    UNSPEC_TLS_IE))]
  ""
  "la.tls.ie\t%0,%1"
  [(set_attr "got" "load")
   (set_attr "type" "load")
   (set_attr "mode" "<MODE>")])

(define_insn "@tlsdesc<mode>"
  [(set (reg:P A0_REGNUM)
	(unspec:P
	    [(match_operand:P 0 "symbolic_operand" "")]
	    UNSPEC_TLSDESC))
   (clobber (reg:P T0_REGNUM))]
  "TARGET_TLSDESC"
  {
    return ".LT%=: auipc\ta0,%%tlsdesc_hi(%0)\;"
           "<load>\tt0,%%tlsdesc_load_lo(.LT%=)(a0)\;"
           "addi\ta0,a0,%%tlsdesc_add_lo(.LT%=)\;"
           "jalr\tt0,t0,%%tlsdesc_call(.LT%=)";
  }
  [(set_attr "type" "multi")
   (set_attr "length" "16")
   (set_attr "mode" "<MODE>")])

(define_insn "auipc<mode>"
  [(set (match_operand:P           0 "register_operand" "=r")
	(unspec:P
	    [(match_operand:P      1 "symbolic_operand" "")
		  (match_operand:P 2 "const_int_operand")
		  (pc)]
	    UNSPEC_AUIPC))]
  "TARGET_AUIPC"
  ".LA%2: auipc\t%0,%h1"
  [(set_attr "type" "auipc")
   (set_attr "cannot_copy" "yes")])

;; Instructions for adding the low 12 bits of an address to a register.
;; Operand 2 is the address: riscv_print_operand works out which relocation
;; should be applied.

(define_insn "*low<mode>"
  [(set (match_operand:P           0 "register_operand" "=r")
	(lo_sum:P (match_operand:P 1 "register_operand" " r")
		  (match_operand:P 2 "symbolic_operand" "")))]
  ""
  "addi\t%0,%1,%R2"
  [(set_attr "type" "arith")
   (set_attr "mode" "<MODE>")])

;; Allow combine to split complex const_int load sequences, using operand 2
;; to store the intermediate results.  See move_operand for details.
(define_split
  [(set (match_operand:GPR 0 "register_operand")
	(match_operand:GPR 1 "splittable_const_int_operand"))
   (clobber (match_operand:GPR 2 "register_operand"))]
  ""
  [(const_int 0)]
{
  riscv_move_integer (operands[2], operands[0], INTVAL (operands[1]));
  DONE;
})

;; Likewise, for symbolic operands.
(define_split
  [(set (match_operand:P 0 "register_operand")
	(match_operand:P 1))
   (clobber (match_operand:P 2 "register_operand"))]
  "riscv_split_symbol (operands[2], operands[1], MAX_MACHINE_MODE, NULL)"
  [(set (match_dup 0) (match_dup 3))]
{
  riscv_split_symbol (operands[2], operands[1],
		      MAX_MACHINE_MODE, &operands[3]);
})

;; Pretend to have the ability to load complex const_int in order to get
;; better code generation around them.
;; But avoid constants that are special cased elsewhere.
;;
;; Hide it from IRA register equiv recog* () to elide potential undoing of split
;;
(define_insn_and_split "*mvconst_internal"
  [(set (match_operand:GPR 0 "register_operand" "=r")
        (match_operand:GPR 1 "splittable_const_int_operand" "i"))]
  "!ira_in_progress
   && !(p2m1_shift_operand (operands[1], <MODE>mode)
	|| high_mask_shift_operand (operands[1], <MODE>mode)
	|| exact_log2 (INTVAL (operands[1])) >= 0)"
  "#"
  "&& 1"
  [(const_int 0)]
{
  riscv_move_integer (operands[0], operands[0], INTVAL (operands[1]));
  DONE;
}
[(set_attr "type" "move")])

;; 64-bit integer moves

(define_expand "movdi"
  [(set (match_operand:DI 0 "")
	(match_operand:DI 1 ""))]
  ""
{
  if (riscv_legitimize_move (DImode, operands[0], operands[1]))
    DONE;
})

(define_insn "*movdi_32bit"
  [(set (match_operand:DI 0 "nonimmediate_operand" "=r,r,r, m,  *f,*f,*r,*f,*m,r")
	(match_operand:DI 1 "move_operand"         " r,i,m,rJ,*J*r,*m,*f,*f,*f,vp"))]
  "!TARGET_64BIT
   && (register_operand (operands[0], DImode)
       || reg_or_0_operand (operands[1], DImode))"
  { return riscv_output_move (operands[0], operands[1]); }
  [(set_attr "move_type" "move,const,load,store,mtc,fpload,mfc,fmove,fpstore,rdvlenb")
   (set_attr "mode" "DI")
   (set_attr "type" "move,move,load,store,move,fpload,move,fmove,fpstore,move")
   (set_attr "ext" "base,base,base,base,d,d,d,d,d,vector")])

(define_insn "*movdi_64bit"
  [(set (match_operand:DI 0 "nonimmediate_operand" "=r,r,r, m,  *f,*f,*r,*f,*m,r")
	(match_operand:DI 1 "move_operand"         " r,T,m,rJ,*r*J,*m,*f,*f,*f,vp"))]
  "TARGET_64BIT
   && (register_operand (operands[0], DImode)
       || reg_or_0_operand (operands[1], DImode))"
  { return riscv_output_move (operands[0], operands[1]); }
  [(set_attr "move_type" "move,const,load,store,mtc,fpload,mfc,fmove,fpstore,rdvlenb")
   (set_attr "mode" "DI")
   (set_attr "type" "move,move,load,store,mtc,fpload,mfc,fmove,fpstore,move")
   (set_attr "ext" "base,base,base,base,d,d,d,d,d,vector")])

;; 32-bit Integer moves

(define_expand "mov<mode>"
  [(set (match_operand:MOVE32 0 "")
	(match_operand:MOVE32 1 ""))]
  ""
{
  if (riscv_legitimize_move (<MODE>mode, operands[0], operands[1]))
    DONE;
})

(define_insn "*movsi_internal"
  [(set (match_operand:SI 0 "nonimmediate_operand" "=r,r,r, m,  *f,*f,*r,*m,r")
	(match_operand:SI 1 "move_operand"         " r,T,m,rJ,*r*J,*m,*f,*f,vp"))]
  "(register_operand (operands[0], SImode)
    || reg_or_0_operand (operands[1], SImode))
    && !(REG_P (operands[1]) && VL_REG_P (REGNO (operands[1])))"
  { return riscv_output_move (operands[0], operands[1]); }
  [(set_attr "move_type" "move,const,load,store,mtc,fpload,mfc,fpstore,rdvlenb")
   (set_attr "mode" "SI")
   (set_attr "type" "move,move,load,store,mtc,fpload,mfc,fpstore,move")
   (set_attr "ext" "base,base,base,base,f,f,f,f,vector")])

;; 16-bit Integer moves

;; Unlike most other insns, the move insns can't be split with
;; different predicates, because register spilling and other parts of
;; the compiler, have memoized the insn number already.
;; Unsigned loads are used because LOAD_EXTEND_OP returns ZERO_EXTEND.

(define_expand "movhi"
  [(set (match_operand:HI 0 "")
	(match_operand:HI 1 ""))]
  ""
{
  /* sc1 synthesis: sh addr, rs → lw aligned; clear halfword; or in value; sw */
  if (!TARGET_HALF && MEM_P (operands[0]))
    {
      rtx addr      = force_reg (SImode, XEXP (operands[0], 0));
      rtx t_neg4    = gen_reg_rtx (SImode);
      emit_move_insn (t_neg4, GEN_INT (-4));
      rtx t_aligned = gen_reg_rtx (SImode);
      emit_insn (gen_andsi3 (t_aligned, addr, t_neg4));

      /* bit_off = (addr & 2) << 3  → 0 or 16 */
      rtx t2        = gen_reg_rtx (SImode);
      emit_move_insn (t2, GEN_INT (2));
      rtx t_hoff    = gen_reg_rtx (SImode);
      emit_insn (gen_andsi3 (t_hoff, addr, t2));
      rtx t_bit_off = gen_reg_rtx (SImode);
      emit_insn (gen_ashlsi3 (t_bit_off, t_hoff, GEN_INT (3)));

      /* Load aligned word */
      rtx t_word    = gen_reg_rtx (SImode);
      emit_move_insn (t_word, gen_rtx_MEM (SImode, t_aligned));

      /* mask = 0xFFFF << bit_off; word &= ~mask */
      rtx t_mask    = gen_reg_rtx (SImode);
      if (!TARGET_LUI)
	riscv_emit_const_no_lui (SImode, t_mask, 0xFFFF);
      else
	emit_move_insn (t_mask, GEN_INT (0xFFFF));
      emit_insn (gen_ashlsi3 (t_mask, t_mask, t_bit_off));
      rtx t_nmask   = gen_reg_rtx (SImode);
      emit_insn (gen_one_cmplsi2 (t_nmask, t_mask));
      emit_insn (gen_andsi3 (t_word, t_word, t_nmask));

      /* val = (src & 0xFFFF) << bit_off; word |= val */
      rtx t_val     = gen_reg_rtx (SImode);
      if (!TARGET_LUI)
	riscv_emit_const_no_lui (SImode, t_val, 0xFFFF);
      else
	emit_move_insn (t_val, GEN_INT (0xFFFF));
      emit_insn (gen_andsi3 (t_val,
                             gen_lowpart (SImode, force_reg (HImode, operands[1])),
                             t_val));
      emit_insn (gen_ashlsi3 (t_val, t_val, t_bit_off));
      emit_insn (gen_iorsi3 (t_word, t_word, t_val));

      emit_move_insn (gen_rtx_MEM (SImode, t_aligned), t_word);
      DONE;
    }
  /* sc1 synthesis: lhu rd, addr → lw aligned; lshr by bit_off; mask 0xFFFF */
  if (!TARGET_HALF && MEM_P (operands[1]))
    {
      rtx addr      = force_reg (SImode, XEXP (operands[1], 0));
      rtx t_neg4    = gen_reg_rtx (SImode);
      emit_move_insn (t_neg4, GEN_INT (-4));
      rtx t_aligned = gen_reg_rtx (SImode);
      emit_insn (gen_andsi3 (t_aligned, addr, t_neg4));
      rtx t_word    = gen_reg_rtx (SImode);
      emit_move_insn (t_word, gen_rtx_MEM (SImode, t_aligned));

      /* bit_off = (addr & 2) << 3  → 0 or 16 */
      rtx t2        = gen_reg_rtx (SImode);
      emit_move_insn (t2, GEN_INT (2));
      rtx t_hoff    = gen_reg_rtx (SImode);
      emit_insn (gen_andsi3 (t_hoff, addr, t2));
      rtx t_bit_off = gen_reg_rtx (SImode);
      emit_insn (gen_ashlsi3 (t_bit_off, t_hoff, GEN_INT (3)));

      rtx t_shifted = gen_reg_rtx (SImode);
      emit_insn (gen_lshrsi3 (t_shifted, t_word, t_bit_off));

      rtx t_mask    = gen_reg_rtx (SImode);
      if (!TARGET_LUI)
	riscv_emit_const_no_lui (SImode, t_mask, 0xFFFF);
      else
	emit_move_insn (t_mask, GEN_INT (0xFFFF));
      rtx t_result  = gen_reg_rtx (SImode);
      emit_insn (gen_andsi3 (t_result, t_shifted, t_mask));
      emit_move_insn (operands[0], gen_lowpart (HImode, t_result));
      DONE;
    }
  if (riscv_legitimize_move (HImode, operands[0], operands[1]))
    DONE;
  /* sc1: route every remaining (register/constant, non-memory) HImode move
     through the full movhi_internal_noload generator explicitly, rather
     than relying on this expand's implicit final-template auto-emit. The
     implicit auto-emit produces a bare (set op0 op1) with no clobbers,
     whose recognition is deferred; but movhi_internal_noload (below) now
     requires two match_scratch clobbers structurally present in every insn
     that matches it (needed for the r,m/m,r escape-valve alternatives --
     see that pattern's comment), so a bare clobber-less SET can never
     recog against it and ICEs as "unrecognizable insn" at the vregs pass.
     The generator embeds the match_scratch operands as plain (scratch:SI)
     placeholders automatically (they aren't caller-supplied arguments);
     LRA only allocates them a real hard register if it ends up picking
     one of the r,m/m,r alternatives that actually needs them.  */
  if (!TARGET_HALF)
    {
      emit_insn (gen_movhi_internal_noload (operands[0], operands[1]));
      DONE;
    }
})

(define_insn "*movhi_internal"
  [(set (match_operand:HI 0 "nonimmediate_operand" "=r,r,r, Bh,  *f,*r,r")
	(match_operand:HI 1 "move_operand"	   " r,T,Bh,rJ,*r*J,*f,vp"))]
  "(register_operand (operands[0], HImode)
    || reg_or_0_operand (operands[1], HImode))
   && TARGET_HALF"
  { return riscv_output_move (operands[0], operands[1]); }
  [(set_attr "move_type" "move,const,load,store,mtc,mfc,rdvlenb")
   (set_attr "mode" "HI")
   (set_attr "type" "move,move,load,store,mtc,mfc,move")
   (set_attr "ext" "base,base,base,base,f,f,vector")])

;; sc1: when !TARGET_HALF, HImode has no legal single-instruction memory
;; access at all (see the movhi expand's SImode-based load/store synthesis
;; above). This pattern intentionally offers no memory-class alternative:
;; the Bh memory constraint's match_test (TARGET_HALF) is not reliably
;; honored by LRA's alternative-costing heuristic when reloading a spilled
;; pseudo into a *new* memory slot (it happily "chooses" the Bh alternative
;; there, producing an insn that only fails much later at the final
;; check_rtl consistency pass -- see pr108789.c mul()). Omitting the
;; alternative entirely, rather than relying on the constraint's runtime
;; predicate, forces LRA to reload through a register instead, which in
;; turn invokes the movhi expand's synthesis for the actual memory access.
;; The yr,yr (NORA_REGS) alternative is required, not just a nice-to-have:
;; a plain reg-reg alternative restricted to "r" (GR_REGS) alone leaves LRA
;; unable to converge when a HImode pseudo's live range crosses a call insn
;; (which clobbers ra, forcing NORA_REGS). Without a same-class copy
;; alternative, LRA's reload-insertion for such a pseudo repeatedly
;; discovers the freshly created GR_REGS copy also needs NORA_REGS, spawns
;; another GR_REGS copy to fix it, discovers *that* also needs NORA_REGS,
;; and so on -- an unbounded chain that trips the "maximum number of
;; generated reload insns per insn" safety valve (see pr108789.c mul()).
;; The old *movhi_internal (with its Bh memory alternative) accidentally
;; avoided this by letting LRA escape into an (invalid, for !TARGET_HALF)
;; memory operand instead, trading this infinite loop for the original
;; check_rtl ICE. yr,yr gives LRA a real, valid same-class alternative so
;; the narrowing converges in one step. yr,yr is listed FIRST: LRA's
;; alternative costing gives it the exact same cost as the plain =r,r
;; alternative (both are "free" reg-reg copies), and on a tie LRA picks
;; whichever alternative comes first -- so =r,r first would keep winning
;; the tie and the narrowing-loop would still fire.
;;
;; Even with yr,yr converging the class-narrowing case, a *different*
;; infinite loop remains possible: a HImode move between two not-yet
;; hard-reg-assigned pseudos, where the destination structurally needs
;; NORA_REGS, can hit LRA's own move-cycle heuristic (lra-constraints.cc,
;; "Cycle danger: overall += LRA_MAX_REJECT") on EVERY register
;; alternative at once, because that heuristic specifically targets
;; register-to-register move insns and neither alternative's operands have
;; "won" a hard register yet. With no non-register alternative to fall
;; back to, LRA has no escape and keeps re-splitting the move into a fresh
;; register copy forever, tripping the "maximum number of generated reload
;; insns" safety valve (see pr108789.c mul(), -O1). The mem alternatives
;; below (r,m and m,r) restore a real escape valve, without reintroducing
;; the original Bh bug, by only ever being reachable post-reload (the
;; movhi expand above always intercepts genuine source-level memory moves
;; first) and by synthesizing the access as an aligned SImode load/store
;; plus AND/OR masking -- no shift required, because STACK_SLOT_ALIGNMENT
;; (riscv.h) forces HImode stack/spill slots to full-word alignment when
;; !TARGET_HALF, so the bit offset within the containing word is always a
;; compile-time 0. That matters because shifting by a run-time offset
;; would itself need loop-based synthesis (new pseudos), illegal
;; post-reload; a fixed offset of 0 needs none.
(define_insn_and_split "movhi_internal_noload"
  [(set (match_operand:HI 0 "nonimmediate_operand" "=yr, r, r,  r,  m")
	(match_operand:HI 1 "general_operand"        " yr, r, T,  m,  r"))
   (clobber (match_scratch:SI 2                     "= X, X, X, &r, &r"))
   (clobber (match_scratch:SI 3                     "= X, X, X,  X, &r"))]
  "(register_operand (operands[0], HImode)
    || reg_or_0_operand (operands[1], HImode))
   && !TARGET_HALF"
  {
    switch (which_alternative)
      {
      case 0: case 1: case 2:
	return riscv_output_move (operands[0], operands[1]);
      case 3: case 4:
	return "#";
      default:
	gcc_unreachable ();
      }
  }
  "&& reload_completed
   && (MEM_P (operands[0]) || MEM_P (operands[1]))"
  [(const_int 0)]
{
  rtx mem = MEM_P (operands[0]) ? operands[0] : operands[1];
  rtx word_mem = adjust_address_nv (mem, SImode, 0);

  if (MEM_P (operands[1]))
    {
      /* Fill: dst = word & 0xFFFF.  */
      rtx dst_si = gen_rtx_REG (SImode, REGNO (operands[0]));
      emit_move_insn (operands[2], word_mem);
      emit_move_insn (dst_si, GEN_INT (0xFFFF));
      emit_insn (gen_andsi3 (dst_si, operands[2], dst_si));
    }
  else
    {
      /* Spill: word = (word & ~0xFFFF) | (src & 0xFFFF).  */
      rtx src_si = gen_rtx_REG (SImode, REGNO (operands[1]));
      emit_move_insn (operands[2], word_mem);
      emit_move_insn (operands[3], GEN_INT (-65536)); /* ~0xFFFF */
      emit_insn (gen_andsi3 (operands[2], operands[2], operands[3]));
      emit_move_insn (operands[3], GEN_INT (0xFFFF));
      emit_insn (gen_andsi3 (operands[3], src_si, operands[3]));
      emit_insn (gen_iorsi3 (operands[2], operands[2], operands[3]));
      emit_move_insn (word_mem, operands[2]);
    }
  DONE;
}
  [(set_attr "move_type" "move,move,const,load,store")
   (set_attr "mode" "HI")
   (set_attr "type" "move,move,move,load,store")])

;; HImode constant generation; see riscv_move_integer for details.
;; si+si->hi without truncation is legal because of
;; TARGET_TRULY_NOOP_TRUNCATION.

(define_insn "*add<mode>hi3"
  [(set (match_operand:HI            0 "register_operand" "=r,r")
	(plus:HI (match_operand:HISI 1 "register_operand" " r,r")
		 (match_operand:HISI 2 "arith_operand"    " r,I")))]
  ""
  "add%i2%~\t%0,%1,%2"
  [(set_attr "type" "arith")
   (set_attr "mode" "HI")])

;; Named entry point for the "xorhi3" optab. GCC's bit-field lowering
;; (expmed.cc) can emit a bare (set (reg:HI) (xor:HI reg imm)) directly
;; during expand -- long before combine ever runs -- when a compound
;; assignment (e.g. "b.field ^= imm") lands entirely within a HImode
;; storage unit (this is the same "safe narrow-mode RMW" trick that
;; produces the analogous *add<mode>hi3 insn above). That bare shape has
;; no clobbers, so it can only ever match a plain 2-operand insn --
;; *xorhi3_noxor below (whose match_scratch clobbers only combine can add
;; post-hoc) can never recognize it. Intercept here and lower directly via
;; SImode synthesis using ordinary pseudo registers, which is safe this
;; early (pre-reload, pre-combine). When TARGET_XOR, FAIL so the generic
;; expand_binop fallback builds the same raw insn as before, which the
;; native *xor<mode>hi3 pattern below matches unchanged.
(define_expand "xorhi3"
  [(set (match_operand:HI 0 "register_operand")
        (xor:HI (match_operand:HI 1 "register_operand")
                (match_operand:HI 2 "arith_operand")))]
  ""
{
  if (TARGET_XOR)
    FAIL;

  rtx op1 = gen_lowpart (SImode, operands[1]);
  rtx op2 = CONST_INT_P (operands[2])
	    ? gen_int_mode (INTVAL (operands[2]), SImode)
	    : gen_lowpart (SImode, operands[2]);
  rtx ab_and = gen_reg_rtx (SImode);
  rtx result = gen_reg_rtx (SImode);
  emit_insn (gen_andsi3 (ab_and, op1, op2));
  emit_insn (gen_iorsi3 (result, op1, op2));
  emit_insn (gen_subsi3 (result, result, ab_and));
  emit_move_insn (operands[0], gen_lowpart (HImode, result));
  DONE;
})

(define_insn "*xor<mode>hi3"
  [(set (match_operand:HI 0 "register_operand"           "=r,r")
	(xor:HI (match_operand:HISI 1 "register_operand" " r,r")
		(match_operand:HISI 2 "arith_operand"    " r,I")))]
  "TARGET_XOR"
  "xor%i2\t%0,%1,%2"
  [(set_attr "type" "logical")
   (set_attr "mode" "HI")])

;; expmed.cc's "safe narrow-mode RMW" bitfield-lowering optimization
;; constructs a bare (set (reg:HI) (xor:HI reg imm)) directly during EXPAND,
;; without ever consulting the "xorhi3" named expand above (confirmed: that
;; expand's synthesis body is simply never reached for this path) and with
;; no clobbers attached. recog_memoized can only match an insn's pattern
;; against an EXACT rtx shape -- it never adds missing clobbers on its own
;; (only combine's recog_for_combine does that, via its own explicit
;; add_clobbers step) -- so a clobber-requiring pattern like *xorhi3_noxor
;; below can never match this bare insn.
;;
;; Since this pattern carries no clobbers, RTL dump forensics (grepping
;; -fdump-rtl-all for a failing case) showed it can survive UNSPLIT all the
;; way through combine, split1, ira and reload, only actually splitting at
;; split2 (post-reload) -- so, unlike the comment that used to be here, the
;; split body must NOT call gen_reg_rtx/force_reg (illegal post-reload).
;; Instead it uses the same zero-scratch, in-place technique as *xorsi3_noxor
;; below: a XOR b = a + b - 2*(a&b), computed entirely within operand 0
;; (constrained "=&r" so it's guaranteed distinct from operands 1/2) while
;; operand 1 is read but never written. For a CONST_INT operand 2, the
;; immediate is first materialized into operand 0 via a plain move (always
;; legal, no new pseudo), then AND is performed register-register (always
;; native, unlike AND-with-immediate/ANDI which is gated by TARGET_ANDI and
;; whose own synthesis would need a fresh pseudo) -- the final ADD then
;; references the immediate rtx directly, since native ADDI always accepts
;; an immediate operand.
(define_insn_and_split "*xorhi3_noxor_bare"
  [(set (match_operand:HI 0 "register_operand" "=&r")
        (xor:HI (match_operand:HISI 1 "register_operand" "r")
                (match_operand:HISI 2 "arith_operand" "rI")))]
  "!TARGET_XOR && !TARGET_64BIT"
  "#"
  "!TARGET_XOR && !TARGET_64BIT"
  [(const_int 0)]
{
  rtx op0 = gen_lowpart (SImode, operands[0]);
  rtx op1 = gen_lowpart (SImode, operands[1]);
  if (CONST_INT_P (operands[2]))
    {
      rtx imm = gen_int_mode (INTVAL (operands[2]), SImode);
      emit_move_insn (op0, imm);
      emit_insn (gen_andsi3 (op0, op1, op0));
      emit_insn (gen_addsi3 (op0, op0, op0));
      emit_insn (gen_subsi3 (op0, op1, op0));
      emit_insn (gen_addsi3 (op0, op0, imm));
    }
  else
    {
      rtx op2 = gen_lowpart (SImode, operands[2]);
      emit_insn (gen_andsi3 (op0, op1, op2));
      emit_insn (gen_addsi3 (op0, op0, op0));
      emit_insn (gen_subsi3 (op0, op1, op0));
      emit_insn (gen_addsi3 (op0, op0, op2));
    }
  DONE;
})

;; HImode XOR synthesis when !TARGET_XOR: force operand2 to a register
;; and apply the identity a XOR b = (a | b) - (a & b).
;;
;; Unlike *xorhi3_noxor_bare above, this variant carries its own
;; match_scratch clobbers, so it exists to match instances where those
;; clobbers HAVE already been attached -- namely when combine reconstructs
;; this shape from a bitfield sequence and adds the clobbers itself via
;; recog_for_combine, possibly after reload_completed. The split body must
;; not call gen_reg_rtx or force_reg for that reason. The two match_scratch
;; operands below get real hard registers allocated during this insn's own,
;; original LRA pass (same technique as movhi_internal_noload above), so
;; they are available no matter when the split fires: operand 3 holds
;; operand 2's value if it is a CONST_INT (materialized via a plain move
;; instead of force_reg), and operand 4 holds the AND intermediate. The
;; final OR is computed directly into operand 0 (already =&r, so distinct
;; from operands 1/2) instead of needing a third scratch, then the SUB
;; overwrites it in place with the final result.
(define_insn_and_split "*xorhi3_noxor"
  [(set (match_operand:HI 0 "register_operand" "=&r")
        (xor:HI (match_operand:HISI 1 "register_operand" "r")
                (match_operand:HISI 2 "arith_operand" "rI")))
   (clobber (match_scratch:SI 3 "=&r"))
   (clobber (match_scratch:SI 4 "=&r"))]
  "!TARGET_XOR && !TARGET_64BIT"
  "#"
  "!TARGET_XOR && !TARGET_64BIT"
  [(const_int 0)]
{
  rtx op1 = gen_lowpart (SImode, operands[1]);
  rtx op2;
  if (CONST_INT_P (operands[2]))
    {
      emit_move_insn (operands[3], gen_int_mode (INTVAL (operands[2]), SImode));
      op2 = operands[3];
    }
  else
    op2 = gen_lowpart (SImode, operands[2]);
  rtx op0 = gen_lowpart (SImode, operands[0]);
  rtx ab_and = operands[4];
  emit_insn (gen_andsi3 (ab_and, op1, op2));
  emit_insn (gen_iorsi3 (op0, op1, op2));
  emit_insn (gen_subsi3 (op0, op0, ab_and));
  DONE;
})

;; 8-bit Integer moves

(define_expand "movqi"
  [(set (match_operand:QI 0 "")
	(match_operand:QI 1 ""))]
  ""
{
  /* sc1 synthesis: sb addr, rs → lw aligned; clear byte; or in value; sw */
  if (!TARGET_BYTE && MEM_P (operands[0]))
    {
      rtx addr      = force_reg (SImode, XEXP (operands[0], 0));
      rtx t_neg4    = gen_reg_rtx (SImode);
      emit_move_insn (t_neg4, GEN_INT (-4));
      rtx t_aligned = gen_reg_rtx (SImode);
      emit_insn (gen_andsi3 (t_aligned, addr, t_neg4));

      /* bit_off = (addr & 3) << 3  → 0, 8, 16, or 24 */
      rtx t3        = gen_reg_rtx (SImode);
      emit_move_insn (t3, GEN_INT (3));
      rtx t_boff    = gen_reg_rtx (SImode);
      emit_insn (gen_andsi3 (t_boff, addr, t3));
      rtx t_bit_off = gen_reg_rtx (SImode);
      emit_insn (gen_ashlsi3 (t_bit_off, t_boff, GEN_INT (3)));

      /* Load aligned word */
      rtx t_word    = gen_reg_rtx (SImode);
      emit_move_insn (t_word, gen_rtx_MEM (SImode, t_aligned));

      /* mask = 0xFF << bit_off; word &= ~mask */
      rtx t_mask    = gen_reg_rtx (SImode);
      emit_move_insn (t_mask, GEN_INT (0xFF));
      emit_insn (gen_ashlsi3 (t_mask, t_mask, t_bit_off));
      rtx t_nmask   = gen_reg_rtx (SImode);
      emit_insn (gen_one_cmplsi2 (t_nmask, t_mask));
      emit_insn (gen_andsi3 (t_word, t_word, t_nmask));

      /* val = (src & 0xFF) << bit_off; word |= val */
      rtx t_val     = gen_reg_rtx (SImode);
      emit_move_insn (t_val, GEN_INT (0xFF));
      emit_insn (gen_andsi3 (t_val,
                             gen_lowpart (SImode, force_reg (QImode, operands[1])),
                             t_val));
      emit_insn (gen_ashlsi3 (t_val, t_val, t_bit_off));
      emit_insn (gen_iorsi3 (t_word, t_word, t_val));

      emit_move_insn (gen_rtx_MEM (SImode, t_aligned), t_word);
      DONE;
    }
  /* sc1 synthesis: lbu rd, addr → lw aligned; lshr by bit_off; mask 0xFF */
  if (!TARGET_BYTE && MEM_P (operands[1]))
    {
      rtx addr      = force_reg (SImode, XEXP (operands[1], 0));
      rtx t_neg4    = gen_reg_rtx (SImode);
      emit_move_insn (t_neg4, GEN_INT (-4));
      rtx t_aligned = gen_reg_rtx (SImode);
      emit_insn (gen_andsi3 (t_aligned, addr, t_neg4));
      rtx t_word    = gen_reg_rtx (SImode);
      emit_move_insn (t_word, gen_rtx_MEM (SImode, t_aligned));

      /* bit_off = (addr & 3) << 3  → 0, 8, 16, or 24 */
      rtx t3        = gen_reg_rtx (SImode);
      emit_move_insn (t3, GEN_INT (3));
      rtx t_boff    = gen_reg_rtx (SImode);
      emit_insn (gen_andsi3 (t_boff, addr, t3));
      rtx t_bit_off = gen_reg_rtx (SImode);
      emit_insn (gen_ashlsi3 (t_bit_off, t_boff, GEN_INT (3)));

      rtx t_shifted = gen_reg_rtx (SImode);
      emit_insn (gen_lshrsi3 (t_shifted, t_word, t_bit_off));

      rtx t_mask    = gen_reg_rtx (SImode);
      emit_move_insn (t_mask, GEN_INT (0xFF));
      rtx t_result  = gen_reg_rtx (SImode);
      emit_insn (gen_andsi3 (t_result, t_shifted, t_mask));
      emit_move_insn (operands[0], gen_lowpart (QImode, t_result));
      DONE;
    }
  if (riscv_legitimize_move (QImode, operands[0], operands[1]))
    DONE;
  /* sc1: same rationale as the movhi expand's equivalent intercept above --
     route every remaining register/constant QImode move through the full
     movqi_internal_noload generator explicitly so the insn is born with
     its required match_scratch clobbers already present, instead of
     falling through to this expand's implicit clobber-less auto-emit.  */
  if (!TARGET_BYTE)
    {
      emit_insn (gen_movqi_internal_noload (operands[0], operands[1]));
      DONE;
    }
})

(define_insn "*movqi_internal"
  [(set (match_operand:QI 0 "nonimmediate_operand" "=r,r,r, Bq,  *f,*r,r")
	(match_operand:QI 1 "move_operand"         " r,I,Bq,rJ,*r*J,*f,vp"))]
  "(register_operand (operands[0], QImode)
    || reg_or_0_operand (operands[1], QImode))
   && TARGET_BYTE"
  { return riscv_output_move (operands[0], operands[1]); }
  [(set_attr "move_type" "move,const,load,store,mtc,mfc,rdvlenb")
   (set_attr "mode" "QI")
   (set_attr "type" "move,move,load,store,mtc,mfc,move")
   (set_attr "ext" "base,base,base,base,f,f,vector")])

;; sc1: same rationale as movhi_internal_noload above, for QImode/TARGET_BYTE
;; -- the yr,yr alternative is required to let LRA converge when a QImode
;; pseudo's live range crosses a call insn (needs NORA_REGS), and it must
;; be listed FIRST so it wins ties against =r,r (see movhi_internal_noload).
;; The r,m and m,r alternatives are the same LRA move-cycle escape valve as
;; movhi_internal_noload, with the same post-reload-only, shift-free,
;; aligned-word AND/OR synthesis (STACK_SLOT_ALIGNMENT forces QImode
;; stack/spill slots to full-word alignment too when !TARGET_BYTE).
(define_insn_and_split "movqi_internal_noload"
  [(set (match_operand:QI 0 "nonimmediate_operand" "=yr, r, r,  r,  m")
	(match_operand:QI 1 "general_operand"        " yr, r, I,  m,  r"))
   (clobber (match_scratch:SI 2                     "= X, X, X, &r, &r"))
   (clobber (match_scratch:SI 3                     "= X, X, X,  X, &r"))]
  "(register_operand (operands[0], QImode)
    || reg_or_0_operand (operands[1], QImode))
   && !TARGET_BYTE"
  {
    switch (which_alternative)
      {
      case 0: case 1: case 2:
	return riscv_output_move (operands[0], operands[1]);
      case 3: case 4:
	return "#";
      default:
	gcc_unreachable ();
      }
  }
  "&& reload_completed
   && (MEM_P (operands[0]) || MEM_P (operands[1]))"
  [(const_int 0)]
{
  rtx mem = MEM_P (operands[0]) ? operands[0] : operands[1];
  rtx word_mem = adjust_address_nv (mem, SImode, 0);

  if (MEM_P (operands[1]))
    {
      /* Fill: dst = word & 0xFF.  */
      rtx dst_si = gen_rtx_REG (SImode, REGNO (operands[0]));
      emit_move_insn (operands[2], word_mem);
      emit_move_insn (dst_si, GEN_INT (0xFF));
      emit_insn (gen_andsi3 (dst_si, operands[2], dst_si));
    }
  else
    {
      /* Spill: word = (word & ~0xFF) | (src & 0xFF).  */
      rtx src_si = gen_rtx_REG (SImode, REGNO (operands[1]));
      emit_move_insn (operands[2], word_mem);
      emit_move_insn (operands[3], GEN_INT (-256)); /* ~0xFF */
      emit_insn (gen_andsi3 (operands[2], operands[2], operands[3]));
      emit_move_insn (operands[3], GEN_INT (0xFF));
      emit_insn (gen_andsi3 (operands[3], src_si, operands[3]));
      emit_insn (gen_iorsi3 (operands[2], operands[2], operands[3]));
      emit_move_insn (word_mem, operands[2]);
    }
  DONE;
}
  [(set_attr "move_type" "move,move,const,load,store")
   (set_attr "mode" "QI")
   (set_attr "type" "move,move,move,load,store")])

;; 32-bit floating point moves

(define_expand "movsf"
  [(set (match_operand:SF 0 "")
	(match_operand:SF 1 ""))]
  ""
{
  if (riscv_legitimize_move (SFmode, operands[0], operands[1]))
    DONE;
})

(define_insn "*movsf_hardfloat"
  [(set (match_operand:SF 0 "nonimmediate_operand" "=f,   f,f,f,m,m,*f,*r,  *r,*r,*m")
	(match_operand:SF 1 "move_operand"         " f,zfli,G,m,f,G,*r,*f,*G*r,*m,*r"))]
  "TARGET_HARD_FLOAT
   && (register_operand (operands[0], SFmode)
       || reg_or_0_operand (operands[1], SFmode))"
  { return riscv_output_move (operands[0], operands[1]); }
  [(set_attr "move_type" "fmove,fmove,mtc,fpload,fpstore,store,mtc,mfc,move,load,store")
   (set_attr "type" "fmove,fmove,mtc,fpload,fpstore,store,mtc,mfc,move,load,store")
   (set_attr "mode" "SF")])

(define_insn "*movsf_softfloat"
  [(set (match_operand:SF 0 "nonimmediate_operand" "= r,r,m")
	(match_operand:SF 1 "move_operand"         " Gr,m,r"))]
  "!TARGET_HARD_FLOAT
   && (register_operand (operands[0], SFmode)
       || reg_or_0_operand (operands[1], SFmode))"
  { return riscv_output_move (operands[0], operands[1]); }
  [(set_attr "move_type" "move,load,store")
   (set_attr "type" "move,load,store")
   (set_attr "mode" "SF")])

;; 64-bit floating point moves

(define_expand "movdf"
  [(set (match_operand:DF 0 "")
	(match_operand:DF 1 ""))]
  ""
{
  if (riscv_legitimize_move (DFmode, operands[0], operands[1]))
    DONE;
})


;; In RV32, we lack fmv.x.d and fmv.d.x.  Go through memory instead.
;; (However, we can still use fcvt.d.w to zero a floating-point register.)
(define_insn "*movdf_hardfloat_rv32"
  [(set (match_operand:DF 0 "nonimmediate_operand" "=f,   f,f,f,m,m,*zmvf,*zmvr,  *r,*r,*th_m_noi")
	(match_operand:DF 1 "move_operand"         " f,zfli,G,m,f,G,*zmvr,*zmvf,*r*G,*th_m_noi,*r"))]
  "!TARGET_64BIT && TARGET_DOUBLE_FLOAT
   && (register_operand (operands[0], DFmode)
       || reg_or_0_operand (operands[1], DFmode))"
  { return riscv_output_move (operands[0], operands[1]); }
  [(set_attr "move_type" "fmove,fmove,mtc,fpload,fpstore,store,mtc,mfc,move,load,store")
   (set_attr "type" "fmove,fmove,mtc,fpload,fpstore,store,mtc,mfc,move,load,store")
   (set_attr "mode" "DF")])

(define_insn "*movdf_hardfloat_rv64"
  [(set (match_operand:DF 0 "nonimmediate_operand" "=f,   f,f,f,m,m,*f,*r,  *r,*r,*m")
	(match_operand:DF 1 "move_operand"         " f,zfli,G,m,f,G,*r,*f,*r*G,*m,*r"))]
  "TARGET_64BIT && TARGET_DOUBLE_FLOAT
   && (register_operand (operands[0], DFmode)
       || reg_or_0_operand (operands[1], DFmode))"
  { return riscv_output_move (operands[0], operands[1]); }
  [(set_attr "move_type" "fmove,fmove,mtc,fpload,fpstore,store,mtc,mfc,move,load,store")
   (set_attr "type" "fmove,fmove,mtc,fpload,fpstore,store,mtc,mfc,move,load,store")
   (set_attr "mode" "DF")])

(define_insn "*movdf_softfloat"
  [(set (match_operand:DF 0 "nonimmediate_operand" "= r,r, m")
	(match_operand:DF 1 "move_operand"         " rG,m,rG"))]
  "!TARGET_DOUBLE_FLOAT
   && (register_operand (operands[0], DFmode)
       || reg_or_0_operand (operands[1], DFmode))"
  { return riscv_output_move (operands[0], operands[1]); }
  [(set_attr "move_type" "move,load,store")
   (set_attr "type" "fmove,fpload,fpstore")
   (set_attr "mode" "DF")])

(define_insn "movsidf2_low_rv32"
  [(set (match_operand:SI      0 "register_operand" "=  r")
	(unspec:SI
	    [(match_operand:DF 1 "register_operand" "zmvf")]
	UNSPEC_FMV_X_W))]
  "TARGET_HARD_FLOAT && !TARGET_64BIT && TARGET_ZFA"
  "fmv.x.w\t%0,%1"
  [(set_attr "move_type" "fmove")
   (set_attr "type" "fmove")
   (set_attr "mode" "DF")])


(define_insn "movsidf2_high_rv32"
  [(set (match_operand:SI      0 "register_operand" "=  r")
	(unspec:SI
	    [(match_operand:DF 1 "register_operand" "zmvf")]
	UNSPEC_FMVH_X_D))]
  "TARGET_HARD_FLOAT && !TARGET_64BIT && TARGET_ZFA"
  "fmvh.x.d\t%0,%1"
  [(set_attr "move_type" "fmove")
   (set_attr "type" "fmove")
   (set_attr "mode" "DF")])

(define_insn "movdfsisi3_rv32"
  [(set (match_operand:DF      0 "register_operand"    "=  f")
	(plus:DF
            (match_operand:SI 2 "register_operand"     "zmvr")
            (ashift:SI
                (match_operand:SI 1 "register_operand" "zmvr")
                (const_int 32))))]
  "TARGET_HARD_FLOAT && !TARGET_64BIT && TARGET_ZFA"
  "fmvp.d.x\t%0,%2,%1"
  [(set_attr "move_type" "fmove")
   (set_attr "type" "fmove")
   (set_attr "mode" "DF")])

(define_split
  [(set (match_operand:MOVE64 0 "nonimmediate_operand")
	(match_operand:MOVE64 1 "move_operand"))]
  "reload_completed
   && riscv_split_64bit_move_p (operands[0], operands[1])"
  [(const_int 0)]
{
  riscv_split_doubleword_move (operands[0], operands[1]);
  DONE;
})

(define_expand "cmpmemsi"
  [(parallel [(set (match_operand:SI 0)
               (compare:SI (match_operand:BLK 1)
                           (match_operand:BLK 2)))
	      (use (match_operand:SI 3))
	      (use (match_operand:SI 4))])]
  "!optimize_size"
{
  /* If TARGET_VECTOR is false, this routine will return false and we will
     try scalar expansion.  */
  if (riscv_vector::expand_vec_cmpmem (operands[0], operands[1],
				       operands[2], operands[3]))
    DONE;

  rtx temp = gen_reg_rtx (word_mode);
  if (riscv_expand_block_compare (temp, operands[1], operands[2],
                                  operands[3]))
    {
      if (TARGET_64BIT)
	{
	  temp = gen_lowpart (SImode, temp);
	  SUBREG_PROMOTED_VAR_P (temp) = 1;
	  SUBREG_PROMOTED_SET (temp, SRP_SIGNED);
	}
      emit_move_insn (operands[0], temp);
      DONE;
    }
  else
    FAIL;
})

(define_expand "cpymem<mode>"
  [(parallel [(set (match_operand:BLK 0 "general_operand")
		   (match_operand:BLK 1 "general_operand"))
	      (use (match_operand:P 2 ""))
	      (use (match_operand:SI 3 "const_int_operand"))])]
  ""
{
  if (riscv_expand_block_move (operands[0], operands[1], operands[2]))
    DONE;
  else
    FAIL;
})

;; Fill memory with constant byte.
;; Argument 0 is the destination
;; Argument 1 is the constant byte
;; Argument 2 is the length
;; Argument 3 is the alignment

(define_expand "setmem<mode>"
  [(parallel [(set (match_operand:BLK 0 "memory_operand")
		   (match_operand:QI 2 "nonmemory_operand"))
	      (use (match_operand:P 1 ""))
	      (use (match_operand:SI 3 "const_int_operand"))])]
 ""
{
  /* If TARGET_VECTOR is false, this routine will return false and we will
     try scalar expansion.  */
  if (riscv_vector::expand_vec_setmem (operands[0], operands[1], operands[2]))
    DONE;

  /* If value to set is not zero, use the library routine.  */
  if (operands[2] != const0_rtx)
    FAIL;

  if (riscv_expand_block_clear (operands[0], operands[1]))
    DONE;
  else
    FAIL;
})

(define_expand "movmem<mode>"
  [(parallel [(set (match_operand:BLK 0 "general_operand")
   (match_operand:BLK 1 "general_operand"))
    (use (match_operand:P 2 "const_int_operand"))
    (use (match_operand:SI 3 "const_int_operand"))])]
  "TARGET_VECTOR"
{
  if (riscv_vector::expand_block_move (operands[0], operands[1], operands[2],
				       true))
    DONE;
  else
    FAIL;
})

;; Expand in-line code to clear the instruction cache between operand[0] and
;; operand[1].
(define_expand "clear_cache"
  [(match_operand 0 "pmode_register_operand")
   (match_operand 1 "pmode_register_operand")]
  ""
{
#ifdef ICACHE_FLUSH_FUNC
  emit_library_call (gen_rtx_SYMBOL_REF (Pmode, ICACHE_FLUSH_FUNC),
		     LCT_NORMAL, VOIDmode, operands[0], Pmode,
		     operands[1], Pmode, const0_rtx, Pmode);
#else
  if (TARGET_ZIFENCEI)
    emit_insn (gen_fence_i ());
#endif
  DONE;
})

(define_insn "fence"
  [(unspec_volatile [(const_int 0)] UNSPECV_FENCE)]
  ""
  "%|fence%-"
  [(set_attr "type" "atomic")])

(define_insn "fence_i"
  [(unspec_volatile [(const_int 0)] UNSPECV_FENCE_I)]
  "TARGET_ZIFENCEI"
  "fence.i"
  [(set_attr "type" "atomic")])

(define_insn "riscv_pause"
  [(unspec_volatile [(const_int 0)] UNSPECV_PAUSE)]
  ""
  "* return TARGET_ZIHINTPAUSE ? \"pause\" : \".insn\t0x0100000f\";"
  [(set_attr "type" "atomic")])

;;
;;  ....................
;;
;;	SHIFTS
;;
;;  ....................

;; Use a QImode shift count, to avoid generating sign or zero extend
;; instructions for shift counts, and to avoid dropping subregs.
;; expand_shift_1 can do this automatically when SHIFT_COUNT_TRUNCATED is
;; defined, but use of that is discouraged.

(define_insn "*<optab>si3"
  [(set (match_operand:SI     0 "register_operand" "= r")
	(any_shift:SI
	    (match_operand:SI 1 "register_operand" "  r")
	    (match_operand:QI 2 "arith_operand"    " rI")))]
  "TARGET_SHIFT"
{
  if (GET_CODE (operands[2]) == CONST_INT)
    operands[2] = GEN_INT (INTVAL (operands[2])
			   & (GET_MODE_BITSIZE (SImode) - 1));

  return "<insn>%i2%~\t%0,%1,%2";
}
  [(set_attr "type" "shift")
   (set_attr "mode" "SI")])

;; Fallback: recognize (ashift:SI reg const_int) when !TARGET_SHIFT so that
;; the combine pass can reconstruct this pattern without causing an unrecognizable-
;; insn ICE in vregs.  Split post-reload using the destination for intermediate
;; values (no new pseudos needed for constant shifts).
(define_insn_and_split "*ashlsi3_noshift"
  [(set (match_operand:SI 0 "register_operand" "=r")
	(ashift:SI (match_operand:SI 1 "register_operand" "r")
		   (match_operand 2 "const_int_operand")))]
  "!TARGET_SHIFT"
  "#"
  "!TARGET_SHIFT"
  [(const_int 0)]
{
  HOST_WIDE_INT shamt = INTVAL (operands[2]) & 31;
  if (shamt == 0)
    {
      emit_move_insn (operands[0], operands[1]);
      DONE;
    }
  emit_insn (gen_addsi3 (operands[0], operands[1], operands[1]));
  for (HOST_WIDE_INT i = 1; i < shamt; i++)
    emit_insn (gen_addsi3 (operands[0], operands[0], operands[0]));
  DONE;
})

;; Fallback: recognize (not:SI reg) when !TARGET_XOR so the combine pass can
;; reconstruct this from the two-instruction synthesis (sub x0,rs; addi -1)
;; without triggering a vregs ICE.  No scratch needed: dest serves as both
;; intermediate and result (sub overwrites op1 only when op0==op1, which is
;; semantically correct for ~x = -x - 1).
(define_insn_and_split "*one_cmplsi2_noxor"
  [(set (match_operand:SI 0 "register_operand" "=r")
        (not:SI (match_operand:SI 1 "register_operand" "r")))]
  "!TARGET_XOR && !TARGET_64BIT"
  "#"
  "!TARGET_XOR && !TARGET_64BIT"
  [(const_int 0)]
{
  emit_insn (gen_subsi3 (operands[0], const0_rtx, operands[1]));
  emit_insn (gen_addsi3 (operands[0], operands[0], GEN_INT (-1)));
  DONE;
})

;; Fallback: recognize (xor:SI reg reg) when !TARGET_XOR so that combine
;; cannot cause a vregs ICE.  Uses the identity XOR(a,b) = a + b - 2*(a&b),
;; which is exact in modular arithmetic because (a|b) - (a&b) never borrows
;; across bit positions.  Sequenced to use only op0 as scratch (early-clobber):
;;   op0 = op1 & op2   (t = a & b)
;;   op0 = op0 + op0   (t = 2*(a&b))
;;   op0 = op1 - op0   (t = a - 2*(a&b))
;;   op0 = op0 + op2   (result = a + b - 2*(a&b) = a XOR b)
(define_insn_and_split "*xorsi3_noxor"
  [(set (match_operand:SI 0 "register_operand" "=&r")
        (xor:SI (match_operand:SI 1 "register_operand" "r")
                (match_operand:SI 2 "register_operand" "r")))]
  "!TARGET_XOR && !TARGET_64BIT"
  "#"
  "!TARGET_XOR && !TARGET_64BIT"
  [(const_int 0)]
{
  emit_insn (gen_andsi3 (operands[0], operands[1], operands[2]));
  emit_insn (gen_addsi3 (operands[0], operands[0], operands[0]));
  emit_insn (gen_subsi3 (operands[0], operands[1], operands[0]));
  emit_insn (gen_addsi3 (operands[0], operands[0], operands[2]));
  DONE;
})

;; Post-reload split patterns for rvsc1 shift synthesis.
;;
;; The synthesis loops allocate several pseudo-registers as temporaries.
;; When these expands run before IRA, IRA sees the temporaries as pseudos
;; with live ranges confined to the synthesis loop body.  Outer variables
;; (from inlined callers) have live-range holes inside those loops, and IRA
;; exploits those holes by assigning synthesis temporaries to the outer
;; variables' registers, silently corrupting them.
;;
;; The fix: present each synthesis as a SINGLE opaque instruction to IRA,
;; with (clobber (match_scratch ...)) operands declaring which physical
;; registers the synthesis will use.  IRA then allocates those scratch
;; registers so they cannot conflict with any outer variable's live range.
;; After reload_completed the split fires and generates the full synthesis
;; using the pre-allocated hard registers (operands[3], [4], ...).
;;
;; The split bodies always use the runtime path for computing in_mask
;; (1 << shift) because the shift count is forced to a register by the
;; define_expand before reaching these patterns.  ANDI synthesis is avoided
;; by loading the mask constant into a scratch first, then using reg-reg AND.

;; LSHIFTRT synthesis — 4 scratch registers.
(define_insn_and_split "lshrsi3_sc1"
  [(set (match_operand:SI 0 "register_operand" "=&yt")
        (lshiftrt:SI (match_operand:SI 1 "register_operand"  "r")
                     (match_operand:SI 2 "register_operand"  "r")))
   (clobber (match_scratch:SI 3 "=&yt"))
   (clobber (match_scratch:SI 4 "=&yt"))
   (clobber (match_scratch:SI 5 "=&yt"))
   (clobber (match_scratch:SI 6 "=&yt"))]
  "!TARGET_SHIFT"
  "#"
  "reload_completed"
  [(const_int 0)]
{
  rtx rs1         = operands[1];
  rtx out_mask    = operands[3];
  rtx in_mask     = operands[4];
  rtx tmp         = operands[5];
  rtx shift_count = operands[6];

  emit_move_insn (operands[0], const0_rtx);
  emit_move_insn (out_mask,    const1_rtx);

  /* in_mask = 1 << (op2 & 31): countdown loop.
     Use register-form AND (li + and) to avoid ANDI synthesis post-reload.  */
  emit_move_insn (shift_count, GEN_INT (31));
  emit_insn (gen_andsi3 (shift_count, operands[2], shift_count));
  emit_move_insn (in_mask, const1_rtx);

  rtx sll_done = gen_label_rtx ();
  rtx sll_loop = gen_label_rtx ();

  emit_cmp_and_jump_insns (shift_count, const0_rtx, EQ, NULL_RTX,
                            SImode, 0, sll_done,
                            profile_probability::uninitialized ());
  emit_label (sll_loop);
  emit_insn (gen_addsi3 (in_mask,     in_mask,     in_mask));
  emit_insn (gen_addsi3 (shift_count, shift_count, GEN_INT (-1)));
  emit_cmp_and_jump_insns (shift_count, const0_rtx, EQ, NULL_RTX,
                            SImode, 0, sll_done,
                            profile_probability::uninitialized ());
  emit_jump_insn (gen_jump (sll_loop));
  emit_barrier ();
  emit_label (sll_done);

  /* Bit-by-bit extraction: test each input bit, copy to result. */
  rtx loop_label = gen_label_rtx ();
  rtx skip_label = gen_label_rtx ();
  rtx done_label = gen_label_rtx ();

  emit_label (loop_label);
  emit_cmp_and_jump_insns (in_mask, const0_rtx, EQ, NULL_RTX,
                            SImode, 0, done_label,
                            profile_probability::uninitialized ());
  emit_insn (gen_andsi3 (tmp, rs1, in_mask));
  emit_cmp_and_jump_insns (tmp, const0_rtx, EQ, NULL_RTX,
                            SImode, 0, skip_label,
                            profile_probability::uninitialized ());
  emit_insn (gen_iorsi3 (operands[0], operands[0], out_mask));
  emit_label (skip_label);
  emit_insn (gen_addsi3 (out_mask, out_mask, out_mask));
  emit_insn (gen_addsi3 (in_mask,  in_mask,  in_mask));
  emit_jump_insn (gen_jump (loop_label));
  emit_barrier ();
  emit_label (done_label);

  DONE;
}
  [(set_attr "type" "arith")])

;; LSHIFTRT-by-constant synthesis — 3 scratch registers (no runtime loop
;; counter needed since the shift amount is known at split time).  Matching
;; a const_int operand 2 also lets this pattern double as the combine-
;; reconstruction safety net (see *ashlsi3_noshift above) for LSHIFTRT.
(define_insn_and_split "lshrsi3_sc1_const"
  [(set (match_operand:SI 0 "register_operand" "=&yt")
        (lshiftrt:SI (match_operand:SI 1 "register_operand"  "r")
                     (match_operand    2 "const_int_operand")))
   (clobber (match_scratch:SI 3 "=&yt"))
   (clobber (match_scratch:SI 4 "=&yt"))
   (clobber (match_scratch:SI 5 "=&yt"))]
  "!TARGET_SHIFT"
  "#"
  "reload_completed"
  [(const_int 0)]
{
  rtx rs1 = operands[1];
  HOST_WIDE_INT shamt = INTVAL (operands[2]) & 31;

  if (shamt == 0)
    {
      emit_move_insn (operands[0], rs1);
      DONE;
    }

  rtx out_mask = operands[3];
  rtx in_mask  = operands[4];
  rtx tmp      = operands[5];

  emit_move_insn (operands[0], const0_rtx);
  emit_move_insn (out_mask,    const1_rtx);

  /* in_mask = 1 << shamt, unrolled at split time. */
  emit_move_insn (in_mask, const1_rtx);
  for (HOST_WIDE_INT i = 0; i < shamt; i++)
    emit_insn (gen_addsi3 (in_mask, in_mask, in_mask));

  /* Bit-by-bit extraction for the remaining (32 - shamt) output bits.
     The per-bit test is data-dependent and still needs a forward
     conditional branch; only the loop CONTROL is eliminated. */
  for (HOST_WIDE_INT i = shamt; i < 32; i++)
    {
      rtx skip_label = gen_label_rtx ();
      emit_insn (gen_andsi3 (tmp, rs1, in_mask));
      emit_cmp_and_jump_insns (tmp, const0_rtx, EQ, NULL_RTX,
                                SImode, 0, skip_label,
                                profile_probability::uninitialized ());
      emit_insn (gen_iorsi3 (operands[0], operands[0], out_mask));
      emit_label (skip_label);
      if (i != 31)
        {
          emit_insn (gen_addsi3 (out_mask, out_mask, out_mask));
          emit_insn (gen_addsi3 (in_mask,  in_mask,  in_mask));
        }
    }

  DONE;
}
  [(set_attr "type" "arith")])

;; ASHIFTRT synthesis — 8 scratch registers.
(define_insn_and_split "ashrsi3_sc1"
  [(set (match_operand:SI 0 "register_operand" "=&yt")
        (ashiftrt:SI (match_operand:SI 1 "register_operand"  "r")
                     (match_operand:SI 2 "register_operand"  "r")))
   (clobber (match_scratch:SI 3  "=&yt"))
   (clobber (match_scratch:SI 4  "=&yt"))
   (clobber (match_scratch:SI 5  "=&yt"))
   (clobber (match_scratch:SI 6  "=&yt"))
   (clobber (match_scratch:SI 7  "=&yt"))
   (clobber (match_scratch:SI 8  "=&yt"))
   (clobber (match_scratch:SI 9  "=&yt"))
   (clobber (match_scratch:SI 10 "=&yt"))]
  "!TARGET_SHIFT"
  "#"
  "reload_completed"
  [(const_int 0)]
{
  rtx rs1          = operands[1];
  rtx out_mask     = operands[3];
  rtx in_mask      = operands[4];
  rtx tmp          = operands[5];
  rtx sign_bit     = operands[6];
  rtx shift_masked = operands[7];
  rtx counter2     = operands[8];
  rtx n_sll2       = operands[9];
  rtx sign_mask2   = operands[10];

  /* Save sign bit (use li+and to avoid ANDI with large immediate). */
  if (!TARGET_LUI)
    {
      /* sc0: lui unavailable and pool forbidden post-reload.
	 riscv_emit_const_no_lui writes only into sign_bit.  */
      riscv_emit_const_no_lui (SImode, sign_bit, HOST_WIDE_INT_1 << 31);
      emit_insn (gen_andsi3 (sign_bit, rs1, sign_bit));
    }
  else
    {
      emit_move_insn (sign_bit, gen_int_mode (0x80000000UL, SImode));
      emit_insn (gen_andsi3 (sign_bit, rs1, sign_bit));
    }

  /* Inline SRL synthesis. */
  emit_move_insn (operands[0], const0_rtx);
  emit_move_insn (out_mask,    const1_rtx);

  /* in_mask = 1 << (op2 & 31): use register-form AND and countdown loop.  */
  emit_move_insn (shift_masked, GEN_INT (31));
  emit_insn (gen_andsi3 (shift_masked, operands[2], shift_masked));
  emit_move_insn (in_mask, const1_rtx);

  rtx sll_done2 = gen_label_rtx ();
  rtx sll_loop2 = gen_label_rtx ();

  emit_cmp_and_jump_insns (shift_masked, const0_rtx, EQ, NULL_RTX,
                            SImode, 0, sll_done2,
                            profile_probability::uninitialized ());
  emit_move_insn (counter2, shift_masked);
  emit_label (sll_loop2);
  emit_insn (gen_addsi3 (in_mask,  in_mask,  in_mask));
  emit_insn (gen_addsi3 (counter2, counter2, GEN_INT (-1)));
  emit_cmp_and_jump_insns (counter2, const0_rtx, EQ, NULL_RTX,
                            SImode, 0, sll_done2,
                            profile_probability::uninitialized ());
  emit_jump_insn (gen_jump (sll_loop2));
  emit_barrier ();
  emit_label (sll_done2);

  rtx loop2_label = gen_label_rtx ();
  rtx skip2_label = gen_label_rtx ();
  rtx srl2_done   = gen_label_rtx ();

  emit_label (loop2_label);
  emit_cmp_and_jump_insns (in_mask, const0_rtx, EQ, NULL_RTX,
                            SImode, 0, srl2_done,
                            profile_probability::uninitialized ());
  emit_insn (gen_andsi3 (tmp, rs1, in_mask));
  emit_cmp_and_jump_insns (tmp, const0_rtx, EQ, NULL_RTX,
                            SImode, 0, skip2_label,
                            profile_probability::uninitialized ());
  emit_insn (gen_iorsi3 (operands[0], operands[0], out_mask));
  emit_label (skip2_label);
  emit_insn (gen_addsi3 (out_mask, out_mask, out_mask));
  emit_insn (gen_addsi3 (in_mask,  in_mask,  in_mask));
  emit_jump_insn (gen_jump (loop2_label));
  emit_barrier ();
  emit_label (srl2_done);

  /* If rs1 was non-negative, srl == sra: done. */
  rtx done2_label = gen_label_rtx ();
  emit_cmp_and_jump_insns (sign_bit, const0_rtx, EQ, NULL_RTX,
                            SImode, 0, done2_label,
                            profile_probability::uninitialized ());

  /* shift_masked == 0 → sra(x,0) is identity; no sign bits to fill. */
  emit_cmp_and_jump_insns (shift_masked, const0_rtx, EQ, NULL_RTX,
                            SImode, 0, done2_label,
                            profile_probability::uninitialized ());

  /* sign_mask = 0xFFFFFFFF << (32 - shift_masked): build via SLL loop. */
  emit_insn (gen_subsi3 (n_sll2, const0_rtx, shift_masked));  /* -shift */
  emit_insn (gen_addsi3 (n_sll2, n_sll2, GEN_INT (32)));      /* 32-shift */
  emit_move_insn (sign_mask2, constm1_rtx);

  rtx ext2_loop = gen_label_rtx ();
  rtx ext2_done = gen_label_rtx ();
  emit_label (ext2_loop);
  emit_insn (gen_addsi3 (sign_mask2, sign_mask2, sign_mask2));
  emit_insn (gen_addsi3 (n_sll2,     n_sll2,     GEN_INT (-1)));
  emit_cmp_and_jump_insns (n_sll2, const0_rtx, EQ, NULL_RTX,
                            SImode, 0, ext2_done,
                            profile_probability::uninitialized ());
  emit_jump_insn (gen_jump (ext2_loop));
  emit_barrier ();
  emit_label (ext2_done);
  emit_insn (gen_iorsi3 (operands[0], operands[0], sign_mask2));

  emit_label (done2_label);
  DONE;
}
  [(set_attr "type" "arith")])

;; ASHIFTRT-by-constant synthesis — 5 scratch registers (out_mask, in_mask,
;; tmp, sign_bit, sign_mask; no shift_masked/counter2/n_sll2 needed since
;; shamt is resolved at split time).  Also serves as the combine-
;; reconstruction safety net for ASHIFTRT.  Handles shamt==0 internally
;; (moved out of the dispatching expand, for symmetry with
;; lshrsi3_sc1_const).
(define_insn_and_split "ashrsi3_sc1_const"
  [(set (match_operand:SI 0 "register_operand" "=&yt")
        (ashiftrt:SI (match_operand:SI 1 "register_operand"  "r")
                     (match_operand    2 "const_int_operand")))
   (clobber (match_scratch:SI 3 "=&yt"))
   (clobber (match_scratch:SI 4 "=&yt"))
   (clobber (match_scratch:SI 5 "=&yt"))
   (clobber (match_scratch:SI 6 "=&yt"))
   (clobber (match_scratch:SI 7 "=&yt"))]
  "!TARGET_SHIFT"
  "#"
  "reload_completed"
  [(const_int 0)]
{
  rtx rs1 = operands[1];
  HOST_WIDE_INT shamt = INTVAL (operands[2]) & 31;

  if (shamt == 0)
    {
      emit_move_insn (operands[0], rs1);
      DONE;
    }

  rtx out_mask  = operands[3];
  rtx in_mask   = operands[4];
  rtx tmp       = operands[5];
  rtx sign_bit  = operands[6];
  rtx sign_mask = operands[7];

  /* Save sign bit (use li+and to avoid ANDI with a large immediate). */
  if (!TARGET_LUI)
    {
      /* sc0: lui unavailable and pool forbidden post-reload.
	 riscv_emit_const_no_lui writes only into sign_bit.  */
      riscv_emit_const_no_lui (SImode, sign_bit, HOST_WIDE_INT_1 << 31);
      emit_insn (gen_andsi3 (sign_bit, rs1, sign_bit));
    }
  else
    {
      emit_move_insn (sign_bit, gen_int_mode (0x80000000UL, SImode));
      emit_insn (gen_andsi3 (sign_bit, rs1, sign_bit));
    }

  /* Inline SRL synthesis, unrolled at split time. */
  emit_move_insn (operands[0], const0_rtx);
  emit_move_insn (out_mask,    const1_rtx);

  emit_move_insn (in_mask, const1_rtx);
  for (HOST_WIDE_INT i = 0; i < shamt; i++)
    emit_insn (gen_addsi3 (in_mask, in_mask, in_mask));

  for (HOST_WIDE_INT i = shamt; i < 32; i++)
    {
      rtx skip_label = gen_label_rtx ();
      emit_insn (gen_andsi3 (tmp, rs1, in_mask));
      emit_cmp_and_jump_insns (tmp, const0_rtx, EQ, NULL_RTX,
                                SImode, 0, skip_label,
                                profile_probability::uninitialized ());
      emit_insn (gen_iorsi3 (operands[0], operands[0], out_mask));
      emit_label (skip_label);
      if (i != 31)
        {
          emit_insn (gen_addsi3 (out_mask, out_mask, out_mask));
          emit_insn (gen_addsi3 (in_mask,  in_mask,  in_mask));
        }
    }

  /* If rs1 was non-negative, srl == sra: done.  (shamt != 0 here, handled
     above, so if rs1 is negative there are sign-extension bits to fill.)  */
  rtx done_label = gen_label_rtx ();
  emit_cmp_and_jump_insns (sign_bit, const0_rtx, EQ, NULL_RTX,
                            SImode, 0, done_label,
                            profile_probability::uninitialized ());

  /* sign_mask = 0xFFFFFFFF << (32 - shamt), unrolled at split time. */
  emit_move_insn (sign_mask, constm1_rtx);
  for (HOST_WIDE_INT i = 0; i < 32 - shamt; i++)
    emit_insn (gen_addsi3 (sign_mask, sign_mask, sign_mask));
  emit_insn (gen_iorsi3 (operands[0], operands[0], sign_mask));

  emit_label (done_label);
  DONE;
}
  [(set_attr "type" "arith")])

;; Variable ASHIFT synthesis — 1 scratch register for the countdown.
(define_insn_and_split "ashlsi3_sc1_var"
  [(set (match_operand:SI 0 "register_operand" "=&yt")
        (ashift:SI (match_operand:SI 1 "register_operand"  "r")
                   (match_operand:SI 2 "register_operand"  "r")))
   (clobber (match_scratch:SI 3 "=&yt"))]
  "!TARGET_SHIFT"
  "#"
  "reload_completed"
  [(const_int 0)]
{
  rtx count = operands[3];

  /* count = op2 & 31 (register-form AND to avoid ANDI post-reload). */
  emit_move_insn (count, GEN_INT (31));
  emit_insn (gen_andsi3 (count, operands[2], count));

  emit_move_insn (operands[0], operands[1]);

  rtx sll_done_label = gen_label_rtx ();
  rtx sll_loop_label = gen_label_rtx ();

  emit_cmp_and_jump_insns (count, const0_rtx, EQ, NULL_RTX,
                            SImode, 0, sll_done_label,
                            profile_probability::uninitialized ());
  emit_label (sll_loop_label);
  emit_insn (gen_addsi3 (operands[0], operands[0], operands[0]));
  emit_insn (gen_addsi3 (count,       count,       GEN_INT (-1)));
  emit_cmp_and_jump_insns (count, const0_rtx, EQ, NULL_RTX,
                            SImode, 0, sll_done_label,
                            profile_probability::uninitialized ());
  emit_jump_insn (gen_jump (sll_loop_label));
  emit_barrier ();
  emit_label (sll_done_label);

  DONE;
}
  [(set_attr "type" "arith")])

(define_expand "<optab>si3"
  [(set (match_operand:SI     0 "register_operand" "= r")
       (any_shift:SI (match_operand:SI 1 "register_operand" "  r")
                (match_operand:QI 2 "arith_operand"    " rI")))]
  ""
{
  if (TARGET_64BIT)
    {
      rtx t = gen_reg_rtx (DImode);
      emit_insn (gen_<optab>si3_extend (t, operands[1], operands[2]));
      t = gen_lowpart (SImode, t);
      SUBREG_PROMOTED_VAR_P (t) = 1;
      SUBREG_PROMOTED_SET (t, SRP_SIGNED);
      emit_move_insn (operands[0], t);
      DONE;
    }
  /* sc1 synthesis: constant sll n via n repeated add (double = shift-left-1). */
  if ((<CODE>) == ASHIFT && !TARGET_SHIFT && CONST_INT_P (operands[2]))
    {
      HOST_WIDE_INT shamt = INTVAL (operands[2]) & 31;
      if (shamt == 0)
	{
	  emit_move_insn (operands[0], operands[1]);
	  DONE;
	}
      rtx tmp = gen_reg_rtx (SImode);
      emit_insn (gen_addsi3 (tmp, operands[1], operands[1]));
      for (HOST_WIDE_INT i = 1; i < shamt; i++)
	emit_insn (gen_addsi3 (tmp, tmp, tmp));
      emit_move_insn (operands[0], tmp);
      DONE;
    }
  /* sc1 synthesis: variable sll via post-reload split (ashlsi3_sc1_var). */
  if ((<CODE>) == ASHIFT && !TARGET_SHIFT)
    {
      rtx cnt = force_reg (SImode, gen_lowpart (SImode, operands[2]));
      emit_insn (gen_ashlsi3_sc1_var (operands[0], operands[1], cnt));
      DONE;
    }
  /* sc1 synthesis: constant srl unrolled at split time (lshrsi3_sc1_const);
     variable srl via runtime-loop post-reload split (lshrsi3_sc1). */
  if ((<CODE>) == LSHIFTRT && !TARGET_SHIFT)
    {
      if (CONST_INT_P (operands[2]))
	{
	  emit_insn (gen_lshrsi3_sc1_const (operands[0], operands[1],
					     operands[2]));
	  DONE;
	}
      rtx cnt = force_reg (SImode, gen_lowpart (SImode, operands[2]));
      emit_insn (gen_lshrsi3_sc1 (operands[0], operands[1], cnt));
      DONE;
    }
  /* sc1 synthesis: constant sra unrolled at split time (ashrsi3_sc1_const,
     which also handles the shamt==0 identity case); variable sra via
     runtime-loop post-reload split (ashrsi3_sc1). */
  if ((<CODE>) == ASHIFTRT && !TARGET_SHIFT)
    {
      if (CONST_INT_P (operands[2]))
	{
	  emit_insn (gen_ashrsi3_sc1_const (operands[0], operands[1],
					     operands[2]));
	  DONE;
	}
      rtx cnt = force_reg (SImode, gen_lowpart (SImode, operands[2]));
      emit_insn (gen_ashrsi3_sc1 (operands[0], operands[1], cnt));
      DONE;
    }
})

(define_insn "<optab>di3"
  [(set (match_operand:DI 0 "register_operand"     "= r")
	(any_shift:DI
	    (match_operand:DI 1 "register_operand" "  r")
	    (match_operand:QI 2 "arith_operand"    " rI")))]
  "TARGET_64BIT"
{
  if (GET_CODE (operands[2]) == CONST_INT)
    operands[2] = GEN_INT (INTVAL (operands[2])
			   & (GET_MODE_BITSIZE (DImode) - 1));

  return "<insn>%i2\t%0,%1,%2";
}
  [(set_attr "type" "shift")
   (set_attr "mode" "DI")])

(define_insn "*<optab><GPR:mode>3_mask_1"
  [(set (match_operand:GPR     0 "register_operand" "= r")
	(any_shift:GPR
	    (match_operand:GPR 1 "register_operand" "  r")
	    (match_operator 4 "subreg_lowpart_operator"
	     [(and:GPR2
	       (match_operand:GPR2 2 "register_operand"  "r")
	       (match_operand 3 "<GPR:shiftm1>"))])))]
  ""
{
  /* If the shift mode is not word mode, then it must be the
     case that we're generating rv64 code, but this is a 32-bit
     operation.  Thus we need to use the "w" variant.  */
  if (E_<GPR:MODE>mode != word_mode)
    return "<insn>w\t%0,%1,%2";
  return "<insn>\t%0,%1,%2";
}
  [(set_attr "type" "shift")
   (set_attr "mode" "<GPR:MODE>")])

(define_insn "<optab>si3_extend"
  [(set (match_operand:DI                   0 "register_operand" "= r")
	(sign_extend:DI
	    (any_shift:SI (match_operand:SI 1 "register_operand" "  r")
			  (match_operand:QI 2 "arith_operand"    " rI"))))]
  "TARGET_64BIT"
{
  if (GET_CODE (operands[2]) == CONST_INT)
    operands[2] = GEN_INT (INTVAL (operands[2]) & 0x1f);

  return "<insn>%i2w\t%0,%1,%2";
}
  [(set_attr "type" "shift")
   (set_attr "mode" "SI")])

(define_insn "*<optab>si3_extend_mask"
  [(set (match_operand:DI                   0 "register_operand" "= r")
	(sign_extend:DI
	    (any_shift:SI
	     (match_operand:SI 1 "register_operand" "  r")
	     (match_operator 4 "subreg_lowpart_operator"
	      [(and:GPR
	        (match_operand:GPR 2 "register_operand" " r")
	        (match_operand 3 "const_si_mask_operand"))]))))]
  "TARGET_64BIT"
  "<insn>w\t%0,%1,%2"
  [(set_attr "type" "shift")
   (set_attr "mode" "SI")])

;; We can reassociate the shift and bitwise operator which may allow us to
;; reduce the immediate operand of the bitwise operator into a range that
;; fits in a simm12.
;;
;; We need to make sure that shifting does not lose any bits, particularly
;; for IOR/XOR.  It probably doesn't matter for AND.
;;
;; We also don't want to do this if the immediate already fits in a simm12
;; field, or it is a single bit operand and zbs is available.
(define_insn_and_split "<optab>_shift_reverse<X:mode>"
  [(set (match_operand:X 0 "register_operand" "=r")
    (any_bitwise:X (ashift:X (match_operand:X 1 "register_operand" "r")
			     (match_operand 2 "immediate_operand" "n"))
		   (match_operand 3 "immediate_operand" "n")))]
  "(!SMALL_OPERAND (INTVAL (operands[3]))
    && SMALL_OPERAND (INTVAL (operands[3]) >> INTVAL (operands[2]))
    && (!TARGET_ZBS || popcount_hwi (INTVAL (operands[3])) > 1)
    && (INTVAL (operands[3]) & ((1ULL << INTVAL (operands[2])) - 1)) == 0)"
  "#"
  "&& 1"
  [(set (match_dup 0) (any_bitwise:X (match_dup 1) (match_dup 3)))
   (set (match_dup 0) (ashift:X (match_dup 0) (match_dup 2)))]
  {
    operands[3] = GEN_INT (INTVAL (operands[3]) >> INTVAL (operands[2]));
  }
  [(set_attr "type" "shift")
   (set_attr "mode" "<X:MODE>")])

;; Non-canonical, but can be formed by ree when combine is not successful at
;; producing one of the two canonical patterns below.
(define_insn "*lshrsi3_zero_extend_1"
  [(set (match_operand:DI                   0 "register_operand" "=r")
	(zero_extend:DI
	 (lshiftrt:SI (match_operand:SI     1 "register_operand" " r")
		      (match_operand        2 "const_int_operand"))))]
  "TARGET_64BIT && (INTVAL (operands[2]) & 0x1f) > 0"
{
  operands[2] = GEN_INT (INTVAL (operands[2]) & 0x1f);

  return "srliw\t%0,%1,%2";
}
  [(set_attr "type" "shift")
   (set_attr "mode" "SI")])

;; Canonical form for a sign/zero-extend of a logical right shift.
;; Special case: extract MSB bits of lower 32-bit word
(define_insn "*lshrsi3_extend_2"
  [(set (match_operand:DI                   0 "register_operand" "=r")
	(any_extract:DI (match_operand:DI  1 "register_operand" " r")
			 (match_operand     2 "const_int_operand")
			 (match_operand     3 "const_int_operand")))]
  "(TARGET_64BIT && (INTVAL (operands[3]) > 0)
    && (INTVAL (operands[2]) + INTVAL (operands[3]) == 32))"
{
  return "<extract_sidi_shift>\t%0,%1,%3";
}
  [(set_attr "type" "shift")
   (set_attr "mode" "SI")])

;; Canonical form for a zero-extend of a logical right shift when the
;; shift count is 31.
(define_insn "*lshrsi3_zero_extend_3"
  [(set (match_operand:DI                   0 "register_operand" "=r")
	(lt:DI (match_operand:SI            1 "register_operand" " r")
	       (const_int 0)))]
  "TARGET_64BIT"
{
  return "srliw\t%0,%1,31";
}
  [(set_attr "type" "shift")
   (set_attr "mode" "SI")])

;; Canonical form for a extend of a logical shift right (sign/zero extraction).
;; Special cases, that are ignored (handled elsewhere):
;; * Single-bit extraction (Zbs/XTheadBs)
;; * Single-bit extraction (Zicondops/XVentanaCondops)
;; * Single-bit extraction (SFB)
;; * Extraction instruction th.ext(u) (XTheadBb)
;; * lshrsi3_extend_2 (see above)
(define_insn_and_split "*<any_extract:optab><GPR:mode>3"
  [(set (match_operand:GPR 0 "register_operand" "=r")
	 (any_extract:GPR
       (match_operand:GPR 1 "register_operand" " r")
       (match_operand     2 "const_int_operand")
       (match_operand     3 "const_int_operand")))
   (clobber (match_scratch:GPR  4 "=&r"))]
  "TARGET_SHIFT
   && !((TARGET_ZBS || TARGET_XTHEADBS || TARGET_ZICOND
         || TARGET_XVENTANACONDOPS || TARGET_SFB_ALU)
        && (INTVAL (operands[2]) == 1))
   && !TARGET_XTHEADBB
   && !TARGET_XANDESPERF
   && !(TARGET_64BIT
        && (INTVAL (operands[3]) > 0)
        && (INTVAL (operands[2]) + INTVAL (operands[3]) == 32))"
  "#"
  "&& reload_completed"
  [(set (match_dup 4)
     (ashift:GPR (match_dup 1) (match_dup 2)))
   (set (match_dup 0)
     (<extract_shift>:GPR (match_dup 4) (match_dup 3)))]
{
  int regbits = GET_MODE_BITSIZE (GET_MODE (operands[0])).to_constant ();
  int sizebits = INTVAL (operands[2]);
  int startbits = INTVAL (operands[3]);
  int lshamt = regbits - sizebits - startbits;
  int rshamt = lshamt + startbits;
  operands[2] = GEN_INT (lshamt);
  operands[3] = GEN_INT (rshamt);
}
  [(set_attr "type" "shift")
   (set_attr "mode" "<GPR:MODE>")])

;; Handle AND with 2^N-1 for N from 12 to XLEN.  This can be split into
;; two logical shifts.  Otherwise it requires 3 instructions: lui,
;; xor/addi/srli, and.

;; Generating a temporary for the shift output gives better combiner results;
;; and also fixes a problem where op0 could be a paradoxical reg and shifting
;; by amounts larger than the size of the SUBREG_REG doesn't work.
(define_split
  [(set (match_operand:GPR 0 "register_operand")
	(and:GPR (match_operand:GPR 1 "register_operand")
		 (match_operand:GPR 2 "p2m1_shift_operand")))
   (clobber (match_operand:GPR 3 "register_operand"))]
  ""
 [(set (match_dup 3)
       (ashift:GPR (match_dup 1) (match_dup 2)))
  (set (match_dup 0)
       (lshiftrt:GPR (match_dup 3) (match_dup 2)))]
{
  /* Op2 is a VOIDmode constant, so get the mode size from op1.  */
  operands[2] = GEN_INT (GET_MODE_BITSIZE (GET_MODE (operands[1])).to_constant ()
			 - exact_log2 (INTVAL (operands[2]) + 1));
})

;; Handle AND with 0xF...F0...0 where there are 32 to 63 zeros.  This can be
;; split into two shifts.  Otherwise it requires 3 instructions: li, sll, and.
(define_split
  [(set (match_operand:DI 0 "register_operand")
	(and:DI (match_operand:DI 1 "register_operand")
		(match_operand:DI 2 "high_mask_shift_operand")))
   (clobber (match_operand:DI 3 "register_operand"))]
  "TARGET_64BIT"
  [(set (match_dup 3)
	(lshiftrt:DI (match_dup 1) (match_dup 2)))
   (set (match_dup 0)
	(ashift:DI (match_dup 3) (match_dup 2)))]
{
  operands[2] = GEN_INT (ctz_hwi (INTVAL (operands[2])));
})

;; Handle SImode to DImode zero-extend combined with a left shift.  This can
;; occur when unsigned int is used for array indexing.  Split this into two
;; shifts.  Otherwise we can get 3 shifts.

(define_insn_and_split "zero_extendsidi2_shifted"
  [(set (match_operand:DI 0 "register_operand" "=r")
	(and:DI (ashift:DI (match_operand:DI 1 "register_operand" "r")
			   (match_operand:QI 2 "immediate_operand" "I"))
		(match_operand 3 "immediate_operand" "")))
   (clobber (match_scratch:DI 4 "=&r"))]
  "TARGET_64BIT && !TARGET_ZBA
   && ((INTVAL (operands[3]) >> INTVAL (operands[2])) == 0xffffffff)"
  "#"
  "&& reload_completed"
  [(set (match_dup 4)
	(ashift:DI (match_dup 1) (const_int 32)))
   (set (match_dup 0)
	(lshiftrt:DI (match_dup 4) (match_dup 5)))]
  "operands[5] = GEN_INT (32 - (INTVAL (operands [2])));"
  [(set_attr "type" "shift")
   (set_attr "mode" "DI")])

;; Handle logical AND feeding an equality test against zero where an operand
;; to the AND is a constant requiring synthesis.  Because we only care about
;; zero/nonzero state afte the AND, we may be able to shift both operands
;; of the AND to the right and eliminate the need for constant synthesis.
;;
;; Once mvconst_internal goes away, this likely turns into a simple splitter.
(define_insn_and_split ""
  [(set (match_operand:X 0 "register_operand" "=r")
	(any_eq:X (and:X (match_operand:X 1 "register_operand" "r")
			 (match_operand 2 "shifted_const_arith_operand"))
		  (const_int 0)))
   (clobber (match_scratch:X 3 "=&r"))]
  "!SMALL_OPERAND (INTVAL (operands[2]))"
  "#"
  "&& reload_completed"
  [(set (match_dup 3) (ashiftrt:X (match_dup 1) (match_dup 4)))
   (set (match_dup 3) (and:X (match_dup 3) (match_dup 2)))
   (set (match_dup 0) (any_eq:X (match_dup 3) (const_int 0)))]
{
  HOST_WIDE_INT shift = ctz_hwi (INTVAL (operands[2]));
  operands[4] = gen_int_mode (shift, QImode);
  operands[2] = gen_int_mode (INTVAL (operands[2]) >> shift, word_mode);
}
  [(set_attr "type" "shift")])

;; The pattern above is a bridge to this pattern.  Essentially a select
;; between 0 and 2^n based on the zero/nonzero status of the AND.
;;
;; It's no fewer instructions, but the resulting code has fewer data
;; dependencies and may compress better depending on 2^n.
(define_insn_and_split ""
  [(set (match_operand:X 0 "register_operand" "=r")
	(ashift:X (any_eq:X
		    (and:X (match_operand:X 1 "register_operand" "r")
			   (match_operand 2 "shifted_const_arith_operand"))
		    (const_int 0))
		  (match_operand 3 "const_int_operand")))
   (clobber (match_scratch:X 4 "=&r"))
   (clobber (match_scratch:X 5 "=&r"))]
  "TARGET_ZICOND && TARGET_ZBS"
  "#"
  "&& reload_completed"
  [(set (match_dup 4) (ashiftrt:X (match_dup 1) (match_dup 6)))
   (set (match_dup 4) (and:X (match_dup 4) (match_dup 2)))
   (set (match_dup 5) (match_dup 3))
   (set (match_dup 0) (if_then_else:X (any_eq:X (match_dup 4) (const_int 0))
				      (match_dup 5)
				      (const_int 0)))]
{
  HOST_WIDE_INT shift = ctz_hwi (INTVAL (operands[2]));
  operands[3] = gen_int_mode (HOST_WIDE_INT_1U << INTVAL (operands[3]), word_mode);
  operands[6] = gen_int_mode (shift, QImode);
  operands[2] = gen_int_mode (INTVAL (operands[2]) >> shift, word_mode);
}
  [(set_attr "type" "shift")])

;;
;;  ....................
;;
;;	CONDITIONAL BRANCHES
;;
;;  ....................

;; Conditional branches

(define_insn_and_split "*branch<ANYI:mode>_shiftedarith_equals_zero"
  [(set (pc)
	(if_then_else (match_operator 1 "equality_operator"
		       [(and:ANYI (match_operand:ANYI 2 "register_operand" "r")
				  (match_operand 3 "shifted_const_arith_operand" "i"))
			(const_int 0)])
	 (label_ref (match_operand 0 "" ""))
	 (pc)))
   (clobber (match_scratch:X 4 "=&r"))]
  "TARGET_SHIFT && !SMALL_OPERAND (INTVAL (operands[3]))"
  "#"
  "&& reload_completed"
  [(set (match_dup 4) (lshiftrt:X (subreg:X (match_dup 2) 0) (match_dup 6)))
   (set (match_dup 4) (match_dup 8))
   (set (pc) (if_then_else (match_op_dup 1 [(match_dup 4) (const_int 0)])
			   (label_ref (match_dup 0)) (pc)))]
{
  HOST_WIDE_INT mask = INTVAL (operands[3]);
  int trailing = ctz_hwi (mask);

  operands[6] = GEN_INT (trailing);
  operands[7] = GEN_INT (mask >> trailing);

  /* This splits after reload, so there's little chance to clean things
     up.  Rather than emit a ton of RTL here, we can just make a new
     operand for that RHS and use it.  For the case where the AND would
     have been redundant, we can make it a NOP move, which does get
     cleaned up.  */
  if (operands[7] == CONSTM1_RTX (word_mode))
    operands[8] = operands[4];
  else
    operands[8] = gen_rtx_AND (word_mode, operands[4], operands[7]);
}
[(set_attr "type" "branch")])

(define_insn_and_split "*branch<ANYI:mode>_shiftedarith_<optab>_shifted"
  [(set (pc)
	(if_then_else (any_eq
		    (and:ANYI (match_operand:ANYI 1 "register_operand" "r")
			  (match_operand 2 "shifted_const_arith_operand" "i"))
		    (match_operand 3 "shifted_const_arith_operand" "i"))
	 (label_ref (match_operand 0 "" ""))
	 (pc)))
   (clobber (match_scratch:X 4 "=&r"))
   (clobber (match_scratch:X 5 "=&r"))]
  "TARGET_SHIFT
    && !SMALL_OPERAND (INTVAL (operands[2]))
    && !SMALL_OPERAND (INTVAL (operands[3]))
    && SMALL_AFTER_COMMON_TRAILING_SHIFT (INTVAL (operands[2]),
					     INTVAL (operands[3]))"
  "#"
  "&& reload_completed"
  [(set (match_dup 4) (ashiftrt:X (match_dup 1) (match_dup 7)))
   (set (match_dup 4) (match_dup 10))
   (set (match_dup 5) (match_dup 9))
   (set (pc) (if_then_else (any_eq (match_dup 4) (match_dup 5))
			   (label_ref (match_dup 0)) (pc)))]
{
  HOST_WIDE_INT mask1 = INTVAL (operands[2]);
  HOST_WIDE_INT mask2 = INTVAL (operands[3]);
  int trailing_shift = COMMON_TRAILING_ZEROS (mask1, mask2);

  operands[7] = GEN_INT (trailing_shift);
  operands[8] = GEN_INT (mask1 >> trailing_shift);
  operands[9] = GEN_INT (mask2 >> trailing_shift);

  /* This splits after reload, so there's little chance to clean things
     up.  Rather than emit a ton of RTL here, we can just make a new
     operand for that RHS and use it.  For the case where the AND would
     have been redundant, we can make it a NOP move, which does get
     cleaned up.  */
  if (operands[8] == CONSTM1_RTX (word_mode))
    operands[10] = operands[4];
  else
    operands[10] = gen_rtx_AND (word_mode, operands[4], operands[8]);
}
[(set_attr "type" "branch")])

(define_insn_and_split "*branch<ANYI:mode>_shiftedmask_equals_zero"
  [(set (pc)
	(if_then_else (match_operator 1 "equality_operator"
		       [(and:ANYI (match_operand:ANYI 2 "register_operand" "r")
				  (match_operand 3 "consecutive_bits_operand" "i"))
			(const_int 0)])
	 (label_ref (match_operand 0 "" ""))
	 (pc)))
   (clobber (match_scratch:X 4 "=&r"))]
  "TARGET_SHIFT
    && (INTVAL (operands[3]) >= 0 || !partial_subreg_p (operands[2]))
    && popcount_hwi (INTVAL (operands[3])) > 1
    && !SMALL_OPERAND (INTVAL (operands[3]))"
  "#"
  "&& reload_completed"
  [(set (match_dup 4) (ashift:X (subreg:X (match_dup 2) 0) (match_dup 6)))
   (set (match_dup 4) (lshiftrt:X (match_dup 4) (match_dup 7)))
   (set (pc) (if_then_else (match_op_dup 1 [(match_dup 4) (const_int 0)])
			   (label_ref (match_dup 0)) (pc)))]
{
	unsigned HOST_WIDE_INT mask = INTVAL (operands[3]);
	int leading  = clz_hwi (mask);
	int trailing = ctz_hwi (mask);

	operands[6] = GEN_INT (leading);
	operands[7] = GEN_INT (leading + trailing);
}
[(set_attr "type" "branch")])

(define_insn "*branch<mode>"
  [(set (pc)
	(if_then_else
	 (match_operator 1 "ordered_comparison_operator"
			 [(match_operand:X 2 "register_operand" "r")
			  (match_operand:X 3 "reg_or_0_operand" "rJ")])
	 (label_ref (match_operand 0 "" ""))
	 (pc)))]
  /* When !TARGET_SLT, the LT/GE/LTU/GEU asm templates embed a full SLT/SLTU
     synthesis using t2/t3/t4 as scratch without declaring RTL clobbers.
     Disallow these codes here so combine cannot replace the cbranch4-emitted
     synthesis+NE sequence with this pattern; those branches stay as properly
     IRA-allocated pseudos feeding a *branch NE insn.  */
  "!TARGET_XCVBI && (TARGET_SLT
   || GET_CODE (operands[1]) == EQ || GET_CODE (operands[1]) == NE)"
{
  if (!TARGET_BNE && GET_CODE (operands[1]) == NE)
    {
      if (!TARGET_LUI)
	/* sc0: lui unavailable; use PC-relative beq zero,zero for the
	   unconditional part.  Valid for short single-function programs.  */
	return "beq\t%2,%z3,1f\n\tbeq\tzero,zero,%l0\n1:";
      /* sc1 NE synthesis: reverse condition to skip over lui+addi+jr.
	 Always 16 bytes; the short beq+beq_zero form is unsafe because GCC
	 branch-shortening can converge at a size where beq zero,zero hits an
	 assembler out-of-range expansion.  Uses t0, not t1: see the "jump"
	 pattern above for why these two scratch registers must stay disjoint
	 from RISCV_CALL_ADDRESS_TEMP (t1).  */
      return "beq\t%2,%z3,1f\n\tlui\tt0,%%hi(%l0)\n\taddi\tt0,t0,%%lo(%l0)\n\tjr\tt0\n1:";
    }

  /* Long-range EQ (length==20): beq to lui-block, then unconditional
     beq zero,zero to skip it, then lui+addi+jr.  Avoids assembler
     bne+jal expansion which uses instructions forbidden by sc1.  */
  if (get_attr_length (insn) == 20)
    return "beq\t%2,%z3,1f\n\tbeq\tzero,zero,2f\n1:\n\tlui\tt0,%%hi(%l0)\n\taddi\tt0,t0,%%lo(%l0)\n\tjr\tt0\n2:";

  /* When !TARGET_SLT, ordered comparisons never reach this insn: the
     condition above requires TARGET_SLT for any code other than EQ/NE, and
     @cbranch<mode>4 (above) intercepts LT/GE/LTU/GEU beforehand, emitting
     its own IRA-allocated SLT/SLTU synthesis into pseudos.  The blocks below
     therefore only ever run with TARGET_SLT set; gcc_unreachable guards the
     case where that invariant is violated.                                */
  if (!TARGET_BGE && GET_CODE (operands[1]) == GE)
    {
      if (!TARGET_SLT)
	/* Unreachable: see @cbranch<mode>4 intercept above.  */
	gcc_unreachable ();
      return "slt\tt0,%2,%z3\n\tbeq\tt0,zero,%l0";
    }

  if (!TARGET_BLT && GET_CODE (operands[1]) == LT)
    {
      if (!TARGET_SLT)
	/* Unreachable: see @cbranch<mode>4 intercept above.  */
	gcc_unreachable ();
      return "slt\tt0,%2,%z3\n\tbeq\tt0,zero,1f\n\tlui\tt0,%%hi(%l0)\n\taddi\tt0,t0,%%lo(%l0)\n\tjr\tt0\n1:";
    }

  if (!TARGET_BGEU && GET_CODE (operands[1]) == GEU)
    {
      if (!TARGET_SLT)
	/* Unreachable: see @cbranch<mode>4 intercept above.  */
	gcc_unreachable ();
      return "sltu\tt0,%2,%z3\n\tbeq\tt0,zero,%l0";
    }

  if (!TARGET_BLTU && GET_CODE (operands[1]) == LTU)
    {
      if (!TARGET_SLT)
	/* Unreachable: see @cbranch<mode>4 intercept above.  */
	gcc_unreachable ();
      return "sltu\tt0,%2,%z3\n\tbeq\tt0,zero,1f\n\tlui\tt0,%%hi(%l0)\n\taddi\tt0,t0,%%lo(%l0)\n\tjr\tt0\n1:";
    }

  if (get_attr_length (insn) == 12)
    return "b%r1\t%2,%z3,1f; jump\t%l0,ra; 1:";

  return "b%C1\t%2,%z3,%l0";
}
  [(set_attr "type" "branch")
   (set_attr "mode" "none")])

;; Combine (and other late passes, e.g. loop exit-test rewriting into a
;; count-down-to-zero sign test) can create a raw ordered-comparison branch
;; on their own -- without ever going through @cbranch<mode>4's expand-time
;; synthesis below. When !TARGET_SLT that shape can't match *branch<mode>
;; above (whose condition excludes every code but EQ/NE unless TARGET_SLT),
;; so it would otherwise be left unrecognizable. Catch it here.
;;
;; Empirically (see gcc.c-torture/execute failures this was written to fix)
;; this shape first appears as late as split2, i.e. *after* reload -- so
;; unlike @cbranch<mode>4's expand-time synthesis, this split cannot use
;; gen_reg_rtx (it would hit the can_create_pseudo_p assert in gen_reg_rtx).
;; It must instead route every temporary through match_scratch operands,
;; which reload allocates real hard registers for regardless of whether the
;; split fires pre- or post-reload. That in turn means it cannot call
;; riscv_emit_slt_synth/riscv_expand_conditional_branch directly, since
;; those go through gen_xorsi3/gen_one_cmplsi2/gen_lshrsi3 -- all of which
;; are synthesized via gen_reg_rtx of their own when !TARGET_XOR/!TARGET_SHIFT
;; (always the case here, since !TARGET_SLT implies both on every target
;; that reaches this pattern). So the same sub/xor/and comparison synthesis
;; is inlined here using explicit scratch registers (via
;; riscv_emit_xor_scratch/riscv_emit_not_scratch for the xor/not steps), and
;; the final "isolate the sign bit" step uses a mask-and (native, via a
;; single lui) instead of a right-shift by 31 (which would need the
;; !TARGET_SHIFT loop synthesis).
(define_insn_and_split "*branch<mode>_slt_synth"
  [(set (pc)
	(if_then_else
	 (match_operator 1 "ordered_comparison_operator"
			 [(match_operand:X 2 "register_operand")
			  (match_operand:X 3 "reg_or_0_operand")])
	 (label_ref (match_operand 0 "" ""))
	 (pc)))
   (clobber (match_scratch:X 4 "=&r"))
   (clobber (match_scratch:X 5 "=&r"))
   (clobber (match_scratch:X 6 "=&r"))
   (clobber (match_scratch:X 7 "=&r"))
   (clobber (match_scratch:X 8 "=&r"))
   (clobber (match_scratch:X 9 "=&r"))
   (clobber (match_scratch:X 10 "=&r"))]
  "!TARGET_XCVBI && !TARGET_SLT
   && GET_CODE (operands[1]) != EQ && GET_CODE (operands[1]) != NE"
  "#"
  "&& reload_completed"
  [(const_int 0)]
{
  rtx op0 = operands[2];
  rtx op1 = operands[3];
  enum rtx_code code = GET_CODE (operands[1]);
  bool use_eq = false;

  switch (code)
    {
    case GT:  std::swap (op0, op1); code = LT;  break;
    case GTU: std::swap (op0, op1); code = LTU; break;
    case GE:  use_eq = true;        code = LT;  break;
    case GEU: use_eq = true;        code = LTU; break;
    case LE:  std::swap (op0, op1); use_eq = true; code = LT;  break;
    case LEU: std::swap (op0, op1); use_eq = true; code = LTU; break;
    default:  break;
    }

  /* Either operand may be the literal 0 (reg_or_0_operand); the swaps
     above can move it into either position.  gen_subsi3's second operand
     and gen_andsi3's first operand both require a real register (not a
     const_int 0), so materialize x0 explicitly rather than relying on
     const0_rtx being accepted everywhere.  */
  if (op0 == CONST0_RTX (<MODE>mode))
    op0 = gen_rtx_REG (<MODE>mode, GP_REG_FIRST);
  if (op1 == CONST0_RTX (<MODE>mode))
    op1 = gen_rtx_REG (<MODE>mode, GP_REG_FIRST);

  rtx diff = operands[4];
  rtx t1   = operands[5];
  rtx t2   = operands[6];
  rtx xa   = operands[7];
  rtx xb   = operands[8];
  rtx result;

  emit_insn (gen_subsi3 (diff, op0, op1));

  if (code == LT)
    {
      /* result = ((a - b) corrected for signed overflow).
	 overflow = (a^b) & (a^diff); corrected = diff ^ overflow.  */
      riscv_emit_xor_scratch (t1, op0, op1, xa, xb);
      riscv_emit_xor_scratch (t2, op0, diff, xa, xb);
      emit_insn (gen_andsi3 (t1, t1, t2));
      riscv_emit_xor_scratch (diff, diff, t1, xa, xb);
      result = diff;
    }
  else
    {
      /* result = borrow.  borrow = (~a & b) | (~(a^b) & diff).  */
      rtx t3 = operands[9];
      riscv_emit_not_scratch (t1, op0);
      emit_insn (gen_andsi3 (t2, t1, op1));
      riscv_emit_xor_scratch (t3, op0, op1, xa, xb);
      riscv_emit_not_scratch (t3, t3);
      emit_insn (gen_andsi3 (t3, t3, diff));
      emit_insn (gen_iorsi3 (t2, t2, t3));
      result = t2;
    }

  rtx mask = operands[10];
  riscv_emit_move (mask, gen_int_mode (0x80000000, <MODE>mode));
  emit_insn (gen_andsi3 (result, result, mask));

  rtx cond = gen_rtx_fmt_ee (use_eq ? EQ : NE, VOIDmode, result, const0_rtx);
  emit_jump_insn (gen_condjump (cond, operands[0]));
  DONE;
}
[(set_attr "type" "branch")])

;; Conditional move and add patterns.

(define_expand "mov<mode>cc"
  [(set (match_operand:GPR 0 "register_operand")
	(if_then_else:GPR (match_operand 1 "comparison_operator")
			  (match_operand:GPR 2 "movcc_operand")
			  (match_operand:GPR 3 "movcc_operand")))]
  "TARGET_SFB_ALU || TARGET_XTHEADCONDMOV || TARGET_ZICOND_LIKE
   || TARGET_MOVCC || TARGET_XMIPSCMOV"
{
  if (riscv_expand_conditional_move (operands[0], operands[1],
				     operands[2], operands[3]))
    DONE;
  else
    FAIL;
})

(define_expand "add<mode>cc"
  [(match_operand:GPR 0 "register_operand")
   (match_operand     1 "comparison_operator")
   (match_operand:GPR 2 "arith_operand")
   (match_operand:GPR 3 "arith_operand")]
  "TARGET_MOVCC"
{
  rtx cmp = operands[1];
  rtx cmp0 = XEXP (cmp, 0);
  rtx cmp1 = XEXP (cmp, 1);
  machine_mode mode0 = GET_MODE (cmp0);

  /* We only handle word mode integer compares for now.  */
  if (INTEGRAL_MODE_P (mode0) && mode0 != word_mode)
    FAIL;

  enum rtx_code code = GET_CODE (cmp);
  rtx reg0 = gen_reg_rtx (<MODE>mode);
  rtx reg1 = gen_reg_rtx (<MODE>mode);
  rtx reg2 = gen_reg_rtx (<MODE>mode);
  bool invert = false;

  if (INTEGRAL_MODE_P (mode0))
    riscv_expand_int_scc (reg0, code, cmp0, cmp1, &invert);
  else if (FLOAT_MODE_P (mode0) && fp_scc_comparison (cmp, GET_MODE (cmp)))
    riscv_expand_float_scc (reg0, code, cmp0, cmp1, &invert);
  else
    FAIL;

  if (invert)
    riscv_emit_binary (PLUS, reg1, reg0, constm1_rtx);
  else
    riscv_emit_unary (NEG, reg1, reg0);
  riscv_emit_binary (AND, reg2, reg1, operands[3]);
  riscv_emit_binary (PLUS, operands[0], reg2, operands[2]);

  DONE;
})

;; Used to implement built-in functions.
(define_expand "condjump"
  [(set (pc)
	(if_then_else (match_operand 0)
		      (label_ref (match_operand 1))
		      (pc)))])

(define_expand "@cbranch<mode>4"
  [(set (pc)
	(if_then_else (match_operator 0 "comparison_operator"
		      [(match_operand:BR 1 "register_operand")
		       (match_operand:BR 2 "nonmemory_operand")])
		      (label_ref (match_operand 3 ""))
		      (pc)))]
  ""
{
  if (!TARGET_SLT && GET_MODE (operands[1]) == SImode)
    {
      enum rtx_code code = GET_CODE (operands[0]);
      if (code != EQ && code != NE)
        {
          rtx op0 = operands[1];
          rtx op1 = force_reg (SImode, operands[2]);
          bool use_eq = false;

          switch (code)
            {
            case GT:  { rtx t = op0; op0 = op1; op1 = t; } code = LT;  break;
            case GTU: { rtx t = op0; op0 = op1; op1 = t; } code = LTU; break;
            case GE:  use_eq = true;                         code = LT;  break;
            case GEU: use_eq = true;                         code = LTU; break;
            case LE:  { rtx t = op0; op0 = op1; op1 = t; } use_eq = true; code = LT;  break;
            case LEU: { rtx t = op0; op0 = op1; op1 = t; } use_eq = true; code = LTU; break;
            default:  break;
            }

          rtx tmp = gen_reg_rtx (SImode);
          riscv_emit_slt_synth (tmp, op0, op1, code == LTU);
          riscv_expand_conditional_branch (operands[3],
                                           use_eq ? EQ : NE,
                                           tmp, const0_rtx);
          DONE;
        }
    }
  riscv_expand_conditional_branch (operands[3], GET_CODE (operands[0]),
				   operands[1], operands[2]);
  DONE;
})

(define_expand "@cbranch<ANYF:mode>4"
  [(parallel [(set (pc)
		   (if_then_else (match_operator 0 "fp_branch_comparison"
				  [(match_operand:ANYF 1 "register_operand")
				   (match_operand:ANYF 2 "register_operand")])
				 (label_ref (match_operand 3 ""))
				 (pc)))
	      (clobber (match_operand 4 ""))])]
  "TARGET_HARD_FLOAT || TARGET_ZFINX"
{
  if (!signed_order_operator (operands[0], GET_MODE (operands[0])))
    {
      riscv_expand_conditional_branch (operands[3], GET_CODE (operands[0]),
				       operands[1], operands[2]);
      DONE;
    }
  operands[4] = gen_reg_rtx (TARGET_64BIT ? DImode : SImode);
})

(define_insn_and_split "*cbranch<ANYF:mode>4"
  [(set (pc)
	(if_then_else (match_operator 1 "fp_native_comparison"
		       [(match_operand:ANYF 2 "register_operand" "f")
			(match_operand:ANYF 3 "register_operand" "f")])
		      (label_ref (match_operand 0 ""))
		      (pc)))
   (clobber (match_operand:X 4 "register_operand" "=r"))]
  "TARGET_HARD_FLOAT || TARGET_ZFINX"
  "#"
  "&& reload_completed"
  [(set (match_dup 4)
	(match_op_dup:X 1 [(match_dup 2) (match_dup 3)]))
   (set (pc)
	(if_then_else (ne:X (match_dup 4) (const_int 0))
		      (label_ref (match_operand 0))
		      (pc)))]
  ""
  [(set_attr "type" "branch")
   (set (attr "length")
	(if_then_else (and (le (minus (match_dup 0) (pc))
			       (const_int 4084))
			   (le (minus (pc) (match_dup 0))
			       (const_int 4096)))
		      (const_int 8)
		      (if_then_else (and (le (minus (match_dup 0) (pc))
					     (const_int 1048564))
					 (le (minus (pc) (match_dup 0))
					     (const_int 1048576)))
				    (const_int 12)
				    (const_int 16))))])

(define_insn_and_split "*cbranch<ANYF:mode>4"
  [(set (pc)
	(if_then_else (match_operator 1 "ne_operator"
		       [(match_operand:ANYF 2 "register_operand" "f")
			(match_operand:ANYF 3 "register_operand" "f")])
		      (label_ref (match_operand 0 ""))
		      (pc)))
   (clobber (match_operand:X 4 "register_operand" "=r"))]
  "TARGET_HARD_FLOAT || TARGET_ZFINX"
  "#"
  "&& reload_completed"
  [(set (match_dup 4)
	(eq:X (match_dup 2) (match_dup 3)))
   (set (pc)
	(if_then_else (eq:X (match_dup 4) (const_int 0))
		      (label_ref (match_operand 0))
		      (pc)))]
  ""
  [(set_attr "type" "branch")
   (set (attr "length")
	(if_then_else (and (le (minus (match_dup 0) (pc))
			       (const_int 4084))
			   (le (minus (pc) (match_dup 0))
			       (const_int 4096)))
		      (const_int 8)
		      (if_then_else (and (le (minus (match_dup 0) (pc))
					     (const_int 1048564))
					 (le (minus (pc) (match_dup 0))
					     (const_int 1048576)))
				    (const_int 12)
				    (const_int 16))))])

;; This pattern's split (below) converts the single-bit test into an
;; ordered (LT/GE-vs-0) sign test after shifting the tested bit into the
;; sign position -- the other 31 bits of the shifted value are garbage, so
;; unlike *branch_on_bit_range<X:mode> below it cannot stay an EQ/NE test.
;; That ordered comparison needs !TARGET_SLT's synthesis, but this split
;; fires "&& reload_completed" (post-reload) and emits the branch as a bare
;; if_then_else with no clobbers, which *branch<mode>_slt_synth's clobbered
;; shape can't match. Rather than duplicating that synthesis here, disable
;; this fast path entirely when !TARGET_SLT: combine then leaves the
;; bit-test as an ordinary AND-with-mask compared with EQ/NE, which
;; *branch<mode> already accepts unconditionally (see its comment above).
(define_insn_and_split "*branch_on_bit<X:mode>"
  [(set (pc)
	(if_then_else
	    (match_operator 0 "equality_operator"
	        [(zero_extract:X (match_operand:X 2 "register_operand" "r")
				 (const_int 1)
				 (match_operand 3 "branch_on_bit_operand"))
				 (const_int 0)])
	    (label_ref (match_operand 1))
	    (pc)))
   (clobber (match_scratch:X 4 "=&r"))]
   "!TARGET_XANDESPERF && TARGET_SLT"
   "#"
   "&& reload_completed"
  [(set (match_dup 4)
	(ashift:X (match_dup 2) (match_dup 3)))
   (set (pc)
	(if_then_else
	    (match_op_dup 0 [(match_dup 4) (const_int 0)])
	    (label_ref (match_operand 1))
	    (pc)))]
{
  int shift = GET_MODE_BITSIZE (<MODE>mode) - 1 - INTVAL (operands[3]);
  operands[3] = GEN_INT (shift);

  if (GET_CODE (operands[0]) == EQ)
    operands[0] = gen_rtx_GE (<MODE>mode, operands[4], const0_rtx);
  else
    operands[0] = gen_rtx_LT (<MODE>mode, operands[4], const0_rtx);
}
[(set_attr "type" "branch")])

(define_insn_and_split "*branch_on_bit_range<X:mode>"
  [(set (pc)
	(if_then_else
	    (match_operator 0 "equality_operator"
		[(zero_extract:X (match_operand:X 2 "register_operand" "r")
				 (match_operand 3 "branch_on_bit_operand")
				 (const_int 0))
				 (const_int 0)])
	    (label_ref (match_operand 1))
	    (pc)))
   (clobber (match_scratch:X 4 "=&r"))]
  ""
  "#"
  "reload_completed"
  [(set (match_dup 4)
	(ashift:X (match_dup 2) (match_dup 3)))
   (set (pc)
	(if_then_else
	    (match_op_dup 0 [(match_dup 4) (const_int 0)])
	    (label_ref (match_operand 1))
	    (pc)))]
{
  operands[3] = GEN_INT (GET_MODE_BITSIZE (<MODE>mode) - INTVAL (operands[3]));
}
[(set_attr "type" "branch")])

;;
;;  ....................
;;
;;	SETTING A REGISTER FROM A COMPARISON
;;
;;  ....................

;; Destination is always set in SI mode.

(define_expand "cstore<mode>4"
  [(set (match_operand:SI 0 "register_operand")
	(match_operator:SI 1 "ordered_comparison_operator"
	    [(match_operand:GPR 2 "register_operand")
	     (match_operand:GPR 3 "nonmemory_operand")]))]
  ""
{
  /* slti/sltiu disabled: force immediate into register so slt/sltu (register
     form) is used instead.  Mirrors the -mori / -mandi pattern. */
  if (TARGET_SLT && !TARGET_SLTI && CONST_INT_P (operands[3]))
    operands[3] = force_reg (GET_MODE (operands[2]), operands[3]);

  if (!TARGET_SLT && GET_MODE (operands[2]) == SImode)
    {
      enum rtx_code code = GET_CODE (operands[1]);
      rtx op0 = operands[2];
      rtx op1 = force_reg (SImode, operands[3]);

      /* EQ/NE: snez(diff) = lshr((diff | -diff), 31); seqz = 1 - snez. */
      if (code == EQ || code == NE)
        {
          rtx diff   = gen_reg_rtx (SImode);
          rtx neg    = gen_reg_rtx (SImode);
          rtx tmp    = gen_reg_rtx (SImode);
          rtx snez_r = gen_reg_rtx (SImode);
          emit_insn (gen_subsi3 (diff, op0, op1));
          emit_insn (gen_subsi3 (neg, const0_rtx, diff));
          emit_insn (gen_iorsi3 (tmp, diff, neg));
          emit_insn (gen_lshrsi3 (snez_r, tmp, GEN_INT (31)));
          if (code == NE)
            emit_move_insn (operands[0], snez_r);
          else
            {
              rtx one = force_reg (SImode, const1_rtx);
              emit_insn (gen_subsi3 (operands[0], one, snez_r));
            }
          DONE;
        }

      bool invert = false;

      /* Normalise to LT or LTU; GT/LE/GE are handled by operand swap + invert. */
      switch (code)
        {
        case GT:  { rtx t = op0; op0 = op1; op1 = t; } code = LT;  break;
        case GTU: { rtx t = op0; op0 = op1; op1 = t; } code = LTU; break;
        case GE:  invert = true;                         code = LT;  break;
        case GEU: invert = true;                         code = LTU; break;
        case LE:  { rtx t = op0; op0 = op1; op1 = t; } invert = true; code = LT;  break;
        case LEU: { rtx t = op0; op0 = op1; op1 = t; } invert = true; code = LTU; break;
        default:  break;
        }

      rtx result = invert ? gen_reg_rtx (SImode) : operands[0];

      riscv_emit_slt_synth (result, op0, op1, code == LTU);

      if (invert)
        {
          /* Invert 0/1: 1 - result avoids XOR synthesis which can produce
             zero_extract RTL that later splits into ashift when !TARGET_SHIFT. */
          rtx one = force_reg (SImode, const1_rtx);
          emit_insn (gen_subsi3 (operands[0], one, result));
        }
      DONE;
    }
  riscv_expand_int_scc (operands[0], GET_CODE (operands[1]), operands[2],
			operands[3]);
  DONE;
})

(define_expand "cstore<mode>4"
  [(set (match_operand:SI 0 "register_operand")
	(match_operator:SI 1 "fp_scc_comparison"
	     [(match_operand:ANYF 2 "register_operand")
	      (match_operand:ANYF 3 "register_operand")]))]
  "TARGET_HARD_FLOAT || TARGET_ZFINX"
{
  riscv_expand_float_scc (operands[0], GET_CODE (operands[1]), operands[2],
			  operands[3]);
  DONE;
})

(define_insn "*cstore<ANYF:mode><X:mode>4"
   [(set (match_operand:X         0 "register_operand" "=r")
	 (match_operator:X 1 "fp_native_comparison"
	     [(match_operand:ANYF 2 "register_operand" " f")
	      (match_operand:ANYF 3 "register_operand" " f")]))]
  "TARGET_HARD_FLOAT || TARGET_ZFINX"
  "f%C1.<fmt>\t%0,%2,%3"
  [(set_attr "type" "fcmp")
   (set_attr "mode" "<UNITMODE>")])

(define_expand "f<quiet_pattern>_quiet<ANYF:mode><X:mode>4"
   [(set (match_operand:X               0 "register_operand")
	 (unspec:X [(match_operand:ANYF 1 "register_operand")
		    (match_operand:ANYF 2 "register_operand")]
		   QUIET_COMPARISON))]
  "TARGET_HARD_FLOAT || TARGET_ZFINX"
{
  rtx op0 = operands[0];
  rtx op1 = operands[1];
  rtx op2 = operands[2];

  if (TARGET_ZFA)
    emit_insn (gen_f<quiet_pattern>_quiet<ANYF:mode><X:mode>4_zfa(op0, op1, op2));
  else
    {
      rtx tmp = gen_reg_rtx (SImode);
      rtx cmp = gen_rtx_<QUIET_PATTERN> (<X:MODE>mode, op1, op2);
      rtx frflags = gen_rtx_UNSPEC_VOLATILE (SImode, gen_rtvec (1, const0_rtx),
					     UNSPECV_FRFLAGS);
      rtx fsflags = gen_rtx_UNSPEC_VOLATILE (SImode, gen_rtvec (1, tmp),
					     UNSPECV_FSFLAGS);

      emit_insn (gen_rtx_SET (tmp, frflags));
      emit_insn (gen_rtx_SET (op0, cmp));
      emit_insn (fsflags);
    }

  if (HONOR_SNANS (<ANYF:MODE>mode))
    emit_insn (gen_rtx_UNSPEC_VOLATILE (<ANYF:MODE>mode,
					gen_rtvec (2, op1, op2),
					UNSPECV_FSNVSNAN));
  DONE;
})

(define_insn "f<quiet_pattern>_quiet<ANYF:mode><X:mode>4_zfa"
   [(set (match_operand:X      0 "register_operand" "=r")
	 (unspec:X
	  [(match_operand:ANYF 1 "register_operand" " f")
	   (match_operand:ANYF 2 "register_operand" " f")]
	  QUIET_COMPARISON))]
  "TARGET_HARD_FLOAT && TARGET_ZFA"
  "f<quiet_pattern>q.<fmt>\t%0,%1,%2"
  [(set_attr "type" "fcmp")
   (set_attr "mode" "<UNITMODE>")
   (set (attr "length") (const_int 16))])

;; fclass instruction output bitmap
;;   0 negative infinity
;;   1 negative normal number.
;;   2 negative subnormal number.
;;   3 -0
;;   4 +0
;;   5 positive subnormal number.
;;   6 positive normal number.
;;   7 positive infinity
;;   8 signaling NaN.
;;   9 quiet NaN

(define_insn "fclass<ANYF:mode><X:mode>"
  [(set (match_operand:X	     0 "register_operand" "=r")
	(unspec [(match_operand:ANYF 1 "register_operand" " f")]
		   UNSPEC_FCLASS))]
  "TARGET_HARD_FLOAT"
  "fclass.<fmt>\t%0,%1";
  [(set_attr "type" "fcmp")
   (set_attr "mode" "<UNITMODE>")])

;; Implements optab for isfinite, isnormal, isinf

(define_int_iterator FCLASS_MASK [126 66 129])
(define_int_attr fclass_optab
  [(126	"isfinite")
   (66	"isnormal")
   (129	"isinf")])

(define_expand "<FCLASS_MASK:fclass_optab><ANYF:mode>2"
  [(match_operand      0 "register_operand" "=r")
   (match_operand:ANYF 1 "register_operand" " f")
   (const_int FCLASS_MASK)]
  "TARGET_HARD_FLOAT"
{
  if (GET_MODE (operands[0]) != SImode
      && GET_MODE (operands[0]) != word_mode)
    FAIL;

  rtx t = gen_reg_rtx (word_mode);
  rtx t_op0 = gen_reg_rtx (word_mode);

  if (TARGET_64BIT)
    emit_insn (gen_fclass<ANYF:mode>di (t, operands[1]));
  else
    emit_insn (gen_fclass<ANYF:mode>si (t, operands[1]));

  riscv_emit_binary (AND, t, t, GEN_INT (<FCLASS_MASK>));
  rtx cmp = gen_rtx_NE (word_mode, t, const0_rtx);
  emit_insn (gen_cstore<mode>4 (t_op0, cmp, t, const0_rtx));

  if (TARGET_64BIT)
    {
      t_op0 = gen_lowpart (SImode, t_op0);
      SUBREG_PROMOTED_VAR_P (t_op0) = 1;
      SUBREG_PROMOTED_SET (t_op0, SRP_SIGNED);
    }

  emit_move_insn (operands[0], t_op0);
  DONE;
})

(define_insn "*seq_zero_<X:mode><GPR:mode>"
  [(set (match_operand:GPR       0 "register_operand" "=r")
	(eq:GPR (match_operand:X 1 "register_operand" " r")
		(const_int 0)))]
  "TARGET_SLT"
  "seqz\t%0,%1"
  [(set_attr "type" "slt")
   (set_attr "mode" "<X:MODE>")])

(define_insn "*sne_zero_<X:mode><GPR:mode>"
  [(set (match_operand:GPR       0 "register_operand" "=r")
	(ne:GPR (match_operand:X 1 "register_operand" " r")
		(const_int 0)))]
  "TARGET_SLT"
  "snez\t%0,%1"
  [(set_attr "type" "slt")
   (set_attr "mode" "<X:MODE>")])

(define_insn "*sgt<u>_<X:mode><GPR:mode>"
  [(set (match_operand:GPR           0 "register_operand" "= r")
	(any_gt:GPR (match_operand:X 1 "register_operand" "  r")
		    (match_operand:X 2 "reg_or_0_operand" " rJ")))]
  "TARGET_SLT"
  "sgt<u>\t%0,%1,%z2"
  [(set_attr "type" "slt")
   (set_attr "mode" "<X:MODE>")])

(define_insn "*sge<u>_<X:mode><GPR:mode>"
  [(set (match_operand:GPR           0 "register_operand" "=r")
	(any_ge:GPR (match_operand:X 1 "register_operand" " r")
		    (const_int 1)))]
  "TARGET_SLT"
  "slti<u>\t%0,zero,%1"
  [(set_attr "type" "slt")
   (set_attr "mode" "<X:MODE>")])

(define_insn "@slt<u>_<X:mode><GPR:mode>3"
  [(set (match_operand:GPR           0 "register_operand" "= r, r")
	(any_lt:GPR (match_operand:X 1 "register_operand" "  r, r")
		    (match_operand:X 2 "arith_operand"    "  r, I")))]
  "TARGET_SLT"
  "slt%i2<u>\t%0,%1,%2"
  [(set_attr "type" "slt")
   (set_attr "mode" "<X:MODE>")
   (set_attr_alternative "enabled"
     [(const_string "yes")
      (if_then_else (match_test "TARGET_SLTI")
        (const_string "yes") (const_string "no"))])])

(define_insn "*sle<u>_<X:mode><GPR:mode>"
  [(set (match_operand:GPR           0 "register_operand" "=r")
	(any_le:GPR (match_operand:X 1 "register_operand" " r")
		    (match_operand:X 2 "sle_operand" "")))]
  "TARGET_SLT && TARGET_SLTI"
{
  operands[2] = GEN_INT (INTVAL (operands[2]) + 1);
  return "slt%i2<u>\t%0,%1,%2";
}
  [(set_attr "type" "slt")
   (set_attr "mode" "<X:MODE>")])

;; We can sometimes do better for unsigned comparisons against
;; values where there's a run of 1s in the LSBs.
;;
(define_split
  [(set (match_operand:X 0 "register_operand")
       (gtu:X (match_operand:X 1 "register_operand")
	      (match_operand 2 "const_int_operand")))
   (clobber (match_operand:X 3 "register_operand"))]
  "exact_log2 (INTVAL (operands[2]) + 1) >= 0"
  [(set (match_dup 3) (lshiftrt:X (match_dup 1) (match_dup 2)))
   (set (match_dup 0) (ne:X (match_dup 3) (const_int 0)))]
{ operands[2] = GEN_INT (exact_log2 (INTVAL (operands[2]) + 1)); })

(define_split
  [(set (match_operand:X 0 "register_operand")
       (leu:X (match_operand:X 1 "register_operand")
	      (match_operand 2 "const_int_operand")))
   (clobber (match_operand:X 3 "register_operand"))]
  "exact_log2 (INTVAL (operands[2]) + 1) >= 0"
  [(set (match_dup 3) (lshiftrt:X (match_dup 1) (match_dup 2)))
   (set (match_dup 0) (eq:X (match_dup 3) (const_int 0)))]
{ operands[2] = GEN_INT (exact_log2 (INTVAL (operands[2]) + 1)); })

;; Alternate forms that are ultimately just sltiu
(define_insn ""
  [(set (match_operand:X 0 "register_operand" "=r")
	(eq:X (zero_extract:X (match_operand:X 1 "register_operand" "r")
			      (match_operand 2 "const_int_operand")
			      (match_operand 3 "const_int_operand"))
	      (const_int 0)))]
  "TARGET_SLT
   && INTVAL (operands[3]) < 11
   && INTVAL (operands[2]) + INTVAL (operands[3]) == BITS_PER_WORD"
{
  operands[2] = GEN_INT (HOST_WIDE_INT_1U << INTVAL (operands[3]));
  return "sltiu\t%0,%1,%2";
}
  [(set_attr "type" "slt")
   (set_attr "mode" "<X:MODE>")])

(define_insn ""
  [(set (match_operand:X 0 "register_operand" "=r")
	(eq:X (lshiftrt:X (match_operand:X 1 "register_operand" "r")
			  (match_operand 2 "const_int_operand"))
	      (const_int 0)))]
  "TARGET_SLT && INTVAL (operands[2]) < 11"
{
  operands[2] = GEN_INT (HOST_WIDE_INT_1U << INTVAL (operands[2]));
  return "sltiu\t%0,%1,%2";
}
  [(set_attr "type" "slt")
   (set_attr "mode" "<X:MODE>")])
;;
;;  ....................
;;
;;	UNCONDITIONAL BRANCHES
;;
;;  ....................

;; Unconditional branches.

(define_insn "jump"
  [(set (pc) (label_ref (match_operand 0 "" "")))]
  ""
{
  if (!TARGET_LUI)
    /* sc0: lui is unavailable; use PC-relative beq zero,zero.
       Valid for single-function programs where all targets are in range.  */
    return "beq\tzero,zero,%l0";

  if (!TARGET_AUIPC)
    /* sc1: jal (PC-relative unconditional jump) is not available.
       Synthesise an absolute jump using lui+addi+jalr.
       Uses t0, not t1: t1 (RISCV_CALL_ADDRESS_TEMP) is what
       riscv_legitimize_call_address materialises call targets into as a
       separate, independently-scheduled movsi ahead of a register-indirect
       jalr. That movsi and this jump pattern are two separate RTL insns
       with no declared dependency between them (this pattern's raw asm
       clobbers t1 without GCC's dataflow knowing — see the "!TARGET_AUIPC"
       jr\tt1 form this used to be), so nothing stops an optimizer from
       treating a call's t1 reload as dead/redundant, or scheduling this
       jump between it and the call, if they ever land nearby (confirmed via
       pr50865.c and pr93249.c: a call fired with a stale t1 still pointing
       at a nearby jump/branch's own target instead of the real callee).
       Using t0 here instead keeps this pattern's scratch register disjoint
       from the call-address register, so the two can never collide; t0 is
       otherwise touched only during prologue/epilogue (RISCV_PROLOGUE_TEMP),
       never live across a mid-function jump.  */
    return "lui\tt0,%%hi(%l0)\n\taddi\tt0,t0,%%lo(%l0)\n\tjr\tt0";

  /* Use the long form (AUIPC+JALR) if the jump distance exceeds 1 MiB,
     or if the jump crosses section boundaries (e.g., from hot to cold
     section when -freorder-blocks-and-partition is used).
     Note: This clobbers $ra and mucks up the return stack predictors.  */
  if (get_attr_length (insn) == 8)
    return "jump\t%l0,ra";

  return "j\t%l0";
}
  [(set_attr "type"	"jump")
   (set_attr "mode"	"none")])

(define_expand "indirect_jump"
  [(set (pc) (match_operand 0 "register_operand"))]
  ""
{
  if (is_zicfilp_p ())
    emit_insn (gen_set_lpl (Pmode, const0_rtx));

  operands[0] = force_reg (Pmode, operands[0]);
  if (is_zicfilp_p ())
    emit_use (gen_rtx_REG (Pmode, T2_REGNUM));

  if (Pmode == SImode)
    emit_jump_insn (gen_indirect_jumpsi (operands[0]));
  else
    emit_jump_insn (gen_indirect_jumpdi (operands[0]));

  DONE;
})

(define_insn "indirect_jump<mode>"
  [(set (pc) (match_operand:P 0 "register_operand" "l"))]
  "TARGET_LUI"
  "jr\t%0"
  [(set_attr "type" "jalr")
   (set_attr "mode" "none")])

(define_expand "tablejump"
  [(set (pc) (match_operand 0 "register_operand" ""))
	      (use (label_ref (match_operand 1 "" "")))]
  ""
{
  if (CASE_VECTOR_PC_RELATIVE)
      operands[0] = expand_simple_binop (Pmode, PLUS, operands[0],
					 gen_rtx_LABEL_REF (Pmode, operands[1]),
					 NULL_RTX, 0, OPTAB_DIRECT);

  if (is_zicfilp_p ())
    {
      rtx t2 = RISCV_CALL_ADDRESS_LPAD (GET_MODE (operands[0]));
      emit_move_insn (t2, operands[0]);

      if (CASE_VECTOR_PC_RELATIVE && Pmode == DImode)
	emit_jump_insn (gen_tablejump_cfidi (operands[1]));
      else
	emit_jump_insn (gen_tablejump_cfisi (operands[1]));
    }
  else
    {
      if (CASE_VECTOR_PC_RELATIVE && Pmode == DImode)
	emit_jump_insn (gen_tablejumpdi (operands[0], operands[1]));
      else
	emit_jump_insn (gen_tablejumpsi (operands[0], operands[1]));
    }
  DONE;
})

(define_insn "tablejump<mode>"
  [(set (pc) (match_operand:GPR 0 "register_operand" "l"))
   (use (label_ref (match_operand 1 "" "")))]
  "TARGET_LUI && !is_zicfilp_p ()"
  "jr\t%0"
  [(set_attr "type" "jalr")
   (set_attr "mode" "none")])

(define_insn "tablejump_cfi<mode>"
  [(set (pc) (reg:GPR T2_REGNUM))
   (use (label_ref (match_operand 0 "")))]
  "is_zicfilp_p ()"
  "jr\tt2"
  [(set_attr "type" "jalr")
   (set_attr "mode" "none")])

;;
;;  ....................
;;
;;	Function prologue/epilogue
;;
;;  ....................
;;

(define_expand "prologue"
  [(const_int 1)]
  ""
{
  riscv_expand_prologue ();
  DONE;
})

;; Block any insns from being moved before this point, since the
;; profiling call to mcount can use various registers that aren't
;; saved or used to pass arguments.

(define_insn "blockage"
  [(unspec_volatile [(const_int 0)] UNSPECV_BLOCKAGE)]
  ""
  ""
  [(set_attr "type" "ghost")
   (set_attr "mode" "none")])

(define_expand "epilogue"
  [(const_int 2)]
  ""
{
  riscv_expand_epilogue (NORMAL_RETURN);
  DONE;
})

(define_expand "sibcall_epilogue"
  [(const_int 2)]
  ""
{
  riscv_expand_epilogue (SIBCALL_RETURN);
  DONE;
})

;; Trivial return.  Make it look like a normal return insn as that
;; allows jump optimizations to work better.

(define_expand "return"
  [(simple_return)]
  "riscv_can_use_return_insn ()"
  "")

(define_insn "simple_return"
  [(simple_return)]
  ""
{
  return riscv_output_return ();
}
  [(set_attr "type"	"jalr")
   (set_attr "mode"	"none")])

;; Normal return.

(define_insn "simple_return_internal"
  [(simple_return)
   (use (match_operand 0 "pmode_register_operand" ""))]
  ""
  "jr\t%0"
  [(set_attr "type"	"jalr")
   (set_attr "mode"	"none")])

;; This is used in compiling the unwind routines.
(define_expand "eh_return"
  [(use (match_operand 0 "general_operand"))]
  ""
{
  if (GET_MODE (operands[0]) != word_mode)
    operands[0] = convert_to_mode (word_mode, operands[0], 0);
  if (TARGET_64BIT)
    emit_insn (gen_eh_set_lr_di (operands[0]));
  else
    emit_insn (gen_eh_set_lr_si (operands[0]));

  emit_jump_insn (gen_eh_return_internal ());
  emit_barrier ();
  DONE;
})

;; Clobber the return address on the stack.  We can't expand this
;; until we know where it will be put in the stack frame.

(define_insn "eh_set_lr_si"
  [(unspec [(match_operand:SI 0 "register_operand" "r")] UNSPEC_EH_RETURN)
   (clobber (match_scratch:SI 1 "=&r"))]
  "! TARGET_64BIT"
  "#"
  [(set_attr "type" "jump")])

(define_insn "eh_set_lr_di"
  [(unspec [(match_operand:DI 0 "register_operand" "r")] UNSPEC_EH_RETURN)
   (clobber (match_scratch:DI 1 "=&r"))]
  "TARGET_64BIT"
  "#"
  [(set_attr "type" "jump")])

(define_split
  [(unspec [(match_operand 0 "register_operand")] UNSPEC_EH_RETURN)
   (clobber (match_scratch 1))]
  "reload_completed"
  [(const_int 0)]
{
  riscv_set_return_address (operands[0], operands[1]);
  DONE;
})

(define_insn_and_split "eh_return_internal"
  [(eh_return)]
  ""
  "#"
  "epilogue_completed"
  [(const_int 0)]
  "riscv_expand_epilogue (EXCEPTION_RETURN); DONE;"
  [(set_attr "type" "ret")])

;;
;;  ....................
;;
;;	FUNCTION CALLS
;;
;;  ....................

(define_expand "sibcall"
  [(parallel [(call (match_operand 0 "")
		    (match_operand 1 ""))
	      (use (unspec:SI [
		     (match_operand 2 "const_int_operand")
	           ] UNSPEC_CALLEE_CC))])]
  ""
{
  rtx target = riscv_legitimize_call_address (XEXP (operands[0], 0));
  emit_call_insn (gen_sibcall_internal (target, operands[1], operands[2]));
  DONE;
})

(define_insn "sibcall_internal"
  [(call (mem:SI (match_operand 0 "call_insn_operand" "j,S,U"))
	 (match_operand 1 "" ""))
   (use (unspec:SI [
          (match_operand 2 "const_int_operand")
        ] UNSPEC_CALLEE_CC))]
  "SIBLING_CALL_P (insn)"
{
  switch (which_alternative)
    {
    case 0: return "jr\t%0";
    case 1:
    case 2:
      if (!TARGET_AUIPC)
	return "lui\tt0,%%hi(%0)\n\taddi\tt0,t0,%%lo(%0)\n\tjr\tt0";
      return which_alternative == 1 ? "tail\t%0" : "tail\t%0@plt";
    default: gcc_unreachable ();
    }
}
  [(set_attr "type" "call")])

(define_expand "sibcall_value"
  [(parallel [(set (match_operand 0 "")
		   (call (match_operand 1 "")
			 (match_operand 2 "")))
	      (use (unspec:SI [
		     (match_operand 3 "const_int_operand")
	           ] UNSPEC_CALLEE_CC))])]
  ""
{
  rtx target = riscv_legitimize_call_address (XEXP (operands[1], 0));
  emit_call_insn (gen_sibcall_value_internal (operands[0], target, operands[2],
					      operands[3]));
  DONE;
})

(define_insn "sibcall_value_internal"
  [(set (match_operand 0 "" "")
	(call (mem:SI (match_operand 1 "call_insn_operand" "j,S,U"))
	      (match_operand 2 "" "")))
   (use (unspec:SI [
          (match_operand 3 "const_int_operand")
        ] UNSPEC_CALLEE_CC))]
  "SIBLING_CALL_P (insn)"
{
  switch (which_alternative)
    {
    case 0: return "jr\t%1";
    case 1:
    case 2:
      if (!TARGET_AUIPC)
	return "lui\tt0,%%hi(%1)\n\taddi\tt0,t0,%%lo(%1)\n\tjr\tt0";
      return which_alternative == 1 ? "tail\t%1" : "tail\t%1@plt";
    default: gcc_unreachable ();
    }
}
  [(set_attr "type" "call")])

(define_expand "call"
  [(parallel [(call (match_operand 0 "")
		    (match_operand 1 ""))
	      (use (unspec:SI [
		     (match_operand 2 "const_int_operand")
	           ] UNSPEC_CALLEE_CC))])]
  ""
{
  rtx target = riscv_legitimize_call_address (XEXP (operands[0], 0));
  emit_call_insn (gen_call_internal (target, operands[1], operands[2]));
  DONE;
})

(define_insn "call_internal"
  [(call (mem:SI (match_operand 0 "call_insn_operand" "l,S,U"))
	 (match_operand 1 "" ""))
   (use (unspec:SI [
          (match_operand 2 "const_int_operand")
        ] UNSPEC_CALLEE_CC))
   (clobber (reg:SI RETURN_ADDR_REGNUM))]
  "TARGET_LUI"
{
  switch (which_alternative)
    {
    case 0: return "jalr\t%0";
    case 1:
    case 2:
      if (!TARGET_AUIPC)
	/* sc1: no AUIPC, so "call sym" would expand to auipc+jalr.
	   Emit lui+addi+jalr instead (absolute address, sets ra).  */
	return "lui\tt0,%%hi(%0)\n\taddi\tt0,t0,%%lo(%0)\n\tjalr\tra,0(t0)";
      return which_alternative == 1 ? "call\t%0" : "call\t%0@plt";
    default: gcc_unreachable ();
    }
}
  [(set_attr "type" "call")])

(define_expand "call_value"
  [(parallel [(set (match_operand 0 "")
		   (call (match_operand 1 "")
			 (match_operand 2 "")))
	      (use (unspec:SI [
		     (match_operand 3 "const_int_operand")
	           ] UNSPEC_CALLEE_CC))])]
  ""
{
  rtx target = riscv_legitimize_call_address (XEXP (operands[1], 0));
  emit_call_insn (gen_call_value_internal (operands[0], target, operands[2],
					   operands[3]));
  DONE;
})

(define_insn "call_value_internal"
  [(set (match_operand 0 "" "")
	(call (mem:SI (match_operand 1 "call_insn_operand" "l,S,U"))
	      (match_operand 2 "" "")))
   (use (unspec:SI [
          (match_operand 3 "const_int_operand")
        ] UNSPEC_CALLEE_CC))
   (clobber (reg:SI RETURN_ADDR_REGNUM))]
  "TARGET_LUI"
{
  switch (which_alternative)
    {
    case 0: return "jalr\t%1";
    case 1:
    case 2:
      if (!TARGET_AUIPC)
	return "lui\tt0,%%hi(%1)\n\taddi\tt0,t0,%%lo(%1)\n\tjalr\tra,0(t0)";
      return which_alternative == 1 ? "call\t%1" : "call\t%1@plt";
    default: gcc_unreachable ();
    }
}
  [(set_attr "type" "call")])

;; Call subroutine returning any type.

(define_expand "untyped_call"
  [(parallel [(call (match_operand 0 "")
		    (const_int 0))
	      (match_operand 1 "")
	      (match_operand 2 "")])]
  ""
{
  int i;

  /* Untyped calls always use the RISCV_CC_BASE calling convention.  */
  emit_call_insn (gen_call (operands[0], const0_rtx,
			    gen_int_mode (RISCV_CC_BASE, SImode)));

  for (i = 0; i < XVECLEN (operands[2], 0); i++)
    {
      rtx set = XVECEXP (operands[2], 0, i);
      riscv_emit_move (SET_DEST (set), SET_SRC (set));
    }

  emit_insn (gen_blockage ());
  DONE;
})

(define_insn "nop"
  [(const_int 0)]
  ""
  "nop"
  [(set_attr "type"	"nop")
   (set_attr "mode"	"none")])

(define_insn "trap"
  [(trap_if (const_int 1) (const_int 0))]
  ""
{
  if (!TARGET_AUIPC)
    /* sc0/sc1 have no trap instruction; spin forever instead. */
    return "beq\tzero,zero,.";
  return "ebreak";
}
  [(set_attr "type" "trap")])

;; Must use the registers that we save to prevent the rename reg optimization
;; pass from using them before the gpr_save pattern when shrink wrapping
;; occurs.  See bug 95252 for instance.

(define_insn "gpr_save"
  [(match_parallel 1 "gpr_save_operation"
     [(unspec_volatile [(match_operand 0 "const_int_operand")]
	               UNSPECV_GPR_SAVE)])]
  ""
  "call\tt0,__riscv_save_%0"
  [(set_attr "type" "call")])

(define_insn "gpr_restore"
  [(unspec_volatile [(match_operand 0 "const_int_operand")] UNSPECV_GPR_RESTORE)]
  ""
  "tail\t__riscv_restore_%0"
  [(set_attr "type" "call")])

(define_insn "gpr_restore_return"
  [(return)
   (use (match_operand 0 "pmode_register_operand" ""))
   (const_int 0)]
  ""
  ""
  [(set_attr "type" "ret")])

(define_insn "riscv_frcsr"
  [(set (match_operand:SI 0 "register_operand" "=r")
	(unspec_volatile:SI [(const_int 0)] UNSPECV_FRCSR))]
  "TARGET_HARD_FLOAT || TARGET_ZFINX"
  "frcsr\t%0"
  [(set_attr "type" "fmove")])

(define_insn "riscv_fscsr"
  [(unspec_volatile [(match_operand:SI 0 "register_operand" "r")] UNSPECV_FSCSR)]
  "TARGET_HARD_FLOAT || TARGET_ZFINX"
  "fscsr\t%0"
  [(set_attr "type" "fmove")])

(define_insn "riscv_frflags"
  [(set (match_operand:SI 0 "register_operand" "=r")
	(unspec_volatile:SI [(const_int 0)] UNSPECV_FRFLAGS))]
  "TARGET_HARD_FLOAT || TARGET_ZFINX"
  "frflags\t%0"
  [(set_attr "type" "fmove")])

(define_insn "riscv_fsflags"
  [(unspec_volatile [(match_operand:SI 0 "csr_operand" "rK")] UNSPECV_FSFLAGS)]
  "TARGET_HARD_FLOAT || TARGET_ZFINX"
  "fsflags%i0\t%0"
  [(set_attr "type" "fmove")])

(define_insn "*riscv_fsnvsnan<mode>2"
  [(unspec_volatile [(match_operand:ANYF 0 "register_operand" "f")
		     (match_operand:ANYF 1 "register_operand" "f")]
		    UNSPECV_FSNVSNAN)]
  "TARGET_HARD_FLOAT || TARGET_ZFINX"
  "feq.<fmt>\tzero,%0,%1"
  [(set_attr "type" "fcmp")
   (set_attr "mode" "<UNITMODE>")])

(define_insn "riscv_mret"
  [(return)
   (unspec_volatile [(const_int 0)] UNSPECV_MRET)]
  ""
  "mret"
  [(set_attr "type" "ret")])

(define_insn "riscv_sret"
  [(return)
   (unspec_volatile [(const_int 0)] UNSPECV_SRET)]
  ""
  "sret"
  [(set_attr "type" "ret")])

(define_insn "riscv_mnret"
  [(return)
   (unspec_volatile [(const_int 0)] UNSPECV_MNRET)]
  "TARGET_SMRNMI"
  "mnret"
  [(set_attr "type" "ret")])

(define_insn "stack_tie<mode>"
  [(set (mem:BLK (scratch))
	(unspec:BLK [(match_operand:X 0 "register_operand" "r")
		     (match_operand:X 1 "register_operand" "r")]
		    UNSPEC_TIE))]
  "!rtx_equal_p (operands[0], operands[1])"
  ""
  [(set_attr "type" "ghost")
   (set_attr "length" "0")]
)

(define_expand "save_stack_nonlocal"
  [(set (match_operand 0 "memory_operand")
	(match_operand 1 "register_operand"))]
  ""
{
  rtx stack_slot;

  if (need_shadow_stack_push_pop_p ())
    {
      /* Copy shadow stack pointer to the first slot
	 and stack pointer to the second slot.  */
      rtx ssp_slot = adjust_address (operands[0], word_mode, 0);
      stack_slot = adjust_address (operands[0], Pmode, UNITS_PER_WORD);

      rtx reg_ssp = force_reg (word_mode, const0_rtx);
      emit_insn (gen_ssrdp (word_mode, reg_ssp));
      emit_move_insn (ssp_slot, reg_ssp);
    }
  else
    stack_slot = adjust_address (operands[0], Pmode, 0);
  emit_move_insn (stack_slot, operands[1]);
  DONE;
})

;; This fixes a failure with gcc.c-torture/execute/pr64242.c at -O2 for a
;; 32-bit target when using -mtune=sifive-7-series.  The first sched pass
;; runs before register elimination, and we have a non-obvious dependency
;; between a use of the soft fp and a set of the hard fp.  We fix this by
;; emitting a clobber using the hard fp between the two insns.
(define_expand "restore_stack_nonlocal"
  [(match_operand 0 "register_operand")
   (match_operand 1 "memory_operand")]
  ""
{
  rtx stack_slot;

  if (need_shadow_stack_push_pop_p ())
    {
      rtx t0 = gen_rtx_REG (Pmode, RISCV_PROLOGUE_TEMP_REGNUM);
      /* Restore shadow stack pointer from the first slot
	 and stack pointer from the second slot.  */
      rtx ssp_slot = adjust_address (operands[1], word_mode, 0);
      stack_slot = adjust_address (operands[1], Pmode, UNITS_PER_WORD);

      /* Get the current shadow stack pointer.  */
      rtx cur_ssp = force_reg (word_mode, const0_rtx);
      emit_insn (gen_ssrdp (word_mode, cur_ssp));

      /* Compare and jump over adjustment code.  */
      rtx noadj_label = gen_label_rtx ();
      emit_cmp_and_jump_insns (cur_ssp, const0_rtx, EQ, NULL_RTX,
			       word_mode, 1, noadj_label);

      rtx loop_label = gen_label_rtx ();
      emit_label (loop_label);
      LABEL_NUSES (loop_label) = 1;

      /* Check if current ssp less than jump buffer ssp,
	 so no loop is needed.  */
      emit_cmp_and_jump_insns (ssp_slot, cur_ssp, LE, NULL_RTX,
			       ptr_mode, 1, noadj_label);

      /* Advance by a maximum of 4K at a time to avoid unwinding
	 past bounds of the shadow stack.  */
      rtx reg_4096 = force_reg (word_mode, GEN_INT (4096));
      rtx cmp_ssp  = gen_reg_rtx (word_mode);
      cmp_ssp = expand_simple_binop (ptr_mode, MINUS,
				     ssp_slot, cur_ssp,
				     cmp_ssp, 1, OPTAB_DIRECT);

      /* Update curr_ssp from jump buffer ssp.  */
      emit_move_insn (cur_ssp, ssp_slot);
      emit_insn (gen_write_ssp (word_mode, cur_ssp));
      emit_jump_insn (gen_jump (loop_label));
      emit_barrier ();

      /* Adjust the ssp in a loop.  */
      rtx cmp_4k_label = gen_label_rtx ();
      emit_label (cmp_4k_label);
      LABEL_NUSES (cmp_4k_label) = 1;

      /* Add 4k for curr_ssp.  */
      cur_ssp = expand_simple_binop (ptr_mode, PLUS,
				     cur_ssp, reg_4096,
				     cur_ssp, 1, OPTAB_DIRECT);
      emit_insn (gen_write_ssp (word_mode, cur_ssp));
      emit_insn (gen_sspush (Pmode, t0));
      emit_insn (gen_sspopchk (Pmode, t0));
      emit_jump_insn (gen_jump (loop_label));
      emit_barrier ();

      emit_label (noadj_label);
      LABEL_NUSES (noadj_label) = 1;
    }
  else
    stack_slot = adjust_address (operands[1], Pmode, 0);

  emit_move_insn (operands[0], stack_slot);
  /* Prevent the following hard fp restore from being moved before the move
     insn above which uses a copy of the soft fp reg.  */
  emit_clobber (gen_rtx_MEM (BLKmode, hard_frame_pointer_rtx));
  DONE;
})

;; Named pattern for expanding thread pointer reference.
(define_expand "get_thread_pointer<mode>"
  [(set (match_operand:P 0 "register_operand" "=r")
	(reg:P TP_REGNUM))]
  ""
{})

;; Named patterns for stack smashing protection.

(define_expand "stack_protect_set"
  [(match_operand 0 "memory_operand")
   (match_operand 1 "memory_operand")]
  ""
{
  machine_mode mode = GET_MODE (operands[0]);
  if (riscv_stack_protector_guard == SSP_TLS)
  {
    rtx reg = gen_rtx_REG (Pmode, riscv_stack_protector_guard_reg);
    rtx offset = GEN_INT (riscv_stack_protector_guard_offset);
    rtx addr = gen_rtx_PLUS (Pmode, reg, offset);
    operands[1] = gen_rtx_MEM (Pmode, addr);
  }

  emit_insn ((mode == DImode
	      ? gen_stack_protect_set_di
	      : gen_stack_protect_set_si) (operands[0], operands[1]));
  DONE;
})

;; DO NOT SPLIT THIS PATTERN.  It is important for security reasons that the
;; canary value does not live beyond the life of this sequence.
(define_insn "stack_protect_set_<mode>"
  [(set (match_operand:GPR 0 "memory_operand" "=m")
	(unspec:GPR [(match_operand:GPR 1 "memory_operand" "m")]
	 UNSPEC_SSP_SET))
   (set (match_scratch:GPR 2 "=&r") (const_int 0))]
  ""
  "<load>\t%2, %1\;<store>\t%2, %0\;li\t%2, 0"
  [(set_attr "type" "multi")
   (set_attr "length" "12")])

(define_expand "stack_protect_test"
  [(match_operand 0 "memory_operand")
   (match_operand 1 "memory_operand")
   (match_operand 2)]
  ""
{
  rtx result;
  machine_mode mode = GET_MODE (operands[0]);

  result = gen_reg_rtx(mode);
  if (riscv_stack_protector_guard == SSP_TLS)
  {
      rtx reg = gen_rtx_REG (Pmode, riscv_stack_protector_guard_reg);
      rtx offset = GEN_INT (riscv_stack_protector_guard_offset);
      rtx addr = gen_rtx_PLUS (Pmode, reg, offset);
      operands[1] = gen_rtx_MEM (Pmode, addr);
  }
  emit_insn ((mode == DImode
		  ? gen_stack_protect_test_di
		  : gen_stack_protect_test_si) (result,
					        operands[0],
					        operands[1]));

  rtx cond = gen_rtx_EQ (VOIDmode, result, const0_rtx);
  emit_jump_insn (gen_cbranch4 (mode, cond, result, const0_rtx, operands[2]));

  DONE;
})

(define_insn "stack_protect_test_<mode>"
  [(set (match_operand:GPR 0 "register_operand" "=r")
	(unspec:GPR [(match_operand:GPR 1 "memory_operand" "m")
		     (match_operand:GPR 2 "memory_operand" "m")]
	 UNSPEC_SSP_TEST))
   (clobber (match_scratch:GPR 3 "=&r"))]
  ""
  "<load>\t%3, %1\;<load>\t%0, %2\;xor\t%0, %3, %0\;li\t%3, 0"
  [(set_attr "type" "multi")
   (set_attr "length" "12")])

(define_insn "riscv_clean_<mode>"
  [(unspec_volatile:X [(match_operand:X 0 "register_operand" "r")]
    UNSPECV_CLEAN)]
  "TARGET_ZICBOM"
  "cbo.clean\t%a0"
  [(set_attr "type" "store")]
)

(define_insn "riscv_flush_<mode>"
  [(unspec_volatile:X [(match_operand:X 0 "register_operand" "r")]
    UNSPECV_FLUSH)]
  "TARGET_ZICBOM"
  "cbo.flush\t%a0"
  [(set_attr "type" "store")]
)

(define_insn "riscv_inval_<mode>"
  [(unspec_volatile:X [(match_operand:X 0 "register_operand" "r")]
    UNSPECV_INVAL)]
  "TARGET_ZICBOM"
  "cbo.inval\t%a0"
  [(set_attr "type" "store")]
)

(define_insn "riscv_zero_<mode>"
  [(unspec_volatile:X [(match_operand:X 0 "register_operand" "r")]
    UNSPECV_ZERO)]
  "TARGET_ZICBOZ"
  "cbo.zero\t%a0"
  [(set_attr "type" "store")]
)

(define_insn "prefetch"
  [(prefetch (match_operand 0 "prefetch_operand" "Qr,ZD")
	     (match_operand 1 "imm5_operand" "i,i")
	     (match_operand 2 "const_int_operand" "n,n"))]
  "TARGET_ZICBOP || TARGET_XMIPSCBOP"
{
  if (TARGET_XMIPSCBOP)
    {
      /* Mips Prefetch write is nop for p8700.  */
      if (operands[1] != CONST0_RTX (GET_MODE (operands[1])))
	return "nop";

      operands[1] = riscv_prefetch_cookie (operands[1], operands[2]);
      return "mips.pref\t%1,%a0";
    }

  switch (INTVAL (operands[1]))
  {
    case 0:
    case 2: return TARGET_ZIHINTNTL ? "%L2prefetch.r\t%a0" : "prefetch.r\t%a0";
    case 1: return TARGET_ZIHINTNTL ? "%L2prefetch.w\t%a0" : "prefetch.w\t%a0";
    default: gcc_unreachable ();
  }
}
  [(set_attr "type" "store")
   (set (attr "length") (if_then_else (and (match_test "TARGET_ZIHINTNTL")
					   (match_test "IN_RANGE (INTVAL (operands[2]), 0, 2)"))
				      (const_string "8")
				      (const_string "4")))])

(define_insn "riscv_prefetchi_<mode>"
  [(unspec_volatile:X [(match_operand:X 0 "prefetch_operand" "Q")
              (match_operand:X 1 "imm5_operand" "i")]
              UNSPECV_PREI)]
  "TARGET_ZICBOP"
  "prefetch.i\t%a0"
  [(set_attr "type" "store")])

(define_expand "extv<mode>"
  [(set (match_operand:GPR 0 "register_operand" "=r")
	(sign_extract:GPR (match_operand:GPR 1 "register_operand" "r")
			 (match_operand 2 "const_int_operand")
			 (match_operand 3 "const_int_operand")))]
  "TARGET_XTHEADBB"
)

(define_expand "extzv<mode>"
  [(set (match_operand:GPR 0 "register_operand" "=r")
	(zero_extract:GPR (match_operand:GPR 1 "register_operand" "r")
			 (match_operand 2 "const_int_operand")
			 (match_operand 3 "const_int_operand")))]
  "TARGET_XTHEADBB"
{
  if (TARGET_XTHEADBB
      && (INTVAL (operands[2]) < 8) && (INTVAL (operands[3]) == 0))
    FAIL;
})

(define_expand "maddhisi4"
  [(set (match_operand:SI 0 "register_operand")
	(plus:SI
	  (mult:SI (sign_extend:SI (match_operand:HI 1 "register_operand"))
		   (sign_extend:SI (match_operand:HI 2 "register_operand")))
	  (match_operand:SI 3 "register_operand")))]
  "TARGET_XTHEADMAC"
)

(define_expand "msubhisi4"
  [(set (match_operand:SI 0 "register_operand")
	(minus:SI
	  (match_operand:SI 3 "register_operand")
	  (mult:SI (sign_extend:SI (match_operand:HI 1 "register_operand"))
		   (sign_extend:SI (match_operand:HI 2 "register_operand")))))]
  "TARGET_XTHEADMAC"
)

;; String compare with length insn.
;; Argument 0 is the target (result)
;; Argument 1 is the source1
;; Argument 2 is the source2
;; Argument 3 is the length
;; Argument 4 is the alignment

(define_expand "cmpstrnsi"
  [(parallel [(set (match_operand:SI 0)
	      (compare:SI (match_operand:BLK 1)
			  (match_operand:BLK 2)))
	      (use (match_operand:SI 3))
	      (use (match_operand:SI 4))])]
  "riscv_inline_strncmp && !optimize_size
    && (TARGET_ZBB || TARGET_XTHEADBB || TARGET_VECTOR)"
{
  rtx temp = gen_reg_rtx (word_mode);
  if (riscv_expand_strcmp (temp, operands[1], operands[2],
                           operands[3], operands[4]))
    {
      if (TARGET_64BIT)
	{
	  temp = gen_lowpart (SImode, temp);
	  SUBREG_PROMOTED_VAR_P (temp) = 1;
	  SUBREG_PROMOTED_SET (temp, SRP_SIGNED);
	}
      emit_move_insn (operands[0], temp);
      DONE;
    }
  else
    FAIL;
})

;; String compare insn.
;; Argument 0 is the target (result)
;; Argument 1 is the source1
;; Argument 2 is the source2
;; Argument 3 is the alignment

(define_expand "cmpstrsi"
  [(parallel [(set (match_operand:SI 0)
	      (compare:SI (match_operand:BLK 1)
			  (match_operand:BLK 2)))
	      (use (match_operand:SI 3))])]
  "riscv_inline_strcmp && !optimize_size
    && (TARGET_ZBB || TARGET_XTHEADBB || TARGET_VECTOR)"
{
  rtx temp = gen_reg_rtx (word_mode);
  if (riscv_expand_strcmp (temp, operands[1], operands[2],
                           NULL_RTX, operands[3]))
    {
      if (TARGET_64BIT)
	{
	  temp = gen_lowpart (SImode, temp);
	  SUBREG_PROMOTED_VAR_P (temp) = 1;
	  SUBREG_PROMOTED_SET (temp, SRP_SIGNED);
	}
      emit_move_insn (operands[0], temp);
      DONE;
    }
  else
    FAIL;
})

;; Search character in string (generalization of strlen).
;; Argument 0 is the resulting offset
;; Argument 1 is the string
;; Argument 2 is the search character
;; Argument 3 is the alignment

(define_expand "strlen<mode>"
  [(set (match_operand:X 0 "register_operand")
	(unspec:X [(match_operand:BLK 1 "general_operand")
		     (match_operand:SI 2 "const_int_operand")
		     (match_operand:SI 3 "const_int_operand")]
		  UNSPEC_STRLEN))]
  "riscv_inline_strlen && !optimize_size
    && (TARGET_ZBB || TARGET_XTHEADBB || TARGET_VECTOR)"
{
  rtx search_char = operands[2];

  if (search_char != const0_rtx)
    FAIL;

  if (riscv_expand_strlen (operands[0], operands[1], operands[2], operands[3]))
    DONE;
  else
    FAIL;
})

; Split (A<<1) | (A>=0) into a rotate + xor. Using two’s-complement identities:
; (A>=0) == ((A >> (W-1)) ^ 1) and (A<<1) | (A>>(W-1)) == ROL1 (A), so the whole
; expression equals ROL1 (A) ^ 1.
(define_split
  [(set (match_operand:X 0 "register_operand")
     (ior:X
       (ashift:X (match_operand:X 1 "register_operand")
		  (const_int 1))
		(ge:X (match_dup 1) (const_int 0))))]
  "TARGET_ZBB"
  [(set (match_dup 0)
       (rotatert:X (match_dup 1) (match_operand 2 "const_int_operand")))
   (set (match_dup 0)
       (xor:X (match_dup 0) (const_int 1)))]
  {
    HOST_WIDE_INT rotval;
    rotval = GET_MODE_BITSIZE (GET_MODE (operands[1])).to_constant () - 1;
    operands[2] = GEN_INT (rotval);
  })

(define_insn "*large_load_address"
  [(set (match_operand:DI 0 "register_operand" "=r")
        (mem:DI (match_operand 1 "pcrel_symbol_operand" "")))]
  "TARGET_64BIT && riscv_cmodel == CM_LARGE"
  "ld\t%0,%1"
  [(set_attr "type" "load")
   (set (attr "length") (const_int 8))])

;; The AND is redunant here.  It always turns off the high 32 bits  and the
;; low number of bits equal to the shift count.  Those upper 32 bits will be
;; reset by the SIGN_EXTEND at the end.
;;
;; One could argue combine should have realized this and simplified what it
;; presented to the backend.  But we can obviously cope with what it gave us.
(define_insn_and_split ""
  [(set (match_operand:DI 0 "register_operand" "=r")
	(sign_extend:DI
	  (plus:SI (subreg:SI
		     (and:DI
		       (ashift:DI (match_operand:DI 1 "register_operand" "r")
				  (match_operand 2 "const_int_operand" "n"))
		       (match_operand 3 "const_int_operand" "n")) 0)
		   (match_operand:SI 4 "register_operand" "r"))))
   (clobber (match_scratch:DI 5 "=&r"))]
  "TARGET_64BIT
   && (INTVAL (operands[3]) | ((1 << INTVAL (operands[2])) - 1)) == 0xffffffff"
  "#"
  "&& reload_completed"
  [(set (match_dup 5) (ashift:DI (match_dup 1) (match_dup 2)))
   (set (match_dup 0) (sign_extend:DI (plus:SI (match_dup 6) (match_dup 4))))]
  "{ operands[6] = gen_lowpart (SImode, operands[5]); }"
  [(set_attr "type" "arith")])

(define_expand "usadd<mode>3"
  [(match_operand:ANYI 0 "register_operand")
   (match_operand:ANYI 1 "reg_or_int_operand")
   (match_operand:ANYI 2 "reg_or_int_operand")]
  ""
  {
    riscv_expand_usadd (operands[0], operands[1], operands[2]);
    DONE;
  }
)

(define_expand "ssadd<mode>3"
  [(match_operand:ANYI 0 "register_operand")
   (match_operand:ANYI 1 "register_operand")
   (match_operand:ANYI 2 "register_operand")]
  ""
  {
    riscv_expand_ssadd (operands[0], operands[1], operands[2]);
    DONE;
  }
)

(define_expand "ussub<mode>3"
  [(match_operand:ANYI 0 "register_operand")
   (match_operand:ANYI 1 "reg_or_int_operand")
   (match_operand:ANYI 2 "reg_or_int_operand")]
  ""
  {
    riscv_expand_ussub (operands[0], operands[1], operands[2]);
    DONE;
  }
)

(define_expand "sssub<mode>3"
  [(match_operand:ANYI 0 "register_operand")
   (match_operand:ANYI 1 "register_operand")
   (match_operand:ANYI 2 "register_operand")]
  ""
  {
    riscv_expand_sssub (operands[0], operands[1], operands[2]);
    DONE;
  }
)

(define_expand "usmul<mode>3"
  [(match_operand:ANYI 0 "register_operand")
   (match_operand:ANYI 1 "register_operand")
   (match_operand:ANYI 2 "register_operand")]
  "TARGET_ZMMUL || TARGET_MUL"
  {
    riscv_expand_usmul (operands[0], operands[1], operands[2]);
    DONE;
  }
)

(define_expand "ustrunc<mode><anyi_double_truncated>2"
  [(match_operand:<ANYI_DOUBLE_TRUNCATED> 0 "register_operand")
   (match_operand:ANYI_DOUBLE_TRUNC       1 "register_operand")]
  ""
  {
    riscv_expand_ustrunc (operands[0], operands[1]);
    DONE;
  }
)

(define_expand "sstrunc<mode><anyi_double_truncated>2"
  [(match_operand:<ANYI_DOUBLE_TRUNCATED> 0 "register_operand")
   (match_operand:ANYI_DOUBLE_TRUNC       1 "register_operand")]
  ""
  {
    riscv_expand_sstrunc (operands[0], operands[1]);
    DONE;
  }
)

(define_expand "ustrunc<mode><anyi_quad_truncated>2"
  [(match_operand:<ANYI_QUAD_TRUNCATED> 0 "register_operand")
   (match_operand:ANYI_QUAD_TRUNC       1 "register_operand")]
  ""
  {
    riscv_expand_ustrunc (operands[0], operands[1]);
    DONE;
  }
)

(define_expand "sstrunc<mode><anyi_quad_truncated>2"
  [(match_operand:<ANYI_QUAD_TRUNCATED> 0 "register_operand")
   (match_operand:ANYI_QUAD_TRUNC       1 "register_operand")]
  ""
  {
    riscv_expand_sstrunc (operands[0], operands[1]);
    DONE;
  }
)

(define_expand "ustrunc<mode><anyi_oct_truncated>2"
  [(match_operand:<ANYI_OCT_TRUNCATED> 0 "register_operand")
   (match_operand:ANYI_OCT_TRUNC       1 "register_operand")]
  ""
  {
    riscv_expand_ustrunc (operands[0], operands[1]);
    DONE;
  }
)

(define_expand "sstrunc<mode><anyi_oct_truncated>2"
  [(match_operand:<ANYI_OCT_TRUNCATED> 0 "register_operand")
   (match_operand:ANYI_OCT_TRUNC       1 "register_operand")]
  ""
  {
    riscv_expand_sstrunc (operands[0], operands[1]);
    DONE;
  }
)

;; These are forms of (x << C1) + C2, potentially canonicalized from
;; ((x + C2') << C1.  Depending on the cost to load C2 vs C2' we may
;; want to go ahead and recognize this form as C2 may be cheaper to
;; synthesize than C2'.
;;
;; It might be better to refactor riscv_const_insns a bit so that we
;; can have an API that passes integer values around rather than
;; constructing a lot of garbage RTL.
;;
;; The mvconst_internal pattern in effect requires this pattern to
;; also be a define_insn_and_split due to insn count costing when
;; splitting in combine.
(define_insn_and_split ""
  [(set (match_operand:DI 0 "register_operand" "=r")
	(plus:DI (ashift:DI (match_operand:DI 1 "register_operand" "r")
			    (match_operand 2 "const_int_operand" "n"))
		 (match_operand 3 "const_int_operand" "n")))
   (clobber (match_scratch:DI 4 "=&r"))]
  "(TARGET_64BIT
    && riscv_const_insns (operands[3], false) == 1
    && riscv_const_insns (GEN_INT (INTVAL (operands[3])
			  << INTVAL (operands[2])), false) != 1)"
  "#"
  "&& reload_completed"
  [(const_int 0)]
  "{
     /* Prefer to generate shNadd when we can, even over using an
	immediate form.  If we're not going to be able to generate
	a shNadd, then use the constant directly if it fits in a
	simm12 field since we won't get another chance to optimize this.  */
     if ((TARGET_ZBA && imm123_operand (operands[2], word_mode))
	 || !SMALL_OPERAND (INTVAL (operands[3])))
       emit_move_insn (operands[4], operands[3]);
     else
       operands[4] = operands[3];

     if (TARGET_ZBA && imm123_operand (operands[2], word_mode))
       {
	 rtx x = gen_rtx_ASHIFT (DImode, operands[1], operands[2]);
	 x = gen_rtx_PLUS (DImode, x, operands[4]);
	 emit_insn (gen_rtx_SET (operands[0], x));
       }
     else
       {
	 rtx x = gen_rtx_ASHIFT (DImode, operands[1], operands[2]);
	 emit_insn (gen_rtx_SET (operands[0], x));
	 x = gen_rtx_PLUS (DImode, operands[0], operands[4]);
	 emit_insn (gen_rtx_SET (operands[0], x));
       }

     DONE;
   }"
  [(set_attr "type" "arith")])

(define_insn_and_split ""
  [(set (match_operand:DI 0 "register_operand" "=r")
	(sign_extend:DI (plus:SI (ashift:SI
				   (match_operand:SI 1 "register_operand" "r")
				   (match_operand 2 "const_int_operand" "n"))
				 (match_operand 3 "const_int_operand" "n"))))
   (clobber (match_scratch:DI 4 "=&r"))]
  "(TARGET_64BIT && riscv_const_insns (operands[3], false) == 1)"
  "#"
  "&& reload_completed"
  [(const_int 0)]
  "{
     operands[1] = gen_lowpart (DImode, operands[1]);
     operands[5] = gen_lowpart (SImode, operands[0]);
     operands[6] = gen_lowpart (SImode, operands[4]);

     rtx x = gen_rtx_ASHIFT (DImode, operands[1], operands[2]);
     emit_insn (gen_rtx_SET (operands[0], x));

     /* If the constant fits in a simm12, use it directly as we do not
	get another good chance to optimize things again.  */
     if (!SMALL_OPERAND (INTVAL (operands[3])))
       emit_move_insn (operands[4], operands[3]);
     else
       operands[6] = operands[3];

     x = gen_rtx_PLUS (SImode, operands[5], operands[6]);
     x = gen_rtx_SIGN_EXTEND (DImode, x);
     emit_insn (gen_rtx_SET (operands[0], x));
     DONE;
   }"
  [(set_attr "type" "arith")])

;; Shadow stack

(define_insn "@sspush<mode>"
  [(unspec_volatile [(match_operand:P 0 "x1x5_operand" "r")] UNSPECV_SSPUSH)]
  "TARGET_ZICFISS"
  "sspush\t%0"
  [(set_attr "type" "arith")
   (set_attr "mode" "<MODE>")])

(define_insn "@sspopchk<mode>"
  [(unspec_volatile [(match_operand:P 0 "x1x5_operand" "r")] UNSPECV_SSPOPCHK)]
  "TARGET_ZICFISS"
  "sspopchk\t%0"
  [(set_attr "type" "arith")
   (set_attr "mode" "<MODE>")])

(define_insn "@ssrdp<mode>"
  [(set (match_operand:P 0 "register_operand" "=r")
	(unspec_volatile [(const_int 0)] UNSPECV_SSRDP))]
  "TARGET_ZICFISS"
  "ssrdp\t%0"
  [(set_attr "type" "arith")
   (set_attr "mode" "<MODE>")])

(define_insn "@write_ssp<mode>"
  [(unspec_volatile [(match_operand:P 0 "register_operand" "r")] UNSPECV_SSP)]
  "TARGET_ZICFISS"
  "csrw\tssp, %0"
  [(set_attr "type" "arith")
   (set_attr "mode" "<MODE>")])

;; Lading pad.

(define_insn "lpad"
  [(unspec_volatile [(match_operand 0 "immediate_operand" "i")] UNSPECV_LPAD)]
  "TARGET_ZICFILP"
  "lpad\t%0"
  [(set_attr "type" "auipc")])

(define_insn "@set_lpl<mode>"
  [(set (reg:GPR T2_REGNUM)
	(unspec_volatile [(match_operand:GPR 0 "immediate_operand" "i")] UNSPECV_SETLPL))]
   "TARGET_ZICFILP"
   "lui\tt2,%0"
  [(set_attr "type" "const")
   (set_attr "mode" "<MODE>")])

(define_insn "lpad_align"
  [(unspec_volatile [(const_int 0)] UNSPECV_LPAD_ALIGN)]
  "TARGET_ZICFILP"
  ".align 2"
  [(set_attr "type" "nop")])

(define_insn "@set_guarded<mode>"
  [(set (reg:GPR T2_REGNUM)
	(unspec_volatile [(match_operand:GPR 0 "register_operand" "r")] UNSPECV_SET_GUARDED))]
  "TARGET_ZICFILP"
  "mv\tt2,%0"
  [(set_attr "type" "move")
   (set_attr "mode" "<MODE>")])

;; If we're trying to create 0 or 2^n-1 based on the result of
;; a test such as (lt (reg) (const_int 0)), we'll see a splat of
;; the sign bit across a GPR using srai, then a logical and to
;; mask off high bits.  We can replace the logical and with
;; a logical right shift which works without constant synthesis
;; for larger constants.
(define_split
  [(set (match_operand:X 0 "register_operand")
	(and:X (ashiftrt:X (match_operand:X 1 "register_operand")
			   (match_operand 2 "const_int_operand"))
	       (match_operand 3 "const_int_operand")))]
  "(INTVAL (operands[2]) == BITS_PER_WORD - 1
    && exact_log2 (INTVAL (operands[3]) + 1) >= 0)"
  [(set (match_dup 0) (ashiftrt:X (match_dup 1) (match_dup 2)))
   (set (match_dup 0) (lshiftrt:X (match_dup 0) (match_dup 3)))]
  { operands[3] = GEN_INT (BITS_PER_WORD
			   - exact_log2 (INTVAL (operands[3]) + 1)); })

;; If a shift count is BITS_PER_WORD - 1 - N, then we can exploit the identity
;; that -x = ~x + 1 which is equivalent to (-1 - x) = ~x.  When shifting only
;; low bits of X matter (5 for SI, 6 for DI).  So 31/63 are equivalent to -1
;; for SI/DI shifts.
;;
;; Strangely, even for rv64, the shift computation is done in SI, presumably
;; something narrowed the arithmetic prior to gimple->rtl expansion.
;; Ultimately it gets wrapped with a SUBREG narrowing to QI.
(define_split
  [(set (match_operand:X 0 "register_operand")
	(any_shift_rotate:X
	  (match_operand:X 1 "register_operand")
	  (subreg:QI (minus:SI (match_operand 2 "bitpos_mask_operand")
			       (match_operand:SI 3 "register_operand")) 0)))
    (clobber (match_operand:X 4 "register_operand"))]
  ""
  [(set (match_dup 4) (not:X (match_dup 6)))
   (set (match_dup 0) (any_shift_rotate:X (match_dup 1) (match_dup 5)))]
 {
   operands[5] = gen_lowpart (QImode, operands[4]);
   operands[6] = gen_lowpart (word_mode, operands[3]);
 })

;; This is the same thing as the prior pattern, but for 32 bit shifts on rv64.
(define_split
  [(set (match_operand:DI 0 "register_operand")
	(sign_extend:DI
	 (any_shift_rotate:SI
	  (match_operand:SI 1 "register_operand")
	  (subreg:QI (minus:SI (const_int 31)
			       (match_operand:SI 2 "register_operand")) 0))))
    (clobber (match_operand:DI 3 "register_operand"))]
  "TARGET_64BIT"
  [(set (match_dup 3) (not:DI (match_dup 2)))
   (set (match_dup 0)
	(sign_extend:DI (any_shift_rotate:SI (match_dup 1)
					     (match_dup 4))))]
 {
   operands[2] = gen_lowpart (DImode, operands[2]);
   operands[4] = gen_lowpart (QImode, operands[3]);
 })

;; This is similar using a shift triplet to implement a logical AND when
;; the mask is a consecutive_bits_operand.
;;
;; The difference is we have a left shift in the input RTL and we verify
;; that clears the appropriate low bits.  So we can get away with just
;; two shifts.
(define_split
  [(set (match_operand:X 0 "register_operand")
	(and:X (ashift:X (match_operand:X 1 "register_operand")
			 (match_operand 2 "const_int_operand"))
		(match_operand 3 "consecutive_bits_operand")))
   (clobber (match_operand:X 4 "register_operand"))]
  "(ctz_hwi (INTVAL (operands[3]) & GET_MODE_MASK (word_mode))
    == INTVAL (operands[2]))"
  [(set (match_dup 4) (ashift:X (match_dup 1) (match_dup 5)))
   (set (match_dup 0) (lshiftrt:X (match_dup 4) (match_dup 6)))]
"{
  /* We want to left shift by the number of leading zeros in the mask,
     plus the number of bits shifted left by the pattern.  Remember that
     a HOST_WIDE_INT may be 64 bits, so clz on that value can count bits
     we don't care about for rv32.  */
  HOST_WIDE_INT lshift
    = clz_hwi (UINTVAL (operands[3])) % BITS_PER_WORD + INTVAL (operands[2]);
  operands[5] = gen_int_mode (lshift, QImode);

  /* And then we right shift things back into position.  */
  HOST_WIDE_INT rshift = lshift - INTVAL (operands[2]);
  operands[6] = gen_int_mode (rshift, QImode);
}")

;; EQ/NE of a sign bit splat against zero is just GE/LT 0, so we can
;; recognize it directly.  Note there may be a subreg expression buried
;; in there
(define_insn "*sign_bit_splat_equality_test"
  [(set (pc)
	(if_then_else
	 (any_eq
	  (subreg:SI (ashiftrt:DI (match_operand:DI 1 "register_operand" "r")
				  (const_int 63)) 0)
	  (const_int 0))
	 (label_ref (match_operand 0 "" ""))
	 (pc)))]
  "TARGET_64BIT"
{
  rtx x = PATTERN (insn);

  /* We'll always have a SET, so it's safe to extract the source.  */
  x = SET_SRC (x);

  /* Get the condition of the IF_THEN_ELSE.  */
  x = XEXP (x, 0);

  if (GET_CODE (x) == EQ)
    {
      if (get_attr_length (insn) == 12)
	return "blt\t%1,zero,1f; jump\t%l0,ra; 1:";
      return "bge\t%1,zero,%l0";
    }
  else if (GET_CODE (x) == NE)
    {
      if (get_attr_length (insn) == 12)
	return "bge\t%1,zero,1f; jump\t%l0,ra; 1:";
      return "blt\t%1,zero,%l0";
    }
  else
    gcc_unreachable ();
}
  [(set_attr "type" "branch")
   (set_attr "mode" "none")])

;; We can save an instruction for this case.  Essentially we can
;; test the (sanitized) shift count against zero.  This only comes
;; up for 32 bit objects on rv64.
(define_split
  [(set (match_operand:DI 0 "register_operand")
	(and:DI (subreg:DI
		 (ashift:SI (const_int 1)
			    (match_operand:QI 1 "register_operand")) 0)
		(const_int 1)))
   (clobber (match_operand:DI 2 "register_operand"))]
  "TARGET_64BIT"
  [(set (match_dup 2) (and:DI (match_dup 1) (const_int 31)))
   (set (match_dup 0) (eq:DI (match_dup 2) (const_int 0)))]
  { operands[1] = gen_lowpart (DImode, operands[1]); })

;; The basic idea is to realize that we can get the sign extension
;; for free when sign extracting a field shifting it such that
;; the sign bit of the field ends up in the SI sign bit.  In that
;; case it's just a slliw.
;;
;; It is tempting to do the extract+shift rewriting independent of
;; the outer AND.  But that's shown to regress code quality in other
;; contexts.  So we're being more conservative about trying to
;; exploit the free sign extension opportunities that show up with
;; shifted sign extractions
(define_split
  [(set (match_operand:DI 0 "register_operand")
	(and:DI
	 (ashift:DI (sign_extract:DI (match_operand:DI 1 "register_operand")
				     (match_operand 2 "const_int_operand")
				     (match_operand 3 "const_int_operand"))
		    (match_operand 4 "const_int_operand"))
	 (match_operand:DI 5 "const_int_operand")))
   (clobber (match_operand:DI 6 "register_operand"))]
  "(TARGET_64BIT
    && INTVAL (operands[2]) + INTVAL (operands[4]) == 32
    && SMALL_OPERAND (INTVAL (operands[5]) >> INTVAL (operands[4])))"
  [(set (match_dup 6) (and:DI (match_dup 1) (match_dup 5)))
   (set (match_dup 0) (sign_extend:DI (ashift:SI (match_dup 7) (match_dup 4))))]
{
  HOST_WIDE_INT new_mask = INTVAL (operands[5]) >> INTVAL (operands[4]);
  operands[5] = GEN_INT (new_mask);
  operands[7] = gen_lowpart (SImode, operands[6]);
})

(include "bitmanip.md")
(include "crypto.md")
(include "sync.md")
(include "sync-rvwmo.md")
(include "sync-ztso.md")
(include "peephole.md")
(include "pic.md")
(include "vector.md")
(include "vector-crypto.md")
(include "vector-bfloat16.md")
(include "zicond.md")
(include "mips-insn.md")
(include "sfb.md")
(include "zc.md")
;; Vendor extensions
(include "thead.md")
(include "corev.md")
(include "andes.md")
;; Pipeline models
(include "generic.md")
(include "xiangshan.md")
(include "mips-p8700.md")
(include "sifive-7.md")
(include "sifive-p400.md")
(include "sifive-p600.md")
(include "generic-vector-ooo.md")
(include "generic-ooo.md")
(include "tt-ascalon-d8.md")
(include "andes-23-series.md")
(include "andes-25-series.md")
(include "andes-45-series.md")
(include "spacemit-x60.md")
(include "arcv-rmx100.md")
(include "arcv-rhx100.md")
