#	memset()								Author: Kees J. Bot
#											2 Jan 1994
.text
.section .rodata
.data
.bss

# void *memset(void *s, int c, size_t n)
#	Set a chunk of memory to the same byte value.
#
.text
.global _memset
.global memset
	.align	16
_memset:
memset:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%edi
	movl	8(%ebp), %edi	# The string
	movzbl	12(%ebp), %eax	# The fill byte
	movl	16(%ebp), %ecx	# Length
	cld
	cmpl	$16, %ecx
	jb	sbyte		# Don't bother being smart with short arrays
	testl	$1, %edi
	jnz	sbyte		# Bit 0 set, use byte store
	testl	$2, %edi
	jnz	sword		# Bit 1 set, use word store
slword:	movb	%al, %ah
	movl	%eax, %edx
	sall	$16, %edx
	orl	%edx, %eax	# One byte to four bytes
	shrdl	$2, %ecx, %edx	# Save low two bits of ecx in edx
	shrl	$2, %ecx
	rep
	stosl			# Store longwords.
	shldl	$2, %edx, %ecx	# Restore low two bits
sword:	movb	%al, %ah	# One byte to two bytes
	shrl	$1, %ecx
	rep
	stosw			# Store words.
	shll	$1, %ecx
	andl	$1, %ecx	# One single byte left?
sbyte:	rep
	stosb			# Store bytes.
	movl	8(%ebp), %eax	# Return value
	popl	%edi
	popl	%ebp
	ret
