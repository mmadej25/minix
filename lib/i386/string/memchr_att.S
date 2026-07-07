#	memchr()					Author: Kees J. Bot
#								2 Jan 1994
.sect .text; .sect .rom; .sect .data; .sect .bss

# void *memchr(const void *s, int c, size_t n)
#	Look for a character in a chunk of memory.
#
.sect .text
.global memchr
	.align	16
memchr:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%edi
	movl	8(%ebp), %edi	# edi = string
	movb	12(%ebp), %al	# The character to look for
	movl	16(%ebp), %ecx	# Length
	cmpb	$1, %cl		# 'Z' bit must be clear if ecx = 0
	cld
	repne
	scasb
	jne	failure
	leal	-1(%edi), %eax	# Found
	popl	%edi
	popl	%ebp
	ret
failure:xorl	%eax, %eax
	popl	%edi
	popl	%ebp
	ret