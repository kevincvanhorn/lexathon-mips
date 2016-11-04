	.data
pNewLine: .asciiz "\n"
	.align 2 # aligns the next value on a word
gameTable:  .space 9 # space for 9 bytes
gameTable2: .byte 'A','B','C','D','E','F','G','H','I'
	.text
#****************************************************************
randomizeBoard: #void randomizeBoard()
#**************
# raises baseparam ($a0) to the power of exponentparam ($a1)
#
#
# Register usage
# $t0 - "index" for looping 
# $t1 - for comparison
# $t2 - stores gameTable[] starting address
# $t3 - stores random number
# $t4 - index*4
#**************

# initialize vars
	add $t0, $zero, $zero # init index to 0
	la $t2, gameTable # load gameTable[] into $t2
	
	slti $t1, $t0, 9 # sets $t1 to 1 if(index < ARRAY_SIZE)
randomizeBoardLoop:
	bne $t1, 1, randomizeBoardLoopEnd # for (int index = 0; index < ARRAY_SIZE; ++index)
	
	li $v0, 41 # gen random int
	add $a0, $zero, $zero
	syscall # stored in $a0
	add $t3, $a0, $zero
	
	div $t3, $t3, 26
	mfhi $t3
	addi $t3, $t3, 65
	
	# Print a0
	#addi $v0, $zero, 1 # Load "print integer" SYSCALL service into revister $v0
	#add $a0, $t3, $zero
	#syscall
	
	#sll $t4, $t0, 2 # mult index by 4
	#add $t4, $t4, $t2
	add $t4, $t2, $t0 # store array[i] into $t2 
	sb $t3, ($t4) # stores random num into array[index]

	
	addi $t0, $t0, 1 # index++
	slti $t1, $t0, 9 # sets $t1 to 1 if(index < ARRAY_SIZE)
	
	j randomizeBoardLoop
	
randomizeBoardLoopEnd:
	#jr $ra
	j Exit
	
			
#****************************************************************	

Exit:

#****************************************************************
printBoard: # void printBoard()
#**************
# Prints the content of gameTable[]
#
# Register Usage:
# $t0 - i
# $t1 - comparison
# $t3 - gameTable begin
# $t4 - gameTable offset 
#**************

add $t0, $zero, $zero #init i = 0
printBoardLoop: # for (int i = 0; i < ARRAY_SIZE; ++i)
	slti $t1, $t0, 9 # i < ARRAY_SIZE
	bne $t1, 1, printBoardLoopReturn

	la $t3, gameTable
	add $t4, $t3, $t0 # store address gameTable[i] into $t4
	lb $t4, ($t4) # Load the character byte into $t4
	
	# Print a0
	addi $v0, $zero, 11 # Load "print character" SYSCALL service into revister $v0
	add $a0, $t4, $zero
	syscall
	
	# Print only after 3rd and 6th element
	beq $t0, 2, printBoardLine
	bne $t0, 5, printBoardLoopEnd
printBoardLine:
	# Print \n
	addi $v0, $zero, 4 # Load "print string" SYSCALL service into revister $v0
	la $a0, pNewLine # Load argument value, to print, into $a0
	syscall

printBoardLoopEnd:	
	addi $t0, $t0, 1 # increment i
	j printBoardLoop
	
printBoardLoopReturn:
	# jr $ra
#****************************************************************


	li $v0, 10 #Exit Syscall
	syscall	
	

