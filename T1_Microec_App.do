cd "/Users/mmunozcampos/Documents/Micro Aplicada/T1 MAP"
clear all
macro drop _all
capture log close
log using Tarea1.log, replace

**  ---- Pregunta 1.1 -----
use "ene-2023-11-ond.dta", clear
**  -----------------------

**  ---- Pregunta 1.2 -----
*summarize
describe
**  -----------------------

**  ---- Pregunta 1.4 -----
keep est_conyugal nivel sexo tramo_edad edad region tipo activ cine ///
	obe tpi ftp habituales efectivas fact_cal asocia sector orig1 ///
	id_identificacion idrph

save "ene-2023-ond_delim.dta", replace
**  -----------------------

**  ---- Pregunta 1.5 -----
gen ponderador = round(fact_cal)
**  -----------------------

**  ---- Pregunta 1.6 -----
gen ocupados = (activ == 1)
gen ocupados_escalado = ocupados * ponderador

describe est_conyugal
label list conyugal_val

preserve
drop if est_conyugal == 0 
collapse (sum) ocupados_escalado, by(sexo tipo est_conyugal)
browse
restore

**  -----------------------

**  ---- Pregunta 1.7 -----
gen desocupados = (activ == 2)

**  -----------------------

log close

