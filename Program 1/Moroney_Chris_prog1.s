###################### DATA SECTION ##############################

.data		# marks the beginning of the data segment
    random_num:	.word   51 	# this can be changed from here
    max_tries:	.word	10	# We have a maximum number of 10 tries
    welcome:	.asciiz "Welcome to Chris's number guessing game. You have 10 attempts to guess my secret number! \n"
    prompt:		.asciiz "Guess a number between 1 and 100\n"
    guess_again:	.asciiz "Try again\n"
    got_it:		.asciiz "You got it!\n"
    got_it_tries1:	.asciiz "It took you "
    got_it_tries2:	.asciiz " tries. Not bad!\n"
    loser:		.asciiz "You've tried too many times. Sorry, you Lose!\n"
    thanksforplaying:   .asciiz "Thanks for playing Chris's game!"
    guess_too_high:	.asciiz "Your guess is too high\n"
    guess_too_low:	.asciiz "Your guess is too low\n"

###################### CODE SECTION ##############################			

.text		# marks the beginning of the code portion

main:
	# initialize variables for current and max tries
	li $t3, 0			# this is the current number of tries. It starts at 0
	lw $t4, max_tries		# this is the maximum number of tries 
	li $v0, 4			# code for print string
	la $a0, welcome			# put the promp into the register
	syscall				# syscall to print the welcome
	

read_next_value:
    # read in the next value after the initial propt has been printed
	add  $t3, $t3, 1		# Add 1 to the number of guesses
	bgt $t3, $t4, out_of_guesses	# If t3 (current guess count) is greater than  t4, game over						 
	li $v0, 4			# code for print string
	la $a0, prompt			# put the promp into the register
	syscall				# execute

	# Get User input and store in t0
	li $v0, 5			# code for read_int
	syscall				# execute - int will be in $v0
	move $t0, $v0			# move the result to $t0



	# Check for less than, greater than, or equal to our desired value
	lw $t1, random_num		# load our random_num into t1
	blt $t0, $t1, too_small   	# t0 is < t1, so go too_small
	bgt $t0, $t1, too_big		# t0 is > t1, so go too_big
	beq $t0, $t1, right_guess   	# if t0 and t1 are the same (branch equal = beq) then go right guess
	j exit
# branches to here if input is smaller than the number
too_small:
	li $v0, 4			# 4 to print a string
	la $a0, guess_too_low		# Load thhe 'its too low' string
	syscall				# Syscall to print
	j try_again			# If t3 (current guess count) is less than t4 (max guesses), try again
# branches to here if input is larger than the number
too_big:
	li $v0, 4			# 4 to print a string
	la $a0, guess_too_high		# Load thhe 'its too low' string
	syscall				# Syscall to print
	j try_again			# If t3 (current guess count) is less than t4 (max guesses), try again
# branches to here if are input matches the random number
right_guess:
    li $v0, 4			# 4 to print a string
    la $a0, got_it			# Load the 'you got it' string
    syscall				# Syscall to print
    li $v0, 4			# 4 to print a string
    la $a0, got_it_tries1		# the first part of the 'you got it' message
    syscall				# print it
    li $v0, 1			# 1 to print an integer
    move $a0, $t3			# t3 has the number of tries, move it to a0
    syscall				# print it
    li $v0, 4			# 4 to print a string
    la $a0, got_it_tries2		# the second half of the 'you got it' message
    syscall				# print it
    li $v0, 4           # 4 to print a string
    la $a0, thanksforplaying    #thanks for playing my game!
    syscall             # Syscall to print
    j exit				# Jump to exit

try_again:
    li $v0, 4			# 4 to print a string
    la $a0, guess_again		# Load the guess again string
    syscall				# Syscall to print
    j read_next_value		# Jump back to read the next value

out_of_guesses:
    li $v0, 4			# 4 to print a string
    la $a0, loser			# Load the guess again string
    syscall				# Syscall to print
    	
    li $v0, 4           # 4 to print a string
    la $a0, thanksforplaying    #thanks for playing my game!
    syscall             # Syscall to print
    j exit				# Jump back to read the next value
    	    	    	    	
exit:
    li $v0, 10                  	# 10 to end the program
    syscall				# Syscall to exit (code 10)
