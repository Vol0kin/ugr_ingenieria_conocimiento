; Practica 1

; Reglas para gestionar los datos de entrada de los sensores

; Regla para incluir un nuevo valor_registrado
; Inserta tambien un nuevo ultimo_registro
; La habitacion tiene que ser valida
(defrule nuevo_registro
  (valor ?tipo ?h ?v)
  (Habitacion ?h)
  =>
  (bind ?t (time))
  (assert (valor_registrado ?t ?tipo ?h ?v))
  (assert (ultimo_registro ?tipo ?h ?t))
)

; Regla para eliminar el anterior ultimo_registro
; del mismo tipo para una habitacion segun el tiempo
(defrule ultimo_reg
  ?f <- (ultimo_registro ?tipo ?h ?t1)
  (ultimo_registro ?tipo ?h ?t2)
  (test (< ?t1 ?t2))
  =>
  (retract ?f)
)

; Regla para insertar una nueva ultima_activacion 
; de un sensor de movimiento en una habitacion en un 
; tiempo
; Se inserta la ultima activacion segun una variable
; que va cambiando, que dice que se ha dado un cambio 
; del tipo off -> on 
; Se inserta que se ha producido ese cambio para evitar 
; insertar valores de ultima_activacion que sean del tipo 
; on -> on   
(defrule ultima_act_mov
  (ultimo_registro movimiento ?h ?t)
  (valor movimiento ?h on)
  (not (activacion movimiento ?h ?))
  =>
  (assert (ultima_activacion movimiento ?h ?t))
  (assert (activacion movimiento ?h ?t))
)

; Regla para insertar una nueva ultima_desactivacion 
; de un sensor de movimiento en una habitacion en un 
; tiempo
; Se inserta la ultima desactivacion segun una variable
; que va cambiando, que dice que se ha dado un cambio 
; del tipo on -> off 
; Se inserta que se ha producido ese cambio para evitar 
; insertar valores de ultima_desactivacion que sean del tipo 
; off -> off   
(defrule ultima_desact_mov
  (ultimo_registro movimiento ?h ?t)
  (valor movimiento ?h off)
  (not (desactivacion movimiento ?h ?))
  =>
  (assert (ultima_desactivacion movimiento ?h ?t))
  (assert (desactivacion movimiento ?h ?t))
)

; Regla que permite comprobar que se ha dado un 
; cambio del tipo on -> off en un sensor de movimiento
; Elimina que se ha producido una desactivacion 
; e inserta una activacion
(defrule activacion
  (activacion movimiento ?h ?t)
  ?f <- (desactivacion movimiento ?h ?t2)
  (test (< ?t2 ?t))
  =>
  (retract ?f)
)

; Regla que permite comprobar que se ha dado un 
; cambio del tipo off -> on en un sensor de movimiento 
; Elimina que se haya producido una activacion 
; e inserta una desactivacion
(defrule desactivacion
  (desactivacion movimiento ?h ?t)
  ?f <- (activacion movimiento ?h ?t2)
  (test (< ?t2 ?t))
  =>
  (retract ?f)
)

; Regla que permite eliminar la ultima_activacion mas antigua
(defrule borrar_act_anterior
  ?f <- (ultima_activacion movimiento ?h ?t)
  (ultima_activacion movimiento ?h ?t2)
  (test (< ?t ?t2))
  =>
  (retract ?f)
)

; Regla que permite eliminar la ultima_desactivacion mas antigua
(defrule borrar_desact_anterior
  ?f <- (ultima_desactivacion movimiento ?h ?t)
  (ultima_desactivacion movimiento ?h ?t2)
  (test (< ?t ?t2))
  =>
  (retract ?f)
)

; Regla para borrar el valor registrado
(defrule borrar_valor
  (declare (salience -10))
  ?f <- (valor ?tipo ?h ?v)
  =>
  (retract ?f)
 )
