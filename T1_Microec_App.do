cd "/Users/mmunozcampos/Documents/Micro Aplicada/T1 MAP/MicroApp-T1"
clear all
macro drop _all
capture log close
log using Tarea1.log, replace

** ---- Instalación librerías ----
ssc install asdoc, replace
ssc install outreg2, replace
ssc install binscatter, replace
** -------------------------------

************************************
************************************
***								 ***
*** ----    PREGUNTA 1.     ---- ***
***								 ***
************************************
************************************

**  ---- Pregunta 1.1 -----
cd "/Users/mmunozcampos/Documents/Micro Aplicada/T1 MAP"
use "ene-2023-11-ond.dta", clear
**  -----------------------

**  ---- Pregunta 1.2 -----
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
	merge 1:1 `x' using ocp_by_`x'.dta, nogenerate
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
	merge 1:1 `x' using ocp_by_`x'.dta, nogenerate
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
	merge 1:1 `x' using ocp_by_`x'.dta. nogenerate
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
	
foreach x in $ste {
	*eliminamos "no sabe", "no aplica", "no responde"
	drop if `x' == 88 | `x' == 0 | `x' == 99
}
	
asdoc sum tasa_de_particip


foreach x in $ste {
	preserve
	use ocp_by_`x'.dta, clear
	
	* Acortamos los labels de la var. categórica
	decode `x', generate(new_var)
	drop `x'
	rename new_var `x'
	replace `x' = substr(`x', 1, 11)

	*Graficamos
	local lbl: variable label `x'
	local lbl_lower = strlower("`lbl'")
	graph bar tasa_de_particip, over(`x', label(angle(45))) ///
		ytitle("Tasa de Participación") title("Tasa de participación (%)") ///
		subtitle("Por `lbl_lower'")///
	*Exportamos el gráfico
	graph export "`x'_tasa_de_particip.png", replace
	
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
graph hbar tasa_de_desemp, over(region, sort(tasa_de_desemp) descending) ///
	ytitle("Tasa de desempleo (%)") title("Tasa de desempleo (%)") ///
	subtitle("Por región") xsize(2) ysize(2) ///
	graphregion(margin(large)) scheme(stcolor) style(verdana)
*Exportamos el gráfico
graph export "tasa_de_desemp_region.png", replace

restore	
**  ------------------------

**  ---- Pregunta 1.13 -----
use "ene-2023-ond_delim.dta", clear
ds
local vars1 `r(varlist)'

use "esi-2023---personas.dta", clear
merge 1:1 _n using "ene-2023-ond_delim.dta"

keep `vars1' ing_t_t ing_ot ing_t_d ing_t_p fact_cal_esi _merge
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
gen log_ingr = log(ing_t_t * ponderador)
gen sq_edad = edad*edad

local controles_total sq_edad sexo region est_conyugal orig1 tipo habituales ///
	sector asocia

local controles edad
reg ed_uni log_ingr edad
outreg2 using REG_p1_18.doc, replace word
	
foreach x in `controles_total' {
	local controles `controles' `x'
	reg ed_uni log_ingr `controles'
	outreg2 using REG_p1_18.doc, append word
}
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

**  ---- Pregunta 2.2 -----
import delimited "A_INSCRITOS_PUNTAJES_PDT_2022_PUB_MRUN.csv", clear
save "inscritos-puntajes.dta", replace
import delimited "B_SOCIOECONOMICO_DOMICILIO_PDT_2022_PUB_MRUN.csv", clear
merge 1:1 _n using "inscritos-puntajes.dta"

asdoc tab _merge, label title(Merge Results) fhc(\b) save(mergetp22.doc) replace

drop _merge
save "puntaje_economico.dta", replace
**  -----------------------


**  ---- Pregunta 2.3 -----
use "puntaje_economico.dta", clear
sum
**  -----------------------


**  ---- Pregunta 2.4 -----
duplicates drop
ds
local vars `r(varlist)'
foreach x in `vars' {
	quietly drop if missing(`x')
}
**  -----------------------


**  ---- Pregunta 2.5 -----
destring educacion_madre educacion_padre, replace
label define educ_parent_label 1 "Nunca asistió" 2 "Educación Preescolar" ///
	3 "Educación especial" 9 "Primaria o preparatoria (sist. antiguo)" ///
	5 "Educación básica" 6 "Humanidades" 7 "Educación Media Cient-Hum" ///
	8 "Técnica, Comercial, Industrial o Normalista (sist. antiguo)" ///
	9 "Educación media técnico profesional" ///
	10 "Técnico Nivel Superior (Carrera 1-3 años)" ///
	11 "Profesional (Carrera +4 años)" 12 "Postgrado (magíster/doctorado)" ///
	13 "Desconozco la info." 99 "Prefiero no responder"
label values educacion_padre educ_parent_label
label values educacion_madre educ_parent_label

drop if educacion_madre == 99 | educacion_padre == 99 | educacion_madre == 13 | ///
	educacion_padre == 13
gen parent_es_profesional = 1 if educacion_madre >= 11 | educacion_padre >= 11
replace parent_es_profesional = 0 if parent_es_profesional != 1
**  -----------------------

**  ---- Pregunta 2.6 -----
destring dependencia tiene_trabajo_rem economicamente sexo, replace

label define dependencia_label 1 "Corporación Municipal" 2 "Municipal" ///
	3 "Particular Subvencionado" 4 "Particular Pagado" ///
	5 "Corporación de Adm. Delegada" 6 "Servicio Local de Educación (SLE)"
label values dependencia dependencia_label

label define tiene_trabajo_rem_label 0 "No" 1 "Sí, ocasionalmente" ///
	2 "Sí, permanentemente" 9 "Prefiero no responder"
label values tiene_trabajo_rem tiene_trabajo_rem_label

label define econ_label 1 "Dependiente (a ingresos familiares)" ///
	2 "Independiente (a ingresos familiares)" 9 "Prefiero no responder"
label values economicamente econ_label

label define sexo_label 1 "Masculino" 2 "Femenino"
label values sexo cat_label
**  -----------------------


**  ---- Pregunta 2.7 -----
label variable ptje_nem "Puntaje PTU asignado al promedio general de notas (NEM)"
ttest ptje_nem, by(parent_es_profesional)
**  -----------------------


**  ---- Pregunta 2.8 -----
count if sexo == 2 & parent_es_profesional == 1
*135.591
**  -----------------------


**  ---- Pregunta 2.9 -----
asdoc sum ptje_nem, stat(N mean sd) by(dependencia) ///
         title(Estadisticos del NEM por dependencia) ///
         labels save(nem_stats_by_dep.doc) replace
**  -----------------------


**  ---- Pregunta 2.10 ----
drop if ptje_nem == 0

preserve
keep if inlist(dependencia, 2, 3, 4)
graph box ptje_nem, over(dependencia) ///
	title("Puntaje NEM por tipo de colegio")   
graph export nem_by_tipo_col.png, replace
restore
**  -----------------------


**  ---- Pregunta 2.11 ----
destring ingreso_percapita_grupo_fa, replace
label variable ingreso_percapita_grupo_fa "Ingreso per cápita del grupo familiar"
drop if ingreso_percapita_grupo_fa == 99

gen median_income = 67867/2 if ingreso_percapita_grupo_fa == 1
replace median_income = (107284+67867)/2 if ingreso_percapita_grupo_fa == 2
replace median_income = (142173+107284)/2 if ingreso_percapita_grupo_fa == 3
replace median_income = (177045+142173)/2 if ingreso_percapita_grupo_fa == 4
replace median_income = (215995+177045)/2 if ingreso_percapita_grupo_fa == 5
replace median_income = (271791+215995)/2 if ingreso_percapita_grupo_fa == 6
replace median_income = (271791+345328)/2 if ingreso_percapita_grupo_fa == 7
replace median_income = (464965+345328)/2 if ingreso_percapita_grupo_fa == 8
replace median_income = (464965+756201)/2 if ingreso_percapita_grupo_fa == 9
replace median_income = 1000000 if ingreso_percapita_grupo_fa == 10

label variable median_income "Mediana del ingreso per cápita familiar"
**  -----------------------

**  ---- Pregunta 2.12 ----
binscatter median_income ptje_nem, ytitle(Mediana del ingreso per cápita familiar) ///
	xtitle(Puntaje PTU asignado al NEM) ///
	title(Correlación entre puntaje NEM e ingreso)
graph export "binscatter_ing_nem.png", replace
**  -----------------------

**  ---- Pregunta 2.13 ----
reg ptje_nem median_income
**  -----------------------

**  ---- Pregunta 2.14 ----
destring rbd, replace
sum rbd
reg ptje_nem median_income rbd, robust
outreg2 using REG_p2_14.doc, replace word
**  -----------------------

**  ---- Pregunta 2.15 ----
gen sexo_f = 1 if sexo == 2
replace sexo_f = 0 if sexo != 2

reg ptje_nem median_income rbd sexo_f, robust
outreg2 using REG_p2_15.doc, replace word

replace hogar_conexion_internet = "1" if hogar_conexion_internet == "S"
replace hogar_conexion_internet = "0" if hogar_conexion_internet == "N"
drop if hogar_conexion_internet == "9"
destring hogar_conexion_internet, replace

reg ptje_nem median_income rbd sexo_f ///
	hogar_conexion_internet, robust
outreg2 using REG_p2_15.doc, append word

replace estudio_institucion_superior = "1" if estudio_institucion_superior == "S"
replace estudio_institucion_superior = "0" if estudio_institucion_superior == "N"
drop if estudio_institucion_superior == "9"
destring estudio_institucion_superior, replace

reg ptje_nem median_income rbd sexo_f ///
	hogar_conexion_internet estudio_institucion_superior, robust
outreg2 using REG_p2_15.doc, append word

gen econ_indep = 1 if economicamente == 2
replace econ_indep = 0 if economicamente == 1
drop if economicamente == 9

reg ptje_nem median_income rbd sexo_f ///
	hogar_conexion_internet estudio_institucion_superior ///
	econ_indep, robust
outreg2 using REG_p2_15.doc, append word

cd "/Users/mmunozcampos/Documents/Micro Aplicada/T1 MAP"
save "puntaje_economico.dta", replace
**  -----------------------

**  ---- Pregunta 2.16 ----
clear all
cd "/Users/mmunozcampos/Documents/Micro Aplicada/T1 MAP"
use "puntaje_economico.dta", clear
destring mrun anyo_proceso, replace
save "puntaje_economico.dta", replace

import delimited "D_MATRICULA_PDT_2022_PUB_MRUN.csv", clear
destring mrun anyo_proceso, replace

duplicates report mrun
merge m:1 mrun anyo_proceso using "puntaje_economico.dta"

cd "/Users/mmunozcampos/Documents/Micro Aplicada/T1 MAP/Pregunta2-T1-MAP"
asdoc tab _merge, label title(Merge Results) fhc(\b) save(mergetp2_16.doc) replace

cd "/Users/mmunozcampos/Documents/Micro Aplicada/T1 MAP"
keep if _merge == 3
drop _merge
save "tarea1_parte2_matias_munoz.dta", replace

cd "/Users/mmunozcampos/Documents/Micro Aplicada/T1 MAP/Pregunta2-T1-MAP"
**  -----------------------

**  ---- Pregunta 2.17 ----
duplicates drop mrun, force
**  -----------------------


**  ---- Pregunta 2.18 ----
gen elite = 1 if sigla_universidad == "PUCCH" | sigla_universidad == "UCHILE"
replace elite = 0 if elite != 1
**  -----------------------

**  ---- Pregunta 2.19 ----
kdensity ptje_nem if elite ==0, legend(label(1 "NEM matr. resto de Chile")) ///
	addplot(kdensity ptje_nem if elite ==1, legend(label(2 "NEM matr. UCH y PUC")) ///
	title("Distr. de puntaje NEM para matriculados") ///
	subtitle("En universidades UCH y PUC respecto al resto de Chile") ///
	xtitle("Puntaje NEM") ytitle("Densidad") note("") caption("") ///
	)
graph export "puntajes_elite.png", replace
**  -----------------------

**  ---- Pregunta 2.20 ----
label define parent_es_profesional_label 1 "Al menos un padre es profesional" ///
	0 "Ningún padre es profesional"
label values parent_es_profesional parent_es_profesional_label
label variable parent_es_profesional "Alguno de los padres es profesional"
label variable elite "Madriculado en la PUC o la UCH"

label define elite_label 1 "Sí" 0 "No"
label values elite elite_label
		 	
asdoc tab parent_es_profesional elite, column ///
       title(Proporcion de matriculados en UCH y PUC) ///
       labels save(nem_by_elite.doc) replace

graph hbar (percent) elite, over(parent_es_profesional) ///
	ytitle("Proporción de matriculados UCH y PUC") ///
	title("Proporción de matriculados UCH y PUC") ///
	subtitle("Según si al menos uno de sus padres tiene título univ.")
graph export "elite_over_prntpf.png", replace
**  -----------------------

log close

