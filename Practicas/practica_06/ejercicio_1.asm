# =====================================
# Autor: Johann Gordillo
# Email: jgordillo@ciencias.unam.mx
# Fecha: 13/10/2019
# =====================================
# Implementación de un procedimiento
# para calcular la exponencial en
# lenguaje ensamblador.
# =====================================


# Nota: Guardo la salida en el registro $a0, y además imprimo el resultado,
#       por lo que necesito del registro $v0.


.data
    r: .word 1 # Valor inicial de r.
    x: .word 3 # --> Cambiar el valor de x.
    n: .word 2 # --> Cambiar el valor de n.

.text
    # Procedimiento principal. 
    main:
        # Por convención, usamos los registros 'a' para pasar argumentos a un procedimiento.
        lw $t1, r
        lw $t2, x
        lw $t3, n 
        
        jal exp_log # Jump link al procedimiento exp_log.
        
        # Imprimir el resultado.
     	addi $v0, $v1, 0
     	li $v0, 1
     	addi $a0, $v1, 0 
     	syscall
    
    # Le decimos al procedimiento principal que hemos llegado al final del programa.
    li $v0, 10
    syscall 
    
    # Procedimiento para implementar la exponencial logaritmica.
    exp_log:   
    	move $t4, $t2     # y = x
    	
    	ciclo:
    	    ble $t3, 1, exit # Verificamos que n > 1
    	    
    	    # if n%2 == 1
    	    div $t5, $t3, 2 # n % 2
    	    mfhi $t6  # Resultado de n%2
    	    
    	    beq $t6, 1, accion # n % 2 == 1 
 
    	    j accion2  
    	
     
    accion: 
        mul $t1, $t1, $t4   # r = r * y 
        j accion2
        
    accion2:
        div $t3, $t3, 2     # n = n / 2
    	mul $t4, $t4, $t4   # y = y * y
    	j ciclo
    	
     exit:
        mul $t1, $t1, $t4  # r = r * y
    	addi $v1, $t1, 0   # return r. Colocamos el resultado de r en v1.
        
        jr $ra # Regresamos al caller del procedimiento (main).
