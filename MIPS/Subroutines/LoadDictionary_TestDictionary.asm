.data
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
pNotValid: .asciiz "\nAnswer not valid. Must be between 4-9 char.\n"

.text

main: 
	jal loadDictionary
	
	jal getPlayerAnswerLength # get the player's answer's length
	
	jal checkDictionary # check the dictionary
	
	j Exit

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
		
		slti $t0, $s0, 4
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
Exit:
