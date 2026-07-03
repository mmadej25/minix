#	inw() - Input one word				Author: Kees J. Bot
#								18 Mar 1996
#	unsigned inw(U16_t port);

.text
.global inw
.type inw, @function

inw:
	pushl	%ebp
	movl	%esp, %ebp
	movl	8(%ebp), %edx		# port
	xorl	%eax, %eax
	inw	%dx, %ax			# read 1 word
	popl	%ebp
	ret