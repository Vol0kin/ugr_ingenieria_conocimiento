; Practica 1

; -----------------------------------------------------------------------------
; Apartado 1
; -----------------------------------------------------------------------------

; A continuacion se describen la prioridad de las reglas:
; Prioridad 2: pasar_puerta, pasar_paso
; Prioridad 1: hab_mas_una_entrada
; Prioridad 0: resto de reglas


; Habitaciones de la casa
(deffacts habitaciones
	(Habitacion pasillo)
	(Habitacion cocina)
	(Habitacion WC)
	(Habitacion salon)
	(Habitacion Dormitorio_Principal)
	(Habitacion Dormitorio_1)
	(Habitacion Dormitorio_2)
	(Habitacion Terraza)
)

; Puertas de la casa
(deffacts puertas
	(Puerta pasillo Dormitorio_2)
	(Puerta pasillo WC)
	(Puerta pasillo salon)
	(Puerta salon Dormitorio_Principal)
	(Puerta salon Dormitorio_1)
	(Puerta Dormitorio_Principal Terraza)
)

; Pasos sin puerta de la casa
(deffacts pasos_sin_puerta
	(Paso pasillo cocina)
)

; Ventanas de la casa
(deffacts ventanas
	(Ventana Dormitorio_2)
	(Ventana cocina)
	(Ventana WC)
	(Ventana salon)
	(Ventana Dormitorio_1)
	(Ventana Terraza)
)

; Regla de pasar de una habitacion a otra mediante una puerta
; Tiene prioridad 2 porque se debe ejecutar antes que:
; - hab_mas_una_entrada
; - hab_necesario_pasar
; Estas dos reglas necesitan que antes se deduzca este conocimiento
(defrule pasar_puerta
	(declare (salience 2))
	(Puerta ?h1 ?h2)
	=>
	(assert (posible_pasar ?h1 ?h2))
	(assert (posible_pasar ?h2 ?h1))
)

; Regla de pasar de una habitacion a otra mediante un paso
; Tiene prioridad 2 porque se debe ejecutar antes que:
; - hab_mas_una_entrada
; - hab_necesario_pasar
; Estas dos reglas necesitan que antes se deduzca este conocimiento
(defrule pasar_paso
	(declare (salience 2))
	(Paso ?h1 ?h2)
	=>
	(assert (posible_pasar ?h1 ?h2))
	(assert (posible_pasar ?h2 ?h1))
)

; Regla para inferir las habitaciones que tienen mas de una entrada
; (pueden ser accedidas desde mas de una habitacion)
; Tiene prioridad 1 porque debe ejecutarse antes que:
; - hab_necesario_pasar
; Se necesita deducir antes que habitaciones pueden ser accedidas por
; mas de un sitio que las que no
(defrule hab_mas_una_entrada
	(declare (salience 1))
	(Habitacion ?h1)
	(Habitacion ?h2 & ~?h1)
	(Habitacion ?h3 & ~?h1 & ~?h2)
	(posible_pasar ?h1 ?h2)
	(posible_pasar ?h1 ?h3)
	=>
	(assert (mas_una_entrada ?h1))
)

; Regla para inferir que para llegar a una habitacion solamente se puede llegar
; pasando por otra
; lectura: pasar por h2 para llegar a h1
; h2 -> h1
(defrule hab_necesario_pasar
	(Habitacion ?h1)
	(posible_pasar ?h1 ?h2)
	(not (mas_una_entrada ?h1))
	=>
	(assert (necesario_pasar ?h2 ?h1))
)

; Regla de habitacion interior
; Una habitacion es interior si no tiene ventanas
(defrule hab_interior
	(Habitacion ?h)
	(not (Ventana ?h))
	=>
	(assert (habitacion_interior ?h))
)

; Conocimiento respecto a la luminosidad de las habitaciones
(deffacts Luminosidades
  (luminosidadmedia salon 300) 
  (luminosidadmedia Dormitorio_Principal 150)
  (luminosidadmedia Dormitorio_1 150)
  (luminosidadmedia Dormitorio_2 150)
  (luminosidadmedia cocina 200)
  (luminosidadmedia pasillo 200)
  (luminosidadmedia WC 200)
  (luminosidadmedia Despacho 500)
)

; -----------------------------------------------------------------------------
; Apartado 2
; -----------------------------------------------------------------------------

; Reglas para gestionar los datos de entrada de los sensores

; Regla para incluir un nuevo valor_registrado
; Inserta tambien un nuevo ultimo_registro
; La habitacion tiene que ser valida
(defrule nuevo_registro
  (valor ?tipo ?h ?v)
  (Habitacion ?h)
  =>
  (bind ?t (momento))
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

; Regla para obtener el informe
(defrule obtener_informe
  (informe ?h)
  (Habitacion ?h)
  =>
  (assert (mayor_que 0 ?h))
)

; Regla para obtener el primer valor mayor que 0 o que uno ya dado 
(defrule valor_mayor
  ?f <- (mayor_que ?val ?h)
  (valor_registrado ?t ?tipo ?h ?v)
  (test (> ?t ?val))
  =>
  (assert (mayor_que ?val menor_que ?t ?h))
  (retract ?f)
)

; Regla para buscar un valor de tiempo mayor que un extremo inferior pero menor
; que un extremo superior
; Se le da una prioridad superior para evitar que se imprima el informe antes 
; de tiempo
(defrule valor_mayor_menor
  (declare (salience 1))
  ?f <- (mayor_que ?inf menor_que ?sup ?h) 
  (valor_registrado ?t ?tipo ?h ?v)
  (test (> ?t ?inf))
  (test (< ?t ?sup))
  =>
  (assert (mayor_que ?inf menor_que ?t ?h))
  (retract ?f)
)

; Regla para imprimir el informe
(defrule imprimir_informe
  ?f <- (mayor_que ?inf menor_que ?sup ?h)
  (valor_registrado ?sup ?tipo ?h ?v)
  =>
  (assert (mayor_que ?sup ?h))
  (retract ?f)
  (printout t "Valor Registrado " ?h ": " ?sup " " ?tipo " " ?v crlf)
)

; Regla para imprimir el informe solicitado
(defrule elimina_informe
  (declare (salience -1))
  ?g <- (informe ?h)
  =>
  (retract ?g)
)

; -----------------------------------------------------------------------------
; Apartado 3
; -----------------------------------------------------------------------------


; Version propia del control de manejo inteligente de luces
; Version simplificada del manejo inteligente de luces de la version del experto

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
  (luminosidadmedia ?hab ?lux)
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
  (luminosidadmedia ?hab ?lux)
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
