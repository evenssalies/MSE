* MSE, chapitre 2, EMT
*	Deux exemples

* 1. Y continue
cls
use			"http://www.evens-salies.com/mesri.dta", clear
keep		PAYSCODE YEAR RD_PC_TOTAL INDIRECT_PC
drop if		YEAR<2000|YEAR==2019
sort		PAYSCODE YEAR

rename		RD_PC_TOTAL Y
rename		INDIRECT_PC D
replace		D=(D>0)

rename		Y Y_0
clonevar	Y_1 = Y_0
order		D, last

replace		Y_1=. if D==0
replace		Y_0=. if D==1

* Rate of change in R&D
keep if		YEAR>=2017
by PAYSCODE, sort: replace Y_0=log(Y_0[_n])-log(Y_0[_n-1]) if _n==_N
by PAYSCODE, sort: replace Y_1=log(Y_1[_n])-log(Y_1[_n-1]) if _n==_N
keep if 	YEAR==2018
drop		YEAR
gsort		-D PAYSCODE
drop if		Y_1==.&D==1
drop if		Y_0==.&D==0

* Create observed outcome (Rubin's equation)
generate	Y=Y_0 if Y_1==.
replace		Y=Y_1 if Y_0==.

* Quick mean difference
summarize	Y if D==1
summarize	Y if D==0

* 2. Y dichotomique
* Lokshin, M., Sajaia, Z., 2011. Impact of intervention on discrete outcomes:
*	maximum likelihood estimation of the binay choice models with binary
*	endogenous regressors. The Stata Journal, 11 (3), 368-385.
*findit 		st0233

cls
clear 		all
use			"http://www.evens-salies.com/switch_probit_example.dta", clear
keep		works migrant

tabulate	works migrant, m cell
drop if		works==.

gsort		-migrant -works

rename		works WORKS_0
clonevar	WORKS_1 = WORKS_0
order		W*

replace		WORKS_1=. if migrant==0
replace		WORKS_0=. if migrant==1

generate	ECI=WORKS_1-WORKS_0

summarize	WORKS_1 if migrant==1 
summarize	WORKS_0 if migrant==0