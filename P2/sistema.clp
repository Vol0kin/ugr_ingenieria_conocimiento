
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

(deffacts RegadoInit
	(regar Cactus off)
	(regar Tulipan off)
	(regar Palmera off)
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
	(declare (salience 20))
	?f <- (valor ?tipo ?p ?v)
	(Tiesto ?p)
	=>
	(bind ?t (time))
	(printout t "Registrado nuevo valor de tipo " ?tipo " para la planta " ?p " con valor " ?v crlf)
	(assert (valor_registrado ?t ?tipo ?p ?v))
	(assert (ultimo_registro ?tipo ?p ?t))
	(retract ?f)
)

; Regla para eliminar el anterior ultimo_registro
; del mismo tipo para un tiesto segun el tiempo
(defrule ultimo_reg
	(declare (salience 15))
	?f <- (ultimo_registro ?tipo ?p ?t1)
	(ultimo_registro ?tipo ?p ?t2)
	(test (< ?t1 ?t2))
	=>
	(retract ?f)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Regla encargada de deducir cual es el momento mas adecuado para regar
; las plantas. Normalmente lo hace cuando se baja del valor de HumedadCrit
; que tiene asociada la planta
(defrule calcularRegarPlanta
	(regar ?p off)
	(Tiesto ?p)

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
	(printout t "El sistema va a razonar sobre la necesidad de regar o no la planta " ?p "..." crlf)

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
)

(defrule riegoNo
	(declare (salience 10))
	?f <- (riego ?p no ?)
	=>
	(printout t "El sistema ha decidido no regar la planta " ?p " debido a que su humedad
	estaba en el rango ideal de humedad o era superior a este" crlf)
	(retract ?f)
)

(defrule riegoBajo
	(declare (salience 10))
	?f <- (riego ?p bajo ?humIdeal)
	?g <- (regar ?p off)
	=>
	(printout t "El sistema ha decidido realizar un riego de baja intensidad para la planta " ?p "
	debido a que su humedad era baja y las condiciones de luminosidad/temperatura
	no le son favorables" crlf)
	(assert (regar ?p on ?humIdeal))
	(retract ?f)
	(retract ?g)
)

(defrule riegoMedio
	(declare (salience 10))
	?f <- (riego ?p medio ?humIdeal)
	?g <- (regar ?p off)
	=>
	(printout t "El sistema ha decidido realizar un riego de intensidad media para la planta " ?p "
	debido a que su humedad era baja y las condiciones de luminosidad/temperatura
	le eran un poco favorables" crlf)
	(assert (regar ?p on ?humIdeal))
	(retract ?f)
	(retract ?g)
)

(defrule riegoAlto
	(declare (salience 10))
	?f <- (riego ?p alto ?humIdeal)
	?g <- (regar ?p off)
	=>
	(printout t "El sistema ha decidido realizar un riego de alta intensidad para la planta " ?p "
	debido a que su humedad era baja y las condiciones de luminosidad/temperatura
	le son favorables" crlf)
	(assert (regar ?p on ?humIdeal))
	(retract ?f)
	(retract ?g)
)

; Regla para regar las plantas
; Modifica el valor de humedad de la planta
(defrule regarPlanta
	(regar ?p on ?humObj)
	(Regado ?inc)
	(ultimo_registro Humedad ?p ?t)
	(valor_registrado ?t Humedad ?p ?hum)
	=>
	(bind ?dif (- ?hum ?humObj))
	(bind ?cantRegado (min ?inc ?dif))
	(bind ?newHum (- ?hum ?cantRegado))
	(printout t "Regando " ?p ". Se incrementa su humedad en " ?cantRegado crlf)
	(assert (valor Humedad ?p ?newHum))
)

; Regla para detener el regado de la planta
; Detiene el regado de las plantas una vez que se ha llegado al valor objetivo
; o se ha excedido
(defrule detenerRegarPlanta
	(declare (salience 10))
	?f <- (regar ?p on ?humObj)
	(ultimo_registro Humedad ?p ?t)
	(valor_registrado ?t Humedad ?p ?hum)
	(test (<= ?hum ?humObj))
	=>
	(printout t "Se deja de regar la planta " ?p " porque ha llegado a su humedad ideal" crlf)
	(retract ?f)
	(assert (regar ?p off))
)
