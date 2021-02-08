##############################################################################
# Proof-of-Study #4 
# 
# This program (when complete) will sort an array of numbers and print them
# out.  Your task is to hand-compile the code for the function that sorts
# the numbers.  You MUST follow the code outline - do not rearrange or
# optimize the algorithm.  Just convert each line of the algorithm
# into a small group of assembly statements.
#
# Several test cases are given below - feel free to adjust the code in 
# 'main' to test one of the other arrays.
#
# P.S.  I've always loved assembly language coding for breaking tasks into
# small, simpler steps.  It was great fun to write the solution, and I hope
# you find a bit of elegance or joy in your coding.  -- PJ
#
#Implementation Completed by Dan Ruley, September 2019
##############################################################################

# Data memory below this point.				
	.data
	
TestArray1:  # 3 elements
	.word 68, 4, 19	
	
TestArray2:  # 9 elements
	.word 9, 3, 7, 5, 1, 2, 4, 6, 8
	
TestArray3:  # 20 elements
        .word 20, 41, 38, 15, 96, 23, 13, 92, 91, 25, 17, 14, 40, 79, 51, 11, 15, 53, 64, 81 
        
Message1:
	.asciiz "*** Program has started. ***\n" 	
	
Message2:
	.asciiz "Unsorted data: " 	
	
Message3:
	.asciiz "Sorted data: " 	
	
Message4:
     	.asciiz "The number 42 from the stack, printed twice: "	
	
Message5:
	.asciiz "*** Program has ended. ***\n" 	


	
	
# Students should place additional asciiz data (and labels) below this line.

TestArray4: #40 elements
	.word 20, 41, 38, 15, 96, 23, 13, 750000, 92, 91, 25, 17, 14, 40, 79, 51, 11, 15, 53, 64, 81, 75, 21, 19, 34, 300, 400, 100, 6, 1, 2, 900000, 2, 1, 7, 8, 61, 69, 42, 24, 48, 96, 12, 13, 20, 41, 38, 15, 96, 23, 13, 92, 91, 25, 17, 14, 40, 79, 51, 11, 15, 53, 64, 81, 75, 21, 19, 34, 300, 400, 100, 6, 1, 2, 900000, 2, 1, 7, 8, 61, 69, 42, 24, 48, 96, 12, 13
        
	
Enter:
	.asciiz "Entering Sort: "
	
Leave:
	.asciiz "Leaving Sort: "
	

			
# Program memory below this point.				
	.text
	
Main:
	# Caution - Remember - You can change the code in Main for testing but
	# we will replace this code with our own code for official tests.  Do
	# NOT do anything here that your sort function will depend on.

	# Before doing anything else, print a message to the screen.
	#   Normally you wouldn't do this, but for testing it is nice to know
	#   that your program is running.
	
	la   $a0, Message1
	li   $v0, 4         # Print string syscall code
	syscall

	# Give our 'main' function a stack frame.  We won't use it, but we
	#   make sure to have one.  For testing, I'll create a frame large
	#   enough to hold ten words, and I'll put a 42 in the first position
	#   just for fun.  Also, because I use $s0 and $s1 below, I'll preserve them,
	#   and I'll also preserve the old frame pointer (whatever it was).
	
	li   $t0, 42        # I am doing this just for testing, no good reason.
	
	addi $sp, $sp, -40  # Create my stack frame.  (Really, just keep track of a new, smaller address.)
	sw   $fp, 12($sp)   # Preserve $fp by storing it in our stack frame.
	sw   $s1,  8($sp)   # Preserve $s1 by storing it in our stack frame.
	sw   $s0,  4($sp)   # Preserve $s0 by storing it in our stack frame.
	sw   $t0,  0($sp)   # Put a 42 in our frame (just to show you it can be done).
	addi $fp, $sp, 36   # The frame pointer address is now the address of 
	                    #   the top word (the tenth word, word 9) of our stack frame).
	                    
	# Set up for testing:
	#   $s0 - contains the base address of an array.
	#   $s1 - contains the length of an array.
	
	la   $s0, TestArray4
	li   $s1, 80
	  
	# Print out the unsorted array.
	
	la   $a0, Message2
	li   $v0, 4         # Print string syscall code
	syscall

        move $t0, $s0       # Copy the array base into $t0
        move $t1, $s1       # Copy the array length into $t1
                            #   $t1 represents the number of values we need to print        
