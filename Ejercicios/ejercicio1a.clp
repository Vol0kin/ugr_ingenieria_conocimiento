
(deffacts habitaciones
  (habitacion Salon)
  (habitacion Dormitorio)
  (habitacion Cocina)
  (habitacion WC)
  (habitacion Pasillo)
)

; Apartado a)

(defrule init_contador
  (ContarHechos habitacion)
  =>
  (assert (NumeroHechos habitacion 0))
)

(defrule borrar_hechos_anteriores
  (declare (salience 1))
  (NumeroHechos habitacion 0)
  ?f <- (NumeroHechos habitacion ?n)
  (test (> ?n 0))
  =>
  (retract ?f)
)

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

(defrule borrar_contar_hechos
  (declare (salience -1))
  ?f <- (ContarHechos habitacion)
  =>
  (retract ?f)
)

(defrule borrar_hab_contadas
  (declare (salience -2))
  ?f <- (habitacion_contada ?h)
  =>
  (retract ?f)
)
