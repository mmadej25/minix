#	strncmp()					Author: Kees J. Bot
#								1 Jan 1994

# int strncmp(const char *s1, const char *s2, size_t ecx)
#	Compare two strings.
#
.text
.global _strncmp
.type _strncmp, @function
.align 16

_strncmp:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%esi
	pushl	%edi
	testl	%ecx, %ecx	# Max length is zero?
	je	done
	movl	8(%ebp), %esi	# esi = string s1
	movl	12(%ebp), %edi	# edi = string s2
	cld
compare:
	cmpsb			# Compare two bytes
	jne	done
	cmpb	$0, -1(%esi)	# End of string?
	je	done
	decl	%ecx		# Length limit reached?
	jne	compare
done:
	seta	%al		# al = (s1 > s2)
	setb	%ah		# ah = (s1 < s2)
	subb	%ah, %al
	movsbl	%al, %eax	# eax = (s1 > s2) - (s1 < s2), i.e. -1, 0, 1
	popl	%edi
	popl	%esi
	popl	%ebp
	ret