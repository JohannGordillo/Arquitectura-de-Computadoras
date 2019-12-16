.data
array:	.word	10,8,6,7,9,4,5,2,1,3
n:	.word	10

.text
	la $a0 array #pasar argumentos
	lw $a1 n #pasar argumentos
	jal sort  #llamada a la subrutina
	move $t0 $v0 
	li $v0 10 #codigo para terminar ejecucion
	syscall

sort:	subi $sp $sp 32 #reservamos espacio en la pila push
	sw $ra 16($sp) #respaldamos la direccion de retorno
	sw $fp 20($sp) # respaldamo el fp
	addi $fp $sp 28 # establecemos el nuevo fp
	# ordenamos
	move $t1 $a0 #inicializamos i (t1) como la direccion	
loop1:	mul $t0 $a1 4 # t0 = n * 4
	add $t0 $t0 $a0 # sumamos la direccion del array, resultando en la direccion final del array
	bge $t1 $t0 con # si i >= final, termina
	move $t2 $t1 #inicializa min (t2) como i
	add $t3 $t1 4 #inicializamos j (t3) como i + 1 (en bytes, es decir, el siguiente entero)
loop2:	bge $t3 $t0 finl2 # si j >= final, termina el loop interno
	lw $t4 ($t2) # carga [min] en t4
	lw $t5 ($t3) # carga [j] en t5
	bge $t5 $t4 finif # si [j] >= [min], se salta la siguiente linea
	move $t2 $t3 #se actualiza min
finif:	add $t3 $t3 4 # incrementa j  para que apunte al siguiente entero
	j loop2
finl2:	# Llamamos swap
	sw $a0 0($sp) # respaldamos array
	sw $a1 4($sp) # respaldamos n
	sw $t1 28($sp) # respaldamos i
	move $a0 $t1 # movemos i a a1
	move $a1 $t2 #movemos el indice min a a2
	jal swap #invocacion a swap
	lw $a0 0($sp) # restauramos array
	lw $a1 4($sp) # restauramos n
	lw $t1 28($sp) # restauramos i
	add $t1 $t1 4 # incrementa i  para que apunte al siguiente entero
	j loop1

con:	move $v0 $zero # regresa cero
	lw $ra 16($sp) #comienza la conclusion de la subrutina. Restauramos la direccion de retorno
	lw $fp 20($sp) #restauramos el fp
	addi $sp $sp 32 # regresamos el sp para liberar la memoria pop (la memoria no se borra)
	jr $ra #regresamos el control al invocador

swap:	subi $sp $sp 8 #reservamos espacio en la pila push
	sw $ra ($sp) #respaldamos la direccion de retorno
	sw $fp 4($sp) # respaldamo el fp
	addi $fp $sp 4 # establecemos el nuevo fp
	lw $t0 ($a0) # cargamos el numero en a0 en t0
	lw $t1 ($a1) # cargamos el numero en a1 en t1
	sw $t0 ($a1) # almacenamos el numero en t0 en a1
	sw $t1 ($a0) # almacenamos el numero en t1 en a0
	lw $ra ($sp) #comienza la conclusion de la subrutina. Restauramos la direccion de retorno
	lw $fp 4($sp) #restauramos el fp
	addi $sp $sp 8 # regresamos el sp para liberar la memoria pop (la memoria no se borra)
	jr $ra #regresamos el control al invocador
	
