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
keep					srace cltypek
clonevar				X=srace
label variable			X ///
 "Student race : 1 (white) 2 (black) 3 (asian) 4 (hispa.) 5 (india.) 6 (other)"
clonevar				D=cltypek
keep					D X
order					D
sort					D X
cls
by D, sort: sum			X
generate				ONE=1
egen					XN=count(X), by(D)
egen					XFREQ=count(ONE), by(D X)
generate				XFRAC=log(100*XFREQ/XN)
label variable			XFRAC "Relative frequency (%)"
*
twoway	(bar XFRAC X if D==1, barwidth(.2) lcolor(gs15) fcolor(gs15) ///
		ylabel(-5(10)5)) ///        
		(bar XFRAC X if D==2, barwidth(.2) lcolor(red) fcolor(none)) ///   
		(bar XFRAC X if D==3, barwidth(.2) lcolor(green) fcolor(none)), ///   
		legend(order(1 "Small" 2 "Regular" 3 "Regular/Aide") ///
		region(lstyle(none))) ///
		xscale(noline) ///
		scheme(s1mono)
