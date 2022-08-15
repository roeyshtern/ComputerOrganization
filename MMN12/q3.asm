# Title: Question 3
# Author: Roey shtern
# Description: this function will get charStr and calculate the number of occurrences of each letter in CharStr
#		and save the result ot ResultArray a 26 byte array represent the number of occurrences of each letter in charStr
#		then it will print the most frequent char in CharStr and the number of appearances in CharStr
#		then it will print each char by its count of occurrences in charStr
#		then it will delete the current char for CharStr
#		then it will ask the user to repeat the process as long as CharStr contains atleast one char
		
# Input: if the user want to repeat the process of the program or exit
# Output:
#		 print the most frequent char in CharStr and the number of appearances in CharStr
#		 print each char by its count of occurrences in charStr
#################### Data segment ####################
.data
CharStr: .asciiz "AEZKLBXWZXYALKFKWZRYLAKWLQLEKKK"
resultStr: .asciiz " has the most appearances with the number of: "
endOfMainStr: .asciiz "\nDo you want to repeat this process with current str\nEnter 1 to continue or 0 to exit\n"
ResultArray: .space 26
#################### Code segment ####################
.text
.global main
main:
	main_loop:
	la $a0, ResultArray
	move $t0, $a0
	li $t2, 26
	# reset ResultArray with zeros
	reset_resultArray:
	sb $zero, ($t0)
	sub $t1, $t0, $a0
	addi, $t0, $t0, 1
	
	blt $t1, $t2, reset_resultArray
	
	la $a0, CharStr
	la $a1, ResultArray
	jal char_occurrences
	
	# back up the most frequent char for 'delete' function
	addi $sp, $sp, -4
	sw $v0, ($sp)
	
	move $a0, $v0
	move $a1, $v1
	jal print_result
	
	la $a1, ResultArray
	jal print_Char_by_occurrences
	
	# restore the most frequent char
	la $a0, CharStr
	lw $a1, ($sp)
	addi $sp, $sp, 4
	jal delete

	la $a0, CharStr
	lb $t0, ($a0)
	beqz $t0, exit_main_loop # if there is zero chars left in CharStr
	
	la $a0, endOfMainStr
	li $v0, 4
	syscall

	li $v0, 5
	syscall
	bnez $v0, main_loop # if the user want to repeat the process then return to the start of main
	
	exit_main_loop:
	j Exit
	
char_occurrences:
	move $t0, $a0
	move $v1, $zero
	move $v0, $zero
	loop_occurrences_char:
	lb $t1, ($t0) #store the current char to $t1
	beq $t1, 0, end_char_occurrences # if reach to end of string
	subi $t2, $t1, 'A' # get the index of the current char by sub the ascii value by the ascii value of 'A'
	add $t3, $a1, $t2 # get the address of the current char in result array (base + index)
	lb $t4, ($t3) # get the current occurrences of the current char
	addi, $t4, $t4, 1 
	sb $t4, ($t3) # store the new value back in resultArray
	
	blt $t4, $v1, next_iteration_occurrences_char# if less then max continue
	bgt $t4, $v1, max_ascii_char # if the current count is bigger than current max replace char and occurrences
	blt $t1, $v0, next_iteration_occurrences_char # if the current count equal and the char is not bigger, continue iterate


	max_ascii_char:
	move $v0, $t1 # save the current max_ascii_char
	max_occurrences:	
	move $v1, $t4 # save the current max_occurrences	
	
	next_iteration_occurrences_char:
	addi $t0, $t0, 1
	j loop_occurrences_char
	
	end_char_occurrences:
	
	jr $ra

# this function will print the result of 'char_occurrences'
print_result:
	move $t0, $a0
	move $t1, $a1

	#print the most frequent char
	move $a0, $t0
	li $v0, 11
	syscall
		
	la $a0, resultStr
	li $v0, 4
	syscall	
	
	# print the number of occurrences
	move $a0, $t1
	li $v0, 1
	syscall

	jr $ra

# this function will print each char by its occurrences in the CharStr
print_Char_by_occurrences:
	move $t0, $a1 # load the address of resultArray
	li $t1, 26 # number of iterations
	li $v0, 11 # the value for syscall to print char

	
	loop_all_chars:
	lb $t2, ($t0) # load the value of occurrences of the current char in Array
	beqz $t2, next_char# if 0 then continue to itrate
	li $a0, '\n'
	syscall
	
	print_all_char_by_occurrences:
	sub $t3, $t0, $a1 # get the index of the current char
	addi $a0, $t3, 'A' # put in $a0 the current ascii value ('A'+ index)
	
	syscall
	subi $t2, $t2, 1
	
	bnez $t2, print_all_char_by_occurrences
	
	next_char:
	subi $t1, $t1, 1 # reduce the number of iteration by one
	addi $t0, $t0, 1
	bnez $t1, loop_all_chars
	
	jr $ra

# this function will get $a0 - address of str, $a1 char. will remove all occurrences of this char from str with the use of the function 'reduction'
delete:
	# store ra
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	move $t0, $a0 # set current pointer to address
	
	delete_chars_loop:
	lb $t1, ($t0) # load the current char value in this address
	bne $t1, $a1, next_delete_char # if not the char we want to remove continue iterate

	#backup t0,t1
	addi $sp, $sp, -8
	sw $t0, ($sp)
	sw $t1, 4($sp)
	
	#make reduction with current position
	move $a0, $t0
	jal reduction
	
	# restore t0,t1
	lw $t1, 4($sp)
	lw $t0, ($sp)
	addi $sp, $sp, 8
	
	#if reduce char then move backward by one the current pointer to address so it will continue to point to the same position
	subi $t0, $t0, 1

	next_delete_char:
	addi $t0, $t0, 1
	bnez $t1, delete_chars_loop
	
	# restore ra
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra

# this function will shift the str left once, reducution by one
reduction:
	move $t0, $a0
	
	reduction_loop:
	lb $t1, ($t0) # get current char by address given
	beqz $t1, exit_reduction # if end of str then exit
	
	# load and store the next byte in current position
	lb $t2, 1($t0)
	sb $t2, ($t0)
	addi, $t0, $t0, 1 # progress position by one
	j reduction_loop
	
	exit_reduction:
	jr $ra
		
Exit:
	li $v0, 10
	syscall
