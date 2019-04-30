; Ejercicio 2b

; Hechos de personas
(deffacts Personas
  (Persona Santiago 30)
  (Persona Teresa 28)
  (Persona Paco 47)
)

; Insertar valor minimo inicial
; Se escoge un valor cualquiera para comenzar
(defrule primer_valor
  (Persona ? ?e)
  (not (edad_minima ?))
  =>
  (assert (edad_minima ?e))
)

; Buscar el minimo
; Ir buscando las edades de las personas que sean menores que el minimo
(defrule minX2Persona
  ?f <- (edad_minima ?e1)
  (Persona ? ?e2)
  (test (< ?e2 ?e1))
  =>
  (retract ?f)
  (assert (edad_minima ?e2))
)
