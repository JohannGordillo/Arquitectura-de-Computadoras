# 0.2 Reading string to sustitute
# 0.3 Reading new string
# 1. File
# 1.1 opening file
# 1.2 reading file

# 2. Modifying information
# 3. Creating salida.txt 
	.data
	fname:	.space 	300
	fbuff: 	.space	1000
	change: .space 	1 # a characher  requires 1 byte of storage
	new:	.space 	1 
	fout:	.asciiz	"salida.txt"
	introm: .asciiz "Este programa recibe el nombre de un archivo de texto, dos caracteres y cambia el primero por el segundo\ny lo escribe en un archivo de salida\n"
	fnamem:	.asciiz "Introduce el nombre del archivo seguido de un enter:\n"
	chanm:	.asciiz	"Introduce el caracter que quieres cambia seguido de un enter:\n"
	newm:	.asciiz "Introduce el caracter por el que quieres cambiar el anterior seguido de un enter:\n"
	endm:	.asciiz "Resultado guardado en salida.txt"
	.text
# 0.0 Input
# 0.1 filename

# prints message
	la $a0 introm
	li $v0 4
	syscall

# prints message
	la $a0 fnamem
	li $v0 4
	syscall

	la $a0 fname
	li $a1 300 #let's suppose every file name is no longer than 300
	li $v0 8
	syscall
	
	# new line char is removed from the string
	li $s0 0               # Set index to 0
remove:	lb $t0 fname($s0)      # Load character at index
    	addi $s0 $s0 1        # Increment index
    	bnez $t0 remove    # Loop until the end of string is reached
    	subiu $s0 $s0 2     # Backtrack index to '\n'
    	sb $0 fname($s0)        # Add the terminating character in its place

# 0.2 char to change

# prints message
	la $a0 chanm
	li $v0 4
	syscall
	
	li $v0 12
	syscall
	move $t0 $v0 #char to change stored in $t0
	# we read the intro char, but we don't use it
	li $v0 12
	syscall 

#0.3 new char

# prints message
	la $a0 newm
	li $v0 4
	syscall
	
	li $v0 12
	syscall
	move $t1, $v0 #new char stored in $t1
	# we read the intro char, but we don't use it
	li $v0 12
	syscall 

# 1. file
# 1.1 opening file
	la $a0 fname #name of the file
	li $a1 0 #flags
	li $a2 0 #mode
	li $v0 13 #code of operation
	syscall
	move $s1 $v0 #saves file description

# 1.2 reading file
	move $a0 $s1 #moving file descriptor to a0
	la $a1 fbuff #input buffer
	li $a2 400 #let's suppose every file info is no longer than 400
	li $v0 14
	syscall #info is in fbuff
	
	move $t3 $v0 #number of characters in the file is going to be in $t3


# 2 Modifying information
#buffeFile address y cloned for usage
	la $s0 fbuff
	lb $t2 ($s0) #actual character

ciclo:	beq $t2 '\0' buffend
	beq $t2 $t0 sus #if actual byte = 'a'
a:	addi $s0 $s0 1 # walk to the next byte
	lb $t2 ($s0) #new actual character
	j ciclo
sus:	sb $t1 ($s0)
	j a

buffend:
# 3. Creating final file

# opening and creating new file
	la $a0 fout #name of the file
	li $a1 1 #flags
	li $a2 0 #mode
	li $v0 13 #code of operation
	syscall

	# write to fiile
	move $a0 $v0 #moving file descriptor to a0
	la $a1 fbuff
	move $a2 $t3 #moving number of chars readed to a2
	li $v0 15 #code of operation
	syscall

# 4. Closing file and exit

# prints message
	la $a0 endm
	li $v0 4
	syscall
	
	move $a0 $s1 #moving file descriptor to a0
	li $v0, 16
	li $v0, 10
	syscall 
