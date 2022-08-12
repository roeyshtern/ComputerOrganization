# Title: Question 2
# Author: Roey shtern
# Description: Given "Linked list" structure in data segment(value, next), The program prints
#		1. the sum of values
#		2. the sum of positive numbers that divide by 4
#		3. the values in base 4
		
# Input: None
# Output: The program prints
#		1. the sum of values
#		2. the sum of positive numbers that divide by 4
#		3. the values in base 4
#################### Data segment ####################
.data
num1: .word -8, num3
num2: .word 1988, 0
num3: .word -9034, num5
num4: .word -100, num2
num5: .word 1972, num4

#################### Code segment ####################
.text
.global main
main:
	#la $a0, num1
	#jal calcSum
	#jal println

	#la $a0, num1
	#jal calcSumDivideBy4
	#jal println
	
	la $a0, num1
	jal printValuesInBase4
		
	j Exit
	
	
# this function will iterate over the given nodes, start from $a0(address of node1)
# and will calculate the node's sum of values
calcSum:
	move $v0, $zero # reset $v0 to zero
	move $t1, $a0 #load the given first node address to the $t1 as holder for current node location
whileNotZeroA:	lw $t0, ($t1) #load the value, the first word by the address of node(stored in $a0) start of the while loop
	add $v0, $v0, $t0 # add it to the current sum
	lw $t1, 4($t1) # load the address of next node
	bne $t1, $zero, whileNotZeroA # check if reached to the final node(the next node address is zero) and branch again to the start of the while loop if not
	jr $ra
	
# this function will iterate over the given nodes, start from $a0(address of node1)
# and will calculate the node's sum of values that are positive and divide by four
# sum the values that has two zero bits on the right binary value and zero bit in MSB for negativity check
calcSumDivideBy4: 
	move $v0, $zero # reset $v0 to zero
	move $t2, $a0 #load the given first node address to the $t1 as holder for current node location
whileNotZeroB:# start of the while loop
	lw $t0, ($t2) #load the value, the first word by the address of node(stored in $a0)
	and $t1, $t0, 0x8003 # find if it positive and divide by 4 0x8003=1000000000000011 and save the rsult to $t1
	bnez $t1, nextNode # if $t1 its not 0 then the node's value is either negative or not divide by four then branch to next node
	add $v0, $v0, $t0 # add it to the current sum
nextNode:	
	lw $t2, 4($t2) # load the address of next node
	bne $t2, $zero, whileNotZeroB # check if reached to the final node(the next node address is zero) and branch again to the start of the while loop if not
	jr $ra

	
#this function will print the values of each node in base 4
# it will print eaxh digit in base 4, every two bits from MSB
# it will do it by shift the number i*2 times to the right and then print the digit for each set of two bits
printValuesInBase4:
	addi $sp, $sp, -8
	sw $ra ,4($sp)
	move $t0, $a0 #load the given first node address to the $t1 as holder for current node location
whileNotZeroC:# start of the while loop
	lw $t1, ($t0) #load the value, the first word by the address of node(stored in $a0)
	sw $t0, ($sp) # backup t0 because we want its value in the next itertations
	move $a0, $t1 # move the value of number to print as an paramter to printValueInBase4
	jal printValueInBase4
	
	lw $t0, ($sp)
	lw $t0, 4($t0) # load the address of next node
	bne $t0, $zero, whileNotZeroC # check if reached to the final node(the next node address is zero) and branch again to the start of the while loop if not
	lw $ra ,4($sp)
	addi $sp, $sp, 8
	jr $ra
	
printValueInBase4:
	addi $sp, $sp, -4
	sw $ra ,($sp)
	move $t0, $a0
	move $s0, $zero # reset $s0 to zero
	addi $s0, ,$s0, 7 #num of oteration
loop:	bgtz $t0, notZero
	not $t0, $t0
	addi, $t0, $t0, 1
notZero:
	srlv $t2, $t0, $s0
	andi $t2, 3 # and with 0000000000000011 to get the current two iterated bits
	subi $s0, $s0, 1
	beqz $t2, notZero
	move $a0, $t2
	jal print
	
	bnez $s0, loop

	lw $ra ,($sp)
	addi $sp, $sp, 4
	jr $ra
# this function will print the given value in $a0 with a \n after it
println:
	# print number in $a0
	move $a0, $v0
	li $v0, 1
	syscall
	# print newline
	li $a0, '\n'
	li $v0, 11
	syscall
	jr $ra
	
# this function will print the given value in $a0 without a \n after it
print:
	# print number in $a0
	move $a0, $v0
	li $v0, 1
	syscall
	jr $ra

Exit:
	li $v0, 10
	syscall
