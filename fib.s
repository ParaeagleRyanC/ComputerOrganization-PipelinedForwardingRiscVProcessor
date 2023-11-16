#######################
#
# Filename: fib.s
#
# Author: Ryan Chiang
# Class: ECEn 323, Section 1, Winter 2023
# Date: 03/27/2023
#
# Template for completing Fibinnoci sequence in lab 11
#
# Description:
#
# Functions:
#  - fibonacci: Calculates the fibonacci number for input a0
#				and returns result to a0 using the iterative method.
#
# Memory Organization:
#   0x0000-0x1fff : text
#   0x2000-0x3fff : data
# Registers:
#   x0: Zero
#   x1: return address
#   x2 (sp): stack pointer (starts at 0x3ffc)
#   x3 (gp): global pointer (to data: 0x2000)
#   s0: Loop index for Fibonacci call
#   s1: Pointer to 'fib_count' in data segment
#   x10-x11: function arguments/return values
#
#######################
.globl  main

.text
main:

    #########################
    # Program Initialization
    #########################

    # Setup the stack: sp = 0x3ffc
    lui sp, 4				# 4 << 12 = 0x4000
    addi sp, sp, -4			# 0x4000 - 4 = 0x3ffc
    # setup the global pointer to the data segment (2<<12 = 0x2000)
    lui gp, 2
    
    # Prepare the loop to iterate over each Fibonacci call
    addi s0, x0, 0			# Loop index (initialize to zero)

    # Load the loop terminal count value (in the .data segment)

    # The following assembly language macro is useful for accessing variables
    # in the data segment. This macro helps determine the address of data variables.
    # The form of the macro is '%lo(label)(register). The 'label' refers to
    # a label in the data segment and the register refers to the RISC-V base
    # register used to access the memory. In this case, the label is 
    # 'fib_count' (see the .data segment) and the register is 'gp' which points
    # to the data segment. The assembler will figure out what the offset is for
    # 'fib_count' from the data segment.
    lw s1,%lo(fib_count)(gp)	 # Load terminal count into s1

FIB_LOOP:
    # Set up argument for call to iterative fibinnoci
    mv a0, s0
    jal iterative_fibinnoci
    # Save the result into s2
    mv s2, a0
    # Set up argument for call to recursive fibinnoci
    mv a0, s0	
    jal recursive_fibinnoci
    # Save the result into t3
    mv s3, a0
    
    # Determine index in circular buffer on where to store result
    andi s4, s0, 0xf	# keep lower 4 bits (between zero and fifteen)
    # multiply by 4 (shift left by 2) to get offset
    slli s4, s4, 2
    
    # Compute base pointer to iterative_data
    addi s5, x3, %lo(iterative_data)
    # add the offset into the table based on the current index
    add s5, s5, s4
    # Store result
    sw s2,(s5)
    
    # Compute base pointer to recursive_data
    addi s5, x3, %lo(recursive_data)
    add s5, s5, s4
    # Store result
    sw s3,(s5)
    
    # Increment pointer and see if we are done
    beq s0, s1, done
    addi s0, s0, 1
    # Not done, jump back to do another iteration
    j FIB_LOOP

done:
    
    # Now add the results and place in a0
    addi t0, x0, 0     	# Counter (initialize to zero)
    addi t1, x0, 16		# Terminal count for loop
    addi a0, x0, 0		# Intialize a0 t0 zero
    # create a pointer to the iterative data
    addi t2, gp, %lo(iterative_data)
    # create a pointer to the recursive data
    addi t3, gp, %lo(recursive_data)
    
    # Add the results of all the calls
final_add:
    lw t4, (t2)
    add a0, a0, t4
    lw t4, (t3)
    add a0, a0, t4
    addi t2, t2, 4		# increment pointer
    addi t3, t3, 4		# increment pointer
    addi t0, t0, 1
    blt t0, t1, final_add
    
    # Done here!
END:
    addi a7, x0, 10   # Exit system call
    ebreak
    # Should never get here
    jal x0, END
    nop
    nop
    nop

