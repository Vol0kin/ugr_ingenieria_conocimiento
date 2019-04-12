
;         REGLAS PARA ACTIVAR LAS HABITACIONES

; Regla para comprobar si una habitacion esta activa 
; Una habitacion esta activa si se registra movimiento
; en esta
(defrule activa_h
  (ultimo_registro movimiento ?h ?t)
  (valor_registrado ?t movimiento ?h on)
  =>
  (assert (activa ?h ?t))
)

; Regla para comprobar si una habitacion parece inactiva
; Una habitacion parece inactiva si se registra un movimiento 
; negativo en esta
(defrule parece_inact_h
  (ultimo_registro movimiento ?h ?t) 
  (valor_registrado ?t movimiento ?h off)
  =>
  (assert (parece_inactiva ?h ?t))
)

; TODO
;(defrule no_activa_hab
;  (parece_inactiva ?h ?t)

;  =>
;  (bind ?tInact (time))
;  (assert (inactiva ?h ?tInact))
;)

; Eliminar la activacion anterior en el momento en el 
; que la habitacion parece inactiva, es decir, si el 
; tiempo de parece_inactiva es superior a activa
(defrule eliminar_activa_h
  ?f <- (activa ?h ?t1) 
  (parece_inactiva ?h ?t2)
  (test (< ?t1 ?t2))
  =>
  (retract ?f)
)

; Eliminar el parece_inactiva actual si se da una activacion 
; mas reciente que el parece_inactiva
(defrule eliminar_parece_inactiva_h
  ?f <- (parece_inactiva ?h ?t1) 
  (activa ?h ?t2)
  (test (< ?t1 ?t2))
  =>
  (retract ?f)
)

; Eliminar el parece_inactiva actual si se da un inactiva 
; mas reciente que el parece_inactiva
(defrule eliminar_parece_inactiva_inactiva_h
  ?f <- (parece_inactiva ?h ?t1) 
  (inactiva ?h ?t2)
  (test (< ?t1 ?t2))
  =>
  (retract ?f)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         REGLAS PARA GESTIONAR LOS PASOS

(defrule posible_paso_hab
  (declare (salience 10))
  (activa ?h1 ?t1)
  (activa ?h2 & ~?h1 ?t2)
  (test (< ?t1 ?t2))
  (posible_pasar ?h1 ?h2)
  =>
  (assert (posible_paso ?h1 ?h2 ?t2))
)

(defrule mas_un_posible_paso
  (posible_paso ?h1 ?h2 ?t1)
  (posible_paso ?h1 ?h3 & ~?h2 ?t2)
  =>
  (bind ?t3 (time))
  (assert (mas_un_posible_paso ?h1 ?t3))
)

(defrule paso_solo_una_hab
  (declare (salience -1))
  (activa ?h ?t)
  ?f <- (posible_paso ?h2 ?h ?t)
  (not (mas_un_posible_paso ?h2 ?))
  =>
  (assert (paso ?h2 ?h ?t))
  (retract ?f)
)

(defrule inactiva_paso_h
  (ultimo_registro movimiento ?h ?t) 
  (parece_inactiva ?h ?t)
  (paso ?h ? ?t2)
  (test (< ?t2 ?t))
  =>
  (bind ?t2 (time))
  (assert (inactiva ?h ?t2))
)

(defrule activa_paso_h
  (ultimo_registro movimiento ?h ?t)
  (parece_inactiva ?h ?t)
  (not (paso ?h ? ?))
  =>
  (bind ?t2 (time))
  (assert (activa ?h ?t2))
)

(defrule eliminar_posible_paso_ant
  ?f <- (posible_paso ?h1 ?h2 ?t1)
  (posible_paso ?h1 ?h2 ?t2)
  (test (< ?t1 ?t2))
  =>
  (retract ?f)
)

(defrule eliminar_paso_ant
  ?f <- (paso ?h1 ?h2 ?t1) 
  (paso ?h1 ?h2 ?t2)
  (test (< ?t1 ?t2))
  =>
  (retract ?f)
)

(defrule eliminar_mas_un_posible_paso_ant
  ?f <- (mas_un_posible_paso ?h ?t1) 
  (mas_un_posible_paso ?h ?t2)
  (test (< ?t1 ?t2))
  =>
  (retract ?f)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         REGLAS PARA GESTIONAR LOS ESTADOS DE LAS LUCES

;(defrule activar_luz
;  (activa ?h) 
;  (ultimo_registro movimiento ?h ?t)
;  (valor_registrado ?t luminosidad ?l)
;)
