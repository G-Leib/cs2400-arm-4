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
		
data		DCD		0b10100100101
recv		DCD		0b101111010100101
		
noer		DCD		0x00
onee		DCD		0x01
		
case		FILL		4
berr		FILL		4
corr		FILL		4
		
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
		MOV		r0, #-1			;loop counter
		MOV		r2, #1			;parity bit position value
		MOV		r3, #15			;parity boundary
		MOV		r4, #1			;parity shifter
		STMia	sp, {r0-r4} 		;store counters
		MOV		r3, r1
xor_loop
		ADD		r0, r0, #1
		LSL		r6, r4, r0		;exponential incremented shift
		CMP		r6, #16
		Bgt		add_par
		CMP		r6, r2			;do not shift(n)/XOR on p(n)
		Beq		xor_loop
		LSL		r5, r1, r6
		EOR		r3, r3, r5
		B		xor_loop
add_par
		MOV		r6, r3
		LDMia	sp, {r0-r4}
		SUB		r5, r3, r2		;find parity bit placement
		LSL		r5, r4, r5		;create mask for parity bit
		AND		r5, r5, r6		;isolate parity bit
		ORR		r1, r1, r5
		LSL		r2, r2, #1
		STMia	sp, {r0-r4}
		MOV		r3, r1
		CMP		r2, #16
		Blt		xor_loop
		END
		
		
		
