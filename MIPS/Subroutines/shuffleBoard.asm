.text
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
	bne $t0, $t2, Exit	# if i >= 9, exit loop
	
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

Exit: jr $ra

#****************************************************************
