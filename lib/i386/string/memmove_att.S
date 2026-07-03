/*	memmove()					Author: Kees J. Bot
 *								2 Jan 1994
 *
 * void *memmove(void *s1, const void *s2, size_t n)
 *	Copy a chunk of memory.  Handle overlap.
 */

.text
.global memmove
.type memmove, @function
.align 16

memmove:
	jmp	_memmove	/* Call common code */