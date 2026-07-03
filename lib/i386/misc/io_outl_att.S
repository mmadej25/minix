#	outl() - Output one dword			Author: Kees J. Bot
#								18 Mar 1996
#	void outl(U16_t port, u32_t value);

.text
.global outl
.type outl, @function

outl:
	pushl	%ebp
	movl	%esp, %ebp
	movl	8(%ebp), %edx		# port
	movl	12(%ebp), %eax		# value
	outl	%eax, %dx			# output 1 dword
	popl	%ebp
	ret