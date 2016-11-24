#****************************************************************************************************
# startGame Global Vars
pStartGamePrompt: .asciiz "Input: "
pEnterWord: .asciiz "Enter word: "
pPrintMenu3: .asciiz "\n1)Enter word \n2)Instructions \n3)Shuffle \n4)End game "
pSeparator: .asciiz "\n---------------------------------------------------------------------------------\n"
#***************************************************************************************************
#****************************************************************
startGame: #void startGame()
	#**************
# When 1 is entered for player's choice 
# this function is called to start the game
# Sets up the board by randomizing it
# Prints the board and loops to continue game

# Register usage
# $a0 -  holds player's decision and answer
#**************

	# Set up the board
	jal randomizeBoard 
	
	startGameLoop:
	#*****************************************************************************
	# Print board
	jal pNew_Line # print a newline char
	
	jal printBoard  # Print the board
	
	li $v0, 4 # Call "print string" syscall and print instructions
	la $a0, pPrintMenu3
	syscall
	
	jal pNew_Line # print a newline char

	#*****************************************************************************
	# Get user's answer
	li $v0, 4 # "Call "print string" syscall and ask for user answer
	la $a0, pStartGamePrompt
	syscall
	
	li $v0, 5 # " Call "read integer" SYSCALL and ask for user choice
	syscall
	move $s2, $v0 # Save the answer into save register $s2
	
	jal pNew_Line # print a newline char
	
	li $t0, 1 # If player enters decision "1" go to checkDictionary()
	beq $s2, $t0, goToCheckDictionary
	
	li $t0, 2 # If player enters decision "2" go to printInstructions()
	beq $s2, $t0, goToPrintInstructions
	
	li $t0, 3 # If player enters decision "3" go to randomizeBoard()
	beq $s2, $t0, goToRandomizeBoard
	
	li $t0, 4 # If player enters decision "4" end the game
	beq $s2, $t0, endStartGameLoop
	
	j startGameLoop
	
	#************************************************************************************
	# Instructions to run based on player's decision or 1 2 or 3
	
	# 1) Check the dictionary if a word is entered
	goToCheckDictionary:
		addu $sp, $sp, -4
		sw $a0, 0($sp)
		jal getPlayerAnswerLength
		jal checkDictionary
		lw $a0, 0($sp)
		addu $sp, $sp 4
		
		j startGameLoop
	
	# 2) Print instructions
	goToPrintInstructions: 
		addu $sp, $sp, -4 # Save argument on stack 
		sw $a0, 0($sp)
		jal printInstructions
		jal pSeparator_
		lw $a0, 0($sp) # Restore argument
		addu $sp, $sp, 4
		
		j startGameLoop
	
	# 3) Randomize board
	goToRandomizeBoard:
		addu $sp, $sp, -4 # Save argument on stack
		sw $a0, 0($sp)
		jal randomizeBoard
		lw $a0, 0($sp)	# Restore argument
		addu $sp, $sp, 4
		
		j startGameLoop 

	# 4) Exit
	endStartGameLoop:
		j Exit
#**********************************************************************************
