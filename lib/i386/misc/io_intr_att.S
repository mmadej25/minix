#	intr_disable(), intr_enable - Disable/Enable hardware interrupts.
#							Author: Kees J. Bot
#								18 Mar 1996
#	void intr_disable(void);
#	void intr_enable(void);

.text
.global intr_disable
.type intr_disable, @function
intr_disable:
	cli
	ret

.global intr_enable
.type intr_enable, @function
intr_enable:
	sti
	ret