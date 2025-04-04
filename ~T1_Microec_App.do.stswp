cd "/Users/mmunozcampos/Documents/Micro Aplicada/T1 MAP"
clear all
macro drop _all
capture log close
log using Tarea1.log, replace

** ---- Instalación librerías ----
*ssc install asdoc, replace


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
	
cd "/Users/mmunozcampos/Documents/Micro Aplicada/T1 MAP/MicroApp-T1"

save "ene-2023-ond_delim.dta", replace
**  -----------------------

**  ---- Pregunta 1.5 -----
gen ponderador = round(fact_cal)
**  -----------------------


**  ---- Pregunta 1.6 -----
gen ocupados = (activ == 1)
gen ocupados_escalado = ocupados * ponderador

global ste sexo tipo est_conyugal

foreach x in $ste {
	preserve
	collapse (sum) ocupados_escalado, by(`x')
	* rescatamos el label para el nombre
	local lbl: variable label `x'
	local lbl_lower = strlower("`lbl'")
	label variable ocupados_escalado "Total de desocupados por `lbl_lower'"
	* guardamos el dataset
	save ocp_by_`x'.dta, replace
	restore
}
**  -----------------------



**  ---- Pregunta 1.7 -----
gen desocupados = (activ == 2)
gen desocupados_escalado = desocupados * ponderador

foreach x in $ste {
	preserve
	collapse (sum) desocupados_escalado, by(`x')
	local lbl: variable label `x'
	local lbl_lower = strlower("`lbl'")
	label variable desocupados_escalado "Total de desocupados por `lbl_lower'"
	merge 1:1 `x' using ocp_by_`x'.dta
	drop _merge
	save ocp_by_`x'.dta, replace
	restore
}
**  -----------------------



**  ---- Pregunta 1.8 -----

gen fuerza_trabajo = ocupados_escalado + desocupados_escalado

foreach x in $ste {
	preserve
	collapse (sum) fuerza_trabajo, by(`x')
	local lbl: variable label `x'
	local lbl_lower = strlower("`lbl'")
	label variable fuerza_trabajo "Fuerza de trabajo por `lbl_lower'"
	merge 1:1 `x' using ocp_by_`x'.dta
	drop _merge
	save ocp_by_`x'.dta, replace
	restore
}
**  -----------------------

**  ---- Pregunta 1.9 -----

gen mayoresde15 = 1 if edad >= 15
replace mayoresde15 = 0 if edad < 15

foreach x in $ste {
	preserve
	replace mayoresde15 = mayoresde15 * ponderador
	collapse (sum) mayoresde15, by(`x')
	local lbl: variable label `x'
	local lbl_lower = strlower("`lbl'")
	label variable mayoresde15 "Pob. en edad de trabajar por `lbl_lower'"
	merge 1:1 `x' using ocp_by_`x'.dta
	drop _merge
	save ocp_by_`x'.dta, replace
	restore
}
**  -----------------------

**  ---- Pregunta 1.10 -----

foreach x in $ste {
	preserve
	use ocp_by_`x'.dta, clear
	gen tasa_de_particip = round(100*(fuerza_trabajo/mayoresde15),0.01)
	local lbl: variable label `x'
	local lbl_lower = strlower("`lbl'")
	label variable tasa_de_particip "Tasa de participación por `lbl_lower'"
	save ocp_by_`x'.dta, replace
	restore
}
**  -----------------------

**  ---- Pregunta 1.11 -----
gen tasa_de_particip = round(100*(fuerza_trabajo/(mayoresde15*ponderador)),0.01) ///
	if edad >= 15
	
sum tasa_de_particip
*asdoc

foreach x in $ste {
	preserve
	use ocp_by_`x'.dta, clear
	drop if `x' == 88 | `x' == 0 | `x' == 99
	quietly graph bar (sum) tasa_de_particip, over(`x')
	quietly graph export `x'_tasa_de_particip.png, replace
	restore
}


use ocp_by_est_conyugal.dta, clear
*describe est_conyugal
browse

**  -----------------------

log close

