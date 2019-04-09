
(defrule activar_hab
  (ultimo_registro movimiento ?h ?t)
  (valor_resgistrado ?t movimiento ?h on)
  =>
  (assert (activa ?h))
)

(defrule activar_luz
  (activa ?h) 
  (ultimo_registro movimiento ?h ?t)
  (valor_registrado ?t luminosidad ?l)
)
