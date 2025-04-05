cd "/Users/mmunozcampos/Documents/Micro Aplicada/T1 MAP/MicroApp-T1"
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

clear all
macro drop _all

**  ---- Pregunta 2.2 -----
cd "/Users/mmunozcampos/Documents/Micro Aplicada/T1 MAP"
import delimited "A_INSCRITOS_PUNTAJES_PDT_2022_PUB_MRUN.csv"
**  -----------------------


log close
