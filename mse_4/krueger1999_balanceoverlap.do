/*	STAR Experiment, 
		Krueger, A. B. (1999). Experimental estimates of education production
		functions. The Quarterly Journal of Economics, 114(2), 497-532.
		
		Replication, Evens SALIES, 11/2020, 11/2021, 03/2025 */

set more off
use 			"webstar.dta", clear
sort 			star*
order			*, alphabetic

/*	Table I, p. 503, désequilibre de la variable Free lunch
	Retrouver la P-valeur 0.09

	Une dummy par groupe en kindergarten
		stark:		attend STAR in kindergarten		{1 ; 2}
		cltypek:	classroom type in kindergarten	{1 ; 2 ; 3}
		sesk:		free lunch						{1 ; 2}
		srace:		ethnicity parents				{1 "white" ; 3 "asian"}
			*/				
keep if			stark==1
tabulate		cltypek, generate(KG_)
codebook		cltypek KG_*

/*	Balance */
/*		Free lunch */
clonevar		FL=sesk
replace			FL=2-FL
/*			Two groups (small class vs regular+aid): normalised difference */
summarize		FL if KG_1==1
local			MEAN1=r(mean)
local			S1=r(sd)^2
summarize		FL if KG_3==1
local			MEAN0=r(mean)
local			S0=r(sd)^2
local			MEANDIFF=`MEAN1'-`MEAN0'
local			NORMDIFF=abs(`MEANDIFF'/sqrt(0.5*(`S1'+`S0')))
display 		"Difference des moyennes des X: " `MEANDIFF' 		
display			""
display			"Difference normalisée : " `NORMDIFF' 		

/* 			More than two groups */
/*				Regression */
regress			FL KG_*
/*				ANOVA */
oneway			FL cltypek, tabulate

/*		White/Asian */
generate		WA=(srace==1|srace==3)
by			cltypek, sort:	///
	su		WA
regress			WA KG_*

/*	Overlap */
/* 		Free lunch */
table			cltypek sesk

/*		White/Asian and more */
keep			srace cltypek
clonevar		X=srace
label variable	X "Ethnic affiliat.: 1 = W, 2 = B, 3 = A, 4 = H, 5 = I, 6 = O"
clonevar		D=cltypek
keep			D X
order			D
sort			D X
cls
by			D, sort: 	///
	su		X
generate		ONE=1
egen			XN=count(X), by(D)
egen			XFREQ=count(ONE), by(D X)
generate		XFRAC=100*XFREQ/XN
label variable	XFRAC "Relative freq. (%)"

twoway	(bar XFRAC X if D==1, barwidth(.2) lcolor(gs15) fcolor(gs15) ///
		ylabel(0(10)70)) ///        
		(bar XFRAC X if D==2, barwidth(.2) lcolor(red) fcolor(none)) ///   
		(bar XFRAC X if D==3, barwidth(.2) lcolor(green) fcolor(none)), ///   
		legend(order(1 "Small" 2 "Regular" 3 "Regular/Aide") rows(1) ///
		region(lstyle(none))) ///
		xscale(noline) yscale(noline) ///
		scheme(s1mono)
