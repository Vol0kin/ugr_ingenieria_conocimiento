; Apartado a)

; Hechos iniciales
(deffacts habitaciones
  (habitacion Salon)
  (habitacion Dormitorio)
  (habitacion Cocina)
  (habitacion WC)
  (habitacion Pasillo)
)

; Regla para inicializar el contador a 0
(defrule init_contador
  (ContarHechos habitacion)
  =>
  (assert (NumeroHechos habitacion 0))
)

; Regla para borrar el NumeroHechos anterior cuando se solicite uno nuevo
(defrule borrar_hechos_anteriores
  (declare (salience 1))
  (NumeroHechos habitacion 0)
  ?f <- (NumeroHechos habitacion ?n)
  (test (> ?n 0))
  =>
  (retract ?f)
)

; Regla para contar un hecho
; Comprueba si hay una habitacion no contada e incrementa el contador en
; 1. Especifica que esa habitacion se ha contado para evitar bucles
(defrule contar_hecho
  (habitacion ?h)
  (ContarHechos habitacion)
  (not (habitacion_contada ?h))
  ?f <- (NumeroHechos habitacion ?n)
  =>
  (assert (habitacion_contada ?h))
  (retract ?f)
  (assert (NumeroHechos habitacion (+ 1 ?n))) 
)

; Regla que borra el hecho ContarHechos habitacion una vez que se ha
; terminado de contar el numero de habitaciones
(defrule borrar_contar_hechos
  (declare (salience -1))
  ?f <- (ContarHechos habitacion)
  =>
  (retract ?f)
)

; Regla para borrar el hecho habitacion_contada una vez se han terminado
; de contar todas las habitaciones y habiendo borrado ContarHechos habitacion
(defrule borrar_hab_contadas
  (declare (salience -2))
  ?f <- (habitacion_contada ?h)
  =>
  (retract ?f)
)
