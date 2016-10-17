# LEXATHON PROJECT
# @author	Kevin VanHorn (kcv150030), Nishant Gurrapadi (), 
#		Thach Ngo (), 
# Course: 	CS3340.50 Professor Nhut Nguyen
# Due: 1 December, 2016
#
# Analysis:
# Design: 
#
# STYLE GUIDE: http://www.sourceformat.com/pdf/asm-coding-standard-brown.pdf
	.data
	.text

main:


exponentiate: # exponentiate (baseparam, exponentparam) #THIS IS A N EXAMPLE
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