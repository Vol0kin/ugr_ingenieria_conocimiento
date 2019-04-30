; Ejercicio 2a

; Template de una persona (contiene nombre y edad)
(deftemplate Persona
  (slot Nombre)
  (slot Edad)
)

; Insertar personas
(deffacts Personas
  (Persona
    (Nombre Santiago)
    (Edad 30))
  (Persona
    (Nombre Teresa)
    (Edad 28))
  (Persona
    (Nombre Paco)
    (Edad 47))
)

; Insertar valor minimo inicial
; Se escoge un valor cualquiera para comenzar
(defrule primer_valor
  (Persona
    (Nombre ?)
    (Edad ?e))
  (not (edad_minima ?))
  =>
  (assert (edad_minima ?e))
)

; Buscar el minimo
; Ir buscando las edades de las personas que sean menores que el minimo
(defrule minEdaddePersona
  ?f <- (edad_minima ?e1)
  (Persona
    (Nombre ?)
    (Edad ?e2))
  (test (< ?e2 ?e1))
  =>
  (retract ?f)
  (assert (edad_minima ?e2))
)
