# =============================================
# Autores: 
#	- Johann Gordillo
#	- Jhovan Gallardo
#	- Diana Nicolas
#
# Email: jgordillo@ciencias.unam.mx
#
# Fecha: 04/12/2019
# =============================================
# Universidad Nacional Autonoma de Mexico
# Organizacion y Arquitectura de Computadoras
# 
# Practica 10: 
# Manejo de Excepciones.
# 
# Ejercicio 01:
# Calculadora. 
# 
# Calculadora para evaluar expresiones
# matematicas en notacion postfija haciendo
# uso de una pila y del manejo de excepciones.
#
# ---------------------------------------------
#  ///// POR MI RAZA HABLARA EL ESPIRITV /////
# ---------------------------------------------
# Copyright 2019 Johann Gordillo.
# =============================================	
		
		
		.data	
expression:	.space 256
stack:		.space 256

new_line:	.asciiz "\n"
welcome_msg:	.asciiz "Calculadora de expresiones matematicas en notacion postfija\n"
exit_msg:	.asciiz "Presione ENTER para salir\n"
in_msg:		.asciiz "--> Ingrese una expresion: "
out_msg:	.asciiz "--> Resultado: "
dashes:		.asciiz "-------------------------------------------------------------\n"
bye_msg:	.asciiz "\nGRACIAS POR USAR EL PROGRAMA :D\n"


#########################################################
# Definicion de los macros.
#########################################################

# ---------------------------------------------
# Macro: print_intro
# ---------------------------------------------
# Descripcion:
#	Imprime en consola un mensaje de
#	bienvenida al programa.
# ---------------------------------------------
.macro print_intro()
	li	$v0, 4				# Se prepara para imprimir una cadena.
	la	$a0, dashes			# Guiones para dar estilo. 
	syscall					# Llamada al sistema para imprimir los guiones.

	li	$v0, 4			 
	la	$a0, welcome_msg		# Mensaje de bienvenida al programa.	 
	syscall				 
	
	li	$v0, 4			 
	la	$a0, dashes			# Guiones para dar estilo.  
	syscall				 
.end_macro

# ---------------------------------------------
# Macro: read_exp
# ---------------------------------------------
# Descripcion:
#	Permite leer una cadena ingresada
#	por el usuario en la entrada estandar.
# ---------------------------------------------
.macro read_exp()
	li	$v0, 4			
	la	$a0, exit_msg			# Indicamos al usuario que puede presionar ENTER para salir.
	syscall			

	li	$v0, 4			
	la	$a0, in_msg			# Solicitamos al usuario que ingrese una expresion postfija.
	syscall				
	
	la	$a0, expression			# Cargamos la direccion de la cadena.
	li	$a1, 256			# Longitud maxima de la cadena.
	li	$v0, 8				# Se prepara para leer una cadena.
	syscall					# Llamada al sistema para leer la cadena del usuario.	
.end_macro

# ---------------------------------------------
# Macro: print_res
# ---------------------------------------------
# Descripcion:
#	Imprime el resultado de evaluar
#	la expresion ingresada por el usuario.
#
# Argumentos:
#	%rs. El registro donde se encuentre
#	guardado el resultado.
# ---------------------------------------------
.macro print_res(%rs)
	move 	$a1, %rs			# Movemos el contenido del registro %rs a $a1.
	
	li	$v0, 4
	la	$a0, out_msg			# Mensaje indicando que se mostrara el resultado.
	syscall

	li 	$v0, 1	
	move 	$a0, $a1			# Resultado de la operacion ingresada.
	syscall

	li	$v0, 4
	la	$a0, new_line			# Linea en blanco.
	syscall

	li	$v0, 4
	la	$a0, new_line			# Linea en blanco.
	syscall
.end_macro

# ---------------------------------------------
# Macro: exit
# ---------------------------------------------
# Descripcion:
#	Finaliza la ejecucion del prorgrama.
# ---------------------------------------------
.macro exit()
	li 	$v0, 10				# Finalizamos la ejecucion del programa.
	syscall
.end_macro

