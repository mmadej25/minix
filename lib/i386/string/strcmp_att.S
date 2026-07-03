#	strcmp()					Author: Kees J. Bot
#								1 Jan 1994

# int strcmp(const char *s1, const char *s2)
#	Compare two strings.
#
.text
.global strcmp
.type strcmp, @function
.align 16

strcmp:
	movl	$-1, %ecx	# Unlimited length
	jmp	_strncmp	# Common code