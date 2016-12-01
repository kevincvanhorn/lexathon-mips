# LEXATHON PROJECT
# @author	Kevin VanHorn (kcv150030), Nishant Gurrapadi (nxg153030), 
#		Thach Ngo (tnn130130), Marco Serrano (mis140230)
# Course: 	CS3340.501 Professor Nhut Nguyen
# Due: 1 December, 2016
	
	.data
# Global Vars
pNewLine: .asciiz "\n"
gameTable:  .space 9 # space for 9 bytes: each byte is a character

# PrintMenu Global Vars
pPrintMenu1: .asciiz "Welcome to Lexathon!\n\n"
pPrintMenu2: .asciiz "1) Start the game\n2) Instructions\n3) Exit\n"

# printInstructions Global Vars	
pPrintInstructions: .asciiz "Lexathon is a word game where you must find as many words\nof thre or more letters in a given board\n\nEach word must contain the central letter exactly once,\nand other tiles can be used once\n\nScores are determined by both the percentage of words found.\n\n"	

# randomizeBoard Global Vars
vowels: .byte 'A', 'E', 'I', 'O', 'U'

# printBoard Global Vars
pPrintBoard1: .asciiz "| "
pPrintBoard2: .asciiz " | "

# loadDictionary Variables
fin: .asciiz "LexathonDictionary.txt" #filename for input
buffer: .space 8000 # initial storage of file (charcount+newlines+wordcount)
bufferArray: .space 10000 # number of bytes in array (10 * english words)

# checkDictionary Variables
playerAnswer: .space 9
pWordLength: .asciiz "\nWord length is: "
pCheckWord: .asciiz "\nEnter a word to check: "
pCheckingDictionary: .asciiz "\nChecking dictionary...\n"
pWordFound: .asciiz "\nWord found!\n"
pWordNotFound: .asciiz "\nWord not found...\n"
pNotValid: .asciiz "\nAnswer not valid. Must be between 3-9 char.\n"
pNotInMiddle: .asciiz "\nERROR: Invalid Word - Try Again\n"

# startGame Global Vars
pStartGamePrompt: .asciiz "Choose Option: "
pEnterWord: .asciiz "Enter word: "
pPrintMenu3: .asciiz "\n1)Enter word \n2)Instructions \n3)Shuffle \n4)End game "
pSeparator: .asciiz "\n---------------------------------------------------------------------------------\n"
pStartGame_Score: .asciiz "\nScore: "	
pEndGameScore: .asciiz "\nGAME OVER! Final Score: "
			
	.text
main:
	jal loadDictionary
	j printMenu

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
loadDictionary: #void loadDictionary()
#**************
# 
#
#
# Register usage (after loading file)
# $t0 - comparison
# $t1 - wordCount // number of words out in array
# $t2 - address of buffer current iterating
# $t3 - current element of buffer
# $t4 - for i vs 10 comparision
# $t6 - current element of array (every word is 10 bytes apart)
# t7  - i is current word length
#**************

#-----Open and Read file into buffer
#-------------------------------------------------------------------
# open file for reading
li $v0, 13 # system call for open file
la $a0, fin # input file name
li $a1, 0 # open for reading (flags are 0: read, 1: write)
li $a2, 0 # mode is ignored
syscall # open a file (file descriptor return in $v0)
move $s6, $v0 # save the file descriptor

# read from file just opened
li $v0, 14 # system call for read from file
move $a0, $s6 # file descriptor
la $a1, buffer # address of buffer from which to read
li $a2, 8000 # hardcoded buffer length
syscall # read from file

# close the file
li $v0, 16 # system call for close file
move $a0, $s6 # file descriptor to close
syscall # close file
#------------------------------------------------------------------------


#-----Load from buffer into array
la $t2, buffer # address of buffer into $t2
la $t6, bufferArray # address of buffer into $t6
add $t1, $zero, $zero # wordCount = 0

WordCountWhile: # Store words in array until wordCount is 28
slti $t0, $t1, 1000 # t0 is 1 if wordCount < 1000
bne $t0, 1, WordCountExit

add $t7, $zero, $zero # current WordLength = 0
WordElementWhile:# While(i <= 10)) - Loop through 10 bytes, setting array elements to buffer elts
slti $t0, $t7, 9 # i < 11
bne $t0, 1, WordElementExit
lb $t3, ($t2) # $t3 has current element of buffer

