
; Autor: Vladislav Nikolov Vasilev

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Hechos iniciales

; Definicion de tiestos
(deffacts Tiestos
	(Tiesto Cactus)
	(Tiesto Tulipan)
	(Tiesto Palmera)
)

; Definicion de valores minimios de humedad de las plantas
; El valor de humedad ideal esta entre el minimo y el maximo
(deffacts HumedadesMin
	(HumedadMin Cactus 800)
	(HumedadMin Tulipan 750)
	(HumedadMin Palmera 700)
)

; Definicion de valores maximos de humedad
; El valor de humedad ideal esta entre el minimo y el maximo
(deffacts HumedadesMax
	(HumedadMax Cactus 600)
	(HumedadMax Tulipan 400)
	(HumedadMax Palmera 300)
)

; Definicion de valores criticos de humedad
; Si un tiesto baja de esta cantidad, tiene que ser regado obligatoriamente
(deffacts HumedadCritica
	(HumedadCrit Cactus 950)
	(HumedadCrit Tulipan 800)
	(HumedadCrit Palmera 750)
)

; Definicion de valores minimos de temperatura para las plantas
; El valor de temperatura ideal esta entre el minimo y el maximo
(deffacts TemperaturaMin
	(TemperaturaMin Cactus 15)
	(TemperaturaMin Tulipan 20)
	(TemperaturaMin Palmera 22)
)

; Definicion de valores maximos de temperatura para las plantas
; El valor de temperatura ideal esta entre el minimo y el maximo
(deffacts TemperaturaMax
	(TemperaturaMax Cactus 45)
	(TemperaturaMax Tulipan 27)
	(TemperaturaMax Palmera 30)
)

; Definicion de valores criticos de temperatura para las plantas
; A partir de este valor sera necesario vaporizar las plantas debido a las
; altas temperaturas a las que estan sometidas
(deffacts TemperaturaCrit
	(TemperaturaCrit Cactus 60)
	(TemperaturaCrit Tulipan 30)
	(TemperaturaCrit Palmera 37)
)

; Definicion de valores minimos de luminosidad para las plantas
; El valor de lumnosidad ideal esta entre el minimo y el maximo
; Esto indica que, si se excede este rango, es mas dificil que se de
; la posibilidad de regar la planta hasta que descienda a valores ideales
(deffacts LuzMin
	(LuminosidadMin Cactus 300)
	(LuminosidadMin Tulipan 250)
	(LuminosidadMin Palmera 350)
)

; Definicion de valores maximos de luminosidad para las plantas
; El valor de luminosidad ideal esta entre el minimo y el maximo
; Esto indica que, si se excede este rango, es mas dificil que se de
; la posibilidad de regar la planta hasta que descienda a valores ideales
(deffacts LuzMax
	(LuminosidadMax Cactus 650)
	(LuminosidadMax Tulipan 560)
	(LuminosidadMax Palmera 600)
)

; Definicion de la cantidad de humedad que aporta el riego
(deffacts CantidadHumedadRecibida
	(Regado 100)
)

; Valores iniciales de los sistemas de riego (desactivados)
(deffacts RegadoInit
	(regar Cactus off)
	(regar Tulipan off)
	(regar Palmera off)
)

; Definicion de la cantidad de temperatura que reduce el vaporizador
; por cada activacion
(deffacts CantidadTemperaturaReducida
	(Vaporizado 2)
)

; Valores iniciales de los sistemas de vaporizacion (desactivados)
(deffacts VaporizadoresInit
	(vaporizador Cactus off)
	(vaporizador Tulipan off)
	(vaporizador Palmera off)
)

; Valor inicial de la hora (se establece que son las 8 de la mañana)
; Las horas son enteros en el rango [0, 23] que se van repitiendo
(deffacts HoraInit
	(hora 8)
)

; Valor inicial asignado al estado de lluvia actual
; Se determina que actualmente no esta lloviendo
(deffacts LluviaInit
	(LluviaActual no)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Reglas para gestionar los datos de entrada de los sensores

; Regla para incluir un nuevo valor_registrado
; Inserta tambien un nuevo ultimo_registro
; El tiesto tiene que ser uno de los definidos
(defrule nuevo_registro
	(declare (salience 50))
	?f <- (valor ?tipo ?p ?v)
	(Tiesto ?p)
	=>
	(bind ?t (time))
	(printout t crlf "Registrado nuevo valor de tipo " ?tipo " para la planta " ?p " con valor " ?v crlf)
	(assert (valor_registrado ?t ?tipo ?p ?v))
	(assert (ultimo_registro ?tipo ?p ?t))
	(retract ?f)
)

; Regla para eliminar el anterior ultimo_registro
; del mismo tipo para un tiesto segun el tiempo
(defrule ultimo_reg
	(declare (salience 40))
	?f <- (ultimo_registro ?tipo ?p ?t1)
	(ultimo_registro ?tipo ?p ?t2)
	(test (< ?t1 ?t2))
	=>
	(retract ?f)
)

; Regla para eliminar la espera impuesta al sistema para que le llegue
; una nueva humedad
; El sistema tiene que esperar a recibir un nuevo valor de humedad
; una vez que ha regado
; De esta forma se evita que el sistema compruebe si tiene que regar de nuevo
; una planta habiéndolo hecho recientemente
(defrule eliminarEsperarHumedad
	(declare (salience 30))
	?f <- (esperar_humedad ?p ?t1)
	(ultimo_registro Humedad ?p ?t2)
	(test (!= ?t1 ?t2))		; Comprobar que ha llegado un nuevo registro
	=>
	(retract ?f)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Reglas para gestionar las horas y las predicciones de lluvia

; Regla para adelantar una hora el tiempo
; Incrementa la hora actual en una hora
(defrule siguienteHora
	?f <- (siguiente_hora)
	?g <- (hora ?h)
	=>
	(bind ?nuevaHora (mod (+ ?h 1) 24))		; La hora esta en el rango [0, 23]
	(printout t crlf "Se ha adelantado la hora. Ahora son las " ?nuevaHora " horas." crlf)
	(retract ?f)
	(retract ?g)
	(assert (hora ?nuevaHora))
)

; Regla para determinar si no hay lluvia prevista
; Se considera que no va a llover si la intensidad esta entre [0.0, 0.2) mm/h
(defrule calcularNoLluvia
	(declare (salience 50))
	?f <- (prevision_lluvia ?h ?int)
	(test (and (<= 0.0 ?int) (< ?int 0.2)))		; Comprobar pertenencia a [0.0, 0.2)
	=>
	(printout t crlf "Se prevee que no habra lluvia a las " ?h " horas" crlf)
	(assert (LluviaPrevista ?h no ?int))
	(retract ?f)
)

; Regla para determinar si la lluvia prevista es debil
; Una lluvia debil tiene una intesidad de [0.2, 6.5) mm/h
(defrule calcularLluviaDebil
	(declare (salience 50))
	?f <- (prevision_lluvia ?h ?int)
	(test (and (<= 0.2 ?int) (< ?int 6.5)))		; Comprobar pertenencia a [0.2, 6.5)
	=>
	(printout t crlf "Se prevee que habra lluvia debil a las " ?h " horas" crlf)
	(assert (LluviaPrevista ?h debil ?int))
	(retract ?f)
)

; Regla para determinar si la lluvia prevista es moderada
; Una lluvia moderada tiene una intesidad de [6.5, 15) mm/h
(defrule calcularLluviaMedio
	(declare (salience 50))
	?f <- (prevision_lluvia ?h ?int)
	(test (and (<= 6.5 ?int) (< ?int 15)))		; Comprobar pertenencia a [6.5, 15)
	=>
	(printout t crlf "Se prevee que habra lluvia moderada a las " ?h " horas" crlf)
	(assert (LluviaPrevista ?h moderada ?int))
	(retract ?f)
)

; Regla para determinar si la lluvia prevista es fuerte
; Una lluvia fuerte tiene una intesidad de [15, 100) mm/h
(defrule calcularLluviaFuerte
	(declare (salience 50))
	?f <- (prevision_lluvia ?h ?int)
	(test (and (<= 15 ?int) (< ?int 100)))		; Comprobar pertenencia a [15, 100)
	=>
	(printout t crlf "Se prevee que habra lluvia fuerte a las " ?h " horas" crlf)
	(assert (LluviaPrevista ?h fuerte ?int))
	(retract ?f)
)

; Regla para determinar si la lluvia prevista es torrencial
; Una lluvia torrencial tiene una intesidad de [100, infinito) mm/h
(defrule calcularLluviaTorrencial
	(declare (salience 50))
	?f <- (prevision_lluvia ?h ?int)
	(test (<= 100 ?int))						; Comprobar pertenencia a [100, infinito)
	=>
	(printout t crlf "Se prevee que habra lluvia torrencial a las " ?h " horas" crlf)
	(assert (LluviaPrevista ?h torrencial ?int))
	(retract ?f)
)

; Regla para modificar el valor de una prevision
(defrule modificarPrediccionLluvia
	?f <- (modificar_prevision ?h ?intNueva)
	?g <- (LluviaPrevista ?h ? ?int)			; Obtener prediccion anterior y eliminarla
	=>
	(printout t crlf "Se va a modificar la pradiccion de las " ?h " horas" crlf)
	(assert (prevision_lluvia ?h ?intNueva))	; Insertar nueva prediccion
	(retract ?f ?g)
)

; Regla para determinar si esta lloviendo en la hora actual
; Comienza a llover cuando en la hora h hay una prevision de lluvia
(defrule comenzarLluvia
	(hora ?h)
	?f <- (LluviaPrevista ?h ?tipo ?int)
	?g <- (LluviaActual ?)
	(test (neq ?tipo no))		; Comprobar que el tiepo de lluvia es distinto a 'no'
	=>
	(printout t crlf "Comienza a llover con intensidad " ?tipo crlf)
	(retract ?f ?g)
	(assert (LluviaActual ?tipo))
)

; Regla para determinar si durante la hora actual no esta lloviendo
; Determina si no va a llover en el momento actual o si ha parado de llover
(defrule pararLluvia
	(hora ?h)
	?f <- (LluviaPrevista ?h no ?)
	?g <- (LluviaActual ?)			; Obtener y eliminar anterior estado de lluvia
	=>
	(printout t crlf "Durante esta hora no llueve" crlf)
	(retract ?f ?g)
	(assert (LluviaActual no))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Reglas para gestionar el calculo de cuando se va a producir la siguiente
; lluvia

; Regla que sirve como contador para ir comprobando cuando se va a producir la
; siguiente lluvia
; Recorre los hechos LluviaPrevista en orden hasta que o bien el valor de ?cont
; (el contador) llegue a 0 o hasta que se encuentre con alguna LLuviaPrevista
; cuyo tipo es distinto a 'no' (es decir, que este prevista lluvia)
; ------------------------------------------------------------------------------
; MUY IMPORTANTE: PARA QUE FUNCIONE CORRECTAMENTE, TIENEN QUE ESTAR
; LAS PREDICCOINES DE TODAS LAS HORAS PARA QUE EL SISTEMA SEPA QUE TIEMPO
; VA A HACER
(defrule contador
	(modulo CalculoSiguienteLluvia)			; Comprobar que esta activo el modulo de calculo de la siguiente lluvia
	?f <- (Contador ?h ?cont)
	(test (> ?cont 0))						; Comprobar que el contador no ha acabado

	; Obtener la lluvia y comprobar que es de tipo 'no' para seguir
	; comprobando los siguientes hechos
	(LluviaPrevista ?h ?tipo ?int)
	(test (eq ?tipo no))
	=>
	(bind ?sigHora (mod (+ ?h 1) 24))
	(bind ?nuevoCont (- ?cont 1))
	(retract ?f)
	(assert (Contador ?sigHora ?nuevoCont))
)

; Regla para determinar si se va a producir una lluvia en la hora ?h
; Se comprueba independientemente de cual sea el valor de ?contador,
; ya que puede ser tanto el primer como ultimo hecho a comprobar
(defrule contadorSiguienteLluvia
	?f <- (modulo CalculoSiguienteLluvia)	; Comprobar que esta activo el modulo de calculo de la siguiente lluvia (se desactiva luego)
	?g <- (Contador ?h ?cont)				; Obtener la hora

	; Obtener la LluviaPrevista en esa hora y ver si es de un tipo distino
	; a 'no' (es decir, que va a llover)
	(LluviaPrevista ?h ?tipo ?int)
	(test (neq ?tipo no))
	=>
	(retract ?f ?g)
	(assert (SiguienteLluvia ?tipo ?h))
	(assert (modulo Riego))					; Activar el modulo de riego
)

; Regla para determinar que no se va a producir lluvia en el intervalo
; de 8 horas que se le ha especificado
; Si se han comprobado ltodos los hechos y en el ultimo hecho se ve
; que no va a llover, se deduce que no se va a producir una lluvia durante
; el intervalo de 8 horas posterior a la hora actual
(defrule contadorNoLluvia
	?f <- (modulo CalculoSiguienteLluvia)	; Comprobar que esta activo el modulo de calculo de la siguiente lluvia (se desactiva luego)

	; Comprobar que el contador ha llegado a 0
	; Esto significa que se han inspeccionado los hechos anteriores
	; y no se ha determinado que vaya a llover
	?g <- (Contador ?h ?cont)
	(test (= ?cont 0))

	; Obtener la LluviaPrevista en esa hora y ver si es de tipo 'no',
	; es decir, que no va a llover
	(LluviaPrevista ?h ?tipo ?int)
	(test (eq ?tipo no))
	=>
	(retract ?f ?g)							; Eliminar hecho contador y desactivar modulo CalculoSiguienteLluvia
	(assert (SiguienteLluvia no 0))
	(assert (modulo Riego))					; Activar el modulo de riego
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Reglas para gestionar el riego de las plantas

; Regla encargada de decidir si regar una planta o no y en que cantidad
; Utiliza un sistema difuso externo que le permite calcular cuanto debe
; regar la planta en concreto
; Esta regla solo se puede activar si no se ha activado el regado para dicha planta
; y no hay una vaporizacion activa en esa planta
; Tampoco se puede activar si llueve o si se ha regado recientemente
(defrule calcularRegarPlanta
	; Comprobar que no esta activado el regado y la caporizacion para la planta
	(regar ?p off)
	(vaporizador ?p off)

	; Comprobar que no esta lloviendo actualmente
	(LluviaActual no)

	; Comprobar que no se tiene que esperar para que le llegue una nueva humedad
	; Esto es, evitar que se active la regla si se ha regado recientemente, evitando
	; una comprobacion extra
	; Cuando le llega una nueva humedad se puede volver a activar
	; Si se decide no regar la planta, no hay problema, ya que la regla se ha
	; activado con una humedad que no ha cambiado
	(not (esperar_humedad ?p ?))

	; Obtener ultimos valores registrados de humedad, temperatura y luminosidad
	(ultimo_registro Humedad ?p ?t)
	(valor_registrado ?t Humedad ?p ?hum)
	(ultimo_registro Temperatura ?p ?t2)
	(valor_registrado ?t2 Temperatura ?p ?tmp)
	(ultimo_registro Luminosidad ?p ?t3)
	(valor_registrado ?t3 Luminosidad ?p ?lum)

	; Obtener valores maximos, minimos y criticos de humedad, temperatura y luminosidad
	(HumedadMin ?p ?humMin)
	(HumedadMax ?p ?humMax)
	(HumedadCrit ?p ?humCrit)
	(TemperaturaMin ?p ?tmpMin)
	(TemperaturaMax ?p ?tmpMax)
	(TemperaturaCrit ?p ?tmpCrit)
	(LuminosidadMin ?p ?lumMin)
	(LuminosidadMax ?p ?lumMax)

	; Obtener la hora actual
	(hora ?hora)
	=>
	(printout t crlf "El sistema va a razonar sobre la necesidad de regar o no la planta " ?p "..." crlf)

	; Escribir datos en un fichero para que el sistema difuso los pueda usar
	(open "DatosSistema.txt" data "w")
	(printout data ?humMin " " ?humMax " " ?humCrit " " ?tmpMin " " ?tmpMax " "
		?tmpCrit " " ?lumMin " " ?lumMax " " ?hum " " ?tmp " " ?lum crlf)
	(close data)

	; Llamar al sistema difuso para que determine cuanto se debe regar
	; con los datos proporcionados anteriormente
	(system "python3 fuzzy.py")

	; Obtener informacion calculada por el sistema difuso
	(open "DatosDeducidos.txt" data)
	(bind ?l1 (read data))
	(bind ?l2 (read data))
	(bind ?l3 (read data))
	(close data)

	(printout t "El sistema ha deducido lo siguiente sobre el riego de la planta" ?p ":" crlf)
	(printout t "- Activacion/Intensidad del riego: " ?l2 crlf)
	(printout t "- Valor de humedad ideal a conseguir: " ?l3 crlf)

	; Insertar los resultados obtenidos por el sistema difuso en la base del conocimiento
	(assert (riego ?p ?l2 ?l3))
	(printout t "El sistema va a comprobar las previsiones de lluvia en las 8 siguientes horas..." crlf)

	; Asignar hora inicial del contador (una mas que la actual)
	(bind ?sigHora (mod (+ ?hora 1) 24))

	; Activar modulo para deducir cuando será la siguiente lluvia
	(assert (modulo CalculoSiguienteLluvia))

	; Inicializar proceso de deduccion, buscando la lluvia en las 8 horas
	; siguients a la actual
	(assert (Contador ?sigHora 7))
)

; Regla que permite salir del modulo Riego si se ha decidido no regar
; Tiene mas prioridad que el resto, ya que si no hace falta regar, no
; hace falta realizar mas operaciones en el modulo
; Elimina tambien el valor deducido de SiguienteLluvia y el riego deducido
(defrule riegoNo
	(declare (salience 20))
	?f <- (modulo Riego)
	?g <- (riego ?p no ?)
	?h <- (SiguienteLluvia ? ?)
	=>
	(printout t crlf "El sistema ha decidido no regar la planta " ?p " debido a que su humedad "
	"estaba en el rango ideal de humedad, era superior a este o se va a producir una lluvia torrencial pronto"
	" y el valor de humedad no es criticamente bajo" crlf)
	(retract ?f ?g ?h)
)

; Regla que permite activar el riego de intensidad baja
; El riego de baja intensidad situa la humedad aproximadamente
; un poco por encima de la humedad minima necesaria (un cuarto del rango
; de humedad ideal por encima del minimo)
(defrule riegoBajo
	(modulo Riego)						; Comprobar que el modulo activo es Riego
	?f <- (riego ?p bajo ?humIdeal)
	?g <- (regar ?p off)
	=>
	(printout t crlf "El sistema ha decidido realizar un riego de baja intensidad para la planta " ?p
	" debido a que su humedad era baja, las condiciones de luminosidad/temperatura "
	"no le son favorables o va a llover de forma fuerte en las proximas horas y la humedad de la planta"
	" era demasiado bajo como para esperar a la lluvia" crlf)

	; Indicar que se activa el riego para conseguir la humedad dada por ?humIdeal
	(assert (regar ?p on ?humIdeal))
	(retract ?f ?g)
)

; Regla que permite activar el riego de intensidad media
; El riego de media intensidad situa la humedad aproximadamente
; un poco por encima de la humedad media del rango ideal (un cuarto del rango
; de humedad ideal por debajo del maximo)
(defrule riegoMedio
	(modulo Riego)						; Comprobar que el modulo activo es Riego
	?f <- (riego ?p medio ?humIdeal)
	?g <- (regar ?p off)
	=>
	(printout t crlf "El sistema ha decidido realizar un riego de intensidad media para la planta " ?p
	" debido a que su humedad era baja y las condiciones de luminosidad/temperatura "
	"le eran ciertamente favorables para conseguir una humedad en el rango ideal" crlf)

	; Indicar que se activa el riego para conseguir la humedad dada por ?humIdeal
	(assert (regar ?p on ?humIdeal))
	(retract ?f ?g)
)

; Regla que permite activar el riego de intensidad alta
; El riego de alta intensidad situa la humedad aproximadamente
; un poco por encima del rango de humedad ideal (un cuarto del rango
; de humedad ideal por encima del maximo)
(defrule riegoAlto
	(modulo Riego)						; Comprobar que el modulo activo es Riego
	?f <- (riego ?p alto ?humIdeal)
	?g <- (regar ?p off)
	=>
	(printout t crlf "El sistema ha decidido realizar un riego de alta intensidad para la planta " ?p
	" debido a que su humedad era baja y las condiciones de luminosidad/temperatura "
	"le son favorables" crlf)

	; Indicar que se activa el riego para conseguir la humedad dada por ?humIdeal
	(assert (regar ?p on ?humIdeal))
	(retract ?f ?g)
)

; Regla para comprobar que el valor deducido de lluvia es debil
; Ofrece una explicacion e indica que no se va a modificar el riego
; que se va a realizar, debido a que la cantidad de humedad que aportara
; la lluvia es muy poca
(defrule modificarRiegoLluviaDebil
	(declare (salience 10))
	(modulo Riego)
	?f <- (SiguienteLluvia debil ?hora)
	=>
	(printout t crlf "El sistema ha detectado que se producirá una lluvia de "
	"intensidad débil a las " ?hora " horas. Por tanto, no se modificará la "
	"intensidad del riego debido a que la lluvia no aportará mucha humedad extra" crlf)
	(retract ?f)
)

; Regla que permite modificar el riego cuando se produce lluvia de intensidad moderada
; Si la intensidad del riego es alto, se baja a medio, ya que habra un extra
; de humedad por la lluvia
; Todas las otras intensidad de riego se dejan igual
(defrule modificarRiegoAltoLluviaModerada
	(declare (salience 10))
	(modulo Riego)						; Comprobar que el modulo activo es Riego

	; Comprobar que la intens. del riego es alta y la lluvia sera moderada
	?f <- (riego ?p alto ?humIdeal)
	?g <- (SiguienteLluvia moderada ?hora)

	; Obtener valores minimos y maximos de humedad
	(HumedadMax ?p ?max)
	(HumedadMin ?p ?min)
	=>
	(printout t crlf "El sistema ha decidido modificar la intensidad del riego (alta) "
	"calculada por una más baja debido a la prediccion de lluvia de intensidad "
	"moderada a las " ?hora " horas" crlf)

	; Calcular valor del rango de [humedad_min, humedad_max]
	(bind ?rangoMinMax (abs (- ?max ?min)))

	; Calcular el incremento (cuanto se modificara la humedad)
	(bind ?inc (integer (/ ?rangoMinMax 4)))

	; Calcular nueva humeda objetivo (un cuarto del rango por debajo del maximo)
	(bind ?nuevaHum  (+ ?max ?inc))

	(printout t "La nueva intensidad del riego será media y tendrá una humedad objetivo de " ?nuevaHum crlf)
	(retract ?f ?g)

	; Insertar en el conocimiento el nuevo riego que se va a hacer
	(assert (riego ?p medio ?nuevaHum))
)

; Regla que permite modificar el riego cuando se produce lluvia de intensidad fuerte
; Si la intensidad del riego es alto, se baja a bajo, ya que habra un extra
; de humedad por la lluvia
; Solo se deja igual la intensidad de riego baja
(defrule modificarRiegoAltoLluviaFuerte
	(declare (salience 10))
	(modulo Riego)						; Comprobar que el modulo activo es Riego

	; Comprobar que la intens. del riego es alta y la lluvia sera fuerte
	?f <- (riego ?p alto ?humIdeal)
	?g <- (SiguienteLluvia fuerte ?hora)

	; Obtener valores minimos y maximos de humedad
	(HumedadMax ?p ?max)
	(HumedadMin ?p ?min)
	=>
	(printout t crlf "El sistema ha decidido modificar la intensidad del riego (alta) "
	"calculada por una más baja debido a la prediccion de lluvia de intensidad "
	"fuerte a las " ?hora " horas" crlf)

	; Calcular valor del rango de [humedad_min, humedad_max]
	(bind ?rangoMinMax (abs (- ?max ?min)))

	; Calcular el incremento (cuanto se modificara la humedad)
	(bind ?inc (integer (/ ?rangoMinMax 4)))

	; Calcular nueva humeda objetivo (un cuarto del rango por encima del minimo)
	(bind ?nuevaHum  (- ?min ?inc))

	(printout t "La nueva intensidad del riego será baja y tendrá una humedad objetivo de " ?nuevaHum crlf)
	(retract ?f ?g)

	; Insertar en el conocimiento el nuevo riego que se va a hacer
	(assert (riego ?p bajo ?nuevaHum))
)

; Regla que permite modificar el riego cuando se produce lluvia de intensidad fuerte
; Si la intensidad del riego es medio, se baja a bajo, ya que habra un extra
; de humedad por la lluvia
; Solo se deja igual la intensidad de riego baja
(defrule modificarRiegoMedioLluviaFuerte
	(declare (salience 10))
	(modulo Riego)						; Comprobar que el modulo activo es Riego

	; Comprobar que la intens. del riego es alta y la lluvia sera fuerte
	?f <- (riego ?p alto ?humIdeal)
	?g <- (SiguienteLluvia fuerte ?hora)

	; Obtener valores minimos y maximos de humedad
	(HumedadMax ?p ?max)
	(HumedadMin ?p ?min)
	=>
	(printout t crlf "El sistema ha decidido modificar la intensidad del riego (alta) "
	"calculada por una más baja debido a la prediccion de lluvia de intensidad "
	"fuerte a las " ?hora " horas" crlf)

	; Calcular valor del rango de [humedad_min, humedad_max]
	(bind ?rangoMinMax (abs (- ?max ?min)))

	; Calcular el incremento (cuanto se modificara la humedad)
	(bind ?inc (integer (/ ?rangoMinMax 4)))

	; Calcular nueva humeda objetivo (un cuarto del rango por encima del minimo)
	(bind ?nuevaHum  (- ?min ?inc))

	(printout t "La nueva intensidad del riego será baja y tendrá una humedad objetivo de " ?nuevaHum crlf)
	(retract ?f ?g)

	; Insertar en el conocimiento el nuevo riego que se va a hacer
	(assert (riego ?p bajo ?nuevaHum))
)

; Regla que permite modificar el riego cuando se produce lluvia de intensidad torrencial
; Si anteriormente se habia deducido que se tenia que regar la planta, se modifica
; esa deduccion para que no se riegue la planta si su humedad no ha bajado del valor critico
; ya que la lluvia torrencial haria que la humedad de la planta aumentase mucho
; Adicionalmente, se sale del modulo Riego, ya que no se va a regar la planta
(defrule modificarRiegoLluviaTorrencialNo
	(declare (salience 10))
	?f <- (modulo Riego)			; Comprobar que el modulo activo es Riego

	; Comprobar que la lluvia sera torrencial y obtener el riego deducido anteriormente
	?g <- (riego ?p ?tipo ?humIdeal)
	?h <- (SiguienteLluvia torrencial ?hora)

	; Obtener humedad critica y ultimo registro de humedad
	(HumedadCrit ?p ?crit)
	(ultimo_registro Humedad ?p ?t)
	(valor_registrado ?t Humedad ?p ?hum)

	; Comprobar que no se excede la humedad critica
	(test (< ?hum ?crit))
	=>
	(printout t crlf "El sistema ha decidido modificar la intensidad del riego (" ?tipo ") "
	"calculada por una más baja debido a la prediccion de lluvia de intensidad "
	"torrencial a las " ?hora " horas" crlf)
	(printout t "El sistema no regará la planta debido a que su humedad (" ?hum ") "
	"no está por debajo del crítico (" ?crit ")" crlf)
	(retract ?f ?g ?h)		; Salir del modulo Riego y eliminar deducciones de lluvia y riego
)

; Regla que permite modificar el riego cuando se produce lluvia de intensidad torrencial
; Si anteriormente se habia deducido que se tenia que regar la planta, se modifica
; esa deduccion para que se riegue con intensidad baja si su humedad esta por debajo
; del valor critico ya que la lluvia torrencial haria que la humedad de la planta aumentase mucho
(defrule modificarRiegoLluviaTorrencialBajo
	(declare (salience 10))
	(modulo Riego)					; Comprobar que el modulo activo es Riego

	; Comprobar que la lluvia sera torrencial y obtener el riego deducido anteriormente
	?f <- (riego ?p ?tipo ?humIdeal)
	?g <- (SiguienteLluvia torrencial ?hora)

	; Obtener valores maximo, minimo y critico de humedad y ultimo registro de humedad
	(HumedadMax ?p ?max)
	(HumedadMin ?p ?min)
	(HumedadCrit ?p ?crit)
	(ultimo_registro Humedad ?p ?t)
	(valor_registrado ?t Humedad ?p ?hum)

	; Comprobar que se excede la humedad critica
	(test (>= ?hum ?crit))
	=>
	(printout t crlf "El sistema ha decidido modificar la intensidad del riego (" ?tipo ") "
	"calculada por una más baja debido a la prediccion de lluvia de intensidad "
	"torrencial a las " ?hora " horas" crlf)

	; Calcular valor del rango de [humedad_min, humedad_max]
	(bind ?rangoMinMax (abs (- ?max ?min)))

	; Calcular el incremento (cuanto se modificara la humedad)
	(bind ?inc (integer (/ ?rangoMinMax 4)))

	; Calcular nueva humeda objetivo (un cuarto del rango por encima del minimo)
	(bind ?nuevaHum  (- ?min ?inc))

	(printout t "El sistema regará la planta con una intensidad baja debido a que su humedad (" ?hum ") "
	"está por debajo del crítico (" ?crit ")" crlf)
	(printout t "La humedad a alcanzar tiene valor de " ?nuevaHum crlf)
	(retract ?f ?g)

	; Insertar en el conocimiento el nuevo riego que se va a hacer
	(assert (riego ?p bajo ?nuevaHum))
)

; Regla para regar las plantas
; Modifica el valor de humedad de la planta
(defrule regarPlanta
	(modulo Riego)						; Comprobar que el modulo activo es Riego

	; Obtener humedad objetivo para la planta e incremento de la humedad
	; por cada riego que se hace
	(regar ?p on ?humObj)
	(Regado ?inc)

	; Obtener ultimos valores registrados de humnedad
	(ultimo_registro Humedad ?p ?t)
	(valor_registrado ?t Humedad ?p ?hum)
	=>
	(bind ?dif (- ?hum ?humObj))			; Calcular cuanto queda para llegar a la humedad indicada

	; Determinar cuanto regar para no pasarse de la humedad indicada
	; (es el minimo de ?inc y lo que quede para llegar a la humedad ideal)
	(bind ?cantRegado (min ?inc ?dif))
	(bind ?newHum (- ?hum ?cantRegado))
	(printout t crlf "Regando " ?p ". Se incrementa su humedad en " ?cantRegado crlf)

	; Insertar nuevo valor de humedad para el sensor
	(assert (valor Humedad ?p ?newHum))
)

; Regla para detener el regado de la planta
; Detiene el regado de las plantas una vez que se ha llegado al valor objetivo
; o se ha excedido
(defrule detenerRegarPlanta
	(declare (salience 10))
	?f <- (modulo Riego)				; Comprobar que el modulo activo es Riego para desactivarlo luego
	?g <- (regar ?p on ?humObj)

	; Obtener ultimo valor registrado de humedad y comprobar que
	; se ha llegado a la humedad objetivo
	(ultimo_registro Humedad ?p ?t)
	(valor_registrado ?t Humedad ?p ?hum)
	(test (<= ?hum ?humObj))
	=>
	(printout t crlf "Se deja de regar la planta " ?p " porque ha llegado a "
	"la humedad adecuada, con un valor de " ?hum crlf)
	(retract ?f ?g)						; Desactivar modulo Riego

	; Indicar que se ha apagado el regado
	(assert (regar ?p off))

	; Indicar que se espera un nuevo valor de humedad antes de activar de nuevo
	; la regla para deducir que se tiene que regar
	(assert (esperar_humedad ?p ?t))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Reglas para gestionar la vaporizacion de las plantas

; Regla que permite deducir si se debe vaporizar una planta o no
; Si se supera la temperatura critica, esta debe ser vaporizada
; En caso contrario, no se deduce nada
; La vaporizacion tiene mayor prioridad que el regado con el objetivo
; de que la temperatura siempre sea menor antes de regar, para asi
; ver si se puede regar mas
; El valor al que se vaporiza es a (temp_max + temp_min) / 2, es decir,
; al valor central, el cual es un valor ideal de temperatura
(defrule calcularVaporizarPlanta
	(declare (salience 10))
	(regar ?p off)								; Ver si no se esta regando la planta
	(LluviaActual no)							; Para vaporizar no debe llover
	?f <- (vaporizador ?p off)					; Ver que el vaporizador de la planta esta desactivado (se activa luego)
	(ultimo_registro Temperatura ?p ?t)
	(valor_registrado ?t Temperatura ?p ?temp)	; Obtener ultimo valor de la temperatura

	; Obtener valores minimo, maximo y critico de las temperaturas para la planta
	(TemperaturaCrit ?p ?crit)
	(TemperaturaMin ?p ?min)
	(TemperaturaMax ?p ?max)

	(test (> ?temp ?crit))						; Comprobar que la temperatura es superior a la critica
	=>
	(printout t crlf "El sistema ha detectado que la temperatura del tiesto de la "
	"planta " ?p " es de " ?temp "ºC, valor por encima del maximo permitido "
	?crit "ºC." crlf)

	; Calcular la temperatura ideal como aquella que se encuentra en medio
	; de la temperatura minima y la maxima
	(bind ?tempIdeal (integer (/ (+ ?max ?min) 2)))

	(printout t "El sistema ha decidido vaporizar la planta " ?p " para reducir "
	"su temperatura a " ?tempIdeal "ºC, valor que se encuentra en el rango de "
	"temperatura ideal" crlf)
	(retract ?f)
	(assert (vaporizador ?p on ?tempIdeal))		; Activar vaporizado
	(assert (modulo Vaporizacion))				; Activar modulo de vaporizacion
)

; Regla para vaporizar las plantas
; Modifica el valor de temperatura de la planta de forma gradual
(defrule vaporizarPlanta
	(modulo Vaporizacion)
	(vaporizador ?p on ?tempIdeal)
	(Vaporizado ?cambio)						; Obtener valor de variacion de la temperatura con cada vaporizacion
	(ultimo_registro Temperatura ?p ?t)
	(valor_registrado ?t Temperatura ?p ?temp)	; Obtener ultimo valor medido de la temperatura
	=>
	(bind ?dif (- ?temp ?tempIdeal))			; Calcular cuanto queda para llegar a la temperatura indicada

	; Determinar cuanto vaporizar para no pasarse de la temperatura indicada
	; (es el minimo de ?cambio y lo que quede para llegar a la temperatura ideal)
	(bind ?cantReducido (min ?cambio ?dif))
	(bind ?newTemp (- ?temp ?cantReducido))		; Determinar nueva temperatura
	(printout t crlf "Reduciendo la temperatura de " ?p " en " ?cantReducido "ºC" crlf)

	; Insertar nuevo valor de temperatura para el sensor
	(assert (valor Temperatura ?p ?newTemp))
)

; Regla para detener la vaporizacion de la planta
; Detiene la vaporizacion de las plantas una vez que se ha llegado al valor objetivo
; de temperatura o se ha excedido
(defrule detenerVaporizadoPlanta
	(declare (salience 10))
	?f <- (modulo Vaporizacion)					; Comprobar que el modulo activo es Vaporizacion para desactivarlo
	?g <- (vaporizador ?p on ?tempIdeal)
	(ultimo_registro Temperatura ?p ?t)
	(valor_registrado ?t Temperatura ?p ?temp)	; Obtener ultimo valor medido de la temperatura
	(test (<= ?temp ?tempIdeal))				; Comprobar si se ha llegado a la temperatura deseada
	=>
	(printout t crlf "Se deja de vaporizar la planta " ?p " porque ha llegado a "
	"la temperatura adecuada, con un valor de " ?tempIdeal "ºC" crlf)
	(retract ?f ?g)
	(assert (vaporizador ?p off))				; Indicar que se ha desactivado la vaporizacion
)
