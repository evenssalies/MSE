* Code: Evens SALIES
* 01/2021, v1

* Description des variables
*	http://www.evens-salies.com/KIELMC.DES

import delimited using ///
	"http://www.evens-salies.com/KIELMC.txt", delimiter(tab) clear

* Keep the following variables
keep 		v1 v2 v3 v6 v9 v10 v11 v12 v13 v17 v22 v23 v24 v25

* Rename working columns from KIELMC.DES file
rename		v1 YEAR
rename		v2 AGE
rename		v3 AGE2
rename		v17 Y81
rename		v22 NEARINC
rename		v24 RPRICE
rename		v25 RPRICEl

* Naive estimations for 1981 and 1978 and DD estimation
*	ATTENTION G0 - G1 dans Stata 
ttest		RPRICE if YEAR==1981, by(NEARINC)	// G1-G0 = 70619.24-101307.51
ttest		RPRICE if YEAR==1978, by(NEARINC)	// G1-G0 = 63692.86-82517.23

generate	ECMT=Y81*NEARINC

regress		RPRICE NEARINC Y81 ECMT // 70619.24-101307.51-(63692.86-82517.23)

regress		RPRICE NEARINC Y81 ECMT, ///
				vce(bootstrap) // 70619.24-101307.51-(63692.86-82517.23)

regress		RPRICE NEARINC Y81 AGE AGE2 ECMT, robust // -21920.27

* Note sur le log:
regress		RPRICEl NEARINC Y81 AGE AGE2 ECMT, robust
summarize	RPRICE if NEARINC==1&YEAR==1978
// -0.18495 * 63692.86 = -11780, qui est tres superieur a -21920.27,
// autrement dit, le log conduirait a une surestimation de l'effet.
// Prenons la correction de Kennedy :
scalar		KENNEDY=exp(_b[ECMT]-0.5*_se[ECMT])-1
display		KENNEDY*63692.86
// Qui reste supérieur
