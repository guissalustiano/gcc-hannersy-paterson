	.file	"sc1_add.c"
	.option nopic
	.text
	.align	2
	.globl	add
	.type	add, @function
add:
	add	a0,a0,a1
	ret
	.size	add, .-add
	.ident	"GCC: (GNU) 17.0.0 20260509 (experimental)"
	.section	.note.GNU-stack,"",@progbits
