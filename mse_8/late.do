* LATE
* Khandker, S. R., Koolwal, G. B., & Hussain, A. S. (2010). 
*	Handbook on Impact Evaluation: Quantitative Methods and Practices. 
*	In The World Bank (Ed.), (pp. 262). 


* Description:	hh_91.dta:		CS		of 826	households in 1991
*				hh_98.dta:		CS		of 1129	households in 1998
*				hh_9198.dta:	CSTS	of 826 	households in 1991 and 1998 	


* There are treated and control villages identified by two variables:
*  dmmfd (male treated) and dfmfd (female treated). Unit of observation is
*  the household. Other variables used in this program are:
*	sexhead: genre du ou de la chef de famille
* 	exptot: total expenditure/(capita.year)
*	hhland: surface en decimals
clear all

use				"http://www.evens-salies.com/hh_98.dta", clear
keep			sexhead hhland dmmfd dfmfd exptot

summarize		sexhead
*	Resultat : 90,8 % d'hommes, 9,2 % de femmes 
by sexhead, sort: summarize		hhland
*	Resultat : les femmes ont des surfaces plus grandes de 1,49 decimals, soit
*		environ 60,3 m²

* Variables creation and transformations
*	On commence par s'interesser a la variable de placement du programme de
*	microfinance dans les villages (log pour les elasticites)
generate		lnland=ln(1+hhland/100)	// Rq : ln(1+50/100)=0,405 ...

* Variable de participation au niveau du menage (si les deux participent)
generate		D=(dmmfd==1|dfmfd==1)
table			D

* Variable d'eligibilite
generate		Z=(hhland<50)
tabulate		D Z, cell

* Variable de depenses
generate		lexptotl=ln(1+exptot)		// Pour les elasticites

cls

* Estimation standard (biaisee)
regress			lexptotl D sexhead

* 2SLS (Stata)
ivregress 2sls	lexptotl sexhead (D = Z)

* 2SLS (manual)
regress			D Z sexhead
capture drop	DA
predict			DA, xb
regress			lexptotl DA sexhead

* Wald estimator of LATE = 2SLS
regress			lexptotl Z sexhead
local			NUM=_b[Z]
regress			D Z sexhead
local			DEN=_b[Z]
local			WALD=`NUM'/`DEN'
display			`WALD'