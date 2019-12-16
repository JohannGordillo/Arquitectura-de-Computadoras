# =============================================
# Autor: Johann Gordillo
# Email: jgordillo@ciencias.unam.mx
# Fecha: 03/11/2019
# =============================================
# Universidad Nacional Autonoma de Mexico
# Organizacion y Arquitectura de Computadoras
#
# Practica 08: 
# Convencion de llamadas a subrutinas.
#
# Ejercicio 02:
# Fibonacci recursivo.
# =============================================


	.data
msg:	.asciiz "Ingresa un numero: "

# ---------------------------------------------
# Macro: end
# ---------------------------------------------
# Termina la ejecucion del programa
# con una llamada al sistema.
# ---------------------------------------------
.macro end()
	li 	$v0, 10       		# Se prepara para finalizar la ejecucion.   
	syscall				# Llamada al sistema para terminar el programa.
.end_macro

# ---------------------------------------------
# Macro: read_int
# ---------------------------------------------
# Lee un entero de la terminal y lo guarda 
# en %rd.
# ---------------------------------------------
.macro read_int(%rd)
	li 	$v0, 4			# Se prepara para imprimir un mensaje.
	la 	$a0, msg		# Guarda en $a0 la cadena 'msg'.
	syscall				# Imprime la cadena solicitando un numero al usuario.

	li 	$v0, 5			# Se prepara para leer un entero.
	syscall				# Llamada al sistema para leer dicho entero.
	move 	%rd, $v0		# Guarda en el registro %rd el valor ingresado.
.end_macro

# ---------------------------------------------
# Macro: print_int
# ---------------------------------------------
# Imprime en la terminal el entero guardado 
# en %rs.
# ---------------------------------------------
.macro print_int(%rs)
	move 	$a0, %rs		# Guarda el valor del registro %rs en $a0.
	li 	$v0, 1			# Se prepara para imprimir un entero.
	syscall				# Llamada al sistema para imprimir dicho entero.
.end_macro

# ---------------------------------------------
# Macro: pre_foo0
# ---------------------------------------------
# Preambulo de foo como rutina invocada.
# ---------------------------------------------
.macro pre_foo0()
	addi 	$sp, $sp, -12		# Guarda espacio en la pila para 3 palabras (12 bytes).
	sw 	$a0, 4($sp)		# Guarda el valor del registro $a0 (sp[4] = $a0).
	sw 	$ra, 0($sp)		# Guarda la direccion de retorno (sp[0] = $ra).
.end_macro

# ---------------------------------------------
# Macro: con_foo0
# ---------------------------------------------
# Conclusion de foo como rutina invodada.
# ---------------------------------------------
.macro con_foo0()
	lw 	$ra, 0($sp)		# Restaura de la pila la direccion de retorno.
	addi 	$sp, $sp, 12		# Limpia la pila haciendo POP de 12 bytes (3 palabras).
	jr 	$ra			# Regresamos.
.end_macro

# ---------------------------------------------
# Macro: pre_foo1
# ---------------------------------------------
# Preambulo para invocar foo(n-1).
# ---------------------------------------------
.macro pre_foo1()	
	addi 	$a0, $a0, -1		# n = n - 1.
.end_macro

# ---------------------------------------------
# Macro: con_foo1
# ---------------------------------------------
# Conclusion de la invocacion de foo(n-1).
# ---------------------------------------------
.macro con_foo1()
	lw 	$a0, 4($sp)		# Restaura el valor de 'n' de la pila.
	sw	$v0, 8($sp)		# Guarda el resultado de foo(n-1) en la pila.
.end_macro

# ---------------------------------------------
# Macro: pre_foo2
# ---------------------------------------------
# Preambulo para invocar foo(n-2).
# ---------------------------------------------
.macro pre_foo2()
	addi 	$a0, $a0, -2		# n = n - 2.
.end_macro

# ---------------------------------------------
# Macro: con_foo2
# ---------------------------------------------
# Conclusion de la invocacion de foo(n-2).
# ---------------------------------------------
.macro con_foo2()
	lw 	$t0, 8($sp)		# Restaura el valor de foo(n-1) de la pila.
.end_macro

# ---------------------------------------------
# Macro: inv_foo
# ---------------------------------------------
# Invocacion a la subrutina foo.
# ---------------------------------------------
.macro inv_foo()
	jal foo 			# Simplemente invocamos a la subrutina foo.	
.end_macro


	.text
	.globl main
# ---------------------------------------------
# Procedimiento: main
# ---------------------------------------------
# Procedimiento principal del programa.
# ---------------------------------------------
main:
	read_int($a0)			# Lee un entero 'n' de stdin y lo guarda en $a0.
	
	inv_foo()			# Guarda el n-esimo termino de la sucesion de fibonacci en $v0.
	
	print_int($v0)			# Imprime el termino calculado por foo.	
	end()				# Finaliza la ejecucion del programa.

# ---------------------------------------------
# Procedimiento: foo
# ---------------------------------------------
# Calcula el n-esimo termino de la sucesion
# de fibonacci usando recursion.
#
# Entrada:
# 	n - Un entero en el registro $a0.
#
# Salida:
#	El n-esimo termino de la sucesion
#	de fibonacci en el registro $v0.
# ---------------------------------------------	
foo:	
	pre_foo0()			# Prologo de foo(n).
	beq	$a0, 1, base1		# Si n = 1, foo(n) = 1.
	beq 	$a0, 2, base1		# Si n = 2, foo(n) = 1.
	
	pre_foo1()			# Prologo a la invocacion de foo(n-1).
	inv_foo()			# Invocacion de foo(n-1).
	con_foo1()			# Conclusion de la invocacion de foo(n-1).
	
	move 	$t0, $v0		# Guardamos el contenido de $v0 en un registro temporal $t0.
	
	pre_foo2()			# Prologo a la invocacion de foo(n-2).
	inv_foo()			# Invocacion de foo(n-2).
	con_foo2()			# Conclusion de la invocacion de foo(n-2).
	
	add 	$v0, $v0, $t0		# Regresamos foo(n) = foo(n-1) + foo(n-2).
	j return			# Regresamos al caller.

# ---------------------------------------------
# Procedimiento: base1
# ---------------------------------------------
# Guarda un 1 en el registro $v0.
# ---------------------------------------------
base1:	
	li 	$v0, 1			# Caso base para el procedimiento recursivo foo.

# ---------------------------------------------
# Procedimiento: return
# ---------------------------------------------
# Conclusion de foo como rutina invodada.
# ---------------------------------------------
return: 
	con_foo0()			# Conclusion del procedimiento foo(n).