# If current char != newline char
beq $t3, 10, WordElementIfExit # 10 is newLine char
sb $t3, ($t6) # store current buffer elt into current array location

addi $t2, $t2, 1 # only iterate buffer elt when \n is not the current char
WordElementIfExit:
addi $t7, $t7, 1 # iterate i
addi $t6, $t6, 1 # iterate to next address of array - 
		 # Array is iterating address even when buffer is not stay aligned by 10

j WordElementWhile
WordElementExit:

addi $t2, $t2, 1 # iterate to next address of buffer to skip \n 
addi $t6, $t6, 1 # iterate to next address of array b/c it is currently one behind due to i <
addi $t1, $t1, 1 # increment wordCount - a dictionary worrd has been stored in bufferArray

j WordCountWhile
WordCountExit:

jr $ra
#****************************************************************

#******************************************************************
getPlayerAnswerLength: # loop through player's answer to get length
#******************************************************************
# Register Usage:
# $a0 - addrees of playerAnswer
# $t1 - register for holding answer byte
# $t2 - comparison
#----------------------------------------------------------------------
	
	li $v0, 4 # SYSCALL 4: Print string; print the prompt
	la $a0, pCheckWord
	syscall
	
	li $v0, 8 # SYSCALL 8: Read string; read in user input for string
	la $a0, playerAnswer # load input into playerAnswer
	li $a1, 10 # maximum number of characters to read is 9
	syscall
	
	la $a0, playerAnswer
	li $s0, 0 # intialize index of playerAnswer[i] i = 0
	getPlayerAnswerLengthLoop:

		slti $t2, $s0, 10 # if i <= 9 run loop
		bne $t2, 1, getPlayerAnswerLengthExit # if not, exit loop
		
		lb $t1, ($a0) # store byte of playerAnswer[i] in t1
		beq $t1, 10, getPlayerAnswerLengthExit # if newline is encountered finish
		beq $t1, $0, getPlayerAnswerLengthExit # if null character is encountered quit
		
		addi $s0, $s0, 1 # increment player's answer element
		addi $a0, $a0, 1 # increment answer address

	j getPlayerAnswerLengthLoop # go back through the loop
	getPlayerAnswerLengthExit:
		#addi $s0, $s0, -1 # compensate for null character
		
		li $v0, 4 # SYSCALL 4: Print string; print  'answer length is:' "
		la $a0, pWordLength
		syscall
		
		li $v0, 1 # SYSCALL 1: Print integer; print word length
		la $a0, ($s0)
		syscall
		
		slti $t0, $s0, 3 # length of word
		beq $t0, 1, notValidAnswer
		
		move $v0, $s0 # move length into return value
		
	jr $ra
	
	notValidAnswer:
		li $v0, 4 # SYSCALL 4: Print String; answer must be 4-9 characters
		la $a0, pNotValid
		syscall
		j getPlayerAnswerLength
#****************************************************************

