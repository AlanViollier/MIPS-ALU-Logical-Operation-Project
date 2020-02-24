.text
.globl au_normal
#####################################################################
# Implement au_normal
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_normal:
	# Caller RTE store
	addi	$sp, $sp, -20
	sw	$fp, 20($sp)
	sw	$ra, 16($sp)
	sw	$s0, 12($sp)
	sw	$s1, 8($sp)
	addi	$fp, $sp, 20
	
	move $s0, $a0
	move $s1, $a1
	beq $a2, '/', au_normal_divide
	beq $a2, '*', au_normal_multiply
	beq $a2, '-', au_normal_subtract
	add $v0, $s0, $s1
	j au_normal_end
au_normal_subtract:
	sub $v0, $s0, $s1
	j au_normal_end
au_normal_multiply:
	mul $v0, $s0, $s1
	mfhi $v1
	j au_normal_end
au_normal_divide:
	div $s0, $s1
	mflo $v0
	mfhi $v1
	j au_normal_end
au_normal_end:
	# Caller RTE restore
	lw	$fp, 20($sp)
	lw	$ra, 16($sp)
	lw	$s0, 12($sp)
	lw	$s1, 8($sp)
	addi	$sp, $sp, 20
	# Return to Caller
	jr	$ra
