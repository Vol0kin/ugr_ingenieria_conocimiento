; Habitaciones de la casa

(deffacts habitaciones
	(Habitacion Pasillo)
	(Habitacion Cocina)
	(Habitacion Baño)
	(Habitacion Salon)
	(Habitacion Dormitorio_Principal)
	(Habitacion Dormitorio_1)
	(Habitacion Dormitorio_2)
	(Habitacion Terraza)
)

; Puertas de la casa
(deffacts puertas
	(Puerta Pasillo Dormitorio_2)
	(Puerta Pasillo Baño)
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
	(Ventana Baño)
	(Ventana Salon)
	(Ventana Dormitorio_1)
	(Ventana Terraza)
)

; Regla de pasar de una habitacion a otra mediante una puerta
(defrule pasar_puerta
	(Puerta ?h1 ?h2)
	=>
	(assert (posible_pasar ?h1 ?h2))
	(assert (posible_pasar ?h2 ?h1))
)

; Regla de pasar de una habitacion a otra mediante un paso
(defrule pasar_paso
	(Paso ?h1 ?h2)
	=>
	(assert (posible_pasar ?h1 ?h2))
	(assert (posible_pasar ?h2 ?h1))
)

; Regla para inferir que dos habitaciones no estan conectadas directamente
(defrule hab_no_conectadas
	(Habitacion ?h1)
	(Habitacion ?h2 & ~?h1)
	(not (posible_pasar ?h1 ?h2))
	=>
	(assert (necesario_pasar ?h1 ?h2))
	(assert (necesario_pasar ?h2 ?h1))
)

; Regla de habitacion interior
(defrule hab_interior
	(Habitacion ?h)
	(not (Ventana ?h))
	=>
	(assert (habitacion_interior ?h))
)
