
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
; por cada vez que se activa
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
; El sistema tiene que esperar a recibir un nuevo valor de humedad antes
; de volver a intentar deducir si tiene o no que regar
; Con esta regla se elimina este hecho y se permite al sistema deducir si regar
; o no
(defrule eliminarEsperarHumedad
	(declare (salience 30))
	?f <- (esperar_humedad ?p ?t1)
	(ultimo_registro Humedad ?p ?t2)
	(test (!= ?t1 ?t2))
	=>
	(retract ?f)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Reglas para gestionar las horas y las predicciones

; Regla para adelantar una hora el tiempo
; Incrementa la hora actual en una hora
(defrule siguienteHora
	?f <- (siguiente_hora)
	?g <- (hora ?h)
	=>
	(bind ?nuevaHora (mod (+ ?h 1) 24))
	(printout t crlf "Se ha adelantado la hora. Ahora son las " ?nuevaHora " horas." crlf)
	(retract ?f)
	(retract ?g)
	(assert (hora ?nuevaHora))
)

; Regla para cambiar la hora a la deseada
; Se establece la hora a la deseada
(defrule adelantarTiempo
	?f <- (cambiar_hora ?nuevaHora)
	?g <- (hora ?h)
	=>
	(printout t crlf "Se ha cambiado la hora manualmente. Ahora son las " ?nuevaHora " horas." crlf)
	(retract ?g)
	(assert (hora ?nuevaHora))
	(retract ?f)
)

; Regla para determinar si no hay lluvia prevista
; Se considera que no va a llover si la intensidad esta entre [0.0, 0.2) mm/h
(defrule calcularNoLluvia
	(declare (salience 50))
	?f <- (prevision_lluvia ?h ?int)
	(test (and (<= 0.0 ?int) (< ?int 0.2)))
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
	(test (and (<= 0.2 ?int) (< ?int 6.5)))
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
	(test (and (<= 6.5 ?int) (< ?int 15)))
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
	(test (and (<= 15 ?int) (< ?int 100)))
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
	(test (<= 100 ?int))
	=>
	(printout t crlf "Se prevee que habra lluvia torrencial a las " ?h " horas" crlf)
	(assert (LluviaPrevista ?h torrencial ?int))
	(retract ?f)
)

; Regla para modificar el valor de una prediccion
(defrule modificarPrediccionLluvia
	?f <- (modificar_prediccion ?h ?intNueva)
	?g <- (LluviaPrevista ?h ? ?int)
	=>
	(printout t crlf "Se va a modificar la pradiccion de las " ?h " horas" crlf)
	(assert (prevision_lluvia ?h ?intNueva))
	(retract ?f ?g)
)

; Regla que comienza la lluvia
; Comienza a llover cuando en la hora h hay una prevision de lluvia
(defrule comenzarLluvia
	(hora ?h)
	?f <- (LluviaPrevista ?h ?tipo ?int)
	?g <- (LluviaActual ?)
	(test (neq ?tipo no))
	=>
	(printout t crlf "Comienza a llover con intensidad " ?tipo crlf)
	(retract ?f ?g)
	(assert (LluviaActual ?tipo))
)

; Regla que indica que para la lluvia o que no va a llover durante la hora h
(defrule pararLluvia
	(hora ?h)
	?f <- (LluviaPrevista ?h no ?)
	?g <- (LluviaActual ?)
	=>
	(printout t crlf "Durante esta hora no llueve" crlf)
	(retract ?f ?g)
	(assert (LluviaActual no))
)

; Regla para determinar cual es la proxima prevision de lluvia en las proximas
; horas
; Se le tiene que especificar cual es el numero maximo de horas que tiene
; que comprobar
(defrule contadorSiguienteLluvia
	(declare (salience 100))
	?f <- (modulo CalculoSiguienteLluvia)
	?g <- (Contador ?h ?cont)
	(LluviaPrevista ?h ?tipo ?int)
	(test (neq ?tipo no))
	=>
	(retract ?f ?g)
	(assert (SiguienteLLuvia ?tipo ?h))
	(assert (modulo Riego))
)

(defrule contador
	(modulo CalculoSiguienteLluvia)
	?f <- (Contador ?h ?cont)
	(test (> ?cont 0))
	(LluviaPrevista ?h ?tipo ?int)
	(test (eq ?tipo no))
	=>
	(bind ?sigHora (mod (+ ?h 1) 24))
	(bind ?nuevoCont (- ?cont 1))
	(retract ?f)
	(assert (Contador ?sigHora ?nuevoCont))
)

(defrule contadorNoLluvia
	(modulo CalculoSiguienteLluvia)
	?f <- (modulo CalculoSiguienteLluvia)
	?g <- (Contador ?h ?cont)
	(test (= ?cont 0))
	(LluviaPrevista ?h ?tipo ?int)
	(test (eq ?tipo no))
	=>
	(retract ?f ?g)
	(assert (SiguienteLluvia no 0))
	(assert (modulo Riego))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Reglas para gestionar el riego de las plantas

; Regla encargada de deducir cual es el momento mas adecuado para regar
; las plantas. Normalmente lo hace cuando se baja del valor de HumedadCrit
; que tiene asociada la planta
(defrule calcularRegarPlanta
	(regar ?p off)
	(vaporizador ?p off)
	(LluviaActual no)
	(Tiesto ?p)
	(not (esperar_humedad ?p ?))

	(ultimo_registro Humedad ?p ?t)
	(valor_registrado ?t Humedad ?p ?hum)

	(ultimo_registro Temperatura ?p ?t2)
	(valor_registrado ?t2 Temperatura ?p ?tmp)

	(ultimo_registro Luminosidad ?p ?t3)
	(valor_registrado ?t3 Luminosidad ?p ?lum)

	(HumedadMin ?p ?humMin)
	(HumedadMax ?p ?humMax)
	(HumedadCrit ?p ?humCrit)
	(TemperaturaMin ?p ?tmpMin)
	(TemperaturaMax ?p ?tmpMax)
	(TemperaturaCrit ?p ?tmpCrit)
	(LuminosidadMin ?p ?lumMin)
	(LuminosidadMax ?p ?lumMax)

	(hora ?hora)
	=>
	(printout t crlf "El sistema va a razonar sobre la necesidad de regar o no la planta " ?p "..." crlf)

	(open "DatosSistema.txt" data "w")
	(printout data ?humMin " " ?humMax " " ?humCrit " " ?tmpMin " " ?tmpMax " "
		?tmpCrit " " ?lumMin " " ?lumMax " " ?hum " " ?tmp " " ?lum crlf)
	(close data)

	(system "python3 fuzzy.py")

	(open "DatosDeducidos.txt" data)
	(bind ?l1 (read data))
	(bind ?l2 (read data))
	(bind ?l3 (read data))
	(close data)

	(printout t "El sistema ha deducido lo siguiente sobre el riego de la planta" ?p ":" crlf)
	(printout t "Activacion/Intensidad del riego: " ?l2 crlf)
	(printout t "Valor de humedad ideal a conseguir: " ?l3 crlf)
	(assert (riego ?p ?l2 ?l3))
	(assert (modulo CalculoSiguienteLluvia))
	(printout t "El sistema va a comprobar las previsiones de lluvia en las 8 siguientes horas..." crlf)
	(bind ?sigHora (mod (+ ?hora 1) 24))
	(assert (Contador ?sigHora 8))
)

(defrule riegoNo
	(declare (salience 20))
	?f <- (modulo Riego)
	?g <- (riego ?p no ?)
	?h <- (SiguienteLLuvia ? ?)
	=>
	(printout t crlf "El sistema ha decidido no regar la planta " ?p " debido a que su humedad "
	"estaba en el rango ideal de humedad o era superior a este" crlf)
	(retract ?f ?g ?h)
)

(defrule riegoBajo
	(modulo Riego)
	?f <- (riego ?p bajo ?humIdeal)
	?g <- (regar ?p off)
	=>
	(printout t crlf "El sistema ha decidido realizar un riego de baja intensidad para la planta " ?p
	" debido a que su humedad era baja y las condiciones de luminosidad/temperatura "
	"no le son favorables" crlf)
	(assert (regar ?p on ?humIdeal))
	(retract ?f ?g)
)

(defrule riegoMedio
	(modulo Riego)
	?f <- (riego ?p medio ?humIdeal)
	?g <- (regar ?p off)
	=>
	(printout t crlf "El sistema ha decidido realizar un riego de intensidad media para la planta " ?p
	" debido a que su humedad era baja y las condiciones de luminosidad/temperatura "
	"le eran un poco favorables" crlf)
	(assert (regar ?p on ?humIdeal))
	(retract ?f ?g)
)

(defrule riegoAlto
	(modulo Riego)
	?f <- (riego ?p alto ?humIdeal)
	?g <- (regar ?p off)
	=>
	(printout t crlf "El sistema ha decidido realizar un riego de alta intensidad para la planta " ?p
	" debido a que su humedad era baja y las condiciones de luminosidad/temperatura "
	"le son favorables" crlf)
	(assert (regar ?p on ?humIdeal))
	(retract ?f ?g)
)

; Regla que permite modificar
(defrule modificarRiegoLluviaDebil
	(declare (salience 10))
	(modulo Riego)
	?f <- (SiguienteLLuvia debil ?hora)
	=>
	(printout t crlf "El sistema ha detectado que se producirá una lluvia de "
	"intensidad débil a las " ?hora " horas. Por tanto, no se modificará la "
	"intensidad del riego debido a que la lluvia no aportará mucha humedad extra" crlf)
	(retract ?f)
)

; Regla que permite modificar
(defrule modificarRiegoAltoLluviaModerada
	(declare (salience 10))
	(modulo Riego)
	?f <- (riego ?p alto ?humIdeal)
	?g <- (SiguienteLLuvia moderada ?hora)
	(HumedadMax ?p ?max)
	(HumedadMin ?p ?min)
	=>
	(printout t crlf "El sistema ha decidido modificar la intensidad del riego (alta) "
	"calculada por una más baja debido a la prediccion de lluvia de intensidad "
	"moderada a las " ?hora " horas" crlf)
	(bind ?rangoMinMax (abs (- ?max ?min)))
	(bind ?inc (integer (/ ?rangoMinMax 4)))
	(bind ?nuevaHum  (+ ?max ?inc))
	(printout t "La nueva intensidad del riego será media y tendrá una humedad objetivo de " ?nuevaHum crlf)
	(retract ?f ?g)
	(assert (riego ?p medio ?nuevaHum))
)

; Regla que permite modificar
(defrule modificarRiegoAltoLluviaFuerte
	(declare (salience 10))
	(modulo Riego)
	?f <- (riego ?p alto ?humIdeal)
	?g <- (SiguienteLLuvia fuerte ?hora)
	(HumedadMax ?p ?max)
	(HumedadMin ?p ?min)
	=>
	(printout t crlf "El sistema ha decidido modificar la intensidad del riego (alta) "
	"calculada por una más baja debido a la prediccion de lluvia de intensidad "
	"fuerte a las " ?hora " horas" crlf)
	(bind ?rangoMinMax (abs (- ?max ?min)))
	(bind ?inc (integer (/ ?rangoMinMax 4)))
	(bind ?nuevaHum  (- ?min ?inc))
	(printout t "La nueva intensidad del riego será baja y tendrá una humedad objetivo de " ?nuevaHum crlf)
	(retract ?f ?g)
	(assert (riego ?p bajo ?nuevaHum))
)

; Regla que permite modificar
(defrule modificarRiegoMedioLluviaFuerte
	(declare (salience 10))
	(modulo Riego)
	?f <- (riego ?p medio ?humIdeal)
	?g <- (SiguienteLLuvia fuerte ?hora)
	(HumedadMax ?p ?max)
	(HumedadMin ?p ?min)
	=>
	(printout t crlf "El sistema ha decidido modificar la intensidad del riego (media) "
	"calculada por una más baja debido a la prediccion de lluvia de intensidad "
	"fuerte a las " ?hora " horas" crlf)
	(bind ?rangoMinMax (abs (- ?max ?min)))
	(bind ?inc (integer (/ ?rangoMinMax 4)))
	(bind ?nuevaHum  (- ?min ?inc))
	(printout t "La nueva intensidad del riego será baja y tendrá una humedad objetivo de " ?nuevaHum crlf)
	(retract ?f ?g)
	(assert (riego ?p bajo ?nuevaHum))
)

; Regla que permite modificar
(defrule modificarRiegoLluviaTorrencialNo
	(declare (salience 10))
	?f <- (modulo Riego)
	?g <- (riego ?p ?tipo ?humIdeal)
	?h <- (SiguienteLLuvia torrencial ?hora)
	(HumedadMax ?p ?max)
	(HumedadMin ?p ?min)
	(HumedadCrit ?p ?crit)
	(ultimo_registro Humedad ?p ?t)
	(valor_registrado ?t Humedad ?p ?hum)
	(test (< ?hum ?crit))
	=>
	(printout t crlf "El sistema ha decidido modificar la intensidad del riego (" ?tipo ") "
	"calculada por una más baja debido a la prediccion de lluvia de intensidad "
	"torrencial a las " ?hora " horas" crlf)
	(printout t "El sistema no regará la planta debido a que su humedad (" ?hum ") "
	"no está por debajo del crítico (" ?crit ")" crlf)
	(retract ?f ?g ?h)
)

; Regla que permite modificar
(defrule modificarRiegoLluviaTorrencialBajo
	(declare (salience 10))
	(modulo Riego)
	?f <- (riego ?p ?tipo ?humIdeal)
	?g <- (SiguienteLLuvia torrencial ?hora)
	(HumedadMax ?p ?max)
	(HumedadMin ?p ?min)
	(HumedadCrit ?p ?crit)
	(ultimo_registro Humedad ?p ?t)
	(valor_registrado ?t Humedad ?p ?hum)
	(test (>= ?hum ?crit))
	=>
	(printout t crlf "El sistema ha decidido modificar la intensidad del riego (" ?tipo ") "
	"calculada por una más baja debido a la prediccion de lluvia de intensidad "
	"torrencial a las " ?hora " horas" crlf)
	(bind ?rangoMinMax (abs (- ?max ?min)))
	(bind ?inc (integer (/ ?rangoMinMax 4)))
	(bind ?nuevaHum  (- ?min ?inc))
	(printout t "El sistema regará la planta con una intensidad baja debido a que su humedad (" ?hum ") "
	"está por debajo del crítico (" ?crit ")" crlf)
	(printout t "La humedad a alcanzar tiene valor de " ?nuevaHum crlf)
	(retract ?f ?g)
	(assert (riego ?p bajo ?nuevaHum))
)

; Regla para regar las plantas
; Modifica el valor de humedad de la planta
(defrule regarPlanta
	(modulo Riego)
	(regar ?p on ?humObj)
	(Regado ?inc)
	(ultimo_registro Humedad ?p ?t)
	(valor_registrado ?t Humedad ?p ?hum)
	=>
	(bind ?dif (- ?hum ?humObj))
	(bind ?cantRegado (min ?inc ?dif))
	(bind ?newHum (- ?hum ?cantRegado))
	(printout t crlf "Regando " ?p ". Se incrementa su humedad en " ?cantRegado crlf)
	(assert (valor Humedad ?p ?newHum))
)

; Regla para detener el regado de la planta
; Detiene el regado de las plantas una vez que se ha llegado al valor objetivo
; o se ha excedido
(defrule detenerRegarPlanta
	(declare (salience 10))
	?f <- (modulo Riego)
	?g <- (regar ?p on ?humObj)
	(ultimo_registro Humedad ?p ?t)
	(valor_registrado ?t Humedad ?p ?hum)
	(test (<= ?hum ?humObj))
	=>
	(printout t crlf "Se deja de regar la planta " ?p " porque ha llegado a "
	"la humedad adecuada, con un valor de " ?hum crlf)
	(retract ?f ?g)
	(assert (regar ?p off))
	(assert (esperar_humedad ?p ?t))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Reglas para gestionar la vaporizacion de las plantas

; Regla que permite deducir si se debe vaporizar una planta o no
; Si se supera la temperatura critica, esta debe ser vaporizada
; En caso contrario, no se deduce nada
(defrule calcularVaporizarPlanta
	(declare (salience 10))
	(regar ?p off)
	(LluviaActual no)
	?f <- (vaporizador ?p off)
	(ultimo_registro Temperatura ?p ?t)
	(valor_registrado ?t Temperatura ?p ?temp)
	(TemperaturaCrit ?p ?crit)
	(TemperaturaMin ?p ?min)
	(TemperaturaMax ?p ?max)
	(test (> ?temp ?crit))
	=>
	(printout t crlf "El sistema ha detectado que la temperatura del tiesto de la "
	"planta " ?p " es de " ?temp "ºC, valor por encima del maximo permitido "
	?crit "ºC." crlf)
	(bind ?tempIdeal (integer (/ (+ ?max ?min) 2)))
	(printout t "El sistema ha decidido vaporizar la planta " ?p " para reducir "
	"su temperatura a " ?tempIdeal "ºC, valor que se encuentra en el rango de "
	"temperatura ideal" crlf)
	(retract ?f)
	(assert (vaporizador ?p on ?tempIdeal))
	(assert (modulo Vaporizacion))
)

; Regla para vaporizar las plantas
; Modifica el valor de temperatura de la planta de forma gradual
(defrule vaporizarPlanta
	(modulo Vaporizacion)
	(vaporizador ?p on ?tempIdeal)
	(Vaporizado ?cambio)
	(ultimo_registro Temperatura ?p ?t)
	(valor_registrado ?t Temperatura ?p ?temp)
	=>
	(bind ?dif (- ?temp ?tempIdeal))
	(bind ?cantReducido (min ?cambio ?dif))
	(bind ?newTemp (- ?temp ?cantReducido))
	(printout t crlf "Reduciendo la temperatura de " ?p " en " ?cantReducido "ºC" crlf)
	(assert (valor Temperatura ?p ?newTemp))
)

; Regla para detener la vaporizacion de la planta
; Detiene la vaporizacion de las plantas una vez que se ha llegado al valor objetivo
; o se ha excedido
(defrule detenerVaporizadoPlanta
	(declare (salience 10))
	?f <- (modulo Vaporizacion)
	?g <- (vaporizador ?p on ?tempIdeal)
	(ultimo_registro Temperatura ?p ?t)
	(valor_registrado ?t Temperatura ?p ?temp)
	(test (<= ?temp ?tempIdeal))
	=>
	(printout t crlf "Se deja de vaporizar la planta " ?p " porque ha llegado a "
	"la temperatura adecuada, con un valor de " ?tempIdeal "ºC" crlf)
	(retract ?f ?g)
	(assert (vaporizador ?p off))
)