# ---------------------------------------------
# Macro: inv_calculadora
# ---------------------------------------------
# Descripcion:
#	Invoca al procedimiento calculadora.
# ---------------------------------------------
.macro inv_calculadora()
	jal 	calculadora			# Invocamos al subproceso 'calculadora'.
.end_macro

# ---------------------------------------------
# Macro: pop
# ---------------------------------------------
# Descripcion:
#	Elimina un elemento de la pila y lo
#	guarda en el registro dado.
#
# Argumentos:
#	%rd. El registro donde se guardara
#	el elemento eliminado de la pila.
#
#	%stack_ptr. El apuntador a la pila.
# ---------------------------------------------
.macro pop(%rd, %stack_ptr)
	lw	%rd, (%stack_ptr)		# Cargamos el elemento al tope de la pila.
	addu	%stack_ptr, %stack_ptr, 4	# Limpiamos espacio en la pila.
	addi 	%rd, %rd, -48			# Pasamos de ASCII a entero.
.end_macro

# ---------------------------------------------
# Macro: push
# ---------------------------------------------
# Descripcion:
#	Inserta un elemento al tope de la pila.
#
# Argumentos:
#	%rs. El registro donde se encuentra
#	el elemento a guardar en la pila.
#
#	%stack_ptr. El apuntador a la pila.
# ---------------------------------------------
.macro push(%rs, %stack_ptr)
	subu	%stack_ptr, %stack_ptr, 4	# Agregamos espacio a la pila.
	sw	%rs, (%stack_ptr)		# Guardamos en el tope de la pila el elemento dado
.end_macro
	
	
#########################################################
# Programa principal.
#########################################################	
	.text
	.globl main
	
# ---------------------------------------------
# Procedimiento: main
# ---------------------------------------------
# Descripcion:
#	Procedimiento principal del programa.
# ---------------------------------------------
main:
	print_intro()				# Mensaje de bienvenida con instrucciones.
	read_exp()				# Leemos la expresion matematica de la entrada estandar.
	inv_calculadora()			# Obtenemos el resultado en $v0 de evaluar la expresion.
	exit()					# Finalizamos la ejecucion del programa.

# ---------------------------------------------
# Procedimiento: calculadora
# ---------------------------------------------
# Descripcion:
#	Verifica que el usuario no haya 
#	ingresado ENTER, inicializa contadores
#	y pasa la cadena al ciclo de 
#	procesamiento para evaluar la
#	expresion.
# ---------------------------------------------	
calculadora:
	la	$a2, stack			# Cargamos la direccion en memoria de la pila.
	move 	$t7, $a2			# La movemos al registro temporal $t2.
	
	move	$t6, $a0			# Movemos la direccion en memoria de la expresion a $t6.
	
	lb 	$s1, ($t6)			# Cargamos el primer caracter de la cadena.
	
	beq 	$s1, '\n', end			# Validamos que no se haya presionado ENTER.
	
	addi	$s2, $zero, 0			# Colocamos el contador de elementos en la pila en cero.
	
	j	loop				# Procesamos la expresion en el loop.

# ---------------------------------------------
# Procedimiento: loop
# ---------------------------------------------
# Descripcion:
#	Ciclo para procesar la expresion
#	matematica.
# ---------------------------------------------			
loop:	
	lb 	$s1, ($t6)			# Cargamos el primer caracter de la cadena.

	addi	$t6, $t6, 1			# Apuntamos al siguiente caracter de la cadena.
				
	beq 	$s1, '\n', result		# Si llegamos al fin de la cadena, finalizamos.
	beq 	$s1, ' ', loop			# Ignoramos los espacios blancos.
	
	beq 	$s1, '+', suma			# Caso 1: Operación suma.
	beq 	$s1, '-', resta			# Caso 2: Operación resta.
	beq 	$s1, '*', producto		# Caso 3: Operación producto.
	beq 	$s1, '/', division		# Caso 4: Operación division entera.
	
	j 	save_digit			# Si el caracter es un digito, lo guardamos en la pila.

