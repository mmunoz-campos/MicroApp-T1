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

*clear all
*macro drop _all

**  ---- Pregunta 2.2 -----
*cd "/Users/mmunozcampos/Documents/Micro Aplicada/T1 MAP"
*import delimited "A_INSCRITOS_PUNTAJES_PDT_2022_PUB_MRUN.csv", clear
*save "inscritos-puntajes.dta", replace
*import delimited "B_SOCIOECONOMICO_DOMICILIO_PDT_2022_PUB_MRUN.csv", clear
*merge 1:1 _n using "inscritos-puntajes.dta"

*cd "/Users/mmunozcampos/Documents/Micro Aplicada/T1 MAP/Pregunta2-T1-MAP"
*save "puntaje_economico.dta", replace
*asdoc sum _merge, save(mergep22.doc) fhc(\i)
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
drop if educacion_madre == 99 | educacion_padre == 99
gen parent_es_profesional = 1 if educacion_madre >= 7 | educacion_padre >= 7
replace parent_es_profesional = 0 if parent_es_profesional != 1
**  -----------------------

**  ---- Pregunta 2.6 -----
destring dependencia tiene_trabajo_rem economicamente sexo, replace
**  -----------------------

**  ---- Pregunta 2.7 -----
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
		 
** FALTA HACER LABEL de las dependencias
**  -----------------------

**  ---- Pregunta 2.10 ----
destring tipo_institucion, replace
graph box ptje_nem, by(tipo_institucion)
**  -----------------------

**  ---- Pregunta 2.11 ----

**  -----------------------

log close
