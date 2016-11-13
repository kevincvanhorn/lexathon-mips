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
answer: .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 # zero is null terminator

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

# startGame Global Vars
pPrompt: .asciiz "Enter word: "
p1: .ascii "1"
p2: .ascii "2"
p3: .ascii "3"
pPrintMenu3: .asciiz "\n1)Instructions\n2)Shuffle\n3)End game\n"

# checkDictionary Global Vars
pCheckingDictionary: .asciiz "Checking dictionary...\n"

# loadDictionary Global Vars
FileName: .asciiz "LexathonDictionary.txt"
DictionaryArray: .space 1125768 # There are exactly 93814 words in the dictionary * 12 bytes per word
pOpeningFile: .asciiz "\nOpening dictionary file...\n"
	.text
main:
	#jal loadDictionary
	jal printMenu

#***************************************************************
 
loadDictionary: # void loadDictionary()
#**************
# Need to load the dictionary into an array before it can be used
#**************
	li $v0, 4
	li $a0, pOpeningFile
	syscall 
	# Open file
	li $v0, 13 # Call "open file" SYSCALL to open LexathonDictionary.txt 
		   # $a0 = address of null-terminated string containing filename
		   # $a1 = flag 0: read only, 1: write only with create, 9: write only with create and append
		   # $a2 = mode
	la $a0, FileName
	li $a1, 0 # set flag to zero
	syscall
	
	# Read from file
	li $v0, 14               # Call "read from file" SYSCALL to read in file to array 
				 # $a0 = file descriptor
				 # $a1 = address of input buffer
				 # $a2 = maximum number of characters to read
	la $a0, FileName
	la $a1, DictionaryArray
	syscall
	
	# Close file
	li $v0, 16
	syscall
	
	jr $ra
#****************************************************************

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
	jr $ra
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

#****************************************************************
# addScore: # int addScore( int length )
#**************
# Takes the user's word's length as an argument and returns (length * 5) as the score 
#
# Register Usage:
# $t0 - holds length
# $t1 - holds 5
# $t2 - holds length * 5
#**************

addScore:
	add $t0, $a0, $zero
	
	li $t1, 5
	
	mult $t0, $t1
	mflo $t2
	
	add $v0, $t2, $zero
	
	jr $ra
#****************************************************************


#****************************************************************
#shuffleBoard: # void shuffleBoard( char gameTable[] )
#**************
# Shuffles the contents of gameTable[], making sure to replace gameTable[4] at the end
#
# Register Usage:
# t0 - for slt comparisons
# t1 - i: for loops
# t2 - randomNum
# t3 - temp
# t4 - gameTable base: referred to as just 'base'
# t5 - adjustableBase: used to reference specific values in gameTable, always an offset of base
# t6 - tempStorage: temp2
# t7 - middle: used to hold the middle value of the array
#**************
shuffleBoard:
	la $a0 gameTable
	add $t4, $a0, $zero	# $s4 = gameTable address
	
	addi $t5, $t4, 4	# adjustableBase = base + 4
	lb $t7, 0($t5)		# middle = gameTable[4]
	
	li $t1, 8	# i = 8

	ForLoop:
	slti $t0, $t1, 1	# if(i < 1) $s0 = 1
	li $t2, 1		# $s2 = 1 in order to compare with $s0
	beq $t0, $t2, FixMiddle	# if i = 0, exit loop
	
	# else
	li $v0, 41
	li $a0, 0
	syscall	# generates random num stored in $a0
	add $t2, $a0, $zero	# randomNum = rand()
	
	div $t2, $t2, $t1	# randomNum % i
	mfhi $t2		# randomNum = randomNum % i
	abs $t2, $t2
	
	add $t5, $t4, $t1	# adjustableBase($s5) = base + i
	lb $t3, 0($t5)		# temp = gameTable[i]
	
	add $t5, $t4, $t2	# adjustableBase($s5) = base + randomNum
	lb $t6, 0($t5)		# tempStorage($s6) = gameTable[randomNum]
	
	add $t5, $t4, $t1	# adjustableBase = base + 1
	sb $t6, 0($t5)		# gameTable[i] = tempStorage = gameTable[randomNum]
	
	add $t5, $t4, $t2	# adjustableBase = base + randomNum
	sb $t3, 0($t5)		# gameTable[randomNum] = temp
	
	addi $t1, $t1, -1	# i--
	
	j ForLoop
	
