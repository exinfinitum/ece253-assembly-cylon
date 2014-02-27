	.include "address_map.s"
	.extern	LEDR_DIRECTION
	.extern	LEDR_PATTERN

/*****************************************************************************
 * Interval Timer - Interrupt Service Routine                                
 *   Must write to the Interval Timer to clear the interrupt. 
 *                                                                          
 * Shifts the pattern being displayed on the LEDR
 * 
******************************************************************************/
	.global TIMER_ISR
TIMER_ISR:					
	#... save registers on the stack
	subi sp, sp, 16
	stw r3, 0(sp)
	stw r4, 4(sp)
	stw r5, 8(sp)
	stw r6, 12(sp)
	
	movia		r3, TIMER_BASE
	sthio		r0,  0(r3)					# Clear the interrupt 

/* Rotate the LEDR bits either to the left or right. Reverses direction when hitting 
	position 17 on the left, or position 0 on the right */
SWEEP:
	ldw		r3, LEDR_DIRECTION(r0)	# put shifting direction into r3
	ldw		r4, LEDR_PATTERN(r0)		# put LEDR pattern into r4
	
	movi r5, 0b100000000000000000
	movi r6, 1
	
	beq r4, r5, L_R
	beq r4, r6, R_L
	br COMMENCE_SWEEP
	
L_R:
	movi	r3, 1						# change direction to right
	br			SHIFTR
	
R_L:
	mov		r3, r0						# change direction to left
	br			SHIFTL
	
COMMENCE_SWEEP:
	beq r3, r6, SHIFTR
	beq r3, r0, SHIFTL
	
SHIFTR:
	ror r4, r4, r6
	br DONE_SWEEP
SHIFTL:
	roli r4, r4, 1

DONE_SWEEP:
	stw		r3, LEDR_DIRECTION(r0)	# put shifting direction back into memory
	stw		r4, LEDR_PATTERN(r0)		# put LEDR pattern back onto stack
	
END_TIMER_ISR:
	#... restore registers from the stack
	ldw r3, 0(sp)
	ldw r4, 4(sp)
	ldw r5, 8(sp)
	ldw r6, 12(sp)
	addi sp, sp, 16
	ret

