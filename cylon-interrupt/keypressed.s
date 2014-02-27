	.include "address_map.s"
/***************************************************************************************
 * Pushbutton - Interrupt Service Routine                                
 *                                                                          
 * This routine checks which KEY has been pressed.  If KEY3 it stops/starts the timer.
****************************************************************************************/
	.global	KEY_ISR
KEY_ISR:
		subi		sp, sp, 12					/* reserve space on the stack */
   stw		r10, 0(sp)
   stw		r11, 4(sp)
   stw		r9, 8(sp)


	movia		r10, KEY_BASE				/* base address of KEYs */
	ldwio		r11, 0xC(r10)				/* read edge capture register */
	stwio		r0,  0xC(r10)				/* clear the interrupt */                  

	movia		r10, TIMER_BASE			/* base address of timer */
CHECK_KEY3:
	#Wait for that meatbag to release its fleshy appendage.
	ldwio r9, (r10) 
	andi r9, r9, 0b1000

	bne r9, r0, END_KEY_ISR

STOP_START:
	ldwio		r9, (r10)					# read timer status register
	andi		r9, r9, 0b010				# check RUN bit
	bne		r9, r0, STOP

START:
	movi r9, 0b0111 #START = 1, CONT = 1, ITO = 1.
	br END_KEY_ISR

STOP:
	movi r9, 0b0101 #START = 1, CONT = 0, ITO = 1.

END_KEY_ISR:
		stwio r9, 4(r10)
		ldw		r10, 0(sp)
		ldw		r11, 4(sp)
		ldw		r9, 8(sp)
		addi		sp, sp, 12					/* reserve space on the stack */
	ret
	.end
	