Loop1Top:
        beq  $t1, $zero, Loop1End # If we have zero items left to print, exit the loop.
        
        lw   $a0, 0($t0)    # Load an integer from the array
        li   $v0, 1         # Print integer syscall code
	syscall
	
        li   $a0, 32        # ASCII code for a space character
	li   $v0, 11        # Print character syscall code
	syscall
	
	addi $t1, $t1, -1   # We now have one less item to print.
	addi $t0, $t0, 4    # Advance the address to the address of the next item.
	j    Loop1Top       # Go back and loop again.

Loop1End:

	li   $a0, 10        # ASCII code for a newline character
	li   $v0, 11        # Print character syscall code
	syscall
	
	#   Next, go sort the array.  (Students will need to write this function
	#   or else the code will stop working at this point.  Students should not
	#   change the way this function is called.  Students should also not add
	#   code to "Main" to preserve anything else on the stack.)
	
	move $a0, $s0       # Copy the array address into the first parameter.
	li   $a1, 0         # Set the low index to 0 (the index of the first array element)
	addi $a2, $s1, -1   # Set the high index to length-1 (the index of the last array element)
	jal  Sort           # Sort the array from positions lowIndex to highIndex (inclusive)

	# Print out the sorted array.
	
	la   $a0, Message3
	li   $v0, 4         # Print string syscall code
	syscall

        move $t0, $s0       # Copy the array base into $t0
        move $t1, $s1       # Copy the array length into $t1
                            #   $t1 represents the number of values we need to print        
Loop2Top:
        beq  $t1, $zero, Loop2End # If we have zero items left to print, exit the loop.
        
        lw   $a0, 0($t0)    # Load an integer from the array
        li   $v0, 1         # Print integer syscall code
	syscall
	
        li   $a0, 32        # ASCII code for a space character
	li   $v0, 11        # Print character syscall code
	syscall
	
	addi $t1, $t1, -1   # We now have one less item to print.
	addi $t0, $t0, 4    # Advance the address to the address of the next item.
	j    Loop2Top       # Go back and loop again.

Loop2End:

	li   $a0, 10        # ASCII code for a newline character
	li   $v0, 11        # Print character syscall code
	syscall
	
	# I stored a number 42 into the stack earlier.  Make sure it is still there, and
	#   use both the stack pointer and the frame pointer to access it.
	#   (This way, we make sure that the student has correctly restored the stack
	#   and that the student has not accidentally overwritten our data.)
	
	la   $a0, Message4
	li   $v0, 4         # Print string syscall code
	syscall
	
	lw   $a0, 0($sp)    # Load the 42 from our frame, use the stack pointer base address.
	li   $v0, 1         # Print integer syscall code
	syscall
	
	li   $a0, 32        # ASCII code for a space character
	li   $v0, 11        # Print character syscall code
	syscall
	
	lw   $a0, -36($fp)  # Load the 42 from our frame, use the frame pointer base address.
	li   $v0, 1         # Print integer syscall code
	syscall
	
	li   $a0, 10        # ASCII code for a newline character
	li   $v0, 11        # Print character syscall code
	syscall
	
	# Our 'Main' function is done.  Restore saved values from the stack frame and
	#   'remove' the stack frame.  We just adjust the $sp address, but this
	#   is how we keep track of stack frames, so the frame is 'removed'.  Since
	#   we grew the stack by 40 bytes above, we'll shrink it by 40 here.  (Remember,
	#   the stack 'grows' down, lower memory addresses = larger stack.)
	#
	# Important:  Don't 'remove' the frame until we have restored the data from it.
	
	lw   $fp, 12($sp)   # Preserve $fp by storing it in our stack frame.
	lw   $s1,  8($sp)   # Preserve $s1 by storing it in our stack frame.
	lw   $s0,  4($sp)   # Preserve $s0 by storing it in our stack frame.
	addi $sp, $sp, 40   # Remove my stack frame.  (Really, just keep track of a new, larger address.)
	                    
	# Now that the program has finished, print a message to the screen.
	#   Normally you wouldn't do this, but for testing it is nice to know
	#   that your program has completed normally.
	
	la   $a0, Message5
	li   $v0, 4         # Print string syscall code
	syscall
	
	# Exit gracefully.

	li   $v0, 10         # Terminate program syscall code
	syscall
        # Simulator will now stop executing statements.

