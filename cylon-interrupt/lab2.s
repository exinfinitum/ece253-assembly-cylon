




















#From the lab manual.
	.text
	.global _start
_start:
	movia sp, STACK_START
	ldw sp, (sp)
	movia r15, KEY_ADDR
	ldw r15, (r15)
	movia r16, LEDR_ADDR
	ldw r16, (r16)
	movia r18, TIMER_ADDR
	ldw r18, (r18)
	
	#Enable interrupts and start that timer.
	
	START_TIMER:
		movia r18, 0x10002000 #r18 is timer
		movia r12, DELAY_TIME #just loading our delay value, nothing to see here...
		ldw r12, (r12) #this is delay
		sthio r12, 8(r18) #store low half of counter
		srli r12, r12, 16 #shift the register
		sthio r12, 0xc(r18) #store high half of counter
		movi r19, 0b0111 #START = 1, CONT = 1, ITO = 1. This allows our Timer to send interrupts.
		sthio r19, 4(r18) #store into control reg.
	
	
ENABLE_KEY13_INTERRUPTS:	
	movia r7, 0b1010 #Enable KEYs 1 and 3.
	stwio r7, 8(r15)
	
	
ENABLE_PROCESSOR_INTERRUPTS:	
	#Enable IRQ1 interrupt for NIOS II.
	movi r7, 0b011 #set 1 for IRQ1 and IRQ2 on the NIOS processor.
	wrctl ienable, r7 #write to the NIOS control reg
	movi r7, 1
	wrctl status, r7 #write to the NIOS STATUS reg (PIE).
	#Now, our PIE is 1!! 3.14159 kinds of YUM!
	
	#Now, we go about our other business (loop, etc.)

	
	



MAIN_LOOP:
	ldw r6, LEDR_PATTERN(r0)	#LEDR pattern, modified by timer ISR
	stwio r6, 0(r16)	#write to red LEDS
	br MAIN_LOOP

	
	
	
	.data
DELAY_TIME:
	.word 2500000	#delay between iterations, in s * (5*10^7)^(-1).

	.global LEDR_DIRECTION
LEDR_DIRECTION:
	.word 0
	
	.global LEDR_PATTERN
LEDR_PATTERN:
	.word 0x1
	
	
	
	
STACK_START:
	.word 0x20000
KEY_ADDR:
	.word 0x10000050
LEDR_ADDR:
	.word 0x10000000
TIMER_ADDR:
	.word 0x10002000