#****************************************************************
checkDictionary: # boolean checkDictionary()
#************************************************************************************************************
# Register usage (after loading file)
# $a0 - address of playerAnswer
# $a1 - address of dictionaryArray
# $t3 - loaded address of playerAnswer and index
# $t4 - loaded address of dictionaryArray
# $s0 - length of player's answer
# $t7 - number of letter matches
# $t8 - dictionary word's length
# $s6 - checkWordLoop counter
# $s7 - checkDictionaryLoop count
#-----------------------------------------------------------------------------------------------------
# 0 1 2 3 4 5 6 7 8 9 <- dictionaryArray e.g.
# _ _ _ _ _ _ _ _ _ /n empty chars are \0 'stupid'
# 0 1 2 3 4 5 6 7 8 <- playerAnswer                                                                                                          012345 6 7 8
# _ _ _ _ _ _ _ _ _ words less than total array size is padded with \n and then \0 if remaining placyes are empty e.g. inputting 'stupid' -> stupid\n\0\0
#------loop through the dictionary; load player's answer element and dictionary letters and check to see if they match-------
	
	move $s0, $v0 # move argument from player answer length into register
	
	la $a0, playerAnswer # load address of player's answer 
	la $a1, bufferArray # load address of dictionary array
	
	#Check Middle -----------------------------------------------
	j checkMiddle
	checkMiddleExit:
	
	beq $v0, 1, continue # Check if middle letter is in answer
	# Not in Middle
	li $v0, 4
	la $a0, pNotInMiddle
	syscall
	j checkDictionaryExit
	#-------------------------------------------------------------
	continue:
	
	la $t4, ($a1) # load address of dictionary array; $t4 <- bufferArray address
	
	checkDictionaryLoop: # loop through the dictionary array until the end of the file is reached
		beq $s0, $t7, wordAlmostFound # check if length of player's answer and dictionary word match
		
		la $t3, 0($a0) # reset playerAnswer[i] letter to beginning for rechecking of next word in dictionary
		li $t7, 0 # reset number of letter matches to 0
		li $s6, 0 # (A) counter for checkWordLoop
		li $t8, 0 # (C) reset dictionary word length to 0
		addi $s7, $s7, 1 # (B) increment checkDictionaryLoop count
		beq $s7, 999, wordNotFound # (B) word not found if entire dictionary array was checked
		
		checkWordLoop:           #                       0 1 2 3 4 5 6 7 8 
			slti $t0, $s6, 8 # (A) for(i <= 9) # run _ _ _ _ _ _ _ _ _ playerAnswer
			bne $t0, 1, Skip #                        0 1 2 3 4 5
					 #                        b a d a s s   b      a      d
			lb $t5, ($t3) # load playerAnswer[i] e.g. _ _ _ _ _ _ 0($t5) 1($t5) 2($t5)
			lb $t6, ($t4) # load dictionaryArray[i]
			
			addDictionaryWordLength: # (C) gets the length of the word in the dictionary
				beq $t6, 0x0, addDictionaryWordLengthExit # if letters in the dictionary are newline or null skip 
				beq $t6, 0xA, addDictionaryWordLengthExit # do not add to length else add to length
				beq $t6, 0xD, addDictionaryWordLengthExit
				addi $t8, $t8, 1 # if it is a letter add to the length
			addDictionaryWordLengthExit:
			
			addi $t3, $t3, 1 # increment playerAnswer[i]
			addi $t4, $t4, 1 # increment dictionaryArray[i]
			addi $s6, $s6, 1 # (A) increment checkDictionaryCount
			
			beq $t5, $t6, letterMatches # compare the letters; if the letters match add 1 to number of matches
			
			j checkWordLoop # go back through loop
			                                            #   d i c t i o n a r y word
			Skip: # skip /n character in dictionaryArray[i] _ _ _ _ _ _ _ _ _ \n _
				addi $t4, $t4, 2                    # * = pointer       * -> * skip 2 bytes     
				j checkDictionaryLoop
			
			letterMatches:
				beq $t5, 0x0, letterMatchesExit # if any of the characters are newLines or null skip letter match
				beq $t6, 0x0, letterMatchesExit
				beq $t5, 0xD, letterMatchesExit
				beq $t6, 0xD, letterMatchesExit
				addi $t7, $t7, 1
				letterMatchesExit:
				j checkWordLoop # if letter match check to see if next letter matches
			

				

	j checkDictionaryExit
#---------------------------------------------------------------------------------------------------------------
	# Pass through one more filter
	# If the length of the number of letter matches and length of dictionary word are equal THEN THE WORDS ARE THE SAME
	wordAlmostFound:
		beq $t7, $t8, wordFound
		j wordNotFound
#---------------------------------------------------------------------------------------------------------------
	# If a word is found 
	wordFound: 
		li $v0, 4 # SYSCALL 4: print string; word was found
		la $a0, pWordFound
		syscall
		
		li $t0, 1 # return 1
		move $v0, $t0
		
		li $t1, 5
		mult $s0, $t1
		mflo $t2
		add $s4, $s4, $t2
		
		j checkDictionaryExit
#--------------------------------------------------------------------------------------------------------------
	# If no matches found 
	wordNotFound: 
		li $v0, 4 # SYSCALL 4: print string; word was not found
		la $a0, pWordNotFound
		syscall
		
		li $t0, 0 # return 0
		move $v0, $t0
		j checkDictionaryExit
		
#---------------------------------------------------------------------------------------------------------------
	checkDictionaryExit:
		jr $ra

#---------------------------------------------------------------------------------------------------------------


