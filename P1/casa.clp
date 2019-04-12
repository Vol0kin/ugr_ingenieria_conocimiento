; Practica 1

; A continuacion se describen la prioridad de las reglas:
; Prioridad 2: pasar_puerta, pasar_paso
; Prioridad 1: hab_mas_una_entrada
; Prioridad 0: resto de reglas


; Habitaciones de la casa
(deffacts habitaciones
	(Habitacion Pasillo)
	(Habitacion Cocina)
	(Habitacion WC)
	(Habitacion Salon)
	(Habitacion Dormitorio_Principal)
	(Habitacion Dormitorio_1)
	(Habitacion Dormitorio_2)
	(Habitacion Terraza)
)

; Puertas de la casa
(deffacts puertas
	(Puerta Pasillo Dormitorio_2)
	(Puerta Pasillo WC)
	(Puerta Pasillo Salon)
	(Puerta Salon Dormitorio_Principal)
	(Puerta Salon Dormitorio_1)
	(Puerta Dormitorio_Principal Terraza)
)

; Pasos sin puerta de la casa
(deffacts pasos_sin_puerta
	(Paso Pasillo Cocina)
)

; Ventanas de la casa
(deffacts ventanas
	(Ventana Dormitorio_2)
	(Ventana Cocina)
	(Ventana WC)
	(Ventana Salon)
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
(deffacts luminosidades
  (luminosidad Salon 300) 
  (luminosidad Dormitorio_Principal 150)
  (luminosidad Dormitorio_1 150)
  (luminosidad Dormitorio_2 150)
  (luminosidad Cocina 200)
  (luminosidad Pasillo 200)
  (luminosidad WC 200)
  (luminosidad Despacho 500)
)
