
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
; la posibilidad de regar la planta hasta que descienda a valors ideales
(deffacts LuzMin
	(LuminosidadMin Cactus 300)
	(LuminosidadMin Tulipan 250)
	(LuminosidadMin Palmera 350)
)

; Definicion de valores maximos de luminosidad para las plantas
; El valor de luminosidad ideal esta entre el minimo y el maximo
; Esto indica que, si se excede este rango, es mas dificil que se de
; la posibilidad de regar la planta hasta que descienda a valors ideales
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
; Reglas para gestionar el riego de las plantas

; Regla encargada de deducir cual es el momento mas adecuado para regar
; las plantas. Normalmente lo hace cuando se baja del valor de HumedadCrit
; que tiene asociada la planta
(defrule calcularRegarPlanta
	(regar ?p off)
	(vaporizador ?p off)
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
	(assert (modulo Riego))
)

(defrule riegoNo
	?f <- (modulo Riego)
	?g <- (riego ?p no ?)
	=>
	(printout t crlf "El sistema ha decidido no regar la planta " ?p " debido a que su humedad "
	"estaba en el rango ideal de humedad o era superior a este" crlf)
	(retract ?f)
	(retract ?g)
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
	(retract ?f)
	(retract ?g)
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
	(retract ?f)
	(retract ?g)
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
	(retract ?f)
	(retract ?g)
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
	(retract ?f)
	(retract ?g)
	(assert (regar ?p off))
	(assert (esperar_humedad ?p ?t))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Reglas para gestionar la vaporizacion de las plantas

(defrule calcularVaporizarPlanta
	(declare (salience 10))
	(regar ?p off)
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

; Regla para regar las plantas
; Modifica el valor de humedad de la planta
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

; Regla para detener el regado de la planta
; Detiene el regado de las plantas una vez que se ha llegado al valor objetivo
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
	(retract ?f)
	(retract ?g)
	(assert (vaporizador ?p off))
)
