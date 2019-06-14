import numpy as np
import skfuzzy as fuzz

in_hum = 850
in_lum = 400

x_hum = np.arange(1024)
x_lum = np.arange(1000)

hum_md = fuzz.trapmf(x_hum, [550, 600, 800, 850])
hum_hi = fuzz.trapmf(x_hum, [0, 0, 550, 600])
hum_lo = fuzz.trapmf(x_hum, [800, 850, 1023, 1023])


x_reg = np.linspace(0.0, 1.0, 11)
lum_lo = fuzz.trapmf(x_lum, [0, 0, 250, 300])
lum_md = fuzz.trapmf(x_lum, [250, 300, 650, 700])
lum_hi = fuzz.trapmf(x_lum, [650, 700, 999, 999])

reg_lo = fuzz.trimf(x_reg, [0, 0, 0.5])
reg_md = fuzz.trimf(x_reg, [0.0, 0.5, 1.0])
reg_hi = fuzz.trimf(x_reg, [0.5, 1.0, 1.0])

hum_level_lo = fuzz.interp_membership(x_hum, hum_lo, in_hum)
hum_level_md = fuzz.interp_membership(x_hum, hum_md, in_hum)
hum_level_hi = fuzz.interp_membership(x_hum, hum_hi, in_hum)

lum_level_lo = fuzz.interp_membership(x_lum, lum_lo, in_lum)
lum_level_md = fuzz.interp_membership(x_lum, lum_md, in_lum)
lum_level_hi = fuzz.interp_membership(x_lum, lum_hi, in_lum)

r1 = np.fmin(lum_level_hi, hum_level_lo)
reg_act_lo = np.fmin(r1, reg_lo)
r21 = np.fmax(lum_level_md, lum_level_lo)
r2 = np.fmin(r21, hum_level_lo)
reg_act_hi = np.fmin(r2, reg_hi)
agg = np.fmax(reg_act_hi, reg_act_lo)
print(agg)
riego = fuzz.defuzz(x_reg, agg, 'centroid')
print(riego)
riego_activation = fuzz.interp_membership(x_reg, agg, riego)
print(riego_activation)
