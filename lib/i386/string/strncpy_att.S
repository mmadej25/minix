#	strncpy()					Author: Kees J. Bot
#								1 Jan 1994

.text
.global strncpy
.type strncpy, @function
.align 16

strncpy:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%esi
	pushl	%edi
	movl	16(%ebp), %ecx	# Maximum length
	call	_strncpy		# Common code
	movl	%edx, %ecx		# Number of bytes not copied
	rep stosb			# strncpy always copies n bytes by null padding
	movl	8(%ebp), %eax	# Return s1
	popl	%edi
	popl	%esi
	popl	%ebp
	ret