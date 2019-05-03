		;		ARM Programming Assignment #4: Count the ones in a binary number
		;
		;		Write a program that counts the number of ones in a binary number,
		;		stored in a word (4 bytes). Its loop should run no more times than there
		;		are ones in the number. Write the count in `numones`. For the example
		;		number given below, the loop should only run 8 times, counting 8 ones.
		;
		;		Hint:
		;		The first significant instruction in the loop is SUB r1, r1, 1, which
		;		decrements the number, assuming it's stored in register r1. Now,
		;		remember your logical operations.
		;
		;		Bonus:
		;		1. (20 extra points) For the shortest program (by instruction count),
		;		because this operation has to be FAST.
		;		2. (30 extra points) For extending the program to counting the ones
		;		in any word-aligned contiguous region of memory.
		
		;		Your code here
		
example	DCD		0x0010070f
numones	FILL		4
		MOV		R0, #0	 	;initialize count as 0
		ADR		R1, example	;retrieve number address
		LDR		R1, [R1]		;load number
		B		compare
check	SUB		R2, R1, #1	;subtract 1 to toggle bits
		AND		R1, R1, R2	;remove toggled bits
		ADD		R0, R0, #1	;increment count
compare	CMP		R1, #0		;check if number is 0
		Bgt		check
		ADR		R1, numones	;find address to store result
		STR		R0, [R1]		;store count