##############################################################################

# Student code for the sort function should go here.  I deleted my solution
#   code below, but I left my comments behind.  (Some comments I replaced with ???
#   because they gave away exactly what to do.)

# void sort (int[] data, int lowIndex, int highIndex)
Sort:
	addi $sp, $sp, -20	#grow the stack to make room
        sw $ra, 0($sp)		#store old $ra
        sw $fp, 4($sp)		#store old $fp
        sw $s1, 8($sp)		#store old $s0
        sw $s2, 12($sp)	#store old $s1
        sw $s3, 16($sp)	#store old $s2
        addi $fp, $sp, 16	#set $fp to top of frame
	
	move $s1, $a0		#Move Data address from $a0 to $s1
	move $s2, $a1		#Move low index to $s2
	move $s3, $a2		#Move high index to $s3
			
	la   $a0, Enter		# print ("Entering sort: ")
	li   $v0, 4		# Print string syscall code
	syscall
	
	move   $a0, $s2		# Load low index
        li   $v0, 1		# Print integer syscall code
	syscall			# Print (lowindex)
	
	li $a0, 32
	li $v0, 11
	syscall			# print (" ")
	
        move $a0, $s3		# Load high index
        li   $v0, 1		# Print integer syscall code
	syscall			# print (highIndex)
	
	li $a0, 10
	li $v0, 11
	syscall			# print ("\n")
	
        blt $s2, $s3, KeepSorting #if lowindex < highindex, branch to KeepSorting, otherwise we go into the if statement.
	
	### if (lowIndex  >=  highIndex) ###
					
	la   $a0, Leave		# print ("Leaving sort: ")
	li   $v0, 4		# Print string syscall code
	syscall
        
        move   $a0, $s2	# Load low index
        li   $v0, 1		# Print integer syscall code
	syscall			# Print (lowindex)
	
	li $a0, 32
	li $v0, 11
	syscall			# print (" ")
	
        move $a0, $s3		# Load high index
        li   $v0, 1		# Print integer syscall code
	syscall			# print (highIndex)
	
	li $a0, 10
	li $v0, 11
	syscall			# print ("\n")
	
	
	j Return		#Jump to return from recursion
    
    	### end of if statement ###
            
KeepSorting:
      
	move $t2, $s2		# centerIndex = lowIndex
	
	sll  $t4, $s3, 2	# shift high index 2 bits to get memory offset
	add $t4, $s1, $t4	# add offset of high index to base address, store in $t5
	lw $t3, 0($t4)		# centerValue = data[highIndex]

    	move $t0, $t2		# tempIndex   = centerIndex
    	
	
