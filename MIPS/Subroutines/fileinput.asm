# Sample MIPS program that writes to a new file

.data
fin: .asciiz "Dictionary.txt" #filename for output
buffer: .space 1240000 
userinput: 

.text

# open (for reading) a file that does not exist
li $v0, 13 # system call for open file
la $a0, fin # input file name
li $a1, 0 # open for reading (flags are 0: read, 1: write)
li $a2, 0 # mode is ignored
syscall # open a file (file descriptor return in $v0)
move $s6, $v0 # save the file descriptor
#####################
# read  file just opened
li $v0, 14 # system call for read from file
move $a0, $s6 # file descriptor
la $a1, buffer # address of buffer from which to read
li $a2, 100000 # hardcoded buffer length
syscall # read from file

la $a0, buffer # address of string to be printed
li $v0, 4 # print string
syscall
##############
# close the file
li $v0, 16 # system call for close file
move $a0, $s6 # file descriptor to close
syscall # close file