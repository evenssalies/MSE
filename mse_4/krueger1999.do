*	STAR Experiment, Krueger (1999)
*		Replication, Evens SALIES, 11/2020, 11/2021
set more off
use 					"http://www.evens-salies.com/webstar.dta", clear
sort star*
order					*, alphabetic

* Table I, p. 503, desequilibre de la variable Free lunch
*	Retrouver la P-valeur 0.09
*
*	Une dummy par groupe en Grande Section (kindergarten)
*		  stark: attend STAR in kindergarten 	{1; 2}
*		cltypek: classroom type in kindergarten {1; 2; 3}
*		  sesk:  free lunch						{1; 2}
keep if					stark==1
tabulate				cltypek, generate(KG_)
codebook				cltypek KG_*

***********
* Balance *
***********
*	Free lunch
clonevar				FL=sesk
replace					FL=2-FL
*		Two groups (small class vs regular+aid)
summarize				FL if KG_1==1
local					MEAN1=r(mean)
local					S1=r(sd)
summarize				FL if KG_3==1
local					MEAN0=r(mean)
local					S0=r(sd)
local					MEANDIFF=`MEAN1'-`MEAN0'
local					NORMDIFF=abs(`MEANDIFF'/sqrt(0.5*(`S1'+`S0')))

display "Difference des moyennes des X: " `MEANDIFF' 		
display	""
display	"Difference normalisee : " `NORMDIFF' 		

* 		More than two groups
*		Regression
regress					FL KG_*, noc
regress					FL KG_*
*		ANOVA
oneway					FL cltypek, tabulate

*	White/Asian
generate				WA=(srace==1|srace==3)
by cltypek, sort: sum	WA
regress					WA KG_*

***********
* Overlap *
***********
* 	Free lunch
table					cltypek sesk

*	White/Asian and more
*keep					srace cltypek
clonevar				X=srace
label variable			X ///
 "Student race : 1 (white) 2 (black) 3 (asian) 4 (hispa.) 5 (india.) 6 (other)"
clonevar				D=cltypek
*keep					D X
order					D
sort					D X
cls
by D, sort: sum			X
generate				ONE=1
egen					XN=count(X), by(D)
egen					XFREQ=count(ONE), by(D X)
generate				XFRAC=log(100*XFREQ/XN)
label variable			XFRAC "Relative frequency (%)"

