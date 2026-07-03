/* See src/kernel/ipc.h for C definitions */
.equ SEND, 1
.equ RECEIVE, 2
.equ SENDREC, 3 
.equ NOTIFY, 4
.equ ECHO, 8
.equ NB_SEND, 1 + 16 		/* flags 0x10 to prevent blocking */
.equ NB_RECEIVE, 2 + 16		/* flags 0x10 to prevent blocking */
.equ SYSVEC, 33			/* trap to kernel */

.equ SRC_DST, 8			/* source/ destination process */
.equ ECHO_MESS, 8			/* doesn't have SRC_DST */
.equ MESSAGE, 12			/* message pointer */

/*========================================================================*
 * IPC assembly routines			  *
 *========================================================================*/
/* all message passing routines save ebp, but destroy eax and ecx. */

.text
.global _echo, _notify, _send, _nb_send, _receive, _nb_receive, _sendrec
.type _send, @function
.type _nb_send, @function
.type _receive, @function
.type _nb_receive, @function
.type _sendrec, @function
.type _notify, @function
.type _echo, @function

_send:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	movl	SRC_DST(%ebp), %eax	/* eax = dest-src */
	movl	MESSAGE(%ebp), %ebx	/* ebx = message pointer */
	movl	$SEND, %ecx		/* _send(dest, ptr) */
	int	$SYSVEC			/* trap to the kernel */
	popl	%ebx
	popl	%ebp
	ret

_nb_send:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	movl	SRC_DST(%ebp), %eax	/* eax = dest-src */
	movl	MESSAGE(%ebp), %ebx	/* ebx = message pointer */
	movl	$NB_SEND, %ecx		/* _nb_send(dest, ptr) */
	int	$SYSVEC			/* trap to the kernel */
	popl	%ebx
	popl	%ebp
	ret

_receive:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	movl	SRC_DST(%ebp), %eax	/* eax = dest-src */
	movl	MESSAGE(%ebp), %ebx	/* ebx = message pointer */
	movl	$RECEIVE, %ecx		/* _receive(src, ptr) */
	int	$SYSVEC			/* trap to the kernel */
	popl	%ebx
	popl	%ebp
	ret

_nb_receive:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	movl	SRC_DST(%ebp), %eax	/* eax = dest-src */
	movl	MESSAGE(%ebp), %ebx	/* ebx = message pointer */
	movl	$NB_RECEIVE, %ecx	/* _nb_receive(src, ptr) */
	int	$SYSVEC			/* trap to the kernel */
	popl	%ebx
	popl	%ebp
	ret

_sendrec:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	movl	SRC_DST(%ebp), %eax	/* eax = dest-src */
	movl	MESSAGE(%ebp), %ebx	/* ebx = message pointer */
	movl	$SENDREC, %ecx		/* _sendrec(srcdest, ptr) */
	int	$SYSVEC			/* trap to the kernel */
	popl	%ebx
	popl	%ebp
	ret

_notify:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	movl	SRC_DST(%ebp), %eax	/* ebx = destination */
	movl	$NOTIFY, %ecx		/* _notify(srcdst) */
	int	$SYSVEC			/* trap to the kernel */
	popl	%ebx
	popl	%ebp
	ret

_echo:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	movl	ECHO_MESS(%ebp), %ebx	/* ebx = message pointer */
	movl	$ECHO, %ecx		/* _echo(srcdest, ptr) */
	int	$SYSVEC			/* trap to the kernel */
	popl	%ebx
	popl	%ebp
	ret