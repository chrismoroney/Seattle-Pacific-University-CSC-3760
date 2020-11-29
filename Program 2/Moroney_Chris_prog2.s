# 3760
# Program 2 Test Harness
#-------------------------------------------------------------------------
# PLACE YOUR FUNCTION HERE
#-------------------------------------------------------------------------
# the conversion happens here, where we will take in a hex value and convert it into decimal evnetually with the other components above
convert_hex_str:
	li $t1, 0  #t1 will have the returned hex value
	move $t5, $a0 # we are not allowed to amend a0, so make a copy in t5
	li $v0,0 #initialize v0 to 0
	li $v1,0 #initialize v1 to 0

# in this loops, we are taking each character in our string and interpretting their ascii value. 
# The ascii values we are intersted in are 0 (null terminal), 48-57 (which is 0-9), 65-70 (A-F), and 97-102(a-f). All ascii values are decimal values
string_loop:	
	
    	lbu $t6, ($t5)    # Get the current character
    	beq $t6, 0, finished_label  # if it is 0, we are at the end of the string, jump to finished
    				    # because we hit null terminal
    	blt $t6, 48, error_label # if it is less than 48, it's invalid because we don't want any values that aren't 0 or less than 48
    	addi $t6, $t6, -48 # subtract 48 in order to reach the decimal ascii values
    	
    	ble  $t6, 10, right_value # if the value is now less than 10, we want it, so return the right_value			  
    				  # ex: if we have 1, which is ascii 49, we see (49-48) < 10, so we want this value.
    				  
    	addi $t6, $t6, -7 # otherwise subtract 7, in order to check and reach A-F values
	ble $t6, 15, second_check # if the value NOW is less than 15, we want it, so return the right_value
				 # ex if we have A, which is 65, we see that (65-48-7) < 15, and represents the decimal number 10, we want this
				 
	addi $t6, $t6, -32 #otherwise subtract 32, in order to reach a-f values
    	bge $t6, 10, third_check # if the value NOW is less than 15, we want it, so return the right_value
    	
    	j error_label # if we don't branch from to any of the right_value or finished_label, then its an error

# these functions are another parameter to make sure we reach only our A-F values or a-f values  
second_check: 
	blt $t6, 10, error_label #reaches here to make sure we don't obtain a value less than 10 after mathematical functions, otherwise is an overflow
third_check:
	bgt $t6, 15, error_label # reaches here to make sure we don't obtain a value greater than 15 after mathematical functions, otherwise is an overflow
	
# when we find a value for our character...	
right_value:
	bge $t1, 0x10000000, error_label # check if we have more than 8 digits. We check if $t1, which is the register doing the shifting 
					 # if it is larger than 0x10000000, then we have more than 8 digits because we shift for every bite, 
					 # and if our last digit is nonzero, then we already have 8 digits. This doesn't account for the whole actual 
					 # number, as that is in a different register.
	sll $t1, $t1, 4   # t1 contains the running total, so shift it left by 4 bits
	add $t1, $t1, $t6 # add what's in t0 to t1
    	addi $t5, $t5, 1  # move to next character
    	j string_loop # jump back to string loop, find value again
    	
# if we find an error or have an overflow constraing, we come here
error_label:
	li $v1, 1  # it's an error, so set v1 to 1, to indicate error state
	j exit_function #a nd exit
	
# when we hit the null terminal, we reach this point
finished_label:
	blt $t1, 0, error_label	# check if we have overflow in having a max positive int. The largest positive int is 
				# 0x7FFFFFFF because of 2s complement, and the last bit of 80000000 is a 1, indicating this is negative
				# if we have overflow, jump to show overflow	
	li $v1, 0 #the label is good, so set v1 to 0, no error
	j exit_function # and exit
	
exit_function:
	move $v0, $t1 #The harness expects the answer in v0, so load it like this
	jr $ra # return to line after the call
#-------------------------------------------------------------------------
# DO NOT MODIFY BELOW THIS COMMENT
#-------------------------------------------------------------------------
# Test harness
# Ask user to enter the hex string.
# Print the resulting integer, or report overflow.
# An empty string will terminate the program.
.data
# User prompt strings
prompt_str:     .asciiz "Enter your hexadecimal string.  Just hit enter to quit: "
your_str:       .asciiz "Your string: "
linefeed:       .asciiz "\n"
dbl_linefeed:   .asciiz "\n\n"
value_str:      .asciiz "Value : "
overflow_str:   .asciiz "Overflow detected!\n\n"
all_done_str:   .asciiz "\nGood luck with your program!.  Goodbye.\n"
error_str:	.asciiz "Oops! You hit an error!\n"
hex_str_buf:  # Space for input string from user.

.space 256

.text

.globl main

.globl convert_hex_str



main: 

get_input_string:

# display prompt
    li $v0,4            # code for print_string
    la $a0,prompt_str   # point $a0 to prompt string
    syscall             # print the string

# get the input string from the user
    li $v0,8            # code for read_string
    la $a0,hex_str_buf  # $a0 - input buffer address
    li $a1,256          # $a1 - Input buffer length
    syscall                # Get the string
                        # The string is NUL terminated.
    la $s0,hex_str_buf  # Save string in $s0
    # SPIM puts a closing NEW LINE (ASCII 0xa) on the end of the string.
    #  We need to strip that off, since that is not a legal character in our hex format.
    #  We just overwrite it with NUL (ASCII 0)
    move $s1, $s0     # $s1 char pointer


strip_nl:
    lbu $s2, ($s1)    # $s2 Get the current character
    beqz $s2, remove_nl
    addi $s1, $s1, 1  # Next character
    j strip_nl


remove_nl:
    li $s2, 10       # Expected NL = ASCII 10 (0xa)
    lbu $s3, -1($s1) # Character just before the NUL terminator
    bne $s3, $s2, check_for_exit
    li $s2, 0        # NUL Char (0)
    sb $s2, -1($s1)  # Wipe out NL


check_for_exit:
    # Check if the input string is empty.
    lbu $s2, ($s0)         # Load first byte of the string.
    beq $s2, $0, all_done  # Exit if first byte is NUL terminator

# print result string
# - Prompt string

    li    $v0,4            # code for print_string
    la $a0, your_str
    syscall                # print the string

# - The string
    li    $v0,4            # code for print_string
    move $a0, $s0
    syscall                # print the string

# - LF    
    li    $v0,4            # code for print_string
    la    $a0,linefeed     # point $a0 to string
    syscall                # print the string

# Call Hex Converter
    move $a0, $s0
    jal convert_hex_str
    move $s1, $v0         # Save value result in $s0
    move $s2, $v1         # Save error result in $s1
    beq $v1, $0, no_overflow

# - Overflow detected
# Print overflow message
    li    $v0,4
    la $a0, overflow_str
    syscall                # print the string
    j get_input_string     # Repeat

# - Value
no_overflow:
    # Print value message.
    li    $v0,4            # code for print_string
    la $a0, value_str
    syscall                # print value prompt
    li    $v0,1            # code for print_int
    move $a0, $s1
    syscall                # print the value itself.
    li    $v0,4            
    la    $a0,dbl_linefeed
    syscall                # print the linefeed
    j get_input_string     # Repeat

# - Prompt string
    li    $v0,4            # code for print_string
    la $a0, error_str
    syscall                # print the string

# All done, thank you!

all_done:    
    li    $v0,4            # code for print_string
    la $a0, all_done_str
    syscall                # print the string

    li    $v0,10           # code for exit
    syscall                # exit program	