# ---------------------------------------------
# Procedimiento: save_digit
# ---------------------------------------------
# Descripcion:
#	Mete un digito a la pila.
# ---------------------------------------------			
save_digit:
	push($s1, $t7)				# Guardamos el digito en la pila.
	addi	$s2, $s2, 1			# Incrementamos el contador de la pila.
	
	j	loop				# Regresamos al ciclo de procesamiento de la expresion.

# ---------------------------------------------
# Procedimiento: suma
# ---------------------------------------------
# Descripcion:
#	Toma los dos ultimos elementos de la
#	pila, los suma, y el resultado lo
#	ingresa de nuevo a la pila.
# ---------------------------------------------	
suma:
	pop($t2, $t7)				# a = pila.pop()
	addi	$s2, $s2, -1			# Decrementamos el contador de la pila.
	
	pop($t3, $t7)				# b = pila.pop()
	addi	$s2, $s2, -1			# Decrementamos el contador de la pila.
		
	add 	$t4, $t2, $t3			# a + b
		
	addi	$t4, $t4, 48 			# Pasamos a entero.
		
	push($t4, $t7)				# Ingresamos (a + b) a la pila.
	addi	$s2, $s2, 1			# Incrementamos el contador de la pila.
	
	j 	loop				# Regresamos al ciclo de procesamiento de la expresion.

# ---------------------------------------------
# Procedimiento: resta
# ---------------------------------------------
# Descripcion:
#	Toma los dos ultimos elementos de la
#	pila, los resta, y el resultado lo
#	ingresa de nuevo a la pila.
# ---------------------------------------------		
resta:	
	pop($t2, $t7)				# a = pila.pop()
	addi	$s2, $s2, -1			# Decrementamos el contador de la pila.
	
	pop($t3, $t7)				# b = pila.pop()
	addi	$s2, $s2, -1			# Decrementamos el contador de la pila.			
		
	sub	$t4, $t2, $t3			# a - b
		
	addi	$t4, $t4, 48 			# Pasamos a entero.
					
	push($t4, $t7)				# Ingresamos (a - b) a la pila.
	addi	$s2, $s2, 1			# Incrementamos el contador de la pila.
	
	j 	loop				# Regresamos al ciclo de procesamiento de la expresion.
	
# ---------------------------------------------
# Procedimiento: producto
# ---------------------------------------------
# Descripcion:
#	Toma los dos ultimos elementos de la
#	pila, los multiplica, y el resultado 
#	lo ingresa de nuevo a la pila.
# ---------------------------------------------	
producto:
	pop($t2, $t7)				# a = pila.pop()
	addi	$s2, $s2, -1			# Decrementamos el contador de la pila.	
	
	pop($t3, $t7)				# b = pila.pop()
	addi	$s2, $s2, -1			# Decrementamos el contador de la pila.			
		
	mul 	$t4, $t2, $t3			# a * b
	
	addi	$t4, $t4, 48 			# Pasamos a entero.

	push($t4, $t7)				# Ingresamos (a * b) a la pila.
	addi	$s2, $s2, 1			# Incrementamos el contador de la pila.
	
	j 	loop				# Regresamos al ciclo de procesamiento de la expresion.
	
# ---------------------------------------------
# Procedimiento: division
# ---------------------------------------------
# Descripcion:
#	Toma los dos ultimos elementos de la
#	pila, los divide, y el resultado lo
#	ingresa de nuevo a la pila.
# ---------------------------------------------	
division:
	pop($t2, $t7)				# a = pila.pop()
	addi	$s2, $s2, -1			# Decrementamos el contador de la pila.	
	
	pop($t3, $t7)				# b = pila.pop()
	addi	$s2, $s2, -1			# Decrementamos el contador de la pila.			
		
	div	$t4, $t2, $t3			# a / b
		
	addi	$t4, $t4, 48 			# Pasmos a entero.

	push($t4, $t7)				# Ingresamos (a / b) a la pila.
	addi	$s2, $s2, 1			# Incrementamos el contador de la pila.
	
	j 	loop				# Regresamos al ciclo de procesamiento de la expresion.

