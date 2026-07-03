#	_strncpy()					Author: Kees J. Bot
#								1 Jan 1994

.text
.global _strncpy
.type _strncpy, @function
.align 16

_strncpy:
	movl	12(%ebp), %edi	# edi = string s2
	xorb	%al, %al		# Look for a zero byte
	movl	%ecx, %edx		# Save maximum count
	cld
	repne scasb			# Look for end of s2
	subl	%ecx, %edx		# Number of bytes in s2 including null
	xchgl	%ecx, %edx
	movl	12(%ebp), %esi	# esi = string s2
	movl	8(%ebp), %edi	# edi = string s1
	rep movsb			# Copy bytes
	ret