* Fichier original "QOB Table IV.do" par Yuqiao Huang, 05/05/2008
*	Les fichiers originaux (.do, .dta, etc.) sont a la page Angrist data Archive
*		a l'adresse http://economics.mit.edu/faculty/angrist/data1/data
*		Les fichiers .do "Table IV", "Table V" et "Table IV" sont tres proches.
*		Le code differe au niveau de la restriction a telle ou telle cohorte ...
*
*	Important : le code qui suit ne reproduit pas les tableaux de l'article
*		d'Angrist et Krueger (1991), mais du tableau 4.1.1, p. 124 d'Angrist et
*		Pischke (2009, p. 119). Restriction a la cohorte 1930-1939
*
*	Revision : Evens Salies, 02/2020, 02/2021

cls
set more	off
set memory	500m

use			"http://www.evens-salies.com/NEW7080.dta", clear

rename 		v1 AGE		// En 1970 (CENSUS 1970), en 1980 (CENSUS 1980)
rename 		v2 AGEQ		// Idem, en decimal, avec les trimestres .25, .5, .75
* v3
rename 		v4 EDUC
rename 		v5 ENOCENT
rename 		v6 ESOCENT
* v7
drop 		v8
rename 		v9 LWKLYWGE
rename 		v10 MARRIED
rename 		v11 MIDATL
rename 		v12 MT
rename 		v13 NEWENG
* v14
* v15
rename 		v16 CENSUS
*	Note : dans le CENSUS de 1970, l'annee de naissance YOB est notee avec tous
*		les chiffres, alors dans le census de 1980 les dizaines et les unites
*		sont notees. Par exemple, 1929 (census 1970) et 29 (census 1980)
*			dans le CENSUS de 1970 les annees de naissance vont de 1920 a 1929
*			dans le CENSUS de 1980 les annees de naissance vont de 1930 a 1949
* v17
rename 		v18 QOB		// Trimestre de naissance
rename 		v19 RACE
rename 		v20 SMSA
rename 		v21 SOATL
* v22
* v23
rename 		v24 WNOCENT
rename 		v25 WSOCENT
* v26
rename 		v27 YOB			// Annee de naissance
generate	COHORT=20.29	// Po. les ind. dt l'annee naiss. < 1930 ds CENSUS70
replace 	COHORT=30.39 if YOB<=39 & YOB >=30	// Po. les CENSUS80
replace 	COHORT=40.49 if YOB<=49 & YOB >=40
order		CENSUS COHORT YOB
replace 	AGEQ=AGEQ-1900 if CENSUS==80	// Dans CENSUS80, age est une annee
generate	AGEQSQ=AGEQ*AGEQ	

* Variables dichotomiques des annees de naissance
*	Note : je ne vois pas a quoi sert ce codage !!!!!!!!!!!!
*		Sachant que dans la figure 4.1.1, p. 119 d'A&P, on a que les annees 30
forvalues	I=0(1)9 {
 generate	YR2`I'=0
 replace	YR2`I'=1 if YOB==192`I'	// YR20 pour naiss. en 1920 (CENSUS 70)
 replace	YR2`I'=1 if YOB==3`I'	// YR20 pour naiss. en 1930 ??????
 replace	YR2`I'=1 if YOB==4`I'
} 
*

order		CENSUS YOB QOB AGE AGEQ COHORT YR*
sort		CENSUS YOB QOB

* Variables dichotomiques des trimestres
generate	QTR1=0
replace 	QTR1=1 if QOB==1
generate	QTR2=0
replace 	QTR2=1 if QOB==2
generate	QTR3=0
replace		QTR3=1 if QOB==3
generate	QTR4=0
replace		QTR4=1 if QOB==4

* Variables dichotomiques d'interaction annee*trimestre
gen 		QTR120= QTR1*YR20
gen 		QTR121= QTR1*YR21
gen 		QTR122= QTR1*YR22
gen 		QTR123= QTR1*YR23
gen 		QTR124= QTR1*YR24
gen 		QTR125= QTR1*YR25
gen 		QTR126= QTR1*YR26
gen 		QTR127= QTR1*YR27
gen 		QTR128= QTR1*YR28
gen 		QTR129= QTR1*YR29

gen 		QTR220= QTR2*YR20
gen 		QTR221= QTR2*YR21
gen 		QTR222= QTR2*YR22
gen 		QTR223= QTR2*YR23
gen 		QTR224= QTR2*YR24
gen 		QTR225= QTR2*YR25
gen 		QTR226= QTR2*YR26
gen 		QTR227= QTR2*YR27
gen 		QTR228= QTR2*YR28
gen 		QTR229= QTR2*YR29

gen 		QTR320= QTR3*YR20
gen 		QTR321= QTR3*YR21
gen 		QTR322= QTR3*YR22
gen 		QTR323= QTR3*YR23
gen 		QTR324= QTR3*YR24
gen 		QTR325= QTR3*YR25
gen 		QTR326= QTR3*YR26
gen 		QTR327= QTR3*YR27
gen 		QTR328= QTR3*YR28
gen 		QTR329= QTR3*YR29


*keep if COHORT<20.30
keep if			COHORT>30&COHORT<40

* Graphique A, p. 119 d'A&P (2009)
preserve
 collapse		(mean) EDUC, by(YOB QOB)
 replace		YOB=YOB+1900
 generate		YOBVALUE=YOB
 tostring		YOB, replace
 tostring		QOB, replace
 generate		TEMP=YOB+":"+QOB
 generate 		DATE=quarterly(TEMP, "YQ")
 generate		DATERELATIVE=DATE
 format			DATE %tq
 drop			TEMP
 tsset			DATE

 twoway (tsline EDUC, recast(connected) lcolor(black) lpattern(solid) ///
			mcolor(black) msize(small) msymbol(square) mlabel(QOB) ///
			mlabsize(small) mlabcolor(black) mlabposition(12) ///
			mfcolor(black) mlwidth(none)), ///
		ytitle(Nombre d'années d'études) ymtick(none) ///
		ttitle(Année-trimestre de naissance) xscale(noline) ///
		tlabel(-120(4)-81, angle(forty_five) noticks grid glwidth(vthin) ///
		glcolor(black) gmin nogmax gextend) ///
		tmtick(##4, grid glwidth(vvvthin) glcolor(gs12)) ///
		title(Nombre moyen d'années d'éducation par trimestre de naissance, ///
		size(medsmall)) legend(off) scheme(s1color)
restore


* Table 4.1.1, p. 124
*	Colonne (1)
regress			LWKLYWGE EDUC, robust		

*	Colonne (2)
regress			LWKLYWGE EDUC i.v17 i.YOB, robust

*	Colonne (3)
ivregress 2sls	LWKLYWGE (EDUC = QTR1)
