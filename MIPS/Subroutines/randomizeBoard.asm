	.data
pNewLine: .asciiz "\n"
gameTable:  .space 36 # space for 9 words, each to store a character
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
	addi $v0, $zero, 1 # Load "print integer" SYSCALL service into revister $v0
	add $a0, $t3, $zero
	syscall
	
	addi $t0, $t0, 1 # index++
	slti $t1, $t0, 9 # sets $t1 to 1 if(index < ARRAY_SIZE)
	j randomizeBoardLoop
	sll $t4, $t0, 2 # mult index by 4
	add $t4, $t4, $t2 # 
	sw $t1, ($t4)
randomizeBoardLoopEnd:
	#jr $ra
	j Exit
	
			
#****************************************************************	

# Dummy Functions:
startGame:
	j Exit
printInstructions:
	j Exit
	
Exit:
#-----------------
#Registers:
#$t0 - i
#$t1 - comparison 
printBoard:
add $t0, $zero, $zero #init i = 0
printBoardLoop:
	slti $t1, $t0, 9
	bne $t1, 1, printBoardLoopEnd
	
printBoardLoopEnd:
	# jr $ra
#------------------
	li $v0, 10 #Exit Syscall
	syscall	
	

