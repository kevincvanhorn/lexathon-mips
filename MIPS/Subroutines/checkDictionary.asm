# Sample MIPS program that writes to a new file

.data
fin: .asciiz "Dictionary.txt" #filename for input
buffer: .space 300#508568 # initial storage of file 
bufferArray: .space 280#508568 # number of bytes in file
debug: .asciiz "debog"
#userinput: 

.text

# open (for reading) a file that does not exist
li $v0, 13 # system call for open file
la $a0, fin # input file name
li $a1, 0 # open for reading (flags are 0: read, 1: write)
li $a2, 0 # mode is ignored
syscall # open a file (file descriptor return in $v0)
move $s6, $v0 # save the file descriptor
#####################
# read from file just opened
li $v0, 14 # system call for read from file
move $a0, $s6 # file descriptor
la $a1, buffer # address of buffer from which to read
li $a2, 300 # hardcoded buffer length
syscall # read from file

li $v0, 4
la $a0, buffer
syscall

# close the file
li $v0, 16 # system call for close file
move $a0, $s6 # file descriptor to close
syscall # close file

#t0 - comparison
#t1 - wordCount // number of words out in array
# $t2 - address of buffer current iterating
# $t3 - current element of buffer
# $t4 - for i vs 10 comparision
#t6 - where we are in bufferArray (every word is 10 bytes apart)
# t7 - i is current word length

la $t2, buffer
la $t6, bufferArray 
add $t1, $zero, $zero

WordCountWhile:
slti $t0, $t1, 28
bne $t0, 1, WordCountExit

add $t7, $zero, $zero

WordElementWhile:#While(i<10)
slt $t0, $t7, 10
bne $t0, 1, WordElementExit
lb $t3, ($t2) # $t3 has current element of buffer
# if current char != newline
beq $t3, 10, WordElementIfExit # 10 is newLine
lb $t3, ($t6) #lb into array[i]
addi $t6, 1 # iterate to next address of array
WordElemenetIfExit:
addi $t7, 1 # iterate i
addi $t2, 1 # iterate to next address of buffer
j WordElementWhile
WordElementExit: 

addi $t4, 10
sub $t4, $t4, $t7# 10 - i
addi $t6, $t4 # array address + (10 - i)
addi $t1, 1# increment wordCount

j WordCountWhile
WordCountExit:

#$t0 - comparison
#$t1 - i
#$t2 - current address through bufferArray
la $t2, bufferArray

printLoop:
slti $t0, $t1, 280 #while i < 280
bne $t0, 1, PrintExit

li $v0, 4
la $a0, $t2
syscall

add $t2, $t2, $t1 # increment address through array
addi $t1, $t1, 1 # i++
j printLoop
PrintExit:




