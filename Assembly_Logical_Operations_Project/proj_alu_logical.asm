.text
.globl au_logical

au_logical:
	# Caller RTE store
	addi	$sp, $sp, -36
	sw	$fp, 36($sp)
	sw	$ra, 32($sp)
	sw	$s0, 28($sp)
	sw	$s1, 24($sp)
	sw	$s2, 20($sp)
	sw	$s3, 16($sp)
	sw	$s4, 12($sp)
	sw	$s5, 8($sp)
	addi	$fp, $sp, 36
		
	move $s0, $a0	# Store first number to $s0
	move $s1, $a1	# Store second number to $s1
	
	beq $a2, '/', au_logical_divide
	beq $a2, '*', au_logical_multiply
	beq $a2, '-', au_logical_subtract

au_logical_add:	# Add
	and $t0, $s0, $s1
	xor $s0, $s0, $s1
	srl $v1, $t0, 31
	sll  $s1, $t0, 1
	bnez $s1, au_logical_add
	move $v0, $s0
	j au_logical_end
	
au_logical_subtract:	# Subrtact
	not $s1, $s1
	move $a0, $s1	# Adds one to the inverted second operand.
	li $a1, 0x1
	li $a2, '+'
	jal  au_logical
	move $s1, $v0
	move $a0, $s0	# Adds both operands together
	move $a1, $s1
	li $a2, '+'
	jal  au_logical
	j au_logical_end
	
au_logical_multiply: 	# Multiply
	move $s2, $zero	# Counter for how many of those two numbers are negatives
	bgez $s0, mul_first	# Branch if first number is non negative
	
	not $s0, $s0	# Otherwise inverse
	move $a0, $s0	# Add one logicaly to the number
	li $a1, 0x1
	li $a2, '+'
	jal  au_logical
	move $s0, $v0
	move $a0, $s2	# Add one logicaly to the counter
	li $a1, 0x1
	li $a2, '+'
	jal  au_logical
	move $s2, $v0
mul_first:
	bgez $s1, mul_second	# Branch if the second number is non negative
	
	not $s1, $s1	# Otherwise inverse
	move $a0, $s1	# Add one logicaly to the number
	li $a1, 0x1
	li $a2, '+'
	jal  au_logical
	move $s1, $v0
	move $a0, $s2	# Add one logicaly to the counter
	li $a1, 0x1
	li $a2, '+'
	jal  au_logical
	move $s2, $v0
mul_second:
	move $s3, $zero	# Create iterator I
	move $s4, $zero	# Create HI
unsigned_mult_loop:	# Unsigned multiply loop
	sll $t0, $s1, 31	# Isolate right most number of Multiplier
	beqz $t0, mul_zero	# Branch if the number is equal to zero
	li $t0, 0xffffffff	# Otherwise if its not zero it has to be one, so replicate 1 bit 32 times
	j mul_not_zero
mul_zero:
	li $t0, 0x00000000	# Replicate 0 bit 32 times
mul_not_zero:
	and $t1, $s0, $t0	# X = Multiplicand & Replicant
	move $a0, $s4	# Add X to HI
	move $a1, $t1
	li $a2, '+'
	jal  au_logical
	move $s4, $v0
	srl $s1, $s1, 1	# Shift Multiplier right by one
	and $t0, $s4, 0x1	# Stores HI[0] to $t0
	beqz $t0, mul_not_one	# Branch if it's zero because if it is then I don't need to do anything
	sll $t0, $t0, 31	# Otherwise move the bit from $t0[0] to $t0[31]
	or $s1, $s1, $t0	# Adds that bit to Multiplier[31]
mul_not_one:
	srl $s4, $s4, 1	# Shift HI to the right one
	move $a0, $s3	# Adds one to the iterator
	li $a1, 0x1
	li $a2, '+'
	jal  au_logical
	move $s3, $v0
	bne $s3, 32, unsigned_mult_loop	# If iterator is not at 32 go back to the beginning of the loop
	
	bne $s2, 1, mul_twos_comp	# If not negative number then skip
	not $s1, $s1 	# Otherwise inverse LO
	not $s4, $s4	# Inverse HI
	
	move $a0, $s1	# Add 1 logically to LO
	li $a1, 0x1
	li $a2, '+'
	jal  au_logical
	move $s1, $v0
	
	move $a0, $s4 	# Add last carryout of adding 1 to LO to HI
	move $a1, $v1
	li $a2, '+'
	jal  au_logical
	move $s4, $v0
