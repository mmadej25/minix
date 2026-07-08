/* This is the C run-time start-off routine.  It's job is to take the
 * arguments as put on the stack by EXEC, and to parse them and set them up the
 * way _main expects them.
 * It also initializes _environ when this variable isn't defined by the
 * programmer.  The detection of whether _environ belong to us is rather
 * simplistic.  We simply check for some magic value, but there is no other
 * way.
 */

.text
.global begtext
begtext:

/* Standard ELF entry point alias */
.global _start
_start:
	jmp     crtso

.section .rom, "a"
.global begrom
begrom:

.data
.global begdata
begdata:

.bss
.global begbss
begbss:

.global crtso, __main, _penviron, _penvp, _fpu_present
.extern main, exit, environ, edata

.text
crtso:
	xorl    %ebp, %ebp		/* clear for backtrace of core files */
	movl    (%esp), %eax		/* argc */
	leal    4(%esp), %edx		/* argv */
	leal    8(%esp,%eax,4), %ecx	/* envp */

	/* Test if environ is in the initialized data area and is set to our
	 * magic number.  If so then it is not redefined by the user.
	 */
	movl	(environ), %ebx
	cmpl	(edata), %ebx		/* within initialized data? */
	jae	0f
	testb	$3, %bl			/* aligned? */
	jnz	0f
	cmpl	$0x53535353, (%ebx)	/* is it our environ? */
	jne	0f
	movl	%ebx, (_penviron)	/* _penviron = &environ; */
0:	movl	(_penviron), %ebx
	movl	%ecx, (%ebx)		/* *_penviron = envp; */

	pushl	%ecx			/* push envp */
	pushl	%edx			/* push argv */
	pushl	%eax			/* push argc */

	/* Test the EM bit of the MSW to determine if an FPU is present and
	 * set _fpu_present if one is found.
	 */
	smsw	%ax
	testb	$4, %al			/* EM bit set? (1 = no FPU) */
	setz	(_fpu_present)		/* _fpu_present = !EM; */

	call	main

	pushl	%eax			/* push exit status */
	call	exit

.data
	.align 4
_penviron:
	.long	environ			/* Pointer to environ or our environ */
_penvp:
	.long	0			/* Pointer to envp elements */

.bss
_fpu_present:
	.space	1			/* Is an FPU present? */