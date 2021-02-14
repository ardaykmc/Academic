.data
# -9999 marks the end of the list
firstList: .word 8, 3, 6, 10, 13, 7, 4, 5, -9999

# other examples for testing your code
secondList: .word 8, 3, 6, 6, 10, 13, 7, 4, 5, -9999
thirdList: .word 8, 3, 6, 10, 13, -9999, 7, 4, 5, -9999

# assertEquals data
failf: .asciiz " failed\n"
passf: .asciiz " passed\n"
buildTest: .asciiz " Build test"
insertTest: .asciiz " Insert test"
findTest: .asciiz " Find test"
asertNumber: .word 0



space: .asciiz " "
line: .asciiz "-"
Xsign: .asciiz "X "
newLine: .asciiz "\n"
.text

# ALlocate the rquired memory and return the address
AllocateMem:
	li $a0,16 #required size is 16 bytes
	li $v0,9  #sbrk system call
	syscall   #store the addres
	jr $ra

# Has two parameters First one Parent Address on $a0 
# Has two parameters Second one Value Address on $a1
# May reuire 3rd address itself positon stored on $a2
LinkNode:
	lw $t0,0($a2) # store its address to t0 register
	sw $a2,0($t0)   # store the value initial position
	sw $a0,12($t0)  # store its parent address to x + 12
	sw $zero,8($t0) # store zero because no right chilf
	sw $zero,4($t0) # store zero because no left chilf
	# It will use as method 
	jr $ra

build:
	# At this point we know init position
	# Create space for first (Node) element

	move $t0,$ra # store return address on $t0 
	#stack pointer usage not neccecart for just 1 register storage
	jal AllocateMem # Now $v0 register have the return address
	# Get the Address of allocated memory
	move $ra,$t0  # restore return address on $ra register
 
	move $s0,$v0  

	lw  $t0,0($s1)
	sw  $t0,0($s0) #store value on t0 (first element of list) to addres of $s0
	sw 	$zero,4($s0)	# set left child zero
	sw 	$zero,8($s0)	# set right child zero too
	move $s0,$s0  	# set parent addres as itselt	
	# After set first element of list we can start build it
	# We need two loop one get next element other one find suitable place for it
	
	# $t0 hold the value of root and $s1 is the first addres on the list
	# $t3  and  $t4 registers used for iterate throught the given list
	# $t5  and  $t6 registers used fot the iterate on tree

	move $t3,$zero
	addi $t3,$s1,4  # assign the second element index 
	lw $t4,0($t3)   # store the value on $t4
listIterator:
	# On each iteration start from root to find proper place to new list element 
	move $t5,$s0  # store init position
	lw $t6,0($t5) # store the value of root 

	beq $t4,-9999,buildExit # if the element comes from list equal -9999 terminate the program 
	nextNode:
	slt $t2,$t6,$t4  # if the node in tree value smaller than the list element $t2 is 1 else $t2 is 0

	bne $t2,0,addToRight
	# else add to left
	j addToLeft

addToLeft:
	# check left node is zero 
	addi $t5,$t5,4  # add 4 to reach addres of left child
	lw $t6,0($t5)   # get value of left child to be compare

	bne $t6,0,increment # If it is zero we add the element otherwise itarete tree by starting this node(Hold the child address)

	move $t7,$t5 # pass parameters for insert method $a0 cause a poblem
	move $a1,$t4
	jal insert

	#Inserting Left node comlete 
	# we need to increment $t3 and $t4 values to traverse list
	addi $t3,$t3,4
	lw $t4,0($t3)
	# now we are ready to jump 
	j listIterator
addToRight:
	# check if the right node is zero
	addi $t5,$t5,8 # get the addres of right node
	lw $t6,0($t5)	# get the value of right node
	bne $t6,0,increment # if the right node is full 
	# Else insert the new element 
	move $t7,$t5 # pass parameters for insert method
	move $a1,$t4
	jal insert
	move $a0,$v0
	li $v0,1
	syscall
	la $a0,line
	li $v0,4
	syscall
	# increase the counter
	addi $t3,$t3,4
	lw $t4,0($t3)
	j listIterator

increment:
	# If we come thise point child stores the next element address 
	# We need to reach that address and get its value
	# $t5 store the address of node element
	# $t6 store the value of node element 
	move $t5,$t6  #  $t6  have the childs address
	lw $t6,0($t5) # by using them update values
	j nextNode

