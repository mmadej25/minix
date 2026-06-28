# ==============================================================================
# src/kernel/mpx386.S
# Low-level protected mode interrupt and process switching for GNU Assembler
# ==============================================================================

# This file, mpx386.S, is included by mpx.s when Minix is compiled for 
# 32-bit Intel CPUs. The alternative mpx88.s is compiled for 16-bit CPUs.

# This file is part of the lowest layer of the MINIX kernel.  (The other part
# is "proc.c".)  The lowest layer does process switching and message handling.
# Furthermore it contains the assembler startup code for Minix and the 32-bit
# interrupt handlers.  It cooperates with the code in "start.c" to set up a 
# good environment for main().

# Every transition to the kernel goes through this file.  Transitions to the 
# kernel may be nested.  The initial entry may be with a system call (i.e., 
# send or receive a message), an exception or a hardware interrupt;  kernel 
# reentries may only be made by hardware interrupts.  The count of reentries 
# is kept in "k_reenter". It is important for deciding whether to switch to 
# the kernel stack and for protecting the message passing code in "proc.c".

# For the message passing trap, most of the machine state is saved in the
# proc table.  (Some of the registers need not be saved.)  Then the stack is
# switched to "k_stack", and interrupts are reenabled.  Finally, the system
# call handler (in C) is called.  When it returns, interrupts are disabled
# again and the code falls into the restart routine, to finish off held-up
# interrupts and run the process or task whose pointer is in "proc_ptr".

# Hardware interrupt handlers do the same, except  (1) The entire state must
# be saved.  (2) There are too many handlers to do this inline, so the save
# routine is called.  A few cycles are saved by pushing the address of the
# appropiate restart routine for a return later.  (3) A stack switch is
# avoided when the stack is already switched.  (4) The (master) 8259 interrupt
# controller is reenabled centrally in save().  (5) Each interrupt handler
# masks its interrupt line using the 8259 before enabling (other unmasked)
# interrupts, and unmasks it after servicing the interrupt.  This limits the
# nest level to the number of lines and protects the handler from itself.

# For communication with the boot monitor at startup time some constant
# data are compiled into the beginning of the text segment. This facilitates 
# reading the data at the start of the boot process, since only the first
# sector of the file needs to be read.

# Some data storage is also allocated at the end of this file. This data 
# will be at the start of the data segment of the kernel and will be read
# and modified by the boot monitor before the kernel starts.

.text
begtext:
.section .rodata
begrom:
.data
begdata:
.bss
begbss:

#include <minix/config.h>
#include <minix/const.h>
#include <minix/com.h>
#include <ibm/interrupt.h>
#include "const.h"
#include "protect.h"
#include "sconst_att.h"

/* Selected 386 tss offsets. */
#define TSS3_S_SP0	4

# Exported functions
# Note: in assembly language the .define statement applied to a function name 
# is loosely equivalent to a prototype in C code -- it makes it possible to
# link to an entity declared in the assembly code but does not create
# the entity.

.global restart
.global save

.global divide_error
.global single_step_exception
.global nmi
.global breakpoint_exception
.global overflow
.global bounds_check
.global inval_opcode
.global copr_not_available
.global double_fault
.global copr_seg_overrun
.global inval_tss
.global segment_not_present
.global stack_exception
.global general_protection
.global page_fault
.global copr_error

.global hwint00	# handlers for hardware interrupts
.global hwint01
.global hwint02
.global hwint03
.global hwint04
.global hwint05
.global hwint06
.global hwint07
.global hwint08
.global hwint09
.global hwint10
.global hwint11
.global hwint12
.global hwint13
.global hwint14
.global hwint15

.global s_call
.global p_s_call
.global level0_call

# Exported variables.
.global begbss
.global begdata

.text
#*===========================================================================*
#*				MINIX					     *
#*===========================================================================*
.global MINIX
MINIX:				# this is the entry point for the MINIX kernel
	jmp	over_flags	# skip over the next few bytes
	.short	CLICK_SHIFT	# for the monitor: memory granularity
flags:
	.short	0x01FD		# boot monitor flags:
				#	call in 386 mode, make bss, make stack,
				#	load high, don't patch, will return,
				#	uses generic INT, memory vector,
				#	new boot code return
	nop			# extra byte to sync up disassembler
over_flags:

