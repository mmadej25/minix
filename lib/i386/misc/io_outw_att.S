#	outw() - Output one word			Author: Kees J. Bot
#								18 Mar 1996
#	void outw(U16_t port, U16_t value);

.text
.global outw
.type outw, @function

outw:
	pushl	%ebp
	movl	%esp, %ebp
	movl	8(%ebp), %edx		# port
	movl	12(%ebp), %eax		# value
	outw	%ax, %dx			# output 1 word
	popl	%ebp
	ret