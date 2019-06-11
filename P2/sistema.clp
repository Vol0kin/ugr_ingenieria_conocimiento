
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Hechos iniciales

; Definicion de tiestos
(deffacts Tiestos
	(Tiesto Cactus)
	(Tiesto Tulipan)
	(Tiesto Palmera)
)

; Definicion de valores minimios de humedad
(deffacts HumedadesMin
	(HumedadMin Cactus 15)
	(HumedadMin Tulipan 45)
	(HumedadMin Palmera 40)
)

; Definicion de valores maximos de humedad
(deffacts HumedadesMax
	(HumedadMax Cactus 50)
	(HumedadMax Tulipan 60)
	(HumedadMax Palmera 70)
)

; Definicion de valores criticos de humedad
; Si un tiesto baja de esta cantidad, tiene que ser regado
(deffacts HumedadCritica
	(HumedadCrit Cactus 10)
	(HumedadCrit Tulipan 35)
	(HumedadCrit Palmera 25)
)

; Definicion de las humedades iniciales
(deffacts HumedadesInit
	(Humedad Cactus 35)
	(Humedad Tulipan 55)
	(Humedad Palmera 65)
)

; Definicion de las luminosidades iniciales
(deffacts LuminosidadesInit
	(Luminosidad Cactus 200)
	(Luminosidad Tulipan 195)
	(Luminosidad Palmera 200)
)

; Definicion de las temperaturas iniciales de los Tiestos
(deffacts TemperaturasInit
	(Temperatura Cactus 28)
	(Temperatura Tulipan 24)
	(Temperatura Palmera 30)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Regla para bajar la humedad de una planta
(defrule deshumidificar
	?g <- (deshumidificar ?p ?hum2)
	(Tiesto ?p)
	?f <- (Humedad ?p ?hum)
	=>
	(bind ?newHum (- ?hum ?hum2))
	(printout t "Reduciendo la humedad de " ?p ". Pasa de una humedad de " ?hum " a " ?newHum crlf)
	(retract ?f)
	(retract ?g)
	(assert (Humedad ?p ?newHum))
)


; Regla encargada de deducir cual es el momento mas adecuado para regar
; las plantas. Normalmente lo hace cuando se baja del valor de HumedadCrit
; que tiene asociada la planta
(defrule calcularRegarPlanta
	(Tiesto ?p)
	(Humedad ?p ?hum)
	(HumedadCrit ?p ?crit)
	(test (< ?hum ?crit))
	=>
	(printout t "La humedad de " ?p " es de " ?hum ", valor por debajo del critico " ?crit crlf)
	(assert (regar ?p))
)

; Regla para regar las plantas
; Modifica el valor de humedad de la planta
(defrule regarPlanta
	?f <- (regar ?p)
	?g <- (Humedad ?p ?hum)
	(HumedadMax ?p ?max)
	(HumedadMin ?p ?min)
	=>
	(bind ?rango (- ?max ?min))
	(bind ?newHum (+ (mod (random) ?rango) ?min))
	(printout t "Regando " ?p ". Su nueva humedad pasa a ser " ?newHum crlf)
	(retract ?f)
	(retract ?g)
	(assert (Humedad ?p ?newHum))
)
