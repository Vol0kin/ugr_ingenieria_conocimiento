; Practica 1

; Registro de los datos de sensores

; Registra un nuevo valor de un sensor
(defrule nuevo_valor_sensor
	(valor ?tipo ?habitacion ?v)
	=>
	(assert (valor_registrado (time) ?tipo ?habitacion ?v))
)

; Registra la primera vez que se registra la activacion
; de un sensor
(defrule primer_registro_sensor
	(valor_registrado ?t ?tipo ?habitacion ?)
	(not (ultimo_registro ?tipo ?habitacion ?t))
	=>
	(assert (ultimo_registro ?tipo ?habitacion ?t))
)

; Registra cuando es la ultima vez que se activo un sensor
; Elimina la activacion anterior
(defrule nuevo_registro
  (valor_registrado ?t ?tipo ?habitacion ?)
	?Registro <- (ultimo_registro ?tipo ?habitacion ?)
	=>
	(assert (ultimo_registro ?tipo ?habitacion ?t))
	(retract ?Registro)
)
