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
			STMia	sp, {r0-r4, r6}
outer_loop
			LSL		r3, r3, #1
			ADD		r0, r0, #1
			CMP		r0, r2
			Blt		xor_loop
			MOV		r0, #0
			B		skip_loop
xor_loop
			EOR		r1, r1, r3
			ADD		r0, r0, #1
			LSL		r3, r3, #1
			ADD		r6, r6, #1
			CMP		r0, r2
			Blt		xor_loop
			MOV		r0, #0
skip_loop
			CMP		r6, #8
			Beq		par_bit_loc
			LSL		r3, r3, #1
			ADD		r0, r0, #1
			CMP		r0, r2
			Blt		skip_loop
			MOV		r0, #0
			B		xor_loop
par_bit_loc
			MOV		r6, #1
			SUB		r5, r4, r2
			LSL		r5, r6, r5
			AND		r5, r1, r5
			LDMia	sp, {r0-r4, r6}
			ORR		r1, r1, r5
			LSL		r2, r2, #1
			STMia	sp, {r0-r4, r6}
			CMP		r2, #8
			Ble		outer_loop
			END
