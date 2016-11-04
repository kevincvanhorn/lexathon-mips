# LEXATHON PROJECT
# @author	Kevin VanHorn (kcv150030), Nishant Gurrapadi (), 
#		Thach Ngo (), 
# Course: 	CS3340.50 Professor Nhut Nguyen
# Due: 1 December, 2016
#
# Analysis:
# Design: 
#
# STYLE GUIDE: http://www.sourceformat.com/pdf/asm-coding-standard-brown.pdf
# https://docs.google.com/spreadsheets/d/1c5XmnOQwUe-ryxMq7yZ0FXpBPmGJkvcXKlpcZLSry6s/edit#gid=0
	
	.data
# Global Vars
pNewLine: .asciiz "\n"
gameTable:  .space 9 # space for 9 bytes: each byte is a character

# PrintMenu Global Vars
pPrintMenu1: .asciiz "Welcome to Lexathon!\n\n"
pPrintMenu2: .asciiz "1) Start the game\n2) Instructions\n3) Exit\n"

# printInstructions Global Vars	
pPrintInstructions: .asciiz "Lexathon is a word game where you must find as many words\nof four or more letters in the alloted time\n\nEach word must contain the central letter exactly once,\nand other tiles can be used once\n\nYou start each game with 60 seconds\nFinding a new word increases time by 20 seconds\n\nThe game ends when:\n-Time runs out, or\n-You give up\n\nScores are determined by both the percentage of words found\nand how quickly words are found.\nso find as many words as quickly as possible.\n\n"	

# randomizeBoard Global Vars
vowels: .byte 'A', 'E', 'I', 'O', 'U'

# printBoard Global Vars
pPrintBoard1: .asciiz "| "
pPrintBoard2: .asciiz " | "
		
	.text
main:
	jal printMenu

#****************************************************************
printMenu: #void printMenu()

#**************
# Loops the Menu options, calling appropriate subroutines to start the game
#
#
# Register usage
# $t0 choice: to hold user input (integer)
#**************

	# Print pPrintMenu1 (welcome message)
	addi $v0, $zero, 4 # Load "print string" SYSCALL service into revister $v0
	la $a0, pPrintMenu1 # Load argument value, to print, into $a0
	syscall
	
	# Print pPrintMenu2 (second prompt)
	addi $v0, $zero, 4 # Load "print string" SYSCALL service into revister $v0
	la $a0, pPrintMenu2 # Load argument value, to print, into $a0
	syscall
	
	# Get input for choice into $v0
	li $v0, 5 # Load "read integer" SYSCALL service into revister $v0
	syscall
	add $t0, $v0, $zero # put choice into $t0
	
	# Print pPrintMenu2 (second prompt)
	addi $v0, $zero, 4 # Load "print string" SYSCALL service into revister $v0
	la $a0, pNewLine # Load argument value, to print, into $a0
	syscall
	
printMenuWhile:	
	beq $t0, 3, Exit # while (choice != 3)
	bne $t0, 1, printMenuElse # if (choice == 1)
	jal startGame # startGame(gameTable);
	add $t0, $zero, $zero # reset $v0 incase lingering from subroutine call
printMenuElse:	
	bne $t0, 2, printMenuChoice # else if (choice == 2)
	jal printInstructions #printInstructions();
printMenuChoice:
	# Print pPrintMenu2 (second prompt)
	addi $v0, $zero, 4 # Load "print string" SYSCALL service into revister $v0
	la $a0, pPrintMenu2 # Load argument value, to print, into $a0
	syscall
	
	# Get input for choice into $v0
	li $v0, 5 # Load "read integer" SYSCALL service into revister $v0
	syscall
	add $t0, $v0, $zero # put choice into $t0
	
	# Print pPrintMenu2 (second prompt)
	addi $v0, $zero, 4 # Load "print string" SYSCALL service into revister $v0
	la $a0, pNewLine # Load argument value, to print, into $a0
	syscall
	
	j printMenuWhile # return to while
#****************************************************************	

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
	
	# Print a0
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

#****************************************************************
randomizeBoard: #void randomizeBoard()
#**************
# sets the elements of gameBoard[]
#
#
# Register usage
# $t0 - "index" for looping 
# $t1 - for comparison
# $t2 - stores gameTable[] starting address
# $t3 - stores random number
# $t4 - index*4
# $t5 - holds address of vowels[]
#**************

# initialize vars
	add $t0, $zero, $zero # init index to 0
	la $t2, gameTable # load gameTable[] into $t2
	
	slti $t1, $t0, 9 # sets $t1 to 1 if(index < ARRAY_SIZE)
randomizeBoardLoop:
	bne $t1, 1, randomizeBoardLoopEnd # for (int index = 0; index < ARRAY_SIZE; ++index)
	
	li $v0, 41 # generate random int A - Z
	add $a0, $zero, $zero # set randomize type to 0
	syscall # stored in $a0
	add $t3, $a0, $zero
	
	div $t3, $t3, 26 # Set range
	mfhi $t3
	abs $t3, $t3
	addi $t3, $t3, 65 
	
	add $t4, $t2, $t0 # store address of array[i] into $t4
	sb $t3, ($t4) # stores random num into array[index]

	addi $t0, $t0, 1 # index++
	slti $t1, $t0, 9 # sets $t1 to 1 if(index < ARRAY_SIZE)
	
	j randomizeBoardLoop
	
randomizeBoardLoopEnd:
	li $v0, 41 # gen random int 0-5
	add $a0, $zero, $zero
	syscall # stored in $a0
	add $t3, $a0, $zero
	div $t3, $t3, 5 # range of random int = 1-5
	mfhi $t3	
	abs $t3, $t3
	
	la $t5, vowels # starting address of vowels[]
	add $t4, $t5, $t3 # vowels[random]
	lb $t4, ($t4)
	sb $t4, 4($t2) # store random vowel in middle of gameTable[]

	jr $ra														
#****************************************************************



# Dummy Functions:
startGame:
	j Exit

printInstructions:
	# Print pPrintInstructions
	addi $v0, $zero, 4 # Load "print string" SYSCALL service into revister $v0
	la $a0, pPrintInstructions # Load argument value, to print, into $a0
	syscall
	jr $ra
			
Exit:
	li $v0, 10 #Exit Syscall
	syscall
