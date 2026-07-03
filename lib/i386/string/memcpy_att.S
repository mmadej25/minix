/*	memcpy()					Author: Kees J. Bot
 *								2 Jan 1994
 *
 * void *memcpy(void *s1, const void *s2, size_t n)
 *	Copy a chunk of memory.
 *	This routine need not handle overlap, so it does not handle overlap.
 *	One could simply call __memmove, the cost of the overlap check is
 *	negligible, but you are dealing with a programmer who believes that
 *	if anything can go wrong, it should go wrong.
 */

.text
.global memcpy
.type memcpy, @function
.align 16

memcpy:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%esi
	pushl	%edi
	movl	8(%ebp), %edi	# String s1
	movl	12(%ebp), %esi	# String s2
	movl	16(%ebp), %ecx	# Length
	# No overlap check here
	jmp	_memcpy		# Call the part of __memmove that copies up