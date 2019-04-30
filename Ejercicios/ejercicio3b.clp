; Ejercicio 3b

; Regla para abrir un archivo
(defrule abrir_archivo
	(declare (salience 2))
	=>
	(open "DatosPersona.txt" mydata)
	(assert (SeguirLeyendo))
)

; Regla para ir leyendo las lineas de un fichero
; Comprueba que el primer simbolo leido no es EOF
; Lee los valores restantes que hay en esa linea y los inserta.
; En este caso es la salida es del tipo : Persona ?Nombre ?Edad ?Sexo
(defrule leer_linea
	(declare (salience 1))
	?f <- (SeguirLeyendo)
	=>
	(bind ?Leido (read mydata))
	(retract ?f)
	(if (neq ?Leido EOF) then
	(assert (Persona ?Leido (read mydata) (read mydata)))
	(assert (SeguirLeyendo)))
)

; Regla para cerrar el archivo
(defrule cerrar_archivo
	=>
	(close mydata)
)
