* 1) Matching et regression
* 2) Rubin
* 3) Imbens with Lalonde's data

******************************************************
* Matching ou regression pour l'estimation de l'ECMT *
******************************************************

import excel using	"http://www.evens-salies.com/cardkruegershort.xlsx", ///
	clear firstrow
rename				(unit d x1 x2 y)(INDI D CHAIN JOBINI JOBFIN)

*
* Estimation de E(Y(0)|1) par matching 
nnmatch				JOBFIN D CHAIN JOBINI, ///
	tc(att) m(1) exact(CHAIN) keep(matchingsave, replace)
*	Estimation au plus proche voisin de l'ECMT : 0,3
*		Note : on rappelle que nnmatch c'est un TAR

* Regression dans la sous-population appariee (aller voir "matchingsave.dta")
*	(suppose un ECMT constant)
save				"temp.dta", replace
keep if				D==1|(_n==7|_n==8|_n==11|_n==15)
regress				JOBFIN D CHAIN JOBINI
*	Estimation par les MCO : 0,75

	* Detour par l'ECM
	* 	La regression tend plutot a estimer l'effet causal moyen (ECM)
	*		(sous l'hypothese que celui-ci est constant ; voir A&P, 2009, p. ?)
	*		Et au plus procheS voisinS
	use					"temp.dta", clear
	regress				JOBFIN D CHAIN JOBINI
	nnmatch				JOBFIN D CHAIN JOBINI, ///
		tc(ate) m(4) exact(CHAIN) keep(matchingsave, replace)

* Estimation de E(Y(0)|1) par regression (Rubin, 1977 ; Dehejia et Wahba, 2002,
*	p. 152, Proposition 1). Regression d'appariement, pas une regression
*		d'estimation de l'effet de D !!!
*
*	E(Y|1,X) : coefficients des var. de la regression dans le groupe test  
regress				JOBFIN CHAIN JOBINI if D==1
*	Ê(Y(1)|1,x)
predict				JOBFINHAT1 if D==1, xb

*	E(Y|0,X) : coefficients des var. de la regression dans le groupe temoin 
regress				JOBFIN CHAIN JOBINI if D==0
*	E(Y(0)|0,X), CIA => E(Y(0)|1,X), Ê(Y(0)|1,x) pour x : D=1
predict				JOBFINHAT0 if D==1, xb

*	EMTT = Ê(Y(1)|1) - Ê(Y(0)|1)
generate			EMT=JOBFINHAT1-JOBFINHAT0
sum					EMT, nod
*		PRESQUE PAREIL !!!	
*	t-Test (equal variances (same individuals INDI))
ttest				EMT=0

******************
*	Rubin (1977) *
******************

* Notes:
*	- group 0 here is 2 of Rubin, group 1 is 1 of Rubin (program)
*	- \delta here is \tau in Rubin

* Data
use			"http://www.evens-salies.com/rubin1977.dta", clear
describe	// 72 obs., 4 var.

* Scatter (Reproduit la Fig. 2 de Rubin, 1977, p. 18)
* Note: pour chaque grp, place l'effectif au croisement de PREX et POSY, So,
* 		for each PREX*POSY*GROUP value, #i's then scatter POSY POSX by(GROUP)
* Rq.:	Rubin n'affiche pas l'effectif quand il vaut 1 mais un marker ".", sans
*		doute pour ne pas encombrer la figure
rename			INDI INDIV
label define	GROUPL 0 "(Programme 2)" 1 "(Programme 1)"
label values	GROUP GROUPL
label variable	POSY "Note après"
label variable	PREX "Note avant"
egen		NINDIV=count(INDIV), by(PREX POSY GROUP)	
scatter 	POSY PREX, mlabel(NINDIV) mcolor(none) by(GROUP)		
replace		NINDIV=. if NINDIV==1	// Plus lisible, avec "." au lieu de "1"				
scatter 	POSY PREX, mlabel(NINDIV) mcolor(none) by(GROUP) ///
					mfcolor(black) mlwidth(none) legend(off) scheme(s1color)

* ECM : Estimation, fitting, linear
regress		POSY GROUP PREX			// Un mixed de l'ECMT et l'ECMnT [PROUVER]
regress		POSY PREX if GROUP==1	// Line for grp 1 only (P_X); b1=1.22
predict		POSY_1, xb			// Use grp 1 line to predict outcome of all i's
regress		POSY PREX if GROUP==0	// Line for grp 0 only (P_X); b0=0.46
predict		POSY_0, xb			// Use grp 0 line to predict outcome of all i's
generate	ATE=POSY_1-POSY_0
ttest		ATE, by(GROUP)		// 3.81 (2-sample t-test with eq. V "comb. line")
ttest		POSY_1==POSY_0		// 3.81 (paired t-test)
summarize	ATE					// Same mean but a diff. s.d., summarize does
								//	not distinguish groups
drop		POSY_1 POSY_0 ATE

* ECMT : estimation du resultat contre-factuel
regress    	POSY if GROUP==1	
predict		POSY_1, xb			// 9.76
regress		POSY PREX if GROUP==0
predict		POSY_0, xb
ttest		POSY_1==POSY_0 if GROUP==1	// 3.51 (paired t-test)
*	Remarque : on peut faire une regression avec vce(bootstrap)
*		si on veut plus de precision
generate	ATE=POSY_1-POSY_0 if GROUP==1
regress		ATE if GROUP==1, vce(bootstrap, rep(500))

drop		POSY_1 POSY_0 ATE

* Estimation, fitting, quadratic
generate	PREX2=PREX*PREX
regress		POSY PREX PREX2 if GROUP==1	
predict		POSY_1, xb
regress		POSY PREX PREX2 if GROUP==0
predict		POSY_0, xb
generate	ATE=POSY_1-POSY_0
ttest		POSY_1==POSY_0	// 3.81; almost no change=>lin. approx. ok, robust
drop		POSY_1 POSY_0 ATE PREX2

********************************************************
* Imbens manipulations of DW version of Lalonde's data *
*	Imbens (2015) ?									   *
********************************************************
* III. 		ATE in EX data
cls
cd				"C:\Users\evens\Documents\"
cd				"Evens\RESEARCH\_LITERATURE\1986_Lalonde\"

* File with N_1=185
use				"nsw_dw.dta", clear
by treat, sort:	summarize re78
*	Result: $6,349.1 - $4,554.8 = $1,794.3, Imbens concludes $2,000

* III.A. Non-experimental comparison group
* 	OLS
drop if			treat==0
* File with N_0=2490 (Imbens, 2015, p. 378)

append using	"psid_controls.dta"
keep			treat re75 re78
replace			re78=re78/1000
replace			re75=re75/1000
summarize		re78 if treat==0
*	Note : la difference avec le groupe de controle randomise est enorme
*		Appariement des caracteristiques pre-intervention necessaire ...

* Figures 1, 2, p. 378 and re75 statistics on the nonEX controls can only be
*	calculated now, but Imbens show them even before calculating the ACE
histogram 	re75 if treat==0, width(1.75) frequency xscale(range(0 160)) ///
				xlabel(0(20)160) xmtick(0(20)160)
histogram 	re75 if treat==1, width(2.5) frequency xscale(range(0 160)) ///
				xlabel(0(20)160) xmtick(0(20)160)
by treat, sort:	summarize re75
* 	Result: re75_0 (19.1, 13.6) and re75_1 (1.5, 3.2) for means and sd, ok!

*	E(Y(0)|D=1) a partir d'un modele lineaire simple E(Y|D,X)
*	OLS estimation of average potential control outcome for the treated
regress			re78 re75 if treat==0, vce(bootstrap)
										// CEF=E(Y|X,0)->b01,b02
*	Result: \beta_c (0.836, 0.0303) \alpha_c (5.601 .5463)
predict			re78_0, xb				// Use b01+b02*x for x in 0 and 1 
regress 		re78_0 if treat==1, vce(bootstrap)
										// regression on a cte to get s.e.
*	Result: 6.883 and s.e. (((2.693892^2)*(185/184))/185)^.5=.198
*	Note: this s.e. is different from that of Imbens .48