# Set up a C stack frame on the monitor stack.  (The monitor sets cs and ds
# right.  The ss descriptor still references the monitor data segment.)
	movzwl	%sp, %esp	# monitor stack is a 16 bit stack
	pushl	%ebp
	movl	%esp, %ebp
	cmpl	$0, 4(%ebp)	# monitor return vector is
	jz	noret		# nonzero if return possible
	incl	mon_return
noret:	movl	%esp, mon_sp	# save stack pointer for later return

# Copy the monitor global descriptor table to the address space of kernel and
# switch over to it.  Prot_init() can then update it with immediate effect.

	sgdt	gdt+GDT_SELECTOR		# get the monitor gdtr
	movl	gdt+GDT_SELECTOR+2, %esi	# absolute address of GDT
	movl	$gdt, %ebx			# address of kernel GDT
	movl	$8*8, %ecx			# copying eight descriptors
copygdt:
	movb	%es:(%esi), %al
	movb	%al, (%ebx)
	incl	%esi
	incl	%ebx
	loop	copygdt
	movl	gdt+DS_SELECTOR+2, %eax	# base of kernel data
	andl	$0x00FFFFFF, %eax		# only 24 bits
	addl	$gdt, %eax			# eax = vir2phys(gdt)
	movl	%eax, gdt+GDT_SELECTOR+2	# set base of GDT
	lgdt	gdt+GDT_SELECTOR		# switch over to kernel GDT

# Locate boot parameters, set up kernel segment registers and stack.
	movl	8(%ebp), %ebx	# boot parameters offset
	movl	12(%ebp), %edx	# boot parameters length
	movl	16(%ebp), %eax	# address of a.out headers
	movl	%eax, aout
	movw	%ds, %ax	# kernel data
	movw	%ax, %es
	movw	%ax, %fs
	movw	%ax, %gs
	movw	%ax, %ss
	movl	$k_stktop, %esp	# set sp to point to the top of kernel stack

# Call C startup code to set up a proper environment to run main().
	pushl	%edx
	pushl	%ebx
	pushl	$SS_SELECTOR
	pushl	$DS_SELECTOR
	pushl	$CS_SELECTOR
	call	cstart		# cstart(cs, ds, mds, parmoff, parmlen)
	addl	$5*4, %esp

# Reload gdtr, idtr and the segment registers to global descriptor table set
# up by prot_init().

	lgdt	gdt+GDT_SELECTOR
	lidt	gdt+IDT_SELECTOR

	ljmp	$CS_SELECTOR, $csinit
csinit:
	movw	$DS_SELECTOR, %ax
	movw	%ax, %ds
	movw	%ax, %es
	movw	%ax, %fs
	movw	%ax, %gs
	movw	%ax, %ss
	movw	$TSS_SELECTOR, %ax	# no other TSS is used
	ltr	%ax
	pushl	$0			# set flags to known good state
	popfl				# esp, clear nested task and int enable

	jmp	main			# main()


#*===========================================================================*
#*				interrupt handlers			     *
#*		interrupt handlers for 386 32-bit protected mode	     *
#*===========================================================================*

#*===========================================================================*
#*				hwint00 - 07				     *
#*===========================================================================*
# Note this is a macro, it just looks like a subroutine.
.macro hwint_master irq
	call	save			# save interrupted process state
	pushl	irq_handlers+4*\irq	# irq_handlers[irq]
	call	intr_handle		# intr_handle(irq_handlers[irq])
	popl	%ecx
	cmpl	$0, irq_actids+4*\irq	# interrupt still active?
	jz	0f
	inb	$INT_CTLMASK, %al	# get current mask
	orb	$(1<<\irq), %al		# mask irq
	outb	%al, $INT_CTLMASK	# disable the irq
0:	movb	$END_OF_INT, %al
	outb	%al, $INT_CTL			# reenable master 8259
	ret				# restart (another) process
.endm

# Each of these entry points is an expansion of the hwint_master macro
	.align	16
hwint00:		# Interrupt routine for irq 0 (the clock).
	hwint_master 0

	.align	16
hwint01:		# Interrupt routine for irq 1 (keyboard)
	hwint_master 1

	.align	16
hwint02:		# Interrupt routine for irq 2 (cascade!)
	hwint_master 2

	.align	16
