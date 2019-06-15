import numpy as np
import skfuzzy as fuzz

# Leer el fichero de datos del sistema
with open('DatosSistema.txt') as f:
    # Obtener linea
    line = f.readline()

    # Dividir linea en valores y obtener lista de enteros con estos
    line = list(map(int, line.replace('\n', '').split(' ')))

    # Obtener valores de entrada
    hum_min, hum_max, hum_crit, tmp_min, tmp_max, tmp_crit, lum_min, lum_max, in_hum, in_tmp, in_lum = line

# Calcular rangos de [HumMin, HumMax] y [HumCrit, HumMin]
hum_min_max = abs(hum_min - hum_max)
hum_min_crit = abs(hum_crit - hum_min)

# Valores del riego
values = np.array([0.0, 0.5, 1.0, 1.5])

# Rangos de valores para cada modelo difuso
x_hum = np.arange(1024)
x_lum = np.arange(1001)
x_tmp = np.arange(100)
x_reg = np.linspace(0.0, 1.5, 16)

# Establecer conjuntos difusos
hum_hi = fuzz.zmf(x_hum, hum_max - hum_min_max / 4, hum_max)
hum_md = fuzz.trapmf(x_hum, [hum_max - hum_min_max / 4, hum_max, hum_min,
                             hum_min + hum_min_crit / 2])
hum_lo = fuzz.smf(x_hum, hum_min + hum_min_crit / 3, hum_crit)

lum_lo = fuzz.zmf(x_lum, lum_min - 50, lum_min)
lum_md = fuzz.trapmf(x_lum, [lum_min - 50, lum_min, lum_max, lum_max + 50])
lum_hi = fuzz.smf(x_lum, lum_max, lum_max + 50)

tmp_lo = fuzz.zmf(x_tmp, tmp_min - 5, tmp_min)
tmp_md = fuzz.trapmf(x_tmp, [tmp_min - 5, tmp_min, tmp_max, tmp_crit])
tmp_hi = fuzz.smf(x_tmp, tmp_max, tmp_crit)

reg_no = fuzz.trimf(x_reg, [0.0, 0.0, 0.5])
reg_lo = fuzz.trimf(x_reg, [0.0, 0.5, 1.0])
reg_md = fuzz.trimf(x_reg, [0.5, 1.0, 1.5])
reg_hi = fuzz.trimf(x_reg, [1.0, 1.5, 1.5])

# Obtener grados de verdad
hum_level_lo = fuzz.interp_membership(x_hum, hum_lo, in_hum)
hum_level_md = fuzz.interp_membership(x_hum, hum_md, in_hum)
hum_level_hi = fuzz.interp_membership(x_hum, hum_hi, in_hum)

lum_level_lo = fuzz.interp_membership(x_lum, lum_lo, in_lum)
lum_level_md = fuzz.interp_membership(x_lum, lum_md, in_lum)
lum_level_hi = fuzz.interp_membership(x_lum, lum_hi, in_lum)

tmp_level_lo = fuzz.interp_membership(x_tmp, tmp_lo, in_tmp)
tmp_level_md = fuzz.interp_membership(x_tmp, tmp_md, in_tmp)
tmp_level_hi = fuzz.interp_membership(x_tmp, tmp_hi, in_tmp)

###############################################################################
# Reglas

# Si HUMEDAD baja y LUMINOSIDAD baja y TEMPERATURA (baja o alta) -> riego medio
reg_hum_lo_lum_lo_tmp_lohi = np.fmin(reg_md,
        np.fmin(hum_level_lo,
            np.fmin(lum_level_lo, np.fmax(tmp_level_lo, tmp_level_hi))))

# Si HUMEDAD baja y LUMINOSIDAD baja y TEMPERATURA media -> regar alto
reg_hum_lo_lum_lo_tmp_md = np.fmin(reg_hi,
        np.fmin(hum_level_lo, np.fmin(lum_level_lo, tmp_level_md)))

# Si HUMEDAD baja y LUMINOSIDAD media y TEMPERATURA baja -> regar medio
reg_hum_lo_lum_md_tmp_lo = np.fmin(reg_md,
        np.fmin(hum_level_lo, np.fmin(lum_level_md, tmp_level_lo)))

# Si HUMEDAD baja y LUMINOSIDAD media y TEMPERATURA media -> regar alto
reg_hum_lo_lum_md_tmp_md = np.fmin(reg_hi,
        np.fmin(hum_level_lo, np.fmin(lum_level_md, tmp_level_md)))

# Si HUMEDAD baja y LUMINOSIDAD alta y TEMPERATURA baja -> regar poco
reg_hum_lo_lum_md_tmp_hi = np.fmin(reg_lo,
        np.fmin(hum_level_lo, np.fmin(lum_level_md, tmp_level_hi)))


# Si HUMEDAD baja y LUMINOSIDAD alta y TEMPERATURA (baja o alta) -> riego poco
reg_hum_lo_lum_hi_tmp_lohi = np.fmin(reg_lo,
        np.fmin(hum_level_lo,
            np.fmin(lum_level_hi, np.fmax(tmp_level_lo, tmp_level_hi))))

# Si HUMEDAD baja y LUMINOSIDAD baja y TEMPERATURA media -> regar medio
reg_hum_lo_lum_hi_tmp_md = np.fmin(reg_md,
        np.fmin(hum_level_lo, np.fmin(lum_level_hi, tmp_level_md)))


# Si HUMEDAD (media o alta) -> no regar
reg_hum_mdhi = np.fmin(reg_no, np.fmax(hum_level_md, hum_level_hi))

# Obtener valor de agrupacion de todos los resultados
agg = np.fmax(reg_hum_lo_lum_lo_tmp_lohi,
        np.fmax(reg_hum_lo_lum_lo_tmp_md,
            np.fmax(reg_hum_lo_lum_md_tmp_lo,
                np.fmax(reg_hum_lo_lum_md_tmp_md,
                    np.fmax(reg_hum_lo_lum_md_tmp_hi,
                        np.fmax(reg_hum_lo_lum_hi_tmp_lohi,
                            np.fmax(reg_hum_lo_lum_hi_tmp_md, reg_hum_mdhi)
                        )
                    )
                )
            )
        )
    )

# Obtener valor "defuzzeado" (conciso) del resultado de la agrupacion
riego = fuzz.defuzz(x_reg, agg, 'centroid')

# Grado de verdad del resultado defuzzeado
riego_activation = fuzz.interp_membership(x_reg, agg, riego)

# Obtener valor de riego mas proximo al resultado defuzzeado
index = (np.abs(values-riego)).argmin()

with open('DatosDeducidos.txt', 'w') as f:
    if index == 0:
        intensity = 'no'
        ideal_hum = in_hum
    elif index == 1:
        intensity = 'bajo'
        ideal_hum = hum_min - hum_min_max / 4
    elif index == 2:
        intensity = 'medio'
        ideal_hum = hum_max + hum_min_max / 4
    elif index == 3:
        intensity = 'alto'
        ideal_hum = hum_max - hum_min_max / 4
    
    f.write('riego ' + intensity + ' ' + str(int(ideal_hum)) + '\n')
