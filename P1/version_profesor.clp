
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
(defrule no_activa_hab
  (parece_inactiva ?h ?t)
  (ultimo_registro movimiento ?h ?t2)
  (valor_registrado ?t2 movimiento ?h off)
  (ultima_desactivacion movimiento ?h ?tDes)
  (test (> ?t2 (+ ?tDes 10)))
  =>
  (assert (inactiva ?h ?t2))
)

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
  (test (<= ?t1 ?t2))
  =>
  (retract ?f)
)

; Eliminar el parece_inactiva actual si se da un inactiva 
; mas reciente que el parece_inactiva
(defrule eliminar_parece_inactiva_inactiva_h
  ?f <- (parece_inactiva ?h ?t1) 
  (inactiva ?h ?t2)
  (test (<= ?t1 ?t2))
  =>
  (retract ?f)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         REGLAS PARA GESTIONAR LOS PASOS

(defrule posible_paso_hab
  (declare (salience 10))
  (parece_inactiva ?h1 ?t1)
  (activa ?h2 & ~?h1 ?t2)
  (test (> ?t1 ?t2))
  (posible_pasar ?h1 ?h2)
  =>
  (assert (posible_paso ?h1 ?h2 ?t1))
)

(defrule mas_un_posible_paso
  (declare (salience 2))
  (posible_paso ?h1 ?h2 ?t1)
  (posible_paso ?h1 ?h3 & ~?h2 ?t2)
  =>
  (bind ?t3 (time))
  (assert (mas_un_posible_paso ?h1 ?t3))
)

(defrule paso_solo_una_hab
  (declare (salience 1))
  (activa ?h ?t)
  ?f <- (posible_paso ?h2 ?h ?t2)
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
  (assert (inactiva ?h ?t))
)

(defrule activa_paso_h
  (ultimo_registro movimiento ?h ?t)
  (parece_inactiva ?h ?t)
  (not (paso ?h ? ?))
  (not (mas_un_posible_paso ?h ?))
  =>
  (assert (activa ?h ?t))
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

(defrule encender_hab_activa_poca_luz
  (Manejo_inteligente_luces ?h)
  (ultimo_registro movimiento ?h ?t)
  (activa ?h ?t) 
  (ultimo_registro estadoluz ?h ?t2)
  (valor_registrado ?t2 estadoluz ?h off)
  (ultimo_registro luminosidad ?h ?t3)
  (valor_registrado ?t3 luminosidad ?h ?l)
  (luminosidad ?h ?lux)
  (test (< ?l (/ ?lux 2)))
  =>
  (assert (encender_luz ?h ?t))
)

(defrule apagar_hab_inactiva
  (Manejo_inteligente_luces ?h)
  (ultimo_registro movimiento ?h ?t)
  (inactiva ?h ?t)
  (ultimo_registro estadoluz ?h ?t2)
  (valor_registrado ?t2 estadoluz ?h on)
  =>
  (assert (apagar_luz ?h ?t))
)

(defrule apagar_hab_mucha_luz
  (Manejo_inteligente_luces ?h)
  (ultimo_registro movimiento ?ht ?t)
  (activa ?h ?t)
  (ultimo_registro estadoluz ?h ?t2)
  (valor_registrado ?t2 estadoluz ?h on)
  (ultimo_registro luminosidad ?h ?t3)
  (valor_registrado ?t3 luminosidad ?h ?l)
  (luminosidad ?h ?lux)
  (test (> ?l (* ?lux 2)))
  =>
  (assert (apagar_luz ?h ?t3))
)

; Regla para eliminar el anterior encendido de las luces, basandose en
; el tiempo de estos
(defrule eliminar_encender_ant
  (declare (salience 1))
  ?f <- (encender_luz ?hab ?t1) 
  ?g <- (accion pulsador_luz ?hab encender)
  (encender_luz ?hab ?t2)
  (test (< ?t1 ?t2))
  =>
  (retract ?f)
  (retract ?g)
)

; Regla para eliminar el anterior apagado de las luces, basandose en 
; el tiempo de estos
(defrule eliminar_apagar_ant
  (declare (salience 1)) 
  ?f <- (apagar_luz ?hab ?t1)
  ?g <- (accion pulsador_luz ?hab apagar)
  (apagar_luz ?hab ?t2)
  (test (< ?t1 ?t2))
  =>
  (retract ?f)
  (retract ?g)
)
; Regla para insertar la accion de encender la luz con el pulsador
(defrule encender_interruptor
  (encender_luz ?hab ?t) 
  =>
  (assert (accion pulsador_luz ?hab encender))
)

; Regla para insertar la accion de apagar la luz con el pulsador
(defrule apagar_interruptor
  (apagar_luz ?hab ?t) 
  =>
  (assert (accion pulsador_luz ?hab apagar))
)
