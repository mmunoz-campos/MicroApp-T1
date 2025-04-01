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

*describe est_conyugal
*label list conyugal_val

preserve

drop if est_conyugal == 0 
collapse (sum) ocupados_escalado, by(sexo tipo est_conyugal)

* Buscamos generar una lista con todas las variables (para automatizar a futuro)
quietly ds
local totvars `r(varlist)'
foreach x in `totvars' { 
	* Queremos que la tabla aparezcan los labels, no los números de la categoría
	* Para eso, imponemos la condición de decodificar solamente si
	* existe un label para los valores.
    if "`: value label `x''" != "" { 
        decode `x', gen(temp_var)  
        drop `x'                   
        rename temp_var `x'     
    } 
	* Para mantener la variable "Total de ocupados" a la derecha, repetimos
	* este proceso de agregar y eliminar, pero sin decodificar.
    else { 
        gen temp_var = `x'
        drop `x'                   
        rename temp_var `x'
    }
}

label variable ocupados_escalado "Total de Ocupados"

* Generamos el documento con la tabla
quietly ds
local totvars `r(varlist)'
quietly asdoc list `totvars', label ///
	title(Total de ocupados (ajustado por valor de expansión)) ///
	fhc(\b) save(tabla16.doc) replace
	
*help asdoc

restore

**  -----------------------

**  ---- Pregunta 1.7 -----
gen desocupados = (activ == 2)

gen desocupados_escalado = desocupados * ponderador

preserve

drop if est_conyugal == 0 
collapse (sum) desocupados_escalado, by(sexo tipo est_conyugal)

quietly ds
local totvars `r(varlist)'
foreach x in `totvars' { 
    if "`: value label `x''" != "" { 
        decode `x', gen(temp_var)  
        drop `x'                   
        rename temp_var `x'     
    } 
    else { 
        gen temp_var = `x'
        drop `x'                   
        rename temp_var `x'
    }
}

label variable desocupados_escalado "Total de Desocupados"

quietly ds
local totvars `r(varlist)'
quietly asdoc list `totvars', label ///
	title(Total de desocupados (ajustado por valor de expansión)) ///
	fhc(\b) save(tabla17.doc) replace

restore
**  -----------------------

log close

