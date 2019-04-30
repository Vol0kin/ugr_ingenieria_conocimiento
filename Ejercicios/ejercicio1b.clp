; Ejercicio 1b

; Insertar hecho inicial
; Inicializar contador a 0
(deffacts ContarHechos
  (NumeroHechos habitacion 0) 
)

; Regla para incrementar en 1 el numero de hechos
; Incrementa el contador en 1 al insertar una nueva habitacion si esta no ha
; sido contada hasta el momento
(defrule incrementar_contador
  (habitacion ?h)
  (not (habitacion_contada ?h))
  ?f <- (NumeroHechos habitacion ?n)
  =>
  (retract ?f)
  (assert (NumeroHechos habitacion (+ ?n 1)))
  (assert (habitacion_contada ?h))
)

; Regla para decrementar el numero de hechos
; Despues de insertar el hecho de que se quiere borrar una habitacion, se
; borra dicha habitacion, el hecho de que haya sido contada y se decrementa
; el contador en 1
(defrule decrementar_contador
  ?f <- (borrar habitacion ?h)
  ?g <- (habitacion ?h)
  ?i <- (NumeroHechos habitacion ?n)
  ?j <- (habitacion_contada ?h)
  =>
  (retract ?f)
  (retract ?g)
  (retract ?i)
  (retract ?j)
  (assert (NumeroHechos habitacion (- ?n 1)))
)
