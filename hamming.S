			;		ARM Programming Assignment #4: Encode in Hamming(15, 11)
			;
			;		Write a subroutine that encodes 11 bits of data into a 15-bit
			;		block, using 4 parity bits. Assume even parity, that is,
			;		the parity of the bits covered by a parity bit, including
			;		the parity bit, has to be an even number. Assume the bits are
			;		written in the following sequence: p1, p2, d1, p4, d2, d3, d4,
			;		p8, d5, d6, d7, d8, d9, d10, d11, p16, d12, d13, d14, d15.
			;		Call the subroutine `hencode`.
			;
			;		Write a subroutine that decodes a H(15, 11) block to extract
			;		the 11 data bits. Call it `hdecode`. It should:
			;		- calculate the correcting code
			;		- dentify the case: no error (noer), one-bit error (onee)
			;		- write the result in `case` using the encoding provided
			;		- if there is a one-bit error, write the number of the
			;		erroneous bit in `berr`
			;		- if there is a one-bit error, correct the data
			;		- write the result in `corr`
			;
			;		Now, write a main function which uses `hencode` and `decode`
			;		to encode `data` and then, after a simulated transmission,
			;		decode `recv`. Assume that `recv` contains what is received
			;		at the other end.
			
			;		Your code here
			
data			DCD		0b10100100101
recv			DCD		0b101111010100101
			
noer			DCD		0x00
onee			DCD		0x01
			
case			FILL		4
berr			FILL		4
corr			FILL		4
			
main
			ADR		r0, data			;load address of data
			LDR		r0, [r0]			;load data
			BL		hencode
			;*********simulated transmittion*********
			ADR		r1, recv			;load address of received data
			LDR		r1, [r1]			;load received data
			BL		hdecode
			END
hencode
			;insert	space for parity bits
			AND		r1, r0, #0b1111111	;d5-d11
			LSR		r2, r0, #7
			AND		r2, r2, #0b111
			LSL		r2, r2, #8
			ADD		r1, r1, r2		;d2-d4 with space for p8
			LSR		r2, r0, #10
			LSL		r2, r2, #12
			ADD		r1, r2, r1		;d1 with space for p4
			;find	and insert parity bits
			MOV		r0, #0			;initialize inner loop counter
			MOV		r2, #1			;initialize parity bit value
			MOV		r3, r1			;make copy of coded data
			MOV		r4, #15			;bit limit
			MOV		r6, #1			;outer loop counter
			STMia	sp, {r0-r4, r6}	;store counters on stack
outer_loop
			LSL		r3, r3, #1		;shift data copy
			ADD		r0, r0, #1		;increment inner counter
			CMP		r0, r2			;check if counter is greater than parity value
			Blt		xor_loop			;branch to xor if less than parity value
			MOV		r0, #0			;otherwise, reset counter and...
			B		skip_loop			;branch to skip loop
xor_loop
			EOR		r1, r1, r3		;xor data with shifted data (changes to 1 for total odd 1s and 0 for total even 0s)
			ADD		r0, r0, #1		;increment inner loop counter
			LSL		r3, r3, #1		;shift data copy
			ADD		r6, r6, #1		;increment outer loop (number of "parity bit definers" checked)
			CMP		r0, r2			;check if counter is greater than parity value
			Blt		xor_loop			;if less than parity value continue checking/xor
			MOV		r0, #0			;otherwise reset inner counter and proceed to skips
skip_loop
			CMP		r6, #8			;if all "parity bit definers" have been checked, move on to assigning parity bit
			Beq		par_bit_loc
			LSL		r3, r3, #1		;shift data copy
			ADD		r0, r0, #1		;increment inner loop
			CMP		r0, r2			;check if skip values are exceeded
			Blt		skip_loop			;if not continue skip loop
			MOV		r0, #0			;otherwise reset inner loop counter
			B		xor_loop			;proceed to xor loop
par_bit_loc
			MOV		r6, #1			;reset outer loop counter
			SUB		r5, r4, r2		;subtract parity bit value from bit limit
			LSL		r5, r6, r5		;shift #1 to parity bit placement to create mask
			AND		r5, r1, r5		;use mask to save parity bit
			LDMia	sp, {r0-r4, r6}	;retrieve stored counter values
			ORR		r1, r1, r5		;use "or" mask to insert parity bit
			LSL		r2, r2, #1		;double parity bit value to prep for next parity bit
			STMia	sp, {r0-r4, r6}	;store updated counter values
			CMP		r2, #8			;check if all parity bits have been inserted
			Ble		outer_loop
			MOV		r0, r1			;write encoded data back into r0 (same as received)
			MOV		lr, pc			;resume main
			
			;**********************************************************
			
hdecode
			