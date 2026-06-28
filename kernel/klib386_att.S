/* ==============================================================================
 * src/kernel/klib386_att.S
 * Assembly utility routines for MINIX jądra (GNU Assembler AT&T syntax)
 * ============================================================================== */

#include <minix/config.h>
#include <minix/const.h>
#include "const.h"
#include "sconst_att.h"
#include "protect.h"

.global monitor
.global int86
.global cp_mess
.global exit
.global _exit
.global __exit
.global ___main
.global phys_insw
.global phys_insb
.global phys_outsw
.global phys_outsb
.global enable_irq
.global disable_irq
.global phys_copy
.global phys_memset
.global mem_rdw
.global reset
.global idle_task
.global level0
.global read_tsc
.global read_cpu_flags

/* Externs from C */
.text

/* ========================================================================= */
/*				monitor					     */
/* ========================================================================= */
/* PUBLIC void monitor(); */
monitor:
	movl	(mon_sp), %esp		/* odtwórz wskaźnik stosu monitora */
	movw	$SS_SELECTOR, %dx	/* segment danych monitora */
	movw	%dx, %ds
	movw	%dx, %es
	movw	%dx, %fs
	movw	%dx, %gs
	movw	%dx, %ss
	popl	%edi
	popl	%esi
	popl	%ebp
	lretw				/* powrót do monitora (16-bit far return) */

/* ========================================================================= */
/*				int86					     */
/* ========================================================================= */
/* PUBLIC void int86(); */
int86:
	cmpb	$0, (mon_return)	/* czy monitor jest dostępny? */
	jnz	0f
	movb	$0x01, %ah		/* błąd int 13 */
	movb	%ah, (reg86 + 0)	/* reg86.w.f = 1 (Cary Flag) */
	movb	%ah, (reg86 + 13)	/* reg86.b.ah = 0x01 = invalid command */
	ret
0:	pushl	%ebp
	pushl	%esi
	pushl	%edi
	pushl	%ebx
	pushf
	cli

	inb	$INT2_CTLMASK, %al
	movb	%al, %ah
	inb	$INT_CTLMASK, %al
	pushl	%eax			/* zapisz maski przerwań */
	movl	(irq_use), %eax
	andl	$~(1 << CLOCK_IRQ), %eax
	outb	%al, $INT_CTLMASK
	movb	%ah, %al
	outb	%al, $INT2_CTLMASK

	movl	$SS_SELECTOR, %eax
	movl	%eax, %ss
	xchgl	%esp, (mon_sp)		/* zamiana stosów */
	pushl	(reg86 + 36)
	pushl	(reg86 + 32)
	pushl	(reg86 + 28)
	pushl	(reg86 + 24)
	pushl	(reg86 + 20)
	pushl	(reg86 + 16)
	pushl	(reg86 + 12)
	pushl	(reg86 + 8)
	pushl	(reg86 + 4)
	pushl	(reg86 + 0)
	movl	%eax, %ds
	movl	%eax, %es
	movl	%eax, %fs
	movl	%eax, %gs
	pushl	%cs
	pushl	$return
	/* Konstrukcja dalekiego skoku przez stos do monitora */
	ljmp	*(20 + 2*4 + 10*4 + 2*4)(%esp)
return:
	popl	(reg86 + 0)
	popl	(reg86 + 4)
	popl	(reg86 + 8)
	popl	(reg86 + 12)
	popl	(reg86 + 16)
	popl	(reg86 + 20)
	popl	(reg86 + 24)
	popl	(reg86 + 28)
	popl	(reg86 + 32)
	popl	(reg86 + 36)
	lgdt	(gdt + GDT_SELECTOR)
	ljmp	$CS_SELECTOR, $csinit
csinit:	movl	$DS_SELECTOR, %eax
	movl	%eax, %ds
	movl	%eax, %es
	movl	%eax, %fs
	movl	%eax, %gs
	movl	%eax, %ss
	xchgl	%esp, (mon_sp)
	lidt	(gdt + IDT_SELECTOR)
	andb	$~0x02, (gdt + TSS_SELECTOR + DESC_ACCESS)
	movl	$TSS_SELECTOR, %eax
	ltr	%ax

	popl	%eax
	outb	%al, $INT_CTLMASK
	movb	%ah, %al
	outb	%al, $INT2_CTLMASK

	addl	%ecx, (lost_ticks)

	popf
	popl	%ebx
	popl	%edi
	popl	%esi
	popl	%ebp
	ret

