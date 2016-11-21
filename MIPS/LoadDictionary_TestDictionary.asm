.data
# loadDictionary Variables
fin: .asciiz "TestDictionary2.txt" #filename for input
buffer: .space 8000 # initial storage of file (charcount+newlines+wordcount)
bufferArray: .space 10000 # number of bytes in array (10 * english words)
# checkDictionary Variables
playerAnswer: .space 9
pWordLength: .asciiz "\nWord length is: \n"
pCheckWord: .asciiz "Enter a word to check: "
pCheckingDictionary: .asciiz "\nChecking dictionary...\n"
pWordFound: .asciiz "Word found\n"
pWordNotFound: .asciiz "Word not found\n"

testDictionary: .space 280

.text

main: 
	jal loadDictionary
	
	li $v0, 4 # SYSCALL 4: Print string; print the prompt
	la $a0, pCheckWord
	syscall
	
	li $v0, 8 # SYSCALL 8: Read string; read in user input for string
	la $a0, playerAnswer # load input into playerAnswer
	li $a1, 9 # maximum number of characters to read is 9
	syscall

	li $s0, 0 # holds player answer's length
	la $a0, playerAnswer
	jal getPlayerAnswerLength # get the player's answer's length
	
	#la $a0, bufferArray # argument takes address of bufferArray
	#li $a1, 0 # hold index of dictionary array
	#jal getDictionaryWordLength
	
	la $a0, playerAnswer # store player's answer into a0
	move $a1, $s0 # store answer length into a1
	la $a2, bufferArray # store bufferArray address into a2
	#jal checkDictionary
	
	j Exit

#****************************************************************
loadDictionary: #void loadDictionary()
#**************
# raises baseparam ($a0) to the power of exponentparam ($a1)
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

#****************************************************************
checkDictionary: # boolean checkDictionary()
#************************************************************************************************************
# Register usage (after loading file)
# $t0 - address of buffer array
# $t1 - address of player's answer
# $s0 - checkDictionary loop counter
# $s1 - check word element loop counter
# $s2 - holds current letter index
	la $s4, bufferArray # load address of buffer into $s4
	la $s5, playerAnswer # load address of players answer into $s5
	li $s0, 0 # initialize checkDictionary loop counter i = 0
	li $s1, 0 # intialize the check word loop index i = 0
	li $t0, 0 # $t0 keeps track of dictionary word length
	checkDictionaryLoop:
		li $s2, 0 # word element counter; i = 0 in playerAnswer[i]; reset it back to beginning of the answer everytime to check
		slti $t5, $s0, 25  # keep running until all the words have been checked
		bne $t5, 1, pWordNotFound # if entire dictionary has been checked and no words were found print 'word not found'
		
		checkWordLoop:
			slti $t4, $t3, 9 # while i <= 10
			bne $t4, 1, checkDictionaryLoop # once all letters have been checked go to next word
			lb $t6, playerAnswer($s2) # load player answer[i] for checking
			lb $t5, ($s4) # load dictionary word[i] for checking
			beq $t6, $t5, letterMatch # if the letters match add 1 to number of matches
			add $s2, $s2, 1 #  increment word element counter (++)
			add $s4, $s4, 1 # increment dictionary array element counter (++)
			j checkWordLoop # go back to checkWordLoop
		addi $s0, $s0, 1 # increment checkDictionary oop counter
		j checkDictionaryLoop
#*************************************************************************************************************
	
# checkDictionary subFunctions
#******************************************************************
wordFound: 
#******************************************************************
	li $v0, 4 # SYSCALL 4: print string; word was found
	la $a0, pWordFound
	syscall
	j Exit
#*******************************************************************

#********************************************************************
wordNotFound: 
#*******************************************************************
	li $v0, 4 # SYSCALL 4: print string; word was not found
	la $a0, pWordNotFound
	syscall
	jr $ra
#********************************************************************
	
#********************************************************************
getPlayerAnswerLength: # loop through player's answer to get length
#********************************************************************
# Register Usage:
# $a0 - address of player's answer
# $t1 - holds byte from answer
# $s0 - contains the length of answer
#----------------------------------------------------------------------
	lb $t1, ($a0) # store byte of player answer in t1
	# if byte is a null then exit the loop, else add 1 to word length
	beq $t1, $0, getPlayerAnswerLengthExit # if null character is encountered exit the loop
	addi $s0, $s0, 1 # ELSE: add 1 to word length
	addi $a0, $a0, 1 # increment player's answer elements
	j getPlayerAnswerLength # go back through the loop
	getPlayerAnswerLengthExit:
		addi $s0, $s0, -1 # compensate for null character
		
		li $v0, 4 # SYSCALL 4: Print string; print  'answer length is:' "
		la $a0, pWordLength
		syscall
		
		li $v0, 1 # SYSCALL 1: Print integer; print word length
		la $a0, ($s0)
		syscall
		
		move $v0, $s0 # move length into return value
		
		jr $ra
#************************************************************************

#***********************************************************************
getDictionaryWordLength: # int getDictionaryWordLength()
#***********************************************************************
# Register Usage:
# $a0 - holds address of dictionary array
# $a1 - holds dictionary array index
# Returns length of word
	lb $t1, ($a0)
	beq $t1, 10, getDictionaryWordLengthExit # If newline character is encountered quit
	addi $a0, $a0, 1 # increment address of array
	addi $a1, $a1, 1 # increment word length
	j getDictionaryWordLength # go back through the loop
	getDictionaryWordLengthExit:
		move $s1, $a1
		
		li $v0, 4 # SYSCALL 4: Print string; print  'word length is:' "
		la $a0, pWordLength
		syscall
		
		li $v0, 1 # SYSCALL 1: Print integer; print word length
		la $a0, ($s1)
		syscall
		
		jr $ra
#***********************************************************************
	
letterMatch:
	
skipNewLineChar:
	
#**************************************************************************************************************
Exit:
