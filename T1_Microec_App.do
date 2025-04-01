cd "/Users/mmunozcampos/Downloads/Tarea 1 Econometria"
clear all
macro drop _all
capture log close
log using Tarea1.log, replace

** Pregunta 1.1
use "ene-2023-11-ond.dta", clear

** Pregunta 1.2
*summarize
describe

** Pregunta 1.4
keep est_conyugal nivel sexo tramo_edad edad region tipo activ cine ///
	obe tpi ftp habituales efectivas fact_cal asocia sector orig1 ///
	id_identificacion idrph

save "ene-2023-ond_delim.dta", replace
** fin Pregunta 1.4

** Pregunta 1.5
gen ponderador = 

log close