/* ========================================================================= */
/*				cp_mess					     */
/* ========================================================================= */
#define CM_ARGS (4 + 4 + 4 + 4 + 4)

.align 16
cp_mess:
	cld
	pushl	%esi
	pushl	%edi
	pushl	%ds
	pushl	%es

	movl	$FLAT_DS_SELECTOR, %eax
	movl	%eax, %ds
	movl	%eax, %es

	movl	(CM_ARGS + 4)(%esp), %esi	/* src clicks */
	shl	$CLICK_SHIFT, %esi
	addl	(CM_ARGS + 4 + 4)(%esp), %esi	/* src offset */
	movl	(CM_ARGS + 4 + 4 + 4)(%esp), %edi /* dst clicks */
	shl	$CLICK_SHIFT, %edi
	addl	(CM_ARGS + 4 + 4 + 4 + 4)(%esp), %edi /* dst offset */

	movl	CM_ARGS(%esp), %eax		/* nr procesu nadawcy */
	stosl					/* kopiuj numer do wiadomości docelowej */
	addl	$4, %esi
	movl	$(Msize - 1), %ecx
	rep	movsl

	popl	%es
	popl	%ds
	popl	%edi
	popl	%esi
	ret

/* ========================================================================= */
/*				exit					     */
/* ========================================================================= */
exit:
_exit:
__exit:
	sti
	jmp	__exit

___main:
	ret

/* ========================================================================= */
/*				phys_insw				     */
/* ========================================================================= */
phys_insw:
	pushl	%ebp
	movl	%esp, %ebp
	cld
	pushl	%edi
	pushl	%es
	movl	$FLAT_DS_SELECTOR, %ecx
	movl	%ecx, %es
	movl	8(%ebp), %edx		/* port */
	movl	12(%ebp), %edi		/* bufor docelowy */
	movl	16(%ebp), %ecx		/* licznik bajtów */
	shrl	$1, %ecx		/* zamiana na słowa (words) */
	rep	insw
	popl	%es
	popl	%edi
	popl	%ebp
	ret

/* ========================================================================= */
/*				phys_insb				     */
/* ========================================================================= */
phys_insb:
	pushl	%ebp
	movl	%esp, %ebp
	cld
	pushl	%edi
	pushl	%es
	movl	$FLAT_DS_SELECTOR, %ecx
	movl	%ecx, %es
	movl	8(%ebp), %edx
	movl	12(%ebp), %edi
	movl	16(%ebp), %ecx
	rep	insb
	popl	%es
	popl	%edi
	popl	%ebp
	ret

/* ========================================================================= */
/*				phys_outsw				     */
/* ========================================================================= */
.align 16
phys_outsw:
	pushl	%ebp
	movl	%esp, %ebp
	cld
	pushl	%esi
	pushl	%ds
	movl	$FLAT_DS_SELECTOR, %ecx
	movl	%ecx, %ds
	movl	8(%ebp), %edx
	movl	12(%ebp), %esi
	movl	16(%ebp), %ecx
	shrl	$1, %ecx
	rep	outsw
	popl	%ds
	popl	%esi
	popl	%ebp
	ret

/* ========================================================================= */
/*				phys_outsb				     */
/* ========================================================================= */
.align 16
phys_outsb:
	pushl	%ebp
	movl	%esp, %ebp
	cld
	pushl	%esi
	pushl	%ds
	movl	$FLAT_DS_SELECTOR, %ecx
	movl	%ecx, %ds
	movl	8(%ebp), %edx
	movl	12(%ebp), %esi
	movl	16(%ebp), %ecx
	rep	outsb
	popl	%ds
	popl	%esi
	popl	%ebp
	ret

/* ========================================================================= */
/*				enable_irq				     */
/* ========================================================================= */
.align 16
enable_irq:
	pushl	%ebp
	movl	%esp, %ebp
	pushf
	cli
	movl	8(%ebp), %eax		/* hook */
	movl	8(%eax), %ecx		/* irq */
	movl	12(%eax), %eax		/* id bit */
	notl	%eax
	andl	%eax, irq_actids(,%ecx,4)
	jnz	en_done
	movb	$~1, %ah
	rolb	%cl, %ah
	movl	$INT_CTLMASK, %edx
	cmpb	$8, %cl
	jb	0f
	movl	$INT2_CTLMASK, %edx
0:	inb	(%dx), %al
	andb	%ah, %al
	outb	%al, (%dx)