FixMiddle:
	slti $t0, $t1, 9	# while(i < 9) $s0 = 1
	li $t2, 1		# $s2 = 1 in order to compare with $s0
	bne $t0, $t2, ShuffleBoardExit	# if i >= 9, exit loop
	
	add $t5, $t4, $t1	# adjustableBase = base + i
	lb $t6, 0($t5)		# tempStorage = gameTable[i]
	bne $t6, $t7, NotMiddleValue	# if (gameTable[i] == middle)
				# then
	addi $t5, $t4, 4	# adjustableBase = base + 4
	lb $t3, 0($t5)		# temp = gameTable[4]
	
	add $t5, $t4, $t1	# adjustableBase = base + i
	sb $t3, 0($t5)		# gameTable[i] = temp = gameTable[4]
	
	addi $t5, $t4, 4	# adjustableBase = base + 4
	sb $t7, 0($t5)		# gameTable[4] = middle
	
	NotMiddleValue:			# else
	
	addi $t1, $t1, 1	# i++
	
	j FixMiddle

ShuffleBoardExit: jr $ra

#****************************************************************

#****************************************************************
startGame: #void startGame()
	#**************
# When 1 is entered for player's choice 
# this function is called to start the game
#
# Register usage
# $a0 -  holds player's decision
#**************

	# Set up the board
	jal randomizeBoard 
	
	startGameLoop:
	#*****************************************************************************
	# Print board
	li $v0, 4 # "Call "print string" syscall and print newline for formatting
	la $a0, pNewLine
	syscall
	
	jal printBoard  # Print the board
	
	li $v0, 4 # Call "print string" syscall and print instructions
	la $a0, pPrintMenu3
	syscall
	
	li $0, 4 # Call "print string" syscall and print newline
	la $a0, pNewLine
	syscall
	
	#*****************************************************************************
	# Get user's answer
	li $v0, 4 # "Call "print string" syscall and ask for user answer
	la $a0, pPrompt
	syscall
	
	li $v0, 8 # Call "read string" syscall, get player's decision and load into argument register
	la $a0, answer
	add $a1, $a1, 9 # Maximum number of characters to read is 9
	move $s0, $v0 # Save the answer into save register to use for later
	syscall
	
	li $v0, 4 # "Call "print string" syscall and print newline for formatting
	la $a0, pNewLine
	syscall
	
	li $v0, 4 # Call "print string" and check to see what is in answer
	la $a0, answer
	syscall 
	
	#********************************************************************************
	# Run appropriate function based on decision 1), 2), or 3)
	
	# This part NEEDS FIXING. Since the player is entering a string,
	# the input would be "1", "2", or "3" not the integers 1, 2, 3
	# Need to find a way to compare if strings are equal instead of integers
	
	# THIS IS REDUNDANT ***********************************
	# DELETE THIS ONCE DONE BUILDING THE FUNCTION
	# Run checkDictionary() if a word is entered 
	move $a0, $s0 
	addu $sp, $sp, -4 # Save argument on stack
	sw $a0, 0($sp)
	jal checkDictionary
	lw $a0, 0($sp) # Restore argument on stack
	addu $sp, $sp, 4
	#**************************************************************************************
	
	la $t0, p1 # If player enters decision "1" go to printInstructions()
	beq $a0, $t0, goToPrintInstructions
	j startGameLoop
	
	
	la $t0, p2 # If player enters decision "2" go to randomizeBoard()
	beq $a0, $t0, goToRandomizeBoard
	j startGameLoop
	
	la $t0, p3 # If player enters decision "3" exit the game
	beq $a0, $t0, endStartGameLoop
	
	# Run checkDictionary() if a word is entered
	move $a0, $s0
	addu $sp, $sp, -4  # Save argument on stack
	sw $a0, 0($sp)
	jal checkDictionary
	lw $a0, 0($sp) # Restore argument on stack
	addu $sp, $sp, 4
	
	#************************************************************************************
	# Instructions to run
	
	# 1) Print instructions
	goToPrintInstructions: 
		addu $sp, $sp, -4 # Save argument on stack 
		sw $a0, 0($sp)
		jal printInstructions
		lw $a0, 0($sp) # Restore argument
		addu $sp, $sp, 4
		
		j startGameLoop
	
	# 2) Randomize board
	goToRandomizeBoard:
		addu $sp, $sp, -4 # Save argument on stack
		sw $a0, 0($sp)
		jal randomizeBoard
		lw $a0, 0($sp)	# Restore argument
		addu $sp, $sp, 4
		
		j startGameLoop 

	# 3) Exit
	endStartGameLoop:
		j Exit
#**********************************************************************************

#**********************************************************************************
checkDictionary:
	
	li $v0, 4 # Call "print string" syscall and print out \'checking dictionary...\'"
	la $a0, pCheckingDictionary
	syscall
	jr $ra
#**********************************************************************************	
# Dummy Functions:
printInstructions:
	# Print pPrintInstructions
	addi $v0, $zero, 4 # Load "print string" SYSCALL service into revister $v0
	la $a0, pPrintInstructions # Load argument value, to print, into $a0
	syscall
	jr $ra
			
Exit:
	li $v0, 10 #Exit Syscall
	syscall
