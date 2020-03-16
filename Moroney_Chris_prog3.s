# Chris Moroney
# Bolding
# CSC 3760
# Due 16 March 2020
# Program 3: Bubble Sort
.data
    Xarray: .word 20, 19, 18, 17, 16, 15
    Xsize: .word 6
    end_prompt_str:     .asciiz "\nBubble Sort Complete!"
    start_prompt_str: .asciiz "Welcome to Bubble Sort by Chris Moroney!\n"
    comma: .asciiz ", "

.text

main:
    li $v0,4            # code for print_string
    la $a0, start_prompt_str   # point $a0 to prompt string
    syscall             # print the string
    la $a1, Xsize     # load size of the array
    lw $t1, 0($a1)     # put the value at the address of the Xsize into $t1

initialize:
    la $a1, Xarray($zero)    # a1 will hold the  pointer to the top of the array
    addi  $t1, $t1, -1   # t1 is the size of the array - 1. We two check nodes this number of times for each loop, then reduce the size by 1 every iteration
    addi $t7, $zero, 0   # t7 is the register that will keep track of the number of times we bubble check in the sorting, starts at 0
    

next_loop:
    move $a2, $a1  # a2 will hold the first array val to compare
    addi $a1, $a1, 4    # 4 bits is the size of a word, want to retrieve next value too
    move $a3, $a1       # a3 will hold the next array val to compare
    jal compare_values   # we have to have compare values as a subroutine, so we jump and link to compare_values
    addi $t7, $t7, 1   # we increment t7 as a check on this current bubble set
    beqz $v1, callforswap # if the value we get back from compare_values is equal to zero (which means earlier number is larger than next number), then we call for swap

swap_done:
    beqz $t1, prepareprint  # we check if the XSize is 0, or if the number of times we need to go through the array is now 0. If this is the case, we print array
    beq $t7, $t1, initialize #if not, then we compare the number of times we have bubbled in the array for the iteration, if that is equal to t1, then we go to next iteration
    j next_loop #otherwise we are still in the same iteration, and we need to keep bubbling until t7 == t1

compare_values:
    lw $t3, 0($a2)  #parameter a2 from array is loaded into t3
    lw $t4, 0($a3)  #parameter a3 from array is loaded into t4
    slt $v1, $t3, $t4   #$v1 will hold 1 if t2<t3 otherwise 0. If v1 is 0, then we need to swap the values in the array
    jr $ra              # return to linked address
    
callforswap: 
    jal swap_values #we come to here if we need to swap values. We call on the subroutine in this branch, then when finished, go to swap_done
    j swap_done	#once returned, we jump to swap_done to check if we still need to keep bubbling, move to next iteration, or print

swap_values:
    lw $t2, 0($a2)  # we load number from a2 in array into t2
    lw $t3, 0($a3)  # we load number from a3 in array into t3
    sw $t2, ($a3)   # we switch the value of address at a3 to have number from t2
    sw $t3, ($a2)   # we switch the value of address at a2 to have number from t3
    #note, this is only swapping in the temp registers, needs to be rewritten to array
    jr $ra    # return to linked address

prepareprint:
    la $a1, Xsize   # when finished, we reload the size into a1, as we need to print whole array
    lw $t1, 0($a1)  # load the size into a temp register t1
    addi $t7, $zero, 0  # set t7 to zero, this register keeps track of number of elements to print out (compares with t1)
    addi $t3, $zero, 0  # set t3 to zero, this register moves to the next address in the array, then retrieves its value
    
printlist:
    li $v0, 1	# tell system we want to print an int
    lw $a0, Xarray($t3)  # load word from what t3 currently is from array into a0
    syscall  #prints the int
    
    addi $t3, $t3, 4   #t3 moves to next address
    addi $t7, $t7, 1   #t7 increments by 1 to compare with the size
    beq $t7, $t1, end_program #if t7 equals t1, then we are done printing
    
    li $v0, 4  #if not, then we prepare to print out a string
    la $a0, comma  #just printing out a comma to separate the values
    syscall  #print the comma
    
    j printlist  #jump back to printlist, then loop through again until t7 == t1
      
end_program:
    li $v0,4            # code for print_string
    la $a0,end_prompt_str   # point $a0 to prompt string
    syscall             # print the string
    
    li $v0, 10 # code for end program
    syscall  #end program without subsequent lines of code