en_done:
	popf
	leave
	ret

/* ========================================================================= */
/*				disable_irq				     */
/* ========================================================================= */
.align 16
disable_irq:
	pushl	%ebp
	movl	%esp, %ebp
	pushf
	cli
	movl	8(%ebp), %eax
	movl	8(%eax), %ecx
	movl	12(%eax), %eax
	orl	%eax, irq_actids(,%ecx,4)
	movb	$1, %ah
	rolb	%cl, %ah
	movl	$INT_CTLMASK, %edx
	cmpb	$8, %cl
	jb	0f
	movl	$INT2_CTLMASK, %edx
0:	inb	(%dx), %al
	testb	%ah, %al
	jnz	dis_already
	orb	%ah, %al
	outb	%al, (%dx)
	movl	$1, %eax
	popf
	leave
	ret
dis_already:
	xorl	%eax, %eax
	popf
	leave
	ret

/* ========================================================================= */
/*				phys_copy				     */
/* ========================================================================= */
#define PC_ARGS (4 + 4 + 4 + 4)

.align 16
phys_copy:
	cld
	pushl	%esi
	pushl	%edi
	pushl	%es

	movl	$FLAT_DS_SELECTOR, %eax
	movl	%eax, %es

	movl	PC_ARGS(%esp), %esi
	movl	(PC_ARGS + 4)(%esp), %edi
	movl	(PC_ARGS + 4 + 4)(%esp), %eax

	cmpl	$10, %eax
	jb	pc_small
	movl	%esi, %ecx
	negl	%ecx
	andl	$3, %ecx
	subl	%ecx, %eax
	rep	movsb
	movl	%eax, %ecx
	shrl	$2, %ecx
	rep	movsl
	andl	$3, %eax
pc_small:
	xchgl	%eax, %ecx
	rep	movsb

	popl	%es
	popl	%edi
	popl	%esi
	ret

/* ========================================================================= */
/*				phys_memset				     */
/* ========================================================================= */
.align 16
phys_memset:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%esi
	pushl	%ebx
	pushl	%ds
	movl	8(%ebp), %esi
	movl	16(%ebp), %eax
	movl	$FLAT_DS_SELECTOR, %ebx
	movl	%ebx, %ds
	movl	12(%ebp), %ebx
	shrl	$2, %eax
fill_start:
	movl	%ebx, (%esi)
	addl	$4, %esi
	decl	%eax
	jnz	fill_start
	movl	16(%ebp), %eax
	andl	$3, %eax
remain_fill:
	cmpl	$0, %eax
	jz	fill_done
	movb	12(%ebp), %bl
	movb	%bl, (%esi)
	addl	$1, %esi
	incl	%ebp
	decl	%eax
	jmp	remain_fill
fill_done:
	popl	%ds
	popl	%ebx
	popl	%esi
	popl	%ebp
	ret

/* ========================================================================= */
/*				mem_rdw					     */
/* ========================================================================= */
.align 16
mem_rdw:
	movw	%ds, %cx
	movw	4(%esp), %ds
	movl	(4 + 4)(%esp), %eax
	movzwl	(%eax), %eax
	movw	%cx, %ds
	ret

/* ========================================================================= */
/*				reset					     */
/* ========================================================================= */
reset:
	lidt	(idt_zero)
	int	$3
.data
idt_zero:
	.long	0, 0
.text

/* ========================================================================= */
/*				idle_task				     */
/* ========================================================================= */
idle_task:
	pushl	$halt
	call	level0
	popl	%eax
	jmp	idle_task
halt:
	sti
	hlt
	cli
	ret

/* ========================================================================= */
/*				level0					     */
/* ========================================================================= */
level0:
	movl	4(%esp), %eax
	movl	%eax, (level0_func)
	int	$LEVEL0_VECTOR
	ret

/* ========================================================================= */
/*				read_tsc				     */
/* ========================================================================= */
.align 16
read_tsc:
	rdtsc				/* instrukcja rdtsc ładuje EDX:EAX */
	pushl	%ebp
	movl	8(%esp), %ebp
	movl	%edx, (%ebp)
	movl	12(%esp), %ebp
	movl	%eax, (%ebp)
	popl	%ebp
	ret

/* ========================================================================= */
/*				read_cpu_flags				     */
/* ========================================================================= */
.align 16
read_cpu_flags:
	pushf
	movl	(%esp), %eax
	popf
	ret

/* Pusta linia na końcu wymagana przez GAS */
