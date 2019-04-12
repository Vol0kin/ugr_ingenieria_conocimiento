
; Version propia del control de manejo inteligene de luces

; Regla para encender las luces en una habitacion
; Las luces se encienden cuando se produce un movimiento en la habitacion 
; (sensor movimiento on) y la luminosidad detectada es menor a la mitad
; de la luminosidad media
; La luz no tiene que estar encendiada en la habitacion para poder hacer
; esta accion
(defrule encender_mov_poca_lum
  (Manejo_inteligente_luces ?hab) 
  (ultimo_registro movimiento ?hab ?t)
  (ultimo_registro luminosidad ?hab ?t2)
  (valor_registrado ?t movimiento ?hab on)
  (valor_registrado ?t2 luminosidad ?hab ?l)
  (luminosidad ?hab ?lux)
  (test (< ?l (/ ?lux 2)))
  (not (encendida ?hab ?))
  =>
  (assert (encender_luz ?hab ?t))
  (assert (encendida ?hab ?t))
)

; Regla para apagar las luces en una habitacion
; Las luces se apagan cuando se produce un movimiento en el la habitacion
; (sensor movimiento on) y la luminosidad detectada es mayor al doble
; de la luminosidad media
; La luz no tiene que estar apagada en la habitacion para poder hacer
; esta accion
(defrule apagar_mov_mucha_lum
  (Manejo_inteligente_luces ?hab) 
  (ultimo_registro movimiento ?hab ?t)
  (ultimo_registro luminosidad ?hab ?t2)
  (valor_registrado ?t movimiento ?hab on)
  (valor_registrado ?t2 luminosidad ?hab ?l)
  (luminosidad ?hab ?lux)
  (test (> ?l (* ?lux 2)))
  (not (apagada ?hab ?))
  =>
  (assert (apagar_luz ?hab ?t))
  (assert (apagada ?hab ?t))
)

; Regla para apagar las luces en una habitacion 
; Las luces se apagan cuando se produce un movimiento negativo en la
; habitacion (sensor movimiento off)
; La luz no tiene que estar apagada en la habitacion para poder hacer 
; esta accion
(defrule apagar_mov
  (Manejo_inteligente_luces ?hab)
  (ultimo_registro movimiento ?hab ?t)
  (valor_registrado ?t movimiento ?hab off)
  (not (apagada ?hab ?))
  =>
  (assert (apagar_luz ?hab ?t))
  (assert (apagada ?hab ?t))
)

; Regla para encender la luz en una habitacion 
; Si la luz estaba anteriormente apagada, elimina este hecho e introduce
; el hecho de que la habitacion tiene la luz encendida, comprobando los 
; tiempos de los dos hechos
(defrule encender 
  (Manejo_inteligente_luces ?hab)
  ?f <- (apagada ?hab ?t1) 
  (encendida ?hab ?t2)
  (test (< ?t1 ?t2))
  =>
  (retract ?f)
)

; Regla para apagar la luz en una habitacion 
; Si la luz estaba anteriormente encendida, elimina este hecho e introduce
; el hecho de que la habitacion tiene la luz apagada, comprobando los 
; tiempos de los dos hechos
(defrule apagar
  (Manejo_inteligente_luces ?hab)
  ?f <- (encendida ?hab ?t1) 
  (apagada ?hab ?t2)
  (test (< ?t1 ?t2))
  =>
  (retract ?f)
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
