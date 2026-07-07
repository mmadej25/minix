#	strncmp()					Author: Kees J. Bot
#								1 Jan 1994
.sect .text; .sect .rom; .sect .data; .sect .bss

# int strncmp(const char *s1, const char *s2, size_t n)
#	Compare two strings.
#
.sect .text
.global strncmp
	.align	16
strncmp:
	movl	12(%esp), %ecx	# Maximum length
	jmp	_strncmp	# Common code