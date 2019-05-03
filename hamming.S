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
			
hencode
			ADR		r0, data			;load address of data
			LDR		r0, [r0]			;load data
			;insert	parity bits
			AND		r1, r0, #0b1111111	;d5-d11
			LSR		r2, r0, #7
			AND		r2, r2, #0b111
			LSL		r2, r2, #8
			ADD		r1, r1, r2		;d2-d4 with space for p4
			LSR		r2, r0, #10
			LSL		r2, r2, #12
			ADD		r1, r2, r1		;d1 with space for p3
			;determine	parity bits
			STR		r1, [sp], #4
			MOV		r0, #1			;loop counter
			MOV		r2, #1			;skip amount
			MOV		r3, #1			;skip mask
			MOV		r5, #0			;determinator
			MOV		r11, sp			;use r11 as frame pointer
			MOV		r10, #0			;frame pointer offset
p_loop
			LDR		r1, [sp, #-4]
			STMia	sp!, {r0, r2-r3}	;store counts
inner_loop
			AND		r4, r1, r3
			ADD		r5, r4, r5
			LSL		r3, r3, r2
			LSR		r1, r1, r2
			CMP		r3, #0b10000000
			Blt		inner_loop
			ADD		r11, r11, #24		;move frame pointer for new subroutine
en_count		;counts 1s in number
			MOV		R0, #0	 		;initialize count as 0
			MOV		R1, r5			;load number
			B		en_comp
en_check
			SUB		R2, R1, #1		;subtract 1 to toggle bits
			AND		R1, R1, R2		;remove toggled bits
			ADD		R0, R0, #1		;increment count
en_comp
			CMP		R1, #0			;check if number is 0
			Bgt		en_check
			AND		r0, r0, #1		;check if LSB is 1 (odd)  or 0 (even)
			STR		r0, [r11, r10] 	;store result (parity bit) on stack
			ADD		r10, r10, #4		;increment fp offset
			SUB		r11, r11, #24		;reset fp return to previous subroutine
			MOV		sp, r11			;reset sp
			LDmia	sp!, {r0, r2-r3}	;retrieve counters
			LSL		r4, r3, r2
			ADD		r3, r3, r4		;change skip mask
			LSL		r2, r2, #1		;increment skip amount exponentially
			CMP		r0, #4
			Ble		p_loop
			end
			