hwint03:		# Interrupt routine for irq 3 (second serial)
	hwint_master 3

	.align	16
hwint04:		# Interrupt routine for irq 4 (first serial)
	hwint_master 4

	.align	16
hwint05:		# Interrupt routine for irq 5 (XT winchester)
	hwint_master 5

	.align	16
hwint06:		# Interrupt routine for irq 6 (floppy)
	hwint_master 6

	.align	16
hwint07:		# Interrupt routine for irq 7 (printer)
	hwint_master 7

#*===========================================================================*
#*				hwint08 - 15				     *
#*===========================================================================*
# Note this is a macro, it just looks like a subroutine.
.macro hwint_slave irq
	call	save			# save interrupted process state
	pushl	irq_handlers+4*\irq	# irq_handlers[irq]
	call	intr_handle		# intr_handle(irq_handlers[irq])
	popl	%ecx
	cmpl	$0, irq_actids+4*\irq	# interrupt still active?
	jz	0f
	inb	$INT2_CTLMASK, %al
	orb	$(1<<(\irq-8)), %al
	outb	%al, $INT2_CTLMASK	# disable the irq
0:	movb	$END_OF_INT, %al
	outb	%al, $INT_CTL			# reenable master 8259
	outb	%al, $INT2_CTL		# reenable slave 8259
	ret				# restart (another) process
.endm

# Each of these entry points is an expansion of the hwint_slave macro
	.align	16
hwint08:		# Interrupt routine for irq 8 (realtime clock)
	hwint_slave 8

	.align	16
hwint09:		# Interrupt routine for irq 9 (irq 2 redirected)
	hwint_slave 9

	.align	16
hwint10:		# Interrupt routine for irq 10
	hwint_slave 10

	.align	16
hwint11:		# Interrupt routine for irq 11
	hwint_slave 11

	.align	16
hwint12:		# Interrupt routine for irq 12
	hwint_slave 12

	.align	16
hwint13:		# Interrupt routine for irq 13 (FPU exception)
	hwint_slave 13

	.align	16
hwint14:		# Interrupt routine for irq 14 (AT winchester)
	hwint_slave 14

	.align	16
hwint15:		# Interrupt routine for irq 15
	hwint_slave 15

#*===========================================================================*
#*				save					     *
#*===========================================================================*
# Save for protected mode.
# This is much simpler than for 8086 mode, because the stack already points
# into the process table, or has already been switched to the kernel stack.

	.align	16
save:
	cld			# set direction flag to a known value
	pushal			# save "general" registers
	pushl	%ds		# save ds
	pushl	%es		# save es
	pushl	%fs		# save fs
	pushl	%gs		# save gs
	movw	%ss, %dx	# ss is kernel data segment
	movw	%dx, %ds	# load rest of kernel segments
	movw	%dx, %es	# kernel does not use fs, gs
	movl	%esp, %eax	# prepare to return
	incb	k_reenter	# from -1 if not reentering
	jnz	set_restart1	# stack is already kernel stack
	movl	$k_stktop, %esp
	pushl	$restart	# build return address for int handler
	xorl	%ebp, %ebp	# for stacktrace
	jmp	*RETADR-P_STACKBASE(%eax)

	.align	4
set_restart1:
	pushl	$restart1
	jmp	*RETADR-P_STACKBASE(%eax)

#*===========================================================================*
#*				_s_call					     *
#*===========================================================================*
	.align	16
s_call:
p_s_call:
	cld			# set direction flag to a known value
	subl	$6*4, %esp	# skip RETADR, eax, ecx, edx, ebx, est
	pushl	%ebp		# stack already points into proc table
	pushl	%esi
	pushl	%edi
	pushl	%ds
	pushl	%es
	pushl	%fs
	pushl	%gs
	movw	%ss, %dx
	movw	%dx, %ds
	movw	%dx, %es
	incb	k_reenter
	movl	%esp, %esi	# assumes P_STACKBASE == 0
	movl	$k_stktop, %esp
	xorl	%ebp, %ebp	# for stacktrace
				# end of inline save
				# now set up parameters for sys_call()
	pushl	%ebx		# pointer to user message
	pushl	%eax		# src/dest
	pushl	%ecx		# SEND/RECEIVE/BOTH
	call	sys_call	# sys_call(function, src_dest, m_ptr)
				# caller is now explicitly in proc_ptr
	movl	%eax, AXREG(%esi)	# sys_call MUST PRESERVE si

