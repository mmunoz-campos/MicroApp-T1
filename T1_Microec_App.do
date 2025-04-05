cd "/Users/mmunozcampos/Documents/Micro Aplicada/T1 MAP"
clear all
macro drop _all
capture log close
log using Tarea1.log, replace

** ---- Instalación librerías ----
*ssc install asdoc, replace

************************************
************************************
***								 ***
*** ----    PREGUNTA 1.     ---- ***
***								 ***
************************************
************************************

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
	local lbl_lower = substr(strlower("`lbl'"), 1, 14)
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
	local lbl_lower = substr(strlower("`lbl'"), 1, 14)
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
	local lbl_lower = substr(strlower("`lbl'"), 1, 14)
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
	local lbl_lower = substr(strlower("`lbl'"), 1, 14)
	label variable mayoresde15 "Pob. en edad de trabajar por `lbl_lower'"
	merge 1:1 `x' using ocp_by_`x'.dta
	drop _merge
	save ocp_by_`x'.dta, replace
	restore
}
**  ------------------------

**  ---- Pregunta 1.10 -----

foreach x in $ste {
	preserve
	use ocp_by_`x'.dta, clear
	gen tasa_de_particip = round(100*(fuerza_trabajo/mayoresde15),0.01)
	label variable tasa_de_particip "Tasa de participación"
	save ocp_by_`x'.dta, replace
	restore
}
**  ------------------------

**  ---- Pregunta 1.11 -----
gen tasa_de_particip = round(100*(fuerza_trabajo/(mayoresde15*ponderador)),0.01) ///
	if edad >= 15
	
sum tasa_de_particip
*asdoc

foreach x in $ste {
	preserve
	use ocp_by_`x'.dta, clear
	
	*eliminamos "no sabe", "no aplica", "no responde"
	drop if `x' == 88 | `x' == 0 | `x' == 99
	
	* Acortamos los labels de la var. categórica
	decode `x', generate(new_var)
	drop `x'
	rename new_var `x'
	replace `x' = substr(`x', 1, 11)

	*Graficamos
	local y_label : variable label tasa_de_particip
	local lbl: variable label `x'
	local lbl_lower = strlower("`lbl'")
	quietly graph bar tasa_de_particip, over(`x', label(angle(45))) ///
		ytitle("`y_label'") title("Tasa de participación (%)") ///
		subtitle("Por `lbl_lower'") xsize(2) ysize(2) ///
		graphregion(margin(large)) scheme(stcolor) style(verdana)
	*Exportamos el gráfico
	quietly graph export `x'_tasa_de_particip.png, replace
	
	restore
}
**  ------------------------

**  ---- Pregunta 1.12 -----
preserve

*preparamos el collapse
replace mayoresde15 = mayoresde15*ponderador
drop ponderador
keep if edad >= 15

*Hacemos el collapse
collapse (sum) desocupados_escalado mayoresde15, by(region)
gen tasa_de_desemp = round(100*(desocupados_escalado/(mayoresde15)),0.01)
gsort -tasa_de_desemp
keep in 1/5

*Graficamos
quietly graph hbar tasa_de_desemp, over(region, sort(tasa_de_desemp) descending) ///
	ytitle("Tasa de desempleo (%)") title("Tasa de desempleo (%)") ///
	subtitle("Por región") xsize(2) ysize(2) ///
	graphregion(margin(large)) scheme(stcolor) style(verdana)
*Exportamos el gráfico
quietly graph export tasa_de_desemp_region.png, replace

restore	
**  ------------------------

**  ---- Pregunta 1.13 -----
cd "/Users/mmunozcampos/Documents/Micro Aplicada/T1 MAP"

use "ene-2023-ond_delim.dta", clear
ds
local vars1 `r(varlist)'

use "esi-2023---personas.dta", clear

merge 1:1 _n using "ene-2023-ond_delim.dta"

keep `vars1' ing_t_t ing_ot ing_t_d ing_t_p fact_cal_esi _merge

cd "/Users/mmunozcampos/Documents/Micro Aplicada/T1 MAP/MicroApp-T1"

asdoc tab _merge, label title(Merge Results) fhc(\b) save(merget1.doc) replace
drop _merge

save "tarea1 parte1 matias munoz.dta", replace
	
**  ------------------------

**  ---- Pregunta 1.14 -----
* Yo nací un 2 de abril
* 2 + 20 = 22
* eliminamos los que terminan en 22, 44, y 88

gen desc_idrph = 1 if mod(idrph, 100) == 22 | mod(idrph, 100) == 44 | ///
	mod(idrph, 100) == 88
drop if desc_idrph == 1
**  ------------------------

**  ---- Pregunta 1.15 -----
gen ponderador = round(fact_cal_esi)

preserve
drop if sector == 3
graph bar (mean) ing_t_t, over(sector) ///
	ytitle("Ingreso promedio") title("Ingreso promedio") ///
	subtitle("Por sector") xsize(2) ysize(2) ///
	graphregion(margin(large)) scheme(stcolor) style(verdana)
quietly graph export ing_por_sector.png, replace
restore
**  ------------------------

**  ---- Pregunta 1.16 -----
hist ing_t_t, bin(100) color(gs12) kdensity
graph export "hist1.png", replace

preserve
drop if ing_t_t == 0
hist ing_t_t, bin(100) color(gs12) kdensity
graph export "hist2.png", replace

drop if ing_t_t < 5000000
hist ing_t_t, bin(100) color(gs12) kdensity
graph export "hist3.png", replace

restore

sum ing_t_t
**  ------------------------


**  ---- Pregunta 1.17 -----
gen ed_uni = 1 if cine >= 7
replace ed_uni = 0 if ed_uni != 1
**  ------------------------

**  ---- Pregunta 1.18 -----
gen log_ing = log(ing_t_t * ponderador)
gen sq_edad = edad*edad

local controles edad sq_edad sexo region est_conyugal orig1 tipo habituales ///
	sector asocia

reg ed_uni log_ing `controles'
**  ------------------------

************************************
************************************
***								 ***
*** ----    PREGUNTA 2.     ---- ***
***								 ***
************************************
************************************

clear all
macro drop _all




log close

