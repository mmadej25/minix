#	inl() - Input one dword				Author: Kees J. Bot
#								18 Mar 1996
#	unsigned inl(U16_t port);

.text
.global inl
.type inl, @function

inl:
	pushl	%ebp
	movl	%esp, %ebp
	movl	8(%ebp), %edx		# port
	inl	%dx, %eax			# read 1 dword
	popl	%ebp
	ret