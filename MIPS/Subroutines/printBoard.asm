	.data
pNewLine: .asciiz "\n"
pPrintBoard1: .asciiz "| "
pPrintBoard2: .asciiz " | "
gameTable01:  .space 9 # space for 9 bytes # This is what will actually be used
gameTable: .byte 'A','B','C','D','E','F','G','H','I' # This is for testing
	.text	

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
	
	# Print "| "
	addi $v0, $zero, 4 # Load "print string" SYSCALL service into revister $v0
	la $a0, pPrintBoard1 # Load argument value, to print, into $a0
	syscall
	
	# Print gameTable[i]
	addi $v0, $zero, 11 # Load "print character" SYSCALL service into revister $v0
	add $a0, $t4, $zero
	syscall
	
	# Print " | "
	addi $v0, $zero, 4 # Load "print string" SYSCALL service into revister $v0
	la $a0, pPrintBoard2 # Load argument value, to print, into $a0
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
	

