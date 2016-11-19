.data
fin: .asciiz "Dictionary.txt" #filename for input
buffer: .space 300 # initial storage of file (charcount+newlines+wordcount)
bufferArray: .space 280 # number of bytes in array (10 * english words)
.text

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
li $a2, 300 # hardcoded buffer length
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
slti $t0, $t1, 28 # t0 is 1 if wordCount < 28
bne $t0, 1, WordCountExit

add $t7, $zero, $zero # current WordLength = 0
WordElementWhile:# While(i <= 10)) - Loop through 10 bytes, setting array elements to buffer elts
slti $t0, $t7, 11 # i < 11
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
addi $t1, $t1, 1 # increment wordCount - a dictionary worrd has been stored in bufferArray

j WordCountWhile
WordCountExit:

jr $ra
#****************************************************************






#Debugging Materials below

#$t0 - comparison
#$t1 - i
#$t2 - current address through bufferArray
la $t2, bufferArray
printLoop:
j PrintExit
slti $t0, $t1, 280 #while i < 280
bne $t0, 1, PrintExit

li $v0, 11
lb $a0, ($t2)
syscall

add $t2, $t2, 1 # increment address through array
addi $t1, $t1, 1
j printLoop
PrintExit:
