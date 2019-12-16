# Maximo común divisor de dos números emulando un algoritmo recursivo de cola
.data 
a:	.word 6 #reservando y llenando espacio para una constante del código _a_ es la dirección de memoria que inicialmente
b:	.word 4 # tiene valor 6
aux:	.word 0
v0:	.space 4 #bytes

# cada $reg son registros del procesardor
.text
	lw $a0 a #cargamos la palabra de la direccion de memoria a para guardarla en el registro a0
	lw $a1 b
	lw $a2 aux


# start es la etiqueta de  la dirección de memoria de la instrucción
start:	beqz $a1 fin #Si se da la condición de paro
	div $a0 $a1			
	move $a0 $a1
	mfhi $a1
	b  start #volvemos al inicio de la función
		 #hasta que se de la condición de paro
fin:  sw $a0 v0