#******************************************************************************************************************


#****************************************************************
startGame: #void startGame()
	#**************
# When 1 is entered for player's choice 
# this function is called to start the game
# Sets up the board by randomizing it
# Prints the board and loops to continue game

# Register usage
# $a0 -  holds player's decision and answer
# $s2
# $t0 - bool inputIsValid (1 = true)
# $t1 - bool letter_repeat
# $s4 - score
#**************

	#init vars
	li $t0, 0
	li $t0, 0
	li $s4, 0

	# Set up the board
	jal randomizeBoard 
	
	startGameLoop:
	#*****************************************************************************
	# Print board
	jal pNew_Line # print a newline char
	
	jal printBoard  # Print the board
	jal printScore # Print the score
	
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
		jal shuffleBoard
		lw $a0, 0($sp)	# Restore argument
		addu $sp, $sp, 4
		
		j startGameLoop 

	# 4) Exit
	endStartGameLoop:
		j Exit
#**********************************************************************************

#****************************************************************		
# checkmiddle subroutine accepts three arguments: 
# gameTable which is an array of 9 characters - $a0
# userinput which is the answer the user enters - $a1
# answer length - $a2
# $t1 = gameTable[4]
# $t2 = first letter in answer (changes every iteration) (contains the byte)
# $t3 = index (0 initially)
# $t4 = answer length
# $t5 = points to first letter in answer (changes every iteration) (contains address)
# $t5 is incremented by 1 every iteration, and the letter it points to is stored in $t2

# table position (middle letter position) = 4
# table positions
# 0 1 2
# 3 4 5 
# 6 7 8
#**************
checkMiddle:
#
#
# return value $v0 = -1, initially
# return 0 if middle letter is used, return -1 if not used
la $t0, gameTable
lb $t1, 4($t0) # t1 has the middle char
addi $t1, $t1, 32 # to CAPS
		
la $t5, ($a0) # $t5 points to position 0 in userinput
li $t3, 0
# store answer length in $t4
addi $t4, $s0, 0

while:
# if index >= answerlength, exit
bge $t3, $t4, exit
lb $t2, ($t5) # set $t2 to next letter in user input

beq $t1, $t2, else
addi $t3, $t3, 1 #index++
addi $t5, $t5, 1 # point to next letter in user input
li $v0, 0
j while

else:
addi $v0, $zero, 1 # middle letter is used, set $v0 = 1
 
exit:
j checkMiddleExit
#****************************************************************

printScore:
	addi $v0, $zero, 4 # Load "print string" SYSCALL service into revister $v0
	la $a0, pStartGame_Score # Load argument value, to print, into $a0
	syscall
	
	addi $v0, $zero, 1 # Load "print int" SYSCALL service into revister $v0
	la $a0, ($s4) # Print Score
	syscall
	
	addi $v0, $zero, 4 # Load "print string" SYSCALL service into revister $v0
	la $a0, pNewLine # Load argument value, to print, into $a0
	syscall
	
	jr $ra

pNew_Line:
# Print pPrintInstructions
	addi $v0, $zero, 4 # Load "print string" SYSCALL service into revister $v0
	la $a0, pNewLine # Load argument value, to print, into $a0
	syscall
	
	jr $ra
	
pSeparator_:
# Print pPrintInstructions
	addi $v0, $zero, 4 # Load "print string" SYSCALL service into revister $v0
	la $a0, pSeparator # Load argument value, to print, into $a0
	syscall
	jr $ra

printInstructions:
	# Print pPrintInstructions
	addi $v0, $zero, 4 # Load "print string" SYSCALL service into revister $v0
	la $a0, pPrintInstructions # Load argument value, to print, into $a0
	syscall
	jr $ra
			
Exit:
	li $v0, 4
	la $a0, pEndGameScore
	syscall
	
	li $v0, 1,
	la $a0, ($s4)
	syscall
	
	li $v0, 10 #Exit Syscall
	syscall
	
#****************************************************************
shuffleBoard: # void shuffleBoard( char gameTable[] )
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

	#add $t4, $a0, $zero	# $s4 = gameTable address
	la $t4, gameTable
	
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
	bne $t0, $t2, ShuffleDone	# if i >= 9, exit loop
	
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
ShuffleDone: jr $ra

#****************************************************************
