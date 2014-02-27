/*********************************************************************************/
 # RESET SECTION
 # Note: "ax" is REQUIRED to designate the section as allocatable and executable.
 # The Nios II tools place the ".reset" section at the reset location specified in 
 # the target system.
/*********************************************************************************/
	.section	.reset, "ax"
	movia		r2, _start
	jmp		r2								/* branch to main program */

/*********************************************************************************/
 # EXCEPTIONS SECTION
 # Note: "ax" is REQUIRED to designate the section as allocatable and executable.
 # The Nios II tools place the ".exceptions" section at the exceptions location 
 # specified in the target system.
/*********************************************************************************/
	.section	.exceptions, "ax"
	.global	EXCEPTION_HANDLER
EXCEPTION_HANDLER:
	subi		sp, sp, 16					/* make room on the stack */
   stw		et,  0(sp)

	rdctl		et, ctl4
	beq		et, r0, SKIP_EA_DEC		/* interrupt is not external */

   subi		ea, ea, 4					/* must decrement ea by one instruction */
												/*  for external interrupts, so that the */
												/*  interrupted instruction will be run */
SKIP_EA_DEC:
   stw		ea, 4(sp)					/* save all used registers on the Stack */
   stw		ra, 8(sp)					/* needed if call inst is used */
   stw		r22, 12(sp)
	
	bne		et, r0, CHECK_IRQ0		/* interrupt is an external interrupt */

NOT_EI:										/* Exception is internal (not from an irq) */
	br		END_ISR							/* This code does not handle these cases */

CHECK_IRQ0:							 		/* interval timer is interrupt level 0 */
		andi	r22, et, 0b01
		beq		r22, r0, CHECK_IRQ1
		
		call TIMER_ISR

CHECK_IRQ1:							 		/* keys are interrupt level 1 */
		andi	r22, et, 0b10
		beq		r22, r0, END_ISR
		
		call KEY_ISR

END_ISR:
   ldw		et, 0(sp)					/* restore all used registers */
   ldw		ea, 4(sp)					
   ldw		ra, 8(sp)					/* needed if call inst is used */
   ldw		r22, 12(sp)
   addi		sp, sp, 16

	eret
	.end

