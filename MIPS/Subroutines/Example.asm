#****************************************************************
exponentiate: # exponentiate (baseparam, exponentparam)
#**************
# raises baseparam ($a0) to the power of exponentparam ($a1)
#
#
# Register usage
# $a0 - first param - x (where exponentiate = x to the y)
# $a0 - second param - y (where exponentiate = x to the y)
# $t0 - number being raised to power - I’m gonna call it the base
# $t1 - counter - this is the exponent, see the algorithm I use
# $t2 - “accumulator” - it holds the accumulated value of the exponentiation
# $v0 - return value - holds the result
#**************
sw $ra, 0($sp) # push ra
sub $sp, $sp, 4 # decrement stack pointer
# save parameters
# I don’t call any subroutines, so I don’t need $s registers
move $t0, $a0 # base = baseparam
move $t1, $a1 # count = exponentparam
li $t2, 1 # accumulator = ONE (initialize the acc)
powerloop:
beqz $t1, endexponentiate# if( ! count = zero ) {
mul $t2, $t2, $t0 # accumulator = accumulator * base
sub $t1, $t1, 1 # count = count - 1
j powerloop # }
endexponentiate:
move $v0, $t2 # return accumulator
add $sp, $sp, 4 # increment stack pointer
lw $ra, 0($sp) # pop ra
jr $ra # return to caller