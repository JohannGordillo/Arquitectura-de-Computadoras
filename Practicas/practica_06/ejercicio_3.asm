.data
res:	.space	4
m:	.word	37

# constantes flotantes
v0:	.float 	0.0
v1:	.float 	1.0
v3:	.float 	3.0
v4:	.float 	4.0

.text 
	lw $t0 m #$t0 es el valor de m inicialmente
	lwc1 $f0 v0 #$f0 sera el resultado final, incializado en cero	
	lwc1 $f1 v0 #$f1 sera el valor de n, inicializado en cero
	lwc1 $f29 v1 #$f29 es 1.0
	lwc1 $f30 v3 #$f30 es 3.0
	lwc1 $f31 v4 #$f31 es 4.0
ciclo:	mul.s $f2 $f1 $f31 #$f2 es 4*n
	add.s $f3 $f2 $f29 #$f3 es 4n + 1
	div.s $f3 $f29 $f3 #$f3 es 1/(4n +1)
	add.s $f4 $f2 $f30 #$f4 es 4n + 3
	div.s $f4 $f29 $f4 #$f4 es 1/(4n +3)
	sub.s $f5 $f3 $f4 #$f5 es $f3 - $f4
	add.s $f0 $f0 $f5 # se suma $f5 al resultado final
	add.s $f1 $f1 $f29 # incrementamos n en 1
	sub $t0 $t0 1 # decrementamos m en 1
	bgez  $t0 ciclo # si m es mayor o igual que cero, continua
	swc1 $f0 res #guardamos en memoria
