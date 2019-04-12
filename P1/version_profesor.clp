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


;         REGLAS PARA ACTIVAR LAS HABITACIONES

; Regla para comprobar si una habitacion esta activa 
; Una habitacion esta activa si se registra movimiento
; en esta y no se ha detectado en un registro anterior
; que esta activa
(defrule activa_h
  (Manejo_inteligente_luces ?h)
  (ultimo_registro movimiento ?h ?t)
  (valor_registrado ?t movimiento ?h on)
  (not (activa ?h ?))
  =>
  (assert (activa ?h ?t))
)

; Regla para comprobar si una habitacion parece inactiva
; Una habitacion parece inactiva si se registra un movimiento 
; negativo en esta
(defrule parece_inact_h
  (Manejo_inteligente_luces ?h)
  (ultimo_registro movimiento ?h ?t) 
  (valor_registrado ?t movimiento ?h off)
  =>
  (assert (parece_inactiva ?h ?t))
)

; Regla para comprobar que una hbitacion esta inactiva
; Una habitacion esta inactiva si se tardan mas de 10
; segundos en decidirse que no parece_inactiva
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

; Eliminar la activacion anterior si el nuevo estado de la
; habitacion es inactiva
(defrule eliminar_activa_h2
  ?f <- (activa ?h ?t1) 
  (inactiva ?h ?t2)
  (test (< ?t1 ?t2))
  =>
  (retract ?f)
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         REGLAS PARA GESTIONAR LOS PASOS

; Obtener los posibles pasos desde una habitacion
; El razonamiento empieza cuando la habitacion parece inactiva
; Comprueba las habitacions contiguas que esten activas
; y dice que se ha podido producir un paso
(defrule posible_paso_hab
  (declare (salience 10))
  (parece_inactiva ?h1 ?t1)
  (activa ?h2 & ~?h1 ?t2)
  (test (> ?t1 ?t2))
  (posible_pasar ?h1 ?h2)
  =>
  (assert (posible_paso ?h1 ?h2 ?t1))
)

; Obtener si se puede realizar mas de un posible paso desde una
; habitacion
; Comprueba que se pueden dar dos o mas posible_paso
(defrule mas_un_posible_paso
  (declare (salience 2))
  (posible_paso ?h1 ?h2 ?t1)
  (posible_paso ?h1 ?h3 & ~?h2 ?t2)
  =>
  (bind ?t3 (momento))
  (assert (mas_un_posible_paso ?h1 ?t3))
)

; Obtener si se ha realizado solo un posible_paso desde una habitacion
; y por tanto se ha producido un unico paso
(defrule paso_solo_una_hab
  (declare (salience 1))
  (activa ?h ?t)
  ?f <- (posible_paso ?h2 ?h ?t2)
  (not (mas_un_posible_paso ?h2 ?))
  =>
  (assert (paso ?h2 ?h ?t))
  (retract ?f)
)

; Regla para decidir si una habitacion esta inactiva
; debido a que se sabe con seguridad se ha producido
; un paso desde esta, y por tanto, pasa de parece_inactiva
; a inactiva
(defrule inactiva_paso_h
  (ultimo_registro movimiento ?h ?t) 
  (parece_inactiva ?h ?t)
  (paso ?h ? ?t2)
  (test (< ?t2 ?t))
  =>
  (assert (inactiva ?h ?t))
)

; Regla para comprobar que no se ha dado ningun paso
; ni tampoco mas de un posible paso y decidir que la 
; habitacion esta activa
(defrule activa_paso_h
  (ultimo_registro movimiento ?h ?t)
  (parece_inactiva ?h ?t)
  (not (paso ?h ? ?))
  (not (mas_un_posible_paso ?h ?))
  =>
  (assert (activa ?h ?t))
)

; -------------- Reglas para liberar BC ---------------------------

; Regla para eliminar un posible paso anterior
(defrule eliminar_posible_paso_ant
  ?f <- (posible_paso ?h1 ?h2 ?t1)
  (posible_paso ?h1 ?h2 ?t2)
  (test (< ?t1 ?t2))
  =>
  (retract ?f)
)

; Regla para eliminar un paso anterior
(defrule eliminar_paso_ant
  ?f <- (paso ?h1 ?h2 ?t1) 
  (paso ?h1 ?h2 ?t2)
  (test (< ?t1 ?t2))
  =>
  (retract ?f)
)

; Regla para eliminar un mas de un posible paso anterior
; de una habitacion
(defrule eliminar_mas_un_posible_paso_ant
  ?f <- (mas_un_posible_paso ?h ?t1) 
  (mas_un_posible_paso ?h ?t2)
  (test (< ?t1 ?t2))
  =>
  (retract ?f)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         REGLAS PARA GESTIONAR LOS ESTADOS DE LAS LUCES

; Regla para encender la luz en una habitacion cuando
; el sensor de movimiento esta activo y hay poca luminosidad
(defrule encender_hab_activa_poca_luz
  (Manejo_inteligente_luces ?h)
  (ultimo_registro movimiento ?h ?t)
  (activa ?h ?t) 
  (ultimo_registro luminosidad ?h ?t3)
  (valor_registrado ?t3 luminosidad ?h ?l)
  (luminosidadmedia ?h ?lux)
  (test (< ?l (/ ?lux 2)))
  =>
  (assert (encender_luz ?h ?t))
)

; Regla para apagar la luz en una habitacion si el sensor
; de movimiento esta inactivo
(defrule apagar_hab_inactiva
  (Manejo_inteligente_luces ?h)
  (ultimo_registro movimiento ?h ?t)
  (inactiva ?h ?t)
  =>
  (assert (apagar_luz ?h ?t))
)

; Regla para apagar la luz en una habitacion si hay mucha luminosidad
; aun teniendo en cuenta que el sensor de movimiento registra
; movimiento dentro de la habitacion
(defrule apagar_hab_mucha_luz
  (Manejo_inteligente_luces ?h)
  (ultimo_registro movimiento ?ht ?t)
  (activa ?h ?t)
  (ultimo_registro luminosidad ?h ?t3)
  (valor_registrado ?t3 luminosidad ?h ?l)
  (luminosidadmedia ?h ?lux)
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
