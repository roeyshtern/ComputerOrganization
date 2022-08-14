# Title: Question 3
# Author: Roey shtern
# Description:
		
# Input: None
# Output:
#################### Data segment ####################
.data
CharStr: .asciiz "AEZKLBXWZXYALKFKWZRYLAKWLQLEK"
#ResultArray: .space 26
#CharStr: .asciiz "WZZZO"
mostFrequentCharStr: .asciiz "The most frequent char is "
appearancesCharStr: .asciiz " and it appears in the str "
timesCharStr: .asciiz " times."
enterToEnd: .asciiz "\nEnter 0 to end the program: "
ResultArray: .space 26
#################### Code segment ####################
.text
.global main
main:
	start_main_loop:
	la $a0, ResultArray
	move $t0, $a0
	clean_results:
	sb $zero, ($t0)
	sub $t1, $t0, $a0
	addi, $t0, $t0, 1
	li $t2, 26
	blt $t1, $t2, clean_results
	and $t0, $t0, $zero
	and $t1, $t1, $zero
	and $t2, $t2, $zero
	
	la $a0, mostFrequentCharStr
	li $v0, 4
	syscall
	la $a0, CharStr
	la $a1, ResultArray
	jal char_occurrences
	move $a0, $v0
	sw $v0, ($sp)
	subi $sp, $sp, 4
	li $v0, 11
	syscall
	la $a0, appearancesCharStr
	li $v0, 4
	syscall
	move $a0, $v1
	li $v0, 1
	syscall
	la $a0, timesCharStr
	li $v0, 4
	syscall
	
	
char_occurrences:
	move $t0, $a0
	move $v1, $zero
	move $v0, $zero
	loop_occurrences_char:
	lb $t1, ($t0) #store the current char to $t1
	beq $t1, 0, end_occurrences_char # if reach to end of string
	subi $t2, $t1, 'A' # get the index of the current char by sub the ascii value by the ascii value of 'A'
	add $t3, $a1, $t2 # get the address of the current char in result array (base + index)
	lb $t4, ($t3) # get the current occurrences of the current char
	addi, $t4, $t4, 1 
	sb $t4, ($t3) # store the new value back in resultArray
	
	blt $t4, $v1, next_iteration_occurrences_char# if less then max continue
	move $v1, $t4 # save the current max
	ble $t1, $v0, next_iteration_occurrences_char
	move $v0, $t1
	
	
	next_iteration_occurrences_char:
	addi $t0, $t0, 1
	j loop_occurrences_char
	
	end_occurrences_char:
	and $t0, $t0, $zero
	and $t1, $t1, $zero
	and $t2, $t2, $zero
	and $t3, $t3, $zero
	and $t4, $t4, $zero
	and $t5, $t5, $zero
	jr $ra

Exit:
	li $v0, 10
	syscall
