	.file	"sc1_call.c"
	.option nopic
	.text
	.align	2
	.globl	bar
	.type	bar, @function
bar:
	addi	sp,sp,-16
	sw	ra,12(sp)
	addi	a0,a0,1
	lui	t1,%hi(foo)
	addi	t1,t1,%lo(foo)
	jalr	t1
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	bar, .-bar
	.ident	"GCC: (GNU) 17.0.0 20260509 (experimental)"
	.section	.note.GNU-stack,"",@progbits