# gets two parameter 
# $t7  address of parent  $a0  cause problem
# $a1  valuee of new element 
insert:
	addi $sp,$sp,-8 #to hold params in register
	sw $t1,4($sp)
	sw $t2,8($sp) # used for the ra , beacuse we have  method call 
	
	move $t2,$ra
	jal AllocateMem	# allocate memory and create node
	move $ra,$t2

	move $t1,$v0  	 # assign allocated memory addres
	sw $a1,0($t1)    # value stored in allocated spaces first element 
	sw $t1,0($t7)    # allocated space address stored in parent
	sw $zero,4($t1)	 # set left child zero
	sw $zero,8($t1)  # set right child zero
	sw $t7,12($t1)	 # set the parents addres to the fouth space


	lw $t1,4($sp)
	lw $t2,8($sp)
	addi $sp,$sp,4 #to hold params in register
	jr $ra

# takes two arguments
# one of them is the value that we search $t9
# second of element is the initial addres of the out BST $a1
find:
	move $t1,$t9  # pass parameter value
	move $t2,$a1  # pass root addres of bst - We can think as a current node
	lw $t3,0($t2) # t3 loaded with the Current nodes value
	findloop:
	bne $t1,$t3,findIter
	# If those things are equal return the values 
	li $v0,0 # It means found
	move $v1,$t2 # the second output value
	jr $ra
# CHECK ADDRESSING
findIter:
	slt $t4,$t3,$t1  # if current node smaller than searched value $t4 is 1

	beq $t4,0,findLeft # look for smaller values
	# Else look for bigger values
	j findRight
findLeft:
	# update current node address and value
	addi $t2,$t2,4 # for reaching left node
	lw $t3,0($t2)  # get the next nodes values
	
	beq $t3,0,exitFind # no child left
	move $t2,$t3
	lw $t3,0($t2)
	
	j findloop
findRight:
	# update current node address and value
	addi $t2,$t2,8 # for reaching right node
	lw $t3,0($t2)  # get the next nodes values
	
	beq $t3,0,exitFind # no child left
	move $t2,$t3
	lw $t3,0($t2)
	
exitFind:
	li $v0,1 # It means not found
	jr $ra




# start position of queue is $s2
# ending position of queue is $s3

create_queue:
	li $a0,32 	   #required size is 4 bytes
	li $v0,9       #sbrk system call
	syscall        #store the addres
	move $s2,$v0   #init position of queue
	addi $s3,$s2,4 #end position of queue
	move $s4,$zero #$s4 store the number of element in queue 	   
	jr $ra
# takes parameter from $a1 as address
Enqueue:
	move $t1,$a1
	sw $t1,0($s3) 	# store address on $t3
	addi $s3,$s3,4	# move tail to next
	addi $s4,$s4,1  # increment counter by 1 
	jr $ra
# No rquired parameter but return deleting element on $v1
Dequeue:
	move $t1,$s2
	addi $t1,$t1,4
	beq $t1,$s3,exit
	# not empty queue
	lw $t2,4($s2)
	move $v1,$t2
	addi $s2,$s2,4
	addi $s4,$s4,-1 # decrement counter
	jr $ra


# Takes argument on $a2 the address of root
printLevelOrder:
	addi $sp,$sp,-4
	sw $ra,0($sp) # store return address	
	
	jal create_queue # queue created


	move $t5,$a2  # root elements address stored in $t5
	lw $t6,0($t5) # the root value
	beq $t6,0,exit
	# it is not null 	
	# Load params
	move $a1,$s0 # root addres is the parameter
	jal Enqueue  # insert it to queue
	
	whileLoop:
	
		la $a0,newLine
		li $v0,4
		syscall

		move $t8,$s2 #init of queue
		addi $t8,$t8,4 # next element of queue
		beq $t8,$s3,exit
		# if the count bigger than zero 
		jal Dequeue
		lw $t9,0($v1)
		move $a0,$t9
		li $v0,1
		syscall
		la $a0,space
		li $v0,4
		syscall
		la $a0,line
		li $v0,4
		syscall
		lw $t1,4($v1) 	# load with left child value
		beq $t1,0,printX # if it is empty (0) can not add to queue
		move $a1,$t1
		jal Enqueue
		returnPoint:
		lw $t3,8($v1)
		beq $t3,0,printXx
		move $a1,$t3
		jal Enqueue
		
	j whileLoop

	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra
main:
	la $s0, firstList
	la $s1, firstList 
	jal build
	# Tree created
buildExit:				# TERMINATE WITH -9999 
	# set find operators
	li $t9,1000
	move $a1,$s0 
	jal find
	move $a0,$v0
	beq $v0,0,foundPrint
	li $v0,1
	syscall
	# exit
	notFound:
	move $a2,$s0

 	jal printLevelOrder
exit:
  li $v0, 10
  syscall
printX:
	la $a0,Xsign
	li $v0,4
	syscall
	j returnPoint
printXx:

j exit

foundPrint:
	move $a0,$v0
	li $v0,1
	syscall
	
	la $a0,line
	li $v0,4
	syscall

	move $a0,$v1
	li $v0,1
	syscall

	j notFound