WhileLoop:

    	### while (tempIndex < highIndex) ###	
    	slt $t9, $t0, $s3
    	beq $t9, $zero, WhileLoopEnd
    	        
    	sll $t4, $t0, 2		# shift temp index 2 bits to get memory offset
	add $t5, $s1, $t4	# add offset of temp index to base address, store in $t5
	lw  $t1, 0($t5)		# tempValue   = data[tempIndex]


	slt $t4, $t1, $t3	#will be true if temp value < center value 
	bne $t4, 1, AfterLoopConditional	#If not true, skip this conditional


	### if (tempValue  < centerValue) ###        
       
	sll $t4, $t0, 2		#offset for data[tempI]
	add $t6, $t4, $s1	#t6 now contains data[tempI] address	
	sll $t5, $t2, 2		#offset for data[centerI]
	add $t5, $t5, $s1	#t5 contains data[centerI] address
	
	lw $t7, 0($t5)		#load data[centerindex] to $t7
	sw $t7, 0($t6)		#data[tempIndex] contains data[centerIndex]
	sw $t1, 0($t5)		#data [centerIndex] contains temp value
    	
    	addi $t2, $t2, 1	#centerIndex = centerIndex + 1
   	
   	
AfterLoopConditional:
   	
   	addi $t0, $t0, 1	#tempIndex = tempIndex + 1
   	
   	j WhileLoop		#back to the top
   	
   	
   	
        ### While loop ends. ###
        
WhileLoopEnd:        

        sll $t4, $s3, 2	#$t4 contains highIndex offset
        add $t4, $t4, $s1	#$t4 contains address of data[highIndex]
        lw $t5, 0($t4)		#$t5 contains data[highIndex] value
        
        sll $t6, $t2, 2	#$t6 contains centerIndex offset
        add $t6, $t6, $s1	#$t6 contains data[centerIndex] address
        lw $t7, 0($t6)		#$t7 contains data[centerIndex] value
        
        sw $t7, 0($t4)		#data[highIndex]   = data[centerIndex]
        sw $t3, 0($t6)		#data[centerIndex] = centerValue


	
	### SET UP RECURSION CALL - RIGHT HALF OF SUBARRAY###
   	move $a0, $s1		#set up parameters for method call
   	addi $a1, $t2, 1
   	move $a2, $s3
   	
   	add $sp, $sp, -4	#grow stack and store $t2 (center index) because called method will change it.
        sw $t2, 0($sp)    
    
        jal Sort 		# sort (data, centerIndex+1, highIndex)
        
        lw $t2, 0($sp)		#pop stack and restore $t2 (center index)
        add $sp, $sp, 4
	### BACK FROM RECURSION CALL - RIGHT HALF OF SUBARRAY###
	
	
	
	### SET UP RECURSION CALL - LEFT HALF OF SUBARRAY###
	move $a0, $s1		#set up parameters for method call
   	move $a1, $s2	
   	addi $a2, $t2, -1
        
        add $sp, $sp, -4	#grow stack and store $t2 (center index) because called method will change it.
        sw $t2, 0($sp)        
        
        jal Sort 		# sort (data, lowIndex, centerIndex-1)
        
        lw $t2, 0($sp)		#pop stack and restore $t2 (center index)
        add $sp, $sp, 4
        ### BACK FROM RECURSION CALL - LEFT HALF OF SUBARRAY###
        
        
        

				# Time to return from recursive call		
	la   $a0, Leave		# print ("Leaving sort: ")
	li   $v0, 4		# Print string syscall code
	syscall
        
        move   $a0, $s2	# Load low index
        li   $v0, 1		# Print integer syscall code
	syscall			# Print (lowindex)
	
	li $a0, 32
	li $v0, 11
	syscall			# print (" ")
	
        move $a0, $s3		# Load high index
        li   $v0, 1		# Print integer syscall code
	syscall			# print (highIndex)
	
	li $a0, 10
	li $v0, 11
	syscall			# print ("\n")	

		
Return:				

	lw $ra, 0($sp)		#restore $ra so function returns to proper point
	lw $fp, 4($sp)		#restore $fp
	lw $s1, 8($sp)		#restore $s0
	lw $s2, 12($sp)		#restore $s1
	lw $s3, 16($sp) 	#restore $s2
	addi $sp, $sp, 20	#pop stack (restore $sp)

        jr $ra			#jump to ra
