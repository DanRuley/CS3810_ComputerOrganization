.data

Num: 0
Data: 0,0,0,0,0,0,0,0,0,0,0,1,1,1


.text

la $s0, Num				#Load num and Data addresses to $s0, $s1 registers.
la $s1, Data

lw $t0, 44($s1)			#Load correct Data words to $t0,1,2 registers.
lw $t1, 48($s1)
lw $t2, 52($s1)

add $t0, $t0, $t0			#2x
add $s2, $t0, $t0			#4x "hundreds" number to $s2
add $t0, $s2, $s2			#8x
add $t0, $t0, $t0			#16x
add $s3, $t0, $t0			#32x "hundreds" number to $s3
add $t0, $s3, $s3			#64x
add $s4, $s2, $s3			#32x + 4x in $s4
add $s4, $s4, $t0			#64x + 36x = 100x

add $s2, $t1, $t1			#2x "tens" number to $s2
add $t1, $s2, $s2			#4x
add $t1, $t1, $t1			#8x
add $s3, $t1, $s2			#10x "tens number to $t1

add $s2, $s4, $s3			#add hundreds and tens numbers
add $s2, $s2, $t2			#add ones

sw $s2, 0($s0)				#Store result from $s3 to num address
