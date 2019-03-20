
(defrule nuevo_registro
  (valor ?tipo ?h ?v)
  (Habitacion ?h)
  =>
  (bind ?t (time))
  (assert (valor_registrado ?t ?tipo ?h ?v))
  (assert (ultimo_registro ?tipo ?h ?t))
)

(defrule ultimo_reg
  ?f <- (ultimo_registro ?tipo ?h ?t1)
  (ultimo_registro ?tipo ?h ?t2)
  (test (< ?t1 ?t2))
  =>
  (retract ?f)
)

(defrule ultima_act_mov
  (ultimo_registro movimiento ?h ?t)
  (valor movimiento ?h on)
  =>
  (assert (ultima_activacion movimiento ?h ?t))
)

(defrule ultima_desact_mov
  (ultimo_registro movimiento ?h ?t)
  (valor movimiento ?h off)
  =>
  (assert (ultima_desactivacion movimiento ?h ?t))
)

(defrule activacion
  ?f <- (ultima_activacion movimiento ?h ?t1) 
  (ultima_desactivacion movimiento ?h ?t2)
  (test (< ?t1 ?t2))
  (ultima_activacion movimiento ?h ?t3)
  (test (< ?t2 ?t3))
  =>
  (retract ?f)
)

(defrule desactivacion
 ?f <- (ultima_desactivacion movimiento ?h ?t1)
 (ultima_activacion movimiento ?h ?t2)
 (test (< ?t1 ?t2))
 (ultima_desactivacion movimiento ?h ?t3)
 (test (< ?t2 ?t3))
 =>
 (retract ?f)
)

(defrule borrar_valor
  (declare (salience -10))
  ?f <- (valor ?tipo ?h ?v)
  =>
  (retract ?f)
 )
