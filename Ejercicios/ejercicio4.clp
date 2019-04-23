(deffacts tiempos
  (ultimo_tiempo (time)) 
)

(defrule imprimir
  ?f <- (inicio ?t1)
  (ultimo_tiempo ?t2)
  (test (>= ?t2 (+ ?t1 60)))
  =>
  (printout t crlf "Estoy esperando nueva información" crlf)
  (retract ?f)
  (assert (inicio ?t2))
)

(defrule bucle
  (declare (salience -10000))
  ?f <- (ultimo_tiempo ?t)
  =>
  (retract ?f)
  (assert (ultimo_tiempo (time)))
)


(defrule add_inicio
  (ultimo_tiempo ?s)
  (not (inicio ?))
  =>
  (bind ?t (time))
  (assert (inicio ?s))
)
