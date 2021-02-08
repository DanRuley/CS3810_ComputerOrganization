# Pascal.asm
#
# This assembly code calculates and prints the first 11 rows of Pascal's Triangle.
#
# Dan Ruley 
# September 2019

.data

                
PascalNums: 0,0,0,0,0,0,0,0,0,0,1
   
NewLine:        .asciiz "\n"


.text

main:					#Registers: $s7 = -1 constant for outer loop branching; $s3 = outer loop index; $t9 constant 10 for CalculateLoop branching
					#$s4, $s6 = used for PrintNums (see fn register comment); 


	addi $s7, $zero, -1		#Constant -1, used for branch logic in outer loop (otherwise bne 0, ... will not print last line)
	addi $s3, $zero, 10		#Outer loop
	addi $t9, $zero, 10		#Constant 10 for equality check
	    
OuterLoop:	

	addi $s4, $t9, 0    		#Print index start (Always 10)
	subi $s6, $s3, 1		#Print index end   (Always outer loop index - 1)
	jal PrintNums 			#Jump to PrintNums function

	addi $s0, $zero, 0		#Reset CalculateLoop index
	jal CalculateLoop		#Jump to CalculateLoop
	   
	subi $s3, $s3, 1		#Decrement outer loop index   
	bne $s7, $s3, OuterLoop	#Back to the top


	li    $v0, 10			
	syscall               		# Done, return to caller



		#End of Program, Functions below



CalculateLoop:            		#Registers: $s0 = loop index; $s1 = array[i] offset; $s2 = array[i + 1] offset 
   					#$t0 = array[i] data; $t1 = array[i + 1] data; $t2 = array[i] + array[i + 1]
   					#$ra = return address
   						
   								
	sll $s1, $s0, 2	   		#Shift $s0 left 2 bits to get offset for i, put in $s1
	lw $t0, PascalNums($s1) 	#Load array[i] into $t0         
	addi $s2, $s1, 4      		#Calculate $s1 + 4 for i + 1 memory offset, store into $s2	      
	lw $t1, PascalNums($s2)	#Load array[i+i] into $t1
            
	add $t2, $t0, $t1		#Array[i] + array[i+1]           
	sw $t2, PascalNums($s1)	#Store calculated result back to array[i]
	addi $s0, $s0, 1		#$s0 = $s0 - 1
	bne $t9, $s0, CalculateLoop	#Keep looping if $s0 < 10 (stored in $t9)
	    
	jr $ra				#Return to caller




PrintNums: 				#Registers: $s4 = print index start; $s6 = print index end; $s5 = memory offset for printing number 
   					#$v0, $a0 = used for printing; $ra = return address
	
	
	sll $s5, $s4, 2	   		#shift $s4 left 2 bits to get offset for array[i] address; put in $s5
		
        li $v0, 1	    		#This is the instruction for printing an integer from a register
        lw $a0, PascalNums($s5)	#Load proper value to $a0 for printing
        syscall               		#Print the result

	li $v0, 11			#Load the syscall #11 (printchar) to $v0 (the system reg)
	la $a0, 9			#Load 32 to $a0, 9 = ascii code for tab
	syscall               		#Print the char (a tab)
	
	subi $s4, $s4, 1		#Decrement print index
	
	bne $s6, $s4, PrintNums 	#Keep looping if $s6 > $s4
	
	li    $v0, 4
	la    $a0, NewLine
	syscall               		#Print extra newline
		
	jr $ra				#Return to caller
