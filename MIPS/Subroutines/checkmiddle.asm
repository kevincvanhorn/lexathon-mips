####################### test checkmiddle #############################
#.data
#prompt: .asciiz "Enter a string: "
#prompt2: .asciiz "Enter answer length: "

#gameTable: .byte 'a', 'e', 'i', 'o', 'z', 'b', 'c', 'd', 'f'
#userinput: .byte 9
#alength: .word 0
# 0 means true, 1 means false
#boolvalue: .word 1
#debug: .asciiz "\nim here\n"
#mletterused: .asciiz "Hurray! you used the middle letter"
#mnotused: .asciiz "You did not use the middle letter"


#.text
		#Ask the user for input
		#li $v0, 4
		#la $a0, prompt
		#syscall
		
		#Read the string from the user.
		#la $a0, userinput
		#li $a1, 9 #read 9 chars
		#li $v0, 8 #read string
		#syscall
		
		# ask user to enter answer length
		#li $v0, 4
		#la $a0, prompt2
		#syscall
		
		 # read answer length
		#li $v0, 5
		#syscall
		
		#sw $v0, alength
		
		# $t0 = 0 use as index for gameTable array of 9 letters
		#addi $t0, $zero, 0 # $t0 = 0
		
		# Call the checkmiddle function with three arguments
		#la $a0, gameTable
		#la $a1, userinput
		#lw $a2, alength
		# jump to checkmiddle
		#jal checkmiddle
		#sw $v0, boolvalue
		#lw $t6, boolvalue
		
		# print $t6
		#li $v0, 1
		#add $a0, $t6, $zero
		#syscall
		
		# if $v0 != 0, middle letter wasn't used
		#bne $t6, 0, else1
		#li $v0, 4
		#la $a0, mletterused
		#syscall
		
		# end program
		#li $v0, 10
		#syscall
		
	#else1:
		#li $v0, 4
		#la $a0, mnotused
		#syscall
		
		# end program
		#li $v0, 10
		#syscall
	####################### test checkmiddle #############################	
		
		
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
checkmiddle:
# return value $v0 = -1, initially
# return 0 if middle letter is used, return -1 if not used

# $a0 points to position 4 in gameTable
addi $a0, $a0, 4
#$t1 = gametable[4]
lb $t1, ($a0)
		
# $a1 points to position 0 in userinput (answer)
la $t5, ($a1) # $t5 points to position 0 in userinput
# index position starts at 0 ($t3)
addi $t3, $zero, 0
# store answer length in $t4
addi $t4, $a2, 0

while:
# if index >= answerlength, exit
bge $t3, $t4, exit
# else, execute the following code
# if gameTable[4] ($t1) = answer[i] ($t2), set $v0 = 0
lb $t2, ($t5) # set $t2 to next letter in user input

beq $t1, $t2, else
addi $t3, $t3, 1 #index++
addi $t5, $t5, 1 # point to next letter in user input
addi $v0, $zero, -1
j while

#index++
else:
addi $v0, $zero, 0 # middle letter is used, set $v0 = 0
jr $ra
 
exit:
jr $ra

		