iterative_fibinnoci:

    # This is where you should create your iterative Fibinnoci function.
    # The input argument arrives in a0. You should create a new stack frame
    # and put your resul in a0 when you return.
	
	addi sp, sp, -12            # Make room to save values on the stack
    sw s0, 0(sp)                # Save the caller s0 on stack. Used as the subroutine fibonacci (a-1) argument
    sw s1, 4(sp)                # Save the caller s1 on stack. Used as the subroutine fibonacci (a-2) argument
    sw ra, 8(sp)                # The return address needs to be saved to know where subroutine was called from 

   	beq x0, a0, iterative_return 			# Branch to return_zero if input (a0) is 0
    addi t0, x0, 1 					# Set register t0 to 1 for the coming up check
    beq a0, t0, iterative_return 			# Branch to return_one if input (a0) is 1
    
   	addi s0, a0, -1				# Set the subroutine fibonacci argument to a-1
   	addi s1, a0, -2				# Set the subroutine fibonacci argument to a-2
   	
   	add a0, x0, s0					# Set the input argument to the subroutine argument (a-1)
   	jal iterative_fibinnoci				# Call the fibonacci function as the first subroutine
   	add s0, x0, a0					# Save the result in s0 for addition later
   	
   	add a0, x0, s1					# Set the input argument to the subroutine argument (a-2)
   	jal iterative_fibinnoci				# Call the fibonacci function as the second subroutine
   	add a0, a0, s0				# Add the two results together and store it in the return register
   
iterative_return:
	lw s0, 0(sp)                # Restore callee saved regs used. Load previous callee fibonacci (a-1) argument
    lw s1, 4(sp)                # Restore callee saved regs used. Load previous callee fibonacci (a-2) argument
    lw ra, 8(sp)                # Restore return address
    addi sp, sp, 12             # Update stack pointer

    
    ret

recursive_fibinnoci:

    # This is where you should create your iterative Fibinnoci function.
    # The input argument arrives in a0. You should create a new stack frame
    # and put your result in a0 when you return.
    
	beq x0, a0, recursive_return 			# Branch to return if input (a0) is 0
    
    addi t0, x0, 1 					# Set register t0 to 1 for the coming up check
    beq a0, t0, recursive_return 			# Branch to return_one if input (a0) is 1
    
    addi t3, x0, 0					# Set register s4 to 0 as variable fib_2
    addi t4, x0, 1					# Set register s5 to 1 as variable fib_1
    addi t5, x0, 0					# Set register s6 to 0 as variable fib	
    
recursive_loop_init:           			# Label for the start of the loop code
	# 1. Initialize the loop variables (executes once for loop)
	addi t0, x0, 2   			# t0 is the loop variable, initialized to 2 (corresponds to i=2)
    addi t1, a0, 1				# t1 is the loop limit constant, add 1 to the limit to satisfy the loop condition (corresponds to limit=(a+1))

recursive_loop_body_start:     			# Label for start of loop
	# 2. Check loop condition (branch out of loop if false)
   	bge t0, t1, recursive_loop_end 		# branch out of loop if the index is >= limit (corresponds to i>=a)

	# 3. Loop body. Put the instructions for the body of the loop here
	add t5, t3, t4				# store the value of s4 + s5 to s6 (corresponds to fib = fib_1 + fib_2)
	add t3, x0, t4					# set the value of s4 to the value of s5 (corresponds to fib_2 = fib_1)
	add t4, x0, t5					# set the value of s5 to the value of s6 (corresponds to fib_1 = fib)
	
	# 4. Post Loop Update. 
   	addi t0, t0, 1    			# Increment loop index t0
   	beq x0, x0, recursive_loop_body_start # Unconditional branch back to the start of the loop

recursive_loop_end:       				# Label for code after loop
	add a0, x0, t5					# Load value of register s6 to register a0, setting return value to fib

        
    ret
    # Extra NOPs inserted to make sure we have instructions in the pipeline for the last instruction
    nop
    nop
    nop


recursive_return:							# Label for return block
    ret							# return from a subroutine
	nop
	nop
	nop

.data

# Indicates how many Fibonacci sequences to compute
fib_count:
    .word 15   # Perform Fibonacci sequence from 0 to 15

# Reserve 16 words for results of iterative sequences
# (16 words of 4 bytes each for a total of 64 bytes)
iterative_data:
    .space 64 

# Reserve 16 words for results of recursive sequences
# (16 words of 4 bytes each for a total of 64 bytes)
recursive_data:
    .space 64 
    
    


