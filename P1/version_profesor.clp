
; Regla para comprobar si una habitacion esta activa 
; Una habitacion esta activa si se registra movimiento
; en esta
(defrule activar_hab
  (ultimo_registro movimiento ?h ?t)
  (valor_resgistrado ?t movimiento ?h on)
  =>
  (assert (activa ?h ?t))
)

; Regla para comprobar si una habitacion parece inactiva
; Una habitacion parece inactiva si se registra un movimiento 
; negativo en esta
(defrule parece_inact_h
  (ultimo_registro movimiento ?t ?t) 
  (valor_registrado ?t movimiento ?h off)
  =>
  (assert (parece_inactiva ?h ?t))
)

(defrule no_activa_hab
  () 
  =>
  ()
)

(defrule posible_paso_hab
  (ultimo_registro movimiento ?h ?t) 
  (activa ?h ?t)
  (ultimo_registro movimiento ?h2 ?t2)
  (activa ?h2 ?t2)
  (posible_pasar ?h2 ?h)
  (test (< ?t2 ?t))
  =>
  (assert (posible_paso ?h2 ?h ?t))
)

(defrule paso_solo_una_hab
  (ultimo_registro ?h ?t)
  (activa ?h ?t)
)


(defrule activar_luz
  (activa ?h) 
  (ultimo_registro movimiento ?h ?t)
  (valor_registrado ?t luminosidad ?l)
)