# Fall into code to restart proc/task running.

#*===========================================================================*
#*				restart					     *
#*===========================================================================*
restart:

# Restart the current process or the next process if it is set. 

	cmpl	$0, next_ptr		# see if another process is scheduled
	jz	0f
	movl 	next_ptr, %eax
	movl	%eax, proc_ptr	# schedule new process 
	movl	$0, next_ptr
0:	movl	proc_ptr, %esp	# will assume P_STACKBASE == 0
	lldt	P_LDT_SEL(%esp)		# enable process' segment descriptors 
	leal	P_STACKTOP(%esp), %eax	# arrange for next interrupt
	movl	%eax, tss+TSS3_S_SP0	# to save state in process table
restart1:
	decb	k_reenter
	popl	%gs
	popl	%fs
	popl	%es
	popl	%ds
	popal
	addl	$4, %esp		# skip return adr
	iretl			# continue process

#*===========================================================================*
#*				exception handlers			     *
#*===========================================================================*
divide_error:
	pushl	$DIVIDE_VECTOR
	jmp	exception

single_step_exception:
	pushl	$DEBUG_VECTOR
	jmp	exception

nmi:
	pushl	$NMI_VECTOR
	jmp	exception

breakpoint_exception:
	pushl	$BREAKPOINT_VECTOR
	jmp	exception

overflow:
	pushl	$OVERFLOW_VECTOR
	jmp	exception

bounds_check:
	pushl	$BOUNDS_VECTOR
	jmp	exception

inval_opcode:
	pushl	$INVAL_OP_VECTOR
	jmp	exception

copr_not_available:
	pushl	$COPROC_NOT_VECTOR
	jmp	exception

double_fault:
	pushl	$DOUBLE_FAULT_VECTOR
	jmp	errexception

copr_seg_overrun:
	pushl	$COPROC_SEG_VECTOR
	jmp	exception

inval_tss:
	pushl	$INVAL_TSS_VECTOR
	jmp	errexception

segment_not_present:
	pushl	$SEG_NOT_VECTOR
	jmp	errexception

stack_exception:
	pushl	$STACK_FAULT_VECTOR
	jmp	errexception

general_protection:
	pushl	$PROTECTION_VECTOR
	jmp	errexception

page_fault:
	pushl	$PAGE_FAULT_VECTOR
	jmp	errexception

copr_error:
	pushl	$COPROC_ERR_VECTOR
	jmp	exception

#*===========================================================================*
#*				exception				     *
#*===========================================================================*
# This is called for all exceptions which do not push an error code.

	.align	16
exception:
	movl	$0, %ss:trap_errno		# clear trap_errno
	popl	%ss:ex_number
	jmp	exception1

#*===========================================================================*
#*				errexception				     *
#*===========================================================================*
# This is called for all exceptions which push an error code.

	.align	16
errexception:
	popl	%ss:ex_number
	popl	%ss:trap_errno
exception1:				# Common for all exceptions.
	pushl	%eax			# eax is scratch register
	movl	4+4(%esp), %eax		# old eip
	movl	%eax, %ss:old_eip
	movzwl	4+4+4(%esp), %eax		# old cs
	movl	%eax, %ss:old_cs
	movl	8+4+4(%esp), %eax		# old eflags
	movl	%eax, %ss:old_eflags
	popl	%eax
	call	save
	pushl	%ss:old_eflags
	pushl	%ss:old_cs
	pushl	%ss:old_eip
	pushl	%ss:trap_errno
	pushl	%ss:ex_number
	call	exception		# (ex_number, trap_errno, old_eip,
					#	old_cs, old_eflags)
	addl	$5*4, %esp
	ret

#*===========================================================================*
#*				level0_call				     *
#*===========================================================================*
level0_call:
	call	save
	jmp	*level0_func

#*===========================================================================*
#*				data					     *
#*===========================================================================*

.section .rodata
	.short	0x526F		# this must be the first data entry (magic #)

.section .bss
k_stack:
	.space	K_STACK_BYTES	# kernel stack
k_stktop:			# top of kernel stack
	.comm	ex_number, 4
	.comm	trap_errno, 4
	.comm	old_eip, 4
	.comm	old_cs, 4
	.comm	old_eflags, 4

