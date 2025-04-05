cd "/Users/mmunozcampos/Documents/Micro Aplicada/T1 MAP/Pregunta2-T1-MAP"
clear all
macro drop _all
capture log close
log using Tarea1.log, replace

************************************
************************************
***								 ***
*** ----    PREGUNTA 2.     ---- ***
***								 ***
************************************
************************************

*ssc install binscatter

*clear all
*macro drop _all

**  ---- Pregunta 2.2 -----
*cd "/Users/mmunozcampos/Documents/Micro Aplicada/T1 MAP"
*import delimited "A_INSCRITOS_PUNTAJES_PDT_2022_PUB_MRUN.csv", clear
*save "inscritos-puntajes.dta", replace
*import delimited "B_SOCIOECONOMICO_DOMICILIO_PDT_2022_PUB_MRUN.csv", clear
*merge 1:1 _n using "inscritos-puntajes.dta"
*save "puntaje_economico.dta", replace

*cd "/Users/mmunozcampos/Documents/Micro Aplicada/T1 MAP/Pregunta2-T1-MAP"
*asdoc sum _merge, save(mergep22.doc) fhc(\i) replace
**  -----------------------


**  ---- Pregunta 2.3 -----
cd "/Users/mmunozcampos/Documents/Micro Aplicada/T1 MAP"
use "puntaje_economico.dta", clear
cd "/Users/mmunozcampos/Documents/Micro Aplicada/T1 MAP/Pregunta2-T1-MAP"

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
label variable ingreso_percapita_grupo_FA "Ingreso per cápita del grupo familiar"
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



**  -----------------------

log close
