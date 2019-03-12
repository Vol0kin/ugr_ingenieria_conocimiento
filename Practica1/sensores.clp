; Practica 1

; Registro de los datos de sensores

; Registra un nuevo valor de un sensor
; Indica que se tiene que guardar una nueva
; activacion del sensor
(defrule nuevo_valor_sensor
	?valor <- (valor ?tipo ?habitacion ?v)
  (Habitacion ?habitacion)
	=>
  (assert (guardar_ultimo_registro))
	(assert (valor_registrado (time) ?tipo ?habitacion ?v))
  (retract ?valor)
)

; Guarda la primera vez que se registra la activacion
; de un sensor. Como no ha habido una previa, no se
; borra
; Se da en los siguientes casos:
; - se ha registrado un nuevo valor para el sensor
; - el utlimo valor no esta actualizado para ese valor
; - se ha indicado que se tiene que guardar el ultimo
;   registro
(defrule primer_registro_sensor
	(valor_registrado ?t ?tipo ?habitacion ?)
	(not (ultimo_registro ?tipo ?habitacion ?))
  ?f <- (guardar_ultimo_registro)
  =>
	(assert (ultimo_registro ?tipo ?habitacion ?t))
  (retract ?f)
)

; Registra cuando es la ultima vez que se activo un sensor
; Elimina la activacion anterior
; Se activa cuando se cumplen las siguientes condiciones:
; - se ha registrado un nuevo valor para el sensor
; - el utlimo valor no esta actualizado para ese valor
; - se ha indicado que se tiene que guardar el ultimo
;   registro
; - existe una ultima activacion anterior a esta
(defrule nuevo_registro
  (valor_registrado ?t ?tipo ?habitacion ?)
  ?f <- (guardar_ultimo_registro)
	?Registro <- (ultimo_registro ?tipo ?habitacion ?)
	=>
	(assert (ultimo_registro ?tipo ?habitacion ?t))
	(retract ?Registro)
  (retract ?f)
)

(defrule primera_activacion_sensor
  (valor_registrado ?t movimiento ?habitacion on)
  (not (ultima_activacion movimiento ?habitacion ?t))
  =>
  (assert (ultima_activacion movimiento ?habitacion ?t))
 )
