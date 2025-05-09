/* Wooldridge's (2009) example of Policy analysis with pooled cross sections
 	Data: "KIELMC.raw" (Data and accompanying files : http://www.cengage.com/)
 	from Kiel and McClain's (1995) paper, "The effect of an incinerator siting
 	on housing appreciation rates", Journal of Urban Economics, 37, p. 311-323. 
	Variables description in file "kielmc.des"

 		Evens SALIES, v1 14/11/2017, v3 04/2025 */

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

/*********************************************************
* Modèle log-linéaire quand le vrai modèle est en niveau *
**********************************************************/

*		En niveau :				-21920.2
regress		RPRICE NEARINC Y81 AGE* ECMT
regress		RPRICEl NEARINC Y81 AGE* ECMT
summarize	RPRICE if NEARINC==0&Y81==0

*		Pas de correction : 	-13933.5
display		r(mean)*(exp(_b[ECMT])-1)

* 		Correction de Kennedy : -14092.8
display		r(mean)*(exp(_b[ECMT]-0.5*_se[ECMT]^2)-1)

/*************************
* Estimateur avant-après *
**************************/

regress			RPRICE Y81 if NEARINC==1

/**********************************************************
* Effets individuels (faisons comme si on avait un panel) *
***********************************************************/

*	Création du panel avec indices individuels
keep			NEARINC Y81 ECMT AGE RPRICE
order			NEARINC Y81 ECMT

table			NEARINC Y81 
by NEARINC Y81, sort: ///
	generate	LINE=_n
egen			TEMP1=count(LINE), by(NEARINC Y81)
egen			TEMP2=min(TEMP1), by(NEARINC)
generate		TEMP3=TEMP2-LINE+1
drop if			TEMP3<=0
egen			INDI=group(TEMP2 TEMP3)

order			INDI Y81 NEARINC
sort			INDI Y81 NEARINC ECMT
xtset			INDI Y81

regress			RPRICE NEARINC Y81 ECMT	// -8146.96

*	Estimation des effets groupe et individuels
xtreg			RPRICE NEARINC Y81 ECMT, fe
regress			RPRICE Y81 ECMT i.INDI
