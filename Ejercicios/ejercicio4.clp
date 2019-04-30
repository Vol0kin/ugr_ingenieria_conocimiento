; Ejercicio 4

; Regla para insertar el tiempo inicial  
(deffacts tiempos
  (ultimo_tiempo (time)) 
)

; Regla para imprimir por pantalla que se esta esperando nueva informacion
; Comprueba que hayan transcurrido 60 segundos desde el ultimo inicio y lo
; actualiza a su nuevo valor
(defrule imprimir
  ?f <- (inicio ?t1)
  (ultimo_tiempo ?t2)
  (test (>= ?t2 (+ ?t1 60)))
  =>
  (printout t crlf "Estoy esperando nueva información" crlf)
  (retract ?f)
  (assert (inicio ?t2))
)

; Regla de bucle, la cual tiene una prioridad minima para poder ejecutar otras
; reglas en la terminal
; Va actualizando el tiempo
(defrule bucle
  (declare (salience -10000))
  ?f <- (ultimo_tiempo ?t)
  =>
  (retract ?f)
  (assert (ultimo_tiempo (time)))
)

; Regla para insertar un tiempo de inicio desde el que se comienzan a contar
; los 60 segundos
(defrule add_inicio
  (ultimo_tiempo ?s)
  (not (inicio ?))
  =>
  (bind ?t (time))
  (assert (inicio ?s))
)
