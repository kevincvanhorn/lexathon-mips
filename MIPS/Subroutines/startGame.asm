	.data
# startGame Global Vars
pPrompt: .asciiz "Enter word: "
p1: .ascii "1"
p2: .ascii "2"
p3: .ascii "3"
pPrintMenu3: .asciiz "\n1)Instructions\n2)Shuffle\n3)End game\n"
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


	
Exit:
	li $v0, 10 #Exit Syscall
	syscall	
	
