	#Stephen Brown's Code from Lecture
	
	#
	
	.text
	.global _start
_start:	movia r16, 0x10000000 #r16 is ledr
		
		movia r17, 0x10000050 #r18 is KEYS
		movia r3, 0x10000020
		movia r4, 0x10000030
		movi r20, 0b00000000000000100000000000000000
		movi r21, 0b00000000000000000000000000000001
		movi r6, 0b00000000000000100000000000000000
		
		
START_TIMER:
		movia r18, 0x10002000 #r18 is timer
		movia r12, DELAY_TIME #just loading our delay value, nothing to see here...
		ldw r12, (r12) #this is delay
		sthio r12, 8(r18) #store low half of counter
		srli r12, r12, 16 #shift the register
		sthio r12, 0xc(r18) #store high half of counter
		movi r19, 0b0110 #START = 1, CONT = 1
		sthio r19, 4(r18) #store into control reg.
		
DO_DISPLAY:
		
		movhi r11, 0b1110111010111000
		ori r11, r11, 0b1011111110110111
		
					
		movia r13, 0b0111001
		
		stwio r11, 0(r3)
		#sthio r14, 0(r3)
		sthio r13, (r4)
		

		ldw r5, (r17) #r5 is KEYS. Use this to check if the meatbag pressed any keys.
		beq r5, r0, NO_KEY
KEY:	#Set the r22, which indicates whether or not the meatbag has pressed the key.
		#After r22 is set, we will WAIT until the meatbag releases its fleshy appendage.
		#If r22 is set, we loop back to WAIT. WAIT shall have a branch to check to see if key is pressed.
		nor r22, r22, r22
		
WAIT:	ldwio r5, (r17) # wait for the slow meatbag to remove its fleshy appendage
		
		bne r5, r0, WAIT
KEY_OFF:
		ldwio r5, (r17) 
		bne r5, r0, KEY #Un-freeze!!

		stwio r0, (r3)
		stwio r0, (r4)
		
		bne r22, r0, KEY_OFF

		
NO_KEY:	stwio r6, (r16) #write to our HEX displays

ROTATE_RIGHT:
bne r10, r0, ROTATE_LEFT
#Do this if our r10 is zero. Else, we rotate left.
		ror r6, r6, r21
ROTATE_LEFT:
beq r10, r0, AFTER_ROTATE
		roli r6, r6, 1 #(rotate the shift reg by one digit - this is like srli, but we wrap around edges)

AFTER_ROTATE:
beq r6, r20, CHANGE_DIRECTION
beq r6, r21, CHANGE_DIRECTION
	
		
DELAY:	ldhio r7, (r18) #read status reg
		andi r7, r7, 1 #check TO bit
		beq r7, r0, DELAY
		sthio r7, (r18) #clear TO bit to 0!
		br DO_DISPLAY

		
CHANGE_DIRECTION:
nor r10, r10, r10
br DELAY
		
	.data

HEX_BITS:
	.word 0x1
DELAY_TIME:
	.word 2500000