mul_twos_comp:
	move $v0, $s1	# LO
	move $v1, $s4	# HI
	j au_logical_end 
	
au_logical_divide:	# Divide
	move $s2, $zero	# Counter for how many of those two numbers are negatives
	move $s5, $zero	# COunter to see if the first number is negative
	bgez $s0, div_first	# Branch if first number is non negative
	
	not $s0, $s0	# Otherwise inverse
	move $a0, $s0	# Add one logicaly to the number
	li $a1, 0x1
	li $a2, '+'
	jal  au_logical
	move $s0, $v0
	move $a0, $s2	# Add one logicaly to the counter for both
	li $a1, 0x1
	li $a2, '+'
	jal  au_logical
	move $s2, $v0
	move $a0, $s5	# Add one logicaly to the counter for the first
	li $a1, 0x1
	li $a2, '+'
	jal  au_logical
	move $s5, $v0
div_first:
	bgez $s1, div_second	# Branch if the second number is non negative
	
	not $s1, $s1	# Otherwise inverse
	move $a0, $s1	# Add one logicaly to the number
	li $a1, 0x1
	li $a2, '+'
	jal  au_logical
	move $s1, $v0
	move $a0, $s2	# Add one logicaly to the counter
	li $a1, 0x1
	li $a2, '+'
	jal  au_logical
	move $s2, $v0
div_second:

	move $s3, $zero	# Create iterator I
	move $s4, $zero	# Create Remainder
unsigned_div_loop:
	sll $s4, $s4, 1	# Shift remainder left by one
	srl $t0, $s0, 31	# Isolate bit at dividend[31]
	or $s4, $s4, $t0	# Add that bit to Remainder[0]
	sll $s0, $s0, 1	# Shift dividend left by one
	
	move $a0, $s4	# $t0 = remainder minus divisor
	move $a1, $s1
	li $a2, '-'
	jal  au_logical
	move $t0, $v0
	
	bltz $t0, div_less_zero	# If $t0 is smaller than zero go to next iterator++
	move $s4, $t0	# Otherwise remainder = $t0
	or $s0, $s0, 0x1	# Dividend[0] = 1
div_less_zero:
	move $a0, $s3	# Adds one to the iterator
	li $a1, 0x1
	li $a2, '+'
	jal  au_logical
	move $s3, $v0
	bne $s3, 32, unsigned_div_loop	# If iterator is not at 32 go back to the beginning of the loop

	bne $s2, 1, div_twos_comp_quotient	# If not negative number then skip
	not $s0, $s0 	# Otherwise inverse quotient
	
	move $a0, $s0	# Add 1 logically to quotient
	li $a1, 0x1
	li $a2, '+'
	jal  au_logical
	move $s0, $v0
div_twos_comp_quotient:

	bne $s5, 1, div_twos_comp_remainder	# If not negative number then skip
	not $s4, $s4 	# Otherwise inverse reaminder
	
	move $a0, $s4	# Add 1 logically to remainder
	li $a1, 0x1
	li $a2, '+'
	jal  au_logical
	move $s4, $v0
div_twos_comp_remainder:
	
	move $v0, $s0	
	move $v1, $s4	
	j au_logical_end 
	
au_logical_end:
	# Caller RTE restore
	lw	$fp, 36($sp)
	lw	$ra, 32($sp)
	lw	$s0, 28($sp)
	lw	$s1, 24($sp)
	lw	$s2, 20($sp)
	lw	$s3, 16($sp)
	lw	$s4, 12($sp)
	lw	$s5, 8($sp)
	addi	$sp, $sp, 36
	# Return to Caller
	jr	$ra
