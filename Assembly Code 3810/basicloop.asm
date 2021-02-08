# Mystery Code.asm
#
# This assembly code accepts an integer as input, computes a result, and
# outputs an integer as output.  Report your input and output as answers
# on your first homework assignment.
#
# To use:
#    Run "MARS" MIPS simulator
#        In CADE lab:     Use Mars menu item or type mars.
#        At home:         Download and double-click it in Windows.
#    Select File->new
#    Cut-and-paste this code into the editor window
#    Select File->save and save the program
#    Press f3 to assemble  (You can also use the toolbar button)
#    Press f5 to run       (You can also use the toolbar button)
#    Enter input
#    Examine output (in Run I/O tabbed window)
#    Return to editor view (click Edit tabbed window)

            .data
            
Num:        .word 42	#The answer (but what's the question?)
            

prompt1:
            .asciiz "Experiment \n"

prompt2:
            .asciiz "\n"

            .text
main:

	    addi $s0, $zero, 10     #set $s0 = 10

MyFirstLoop:
            	
         
            
            lw $t0, Num
                        
            
            li    $v0, 1	    #This is the instruction for printing an integer from a register (I think)
            move  $a0, $t0        #move $t0 -> $a0
            syscall               # Print the result
            
            
            addi $t0, $t0, 1
            sw $t0, Num 	#Num++
            
                        
            jal PrintSpace
	
	    subi $s0, $s0, 1		#$s0 = $s0 - 1

	    bne $zero, $s0, MyFirstLoop	#branch if not equal: if 0 != $s0, go back to top of MyFirstLoop
         
            li    $v0, 10
            syscall               # Done, return to caller

PrintSpace: 

	    li    $v0, 11		#load the syscall #11 (printchar) to $v0 (the system reg)
            la $a0, 32			#load 32 to $a0, 32 = ascii code for space
            syscall               	# print the char (a space)
            jr $ra			#return