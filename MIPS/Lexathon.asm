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
	
	.data
# Global Vars
pNewLine: .asciiz "\n"
gameTable:  .space 36 # space for 9 words, each to store a character

# PrintMenu Global Vars
pPrintMenu1: .asciiz "Welcome to Lexathon!\n\n"
pPrintMenu2: .asciiz "1) Start the game\n2) Instructions\n3) Exit\n"

# printInstructions Global Vars	
pPrintInstructions: .asciiz "Lexathon is a word game where you must find as many words\nof four or more letters in the alloted time\n\nEach word must contain the central letter exactly once,\nand other tiles can be used once\n\nYou start each game with 60 seconds\nFinding a new word increases time by 20 seconds\n\nThe game ends when:\n-Time runs out, or\n-You give up\n\nScores are determined by both the percentage of words found\nand how quickly words are found.\nso find as many words as quickly as possible.\n\n"	
	
	.text
main:
	jal printMenu

#****************************************************************
printMenu: #void printMenu()

#**************
# raises baseparam ($a0) to the power of exponentparam ($a1)
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
