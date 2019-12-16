# =============================================
# Autor: Johann Gordillo
# Email: jgordillo@ciencias.unam.mx
# Fecha: 20/10/2019
# =============================================
# Universidad Nacional Autonoma de México
# Organización y Arquitectura de Computadoras
#
# Practica 07: Llamadas al sistema
#
# Ejercicio 01: Cadena en reversa.
# =============================================


# ---------------------------------------
# Macro: usage_msg
# ---------------------------------------
# Lanza un mensaje en consola con las 
# instrucciones de uso del programa.
# ---------------------------------------
.macro usage_message()			
	li $v0, 4
	la $a0, usage          
	syscall
.end_macro

# ---------------------------------------
# Macro: end_program
# ---------------------------------------
# Finaliza la ejecucion del programa.
# ---------------------------------------
.macro end_program()			
	li $v0, 10          
	syscall
.end_macro

# ---------------------------------------
# Macro: print_string
# ---------------------------------------
# Imprime la cadena %str.
# ---------------------------------------
.macro print_string(%str)
	li $v0, 4
	la $a0, %str
	syscall
.end_macro


	    .data
input:      .space    256
output:     .space    256
usage: 	    .asciiz   "-------------------- USO --------------------\n 1) Ingrese la cadena\n 2) Presione ENTER\n 3) Listo!\n---------------------------------------------\n"
request:    .asciiz   "Su cadena: "
		       

            .text
            .globl main  			# Permite referencias desde otros archivos.

# ---------------------------------------
# Procedimiento: main
# ---------------------------------------
# Procedimientio principal del
# programa.
# ---------------------------------------
main:
	usage_message				# Mensaje con las instrucciones de uso del programa.
	
	li 	$v0, 4				# Nos preparamos para leer una cadena de la entrada.
	la	$a0, request			# Mensaje para pedir al usuario la cadena.
	syscall					# Llamada al sistema.
	
	li      $v0, 8				# Nos preparamos para leer una cadena de la entrada.
	la      $a0, input			# Guarda la cadena. 
	li      $a1, 256			# Permitimos unicamente 256 caracteres.
	syscall
	
	jal     strlen				# Guardaremos la longitud de la cadena en $v0.
	
	move 	$t1, $v0			# Movemos la longitud a t1 para el procedimiento reverse.
	move 	$t2, $a0 			# Movemos el contenido de a0 (la entrada) a t2.
	move 	$a0, $v0 			# Movemos el contenido de v0 como argumento en a0.

# ---------------------------------------
# Procedimiento: reverse
# ---------------------------------------
# Invierte la cadena, respetando
# espacios.
# ---------------------------------------	
reverse:
	li	$t0, 0				# Limpiamos el registro temporal t0.
	li	$t3, 0				# De la misma manera, limpiamos t3.
	
	reverse_loop:
		add	$t3, $t2, $t0		
		lb	$t4, 0($t3)		# Cargamos la letra.
		beqz	$t4, reverse_exit	# En el caso de encontrar el caracter nulo, terminamos.
		sb	$t4, output($t1)	# En caso contrario, sobreescribimos.
		subi	$t1, $t1, 1		
		addi	$t0, $t0, 1		# Aumentamos el contador.
		j	reverse_loop		# Continuamos a la siguiente iteracion del ciclo.
	
	reverse_exit:
		print_string(output)		# Imprimimos la cadena invertida.
		j exit 				# Saltamos al procedimiento que finaliza el programa.

# ---------------------------------------
# Procedimiento: exit
# ---------------------------------------
# Finaliza el programa con ayuda
# del macro definido.
# ---------------------------------------	
exit:	
	end_program           			# Finalizamos la ejecucion del programa.
	
# ---------------------------------------
# Procedimiento: strlen
# ---------------------------------------
# Itera sobre una cadena en el registro
# a0 hasta encontrar el carácter nulo, 
# y regresa en el registro v0 la 
# longitud de la misma.
# ---------------------------------------
strlen:
	li	$t0, 0				# Limpiamos el registro temporal t0.
	li	$t2, 0				# Limpiamos el registro temporal t2.
	
	strlen_loop:
		add	$t2, $a0, $t0		
		lb	$t1, 0($t2)		# Cargamos una letra.
		beqz	$t1, strlen_exit	# Si llegamos al final, salimos del ciclo.
		addiu	$t0, $t0, 1		# Aumentamos el contador.
		j	strlen_loop		# Repetimos el ciclo.
		
	strlen_exit:
		subi	$t0, $t0, 1		# Disminuimos en 1 el valor de t0 por el caracter nulo.	
		move 	$v0, $t0 		# Guardamos en v0 la longitud de la cadena.		
		add	$t0, $zero, $zero	# Limpiamos el registro t0.
		jr	$ra			# Regresamos al procedimiento main donde se llamo a strlen.