twoway	(bar XFRAC X if D==1, barwidth(.2) lcolor(gs15) fcolor(gs15) ///
		ylabel((-5)(1)(5) ///        
		(bar XFRAC X if D==2, barwidth(.2) lcolor(red) fcolor(none)) ///   
		(bar XFRAC X if D==3, barwidth(.2) lcolor(green) fcolor(none)), ///   
		legend(order(1 "Small" 2 "Regular" 3 "Regular/Aide") ///
		region(lstyle(none))) ///
		xscale(noline) ///
		scheme(s1mono)
s
*/ 
* Refaire avec log(100*XFREQ/XN) et -5(1)5 ...

*******************************
* Stratification (Chapitre 5) *
*******************************
s
drop		ONE WA XN XFREQ XFRAC KG_* D

*	Petites classes par type de commune en kindergarten
table 				schtypek if cltypek==1, c(n cltypek)
table				cltypek, by(schtypek)
tabulate			cltypek schtypek, nofreq cell
order				schidkn			// School id in kindergarten
drop				clad1-clad3		// Teacher career ladder level
drop				cltype1-cltype3	// Type of class
drop				hdeg1-hdeg3		// Highest teacher's degree
drop				sbirth* // Birth info
drop				schtype1-schtype3	// Type of territory
drop				ses1-ses3 // Socio economic status
*keep if			stark==1	// Useless since in the remaining data, 
								//	all students attend STAR in kindergarten
drop				star*
drop				sysid* trace*
drop				totexp1-totexp3	// Years of total teachning experience
drop				tmathss1-tmathss3
drop				treadss1-treadss3
drop				schid1n-schid3n	// School id new ?

* Keep schools with at least two Small and Regular classes
*	Probleme, l'id de classe est perdu ; reprendre A&P (2009)
* 	We want create the estimates in Tables 9.1 and 9.2 in Imbens & Rubin (2015).
*	The data Angrist and Piscke used are from http://www.heros-inc.org/data.htm,
*	where there is the public use version of the STAR data.
*	 Problem: the public use data doesn't have class identifiers, so these are
*	 imputed (based on school characteristics, experimental group, and teacher
*	 characteristics). 

sort		schidkn cltypek

* Premiere agregation : 149 classes
egen 		classid1 = group(schidkn cltypek)
egen 		cs1 = count(classid1), by(classid1)	// # classes eleves ? par id's

* Deuxieme agregation : 
egen 		classid2 = group(classid1 totexpk hdegk cladk) if ///
				cltypek==1 & cs1 >= 20	// Small et au moins 20 classes
egen 		classid3 = group(classid1 totexpk hdegk cladk) if ///
				cltypek>1 & cs1 >= 30	// Regular et au moins 30 classes
gen 		temp = classid1*100
egen 		classid = rowtotal(temp classid2 classid3)
egen 		cs2 = count(classid), by(classid)

compress
* Inspection
order		schidkn classid cltypek cs2 classid1 cs1 classid2 classid3 temp
rename		cltypek D

* Vire quelques variables plus utiles
drop		temp cs2 classid1-classid3 ssex srace cladk hdegk newid totexpk
cls
describe
s
* Nombre d'eleves par classe
egen		STUDN=count(classid), by(schidkn classid)
order		STUDN

* Nombre de classes de chaque type (Small, Regular) par ecole
by 			schidkn classid, sort: generate ONESMALL=(_n==1&D==1)
by 			schidkn classid, sort: generate ONEREGULAR=(_n==1&D==2)
drop if		D==3
order		STUDN ONE*
egen		COUNTSMALL=sum(ONESMALL), by(schidkn) // #petites par ecole
egen		COUNTREGULAR=sum(ONEREGULAR), by(schidkn)
order		STUDN ONE* COUNT*
drop		ONE*

* Garde les ecoles ayant au moins deux classes de chaque type
keep if		COUNTSMALL>=2&COUNTREGULAR>=2

sort		schidkn classid D

* Liste les ecoles et le nombre d'eleves
table		schidkn

* Cree le SAT math
keep if 	tmathssk ~= .
sort 		tmathssk
generate 	pmath0 = 100*_n/_N
egen 		pmath = mean(pmath0), by(tmathssk)	// Les tie !!!
order		tmathssk pmath
drop		tmathssk pmath0 treadssk

sort		schidkn classid D
order		schidkn classid D STUDN COUNT*

* Etendue du SAT des eleves par ecole
tabstat 	pmath if D==1, by(schidkn) stat(min max)
tabstat 	pmath if D==2, by(schidkn) stat(min max)

* Collapse par classe : 58 classes
collapse	(max) COUNTSMALL (max) COUNTREGULAR (sum) pmath (max) STUDN, ///
				by(schidkn classid D)
rename		(schidkn classid COUNTSMALL COUNTREGULAR pmath)(SCID CLID NS NR Y)
drop		CLID

* SAT moyen par classe
replace		Y=Y/STUDN
drop		STUDN
save		"file1.dta", replace

*	Variances a la Neyman par ecole
egen			SCGROUP=group(SCID)
replace			D=2-D
label define	DL 0 "regular" 1 "small cl"
label values	D DL
generate		DIFF=0
generate		VAR=0
forvalues		I=1(1)13 {
 summarize		Y if SCGROUP==`I'&D==1
 local			MEAN1=r(mean)
 local			VAR1=r(sd)*r(sd)
 local			N1=r(N)
* 	Moyenne et variance dans le groupe temoin
 summarize		Y if SCGROUP==`I'&D==0
 local			MEAN0=r(mean)
 local			VAR0=r(sd)*r(sd)
 local			N0=r(N)
*	Difference de moyennes
 replace		DIFF=`MEAN1'-`MEAN0' if SCGROUP==`I'
* 	Estimateur de la variance (Neyman)
 replace		VAR=`VAR0'/`N0'+`VAR1'/`N1' if SCGROUP==`I'
}
*

* Collapse par type de classe (traitement
collapse	(max) NS (max) NR DIFF VAR (mean) Y, ///
				by(SCID D)
reshape wide	NS NR DIFF VAR Y, i(SCID) j(D)
compress
drop			NS1 NR1 DIFF1 VAR1
generate		N=NS0+NR0
order			SCID Y1 Y0 NS0 NR0 N
rename			(NS0 NR0 DIFF0 VAR0)(N1 N0 TAUSTRATA VARSTRATA)

cd			"C:\Users\evens\Documents\"
save 		"krueger1999_imbensrubin2015.dta", replace

*	Recupere le nombre de classes et le passe en variable locale
matrix drop _all

total			N					// Nombre total de classes
matrix define	NTOTAL=e(b)
local			NTOTAL=NTOTAL[1,1]
di				`NTOTAL'

total			N1					// Nombre total de classes tests
matrix define	N1TOTAL=e(b)
local			N1TOTAL=N1TOTAL[1,1]
di				`N1TOTAL'

total			N0					// Nombre total de classes temoins
matrix define	N0TOTAL=e(b)
local			N0TOTAL=N0TOTAL[1,1]
di				`N0TOTAL'

* Estimation de l'ECM
local			TAU=0
local			TAU1=0
local			TAU0=0
forvalues 		I=1(1)13 {
 local			TAU=`TAU'+TAUSTRATA[`I']*N[`I']
 local			TAU1=`TAU1'+TAUSTRATA[`I']*N1[`I']
 local			TAU0=`TAU0'+TAUSTRATA[`I']*N0[`I']
 }
*		

display			"Estimation de l'ECM :" `TAU'/`NTOTAL'
display			"Estimation de l'ECMT :" `TAU1'/`N1TOTAL'
display			"Estimation de l'ECMnT :" `TAU0'/`N0TOTAL'

* Construction d'un IC pour l'ECMT
*	Erreur Type
local			ET=0
forvalues		I=1(1)13 {
 local			ET=`ET'+VARSTRATA[`I']*(N1[`I']/`N1TOTAL')^2
}
*	IC
display			"Neyman avec fractile de Student :"
local			CV=invt(58,0.975)
local			EMTT=`TAU1'/`N1TOTAL'
display		"IC = [" `EMTT'-`CV'*sqrt(`ET') " ;" `EMTT'+`CV'*sqrt(`ET') "]"

* Reflexion post-cours, suite a l'intervention d'Adam sur l'estimateur stratifie
*	obtenu en une seule regression de type panel avec effets fixes
* On peut retrouver l'estimation de l'ECMT par une regression avec effets fixes 
*	pour les ecoles et une ponderation a la Horvitz-Thompson avec la proportion
*	de regular classes pour le poids 
use				"file1.dta", clear
tabulate		SCID, generate(SCID_)
replace			D=2-D
label define	DL 0 "regular" 1 "small cl"
label values	D DL
generate		WEIGHT=NR/(NS+NR)
regress			Y D SCID_1-SCID_12 [pweight=1/WEIGHT]


