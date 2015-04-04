	.file	"printk.c"
	.text
	.align 2
.globl Printk
	.type	Printk,@function
Printk:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	ConsoleWrite
	subl	$4, %esp
	movl	$0, %eax
	leave
	ret	$4
.Lfe1:
	.size	Printk,.Lfe1-Printk
	.align 2
.globl Hex2Asc
	.type	Hex2Asc,@function
Hex2Asc:
	pushl	%ebp
	movl	%esp, %ebp
	movl	8(%ebp), %edx
	movl	12(%ebp), %eax
	sarl	$4, %eax
	andb	$15, %al
	addb	$48, %al
	movb	%al, (%edx)
	movl	8(%ebp), %eax
	cmpb	$57, (%eax)
	jle	.L3
	movl	8(%ebp), %eax
	movl	8(%ebp), %edx
	movzbl	(%edx), %edx
	addb	$7, %dl
	movb	%dl, (%eax)
.L3:
	movl	8(%ebp), %edx
	incl	%edx
	movzbl	12(%ebp), %eax
	andb	$15, %al
	addb	$48, %al
	movb	%al, (%edx)
	movl	8(%ebp), %eax
	incl	%eax
	cmpb	$57, (%eax)
	jle	.L4
	movl	8(%ebp), %eax
	incl	%eax
	movl	8(%ebp), %edx
	incl	%edx
	movzbl	(%edx), %edx
	addb	$7, %dl
	movb	%dl, (%eax)
.L4:
	movl	8(%ebp), %eax
	popl	%ebp
	ret	$8
.Lfe2:
	.size	Hex2Asc,.Lfe2-Hex2Asc
	.align 2
.globl PrintB
	.type	PrintB,@function
PrintB:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$40, %esp
	movb	$0, -22(%ebp)
	movl	8(%ebp), %eax
	movl	%eax, 4(%esp)
	leal	-24(%ebp), %eax
	movl	%eax, (%esp)
	call	Hex2Asc
	subl	$8, %esp
	movl	%eax, (%esp)
	call	Printk
	subl	$4, %esp
	leave
	ret	$4
.Lfe3:
	.size	PrintB,.Lfe3-PrintB
	.align 2
.globl PrintW
	.type	PrintW,@function
PrintW:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	8(%ebp), %eax
	sarl	$8, %eax
	movl	%eax, (%esp)
	call	PrintB
	subl	$4, %esp
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	PrintB
	subl	$4, %esp
	leave
	ret	$4
.Lfe4:
	.size	PrintW,.Lfe4-PrintW
	.align 2
.globl PrintD
	.type	PrintD,@function
PrintD:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	8(%ebp), %eax
	sarl	$16, %eax
	movl	%eax, (%esp)
	call	PrintW
	subl	$4, %esp
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	PrintW
	subl	$4, %esp
	leave
	ret	$4
.Lfe5:
	.size	PrintD,.Lfe5-PrintD
	.ident	"GCC: (GNU) 3.2"
