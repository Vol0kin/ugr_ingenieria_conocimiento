; Ejercicio 3a

; Hechos de personas
(deffacts Personas
  (Persona Santiago 30 H)
  (Persona Teresa 28 M)
  (Persona Paco 47 H)
)

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Reglas del ejercicio 2b modificadas

; Insertar valor minimo inicial
; Se escoge un valor cualquiera para comenzar
(defrule init_nueva_busqueda
	(guardar Persona)
  (Persona ? ?e ?)
  (mayor_que ?min)
  (not (edad_minima ?))
  (test (> ?e ?min))
  =>
  (assert (edad_minima ?e))
  (assert (mayor_que ?min))
)

; Insertar valor minimo inicial para la primera busqueda
; Se escoge un valor cualquiera para comenzar, teniendo en cuenta que no se ha
; realizado una busqueda anterior (no existe un extremo inferior)
; Se establece que el valor del extremo inferior es 0
(defrule init_primera_busqueda
	(guardar Persona)
  (Persona ? ?e ?)
  (not (edad_minima ?))
  (not (mayor_que ?))
  =>
  (assert (edad_minima ?e))
  (assert (mayor_que 0))
)

; Buscar el minimo
; Ir buscando las edades de las personas que sean menores que el valor minimo
; actual y mayores que un cierto valor umbral inferior
(defrule minX2Persona
	(guardar Persona)
  ?f <- (edad_minima ?e1)
  (Persona ? ?e2 ?)
  (mayor_que ?m)
  (test (< ?e2 ?e1))
  (test (> ?e2 ?m))
  =>
  (retract ?f)
  (assert (edad_minima ?e2))
)

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Regla para abrir un fichero
(defrule abrir_escritura
	(declare (salience 30))
	=>
	(open "DatosPersona.txt" mydata "w")
)

; Regla para cerrar un fichero
(defrule cerrar_fichero
	?f <- (cerrar fichero)
	=>
	(close mydata)
	(retract ?f)
)

; Regla para escribir una linea
; Se tiene que haber finalizado la busqueda actual primero
(defrule escribir_datos
	(declare (salience -1))
  ?f <- (edad_minima ?e)
  ?g <- (mayor_que ?min)
  (Persona ?n ?e ?s)
  =>
  (retract ?f)
  (retract ?g)
  (assert (mayor_que ?e))
  (printout mydata ?n " " ?e " " ?s crlf)
)

; Regla para eliminar los datos extra generados durante el guardado del archivo
; Se ejecuta una vez finalizadas todas las busquedas
(defrule eliminar_busqueda
  (declare (salience -10))
  ?h <- (mayor_que ?)
  ?g <- (guardar Persona)
  =>
  (retract ?g)
  (retract ?h)
)