# ---------------------------------------------
# Procedimiento: result
# ---------------------------------------------
# Descripcion:
#	Toma el elemento al tope de la pila
#	y lo imprime como entero.
# ---------------------------------------------	
result:	
	lw	$t5, ($t7)			# Cargamos en $t5 el resultado final de la expresion.
	addu	$t7, $t7, 4			# Limpiamos espacio en la pila.
	addi	$s2, $s2, -1			# Decrementamos el contador de la pila.	
	
	tnei 	$s2, 0				# Verificamos que ya no haya elementos en la pila.
	
	addi	$t5, $t5, -48 			# Convertimos el resultado a entero.
			
	print_res($t5)				# Imprimimos el resultado.
	
	j main					# Volvemos al procedimiento principal.
	
# ---------------------------------------------
# Procedimiento: end
# ---------------------------------------------
# Descripcion:
#	Imprime un mensaje de despedida y
#	finaliza la ejecucion del programa.
# ---------------------------------------------	
end:	
	la	$a0, bye_msg			# Mensaje de despedida del programa.
	li	$v0, 4
	syscall
	
	exit()					# Finalizamos la ejecucion del programa.


#########################################################
# Manejador de excepciones.
#########################################################

		.kdata
msg_error:	.asciiz "Ha ocurrido un error: "

msg_divz:	.asciiz "No se puede dividir por cero\n"
msg_ov:		.asciiz "Desbordamiento aritmetico\n"
msg_tr:		.asciiz "Expresion invalida\n"

sa0:  		.word 0	# memoria para respaldar los resgitros que usaremos(No se puede usar la pila)
sv0:  		.word 0


		.ktext	0x80000180
k_main:
	move	$k1 $at			
	sw	$a0 sa0				# Respaldamos el valor en el registro $a0.
	sw	$v0 sv0				# Respaldamos el valor en el registro $v0.
	
	la	$a0, msg_error			# Carga el mensaje de error.
	li	$v0, 4				# Se prepara para imprimir la cadena en 'msg_error'.
	syscall					# Llamada al sistema para imprimir la cadena.
	
	mfc0	$k0, $13			# Obtenemos la causa de la excepcion.
	andi	$k0, $k0, 0x7C			# Omitimos las excepciones pendientes.
	
	beq 	$k0, 0x24, err_divz		# Caso en el que el error haya sido causado por dividir por cero.
	beq 	$k0, 0x30, err_ov		# Caso en el que el error haya sido causado por despordamiento.
	beq 	$k0, 0x34, err_tr		# Caso en el que el error haya sido causado por una expresion invalida.
	
	j 	k_end				# Cualquier otro caso.
	
err_divz:
	la	$a0, msg_divz			# Carga el mensaje de error al dividir por cero.
	li	$v0, 4				# Se prepara para imprimir la cadena en 'msg_divz'.
	syscall					# Llamada al sistema para imprimir la cadena.
	
	j 	k_end				# Finalizamos el manejador de excepciones y el programa.

err_ov:	
	la	$a0, msg_ov			# Carga el mensaje de error por desbordamiento.
	li	$v0, 4				# Se prepara para imprimir la cadena en 'msg_ov'.
	syscall					# Llamada al sistema para imprimir la cadena.
	
	j 	k_end				# Finalizamos el manejador de excepciones y el programa.

err_tr:	
	la	$a0, msg_tr			# Carga el mensaje de error por expresion invalida.
	li	$v0, 4				# Se prepara para imprimir la cadena en 'msg_tr'.
	syscall					# Llamada al sistema para imprimir la cadena.
	
	j 	k_end				# Finalizamos el manejador de excepciones y el programa.

k_end:
	mfc0	$k0 $14				# Obtenemos el valor del EPC.
	addi	$k0 $k0 4			# Aumentamos en una palabra el valor del EPC.
	mtc0	$k0 $14				# Actualizamos el valor del EPC.

	lw	$a0 sa0				# Restauramos el valor en el registro $a0.
	lw	$v0 sv0				# Restauramos el valor en el registro $v0.

	li 	$v0, 10				# Finalizamos la ejecución del programa.
	syscall
	
	eret					# Fin del manejador de excepciones.
