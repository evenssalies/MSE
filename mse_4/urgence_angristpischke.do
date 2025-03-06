* Angrist and Pischke (2009, p. 13)
*	Source http://economics.mit.edu/faculty/angrist/data1/mhe/mhe
* 	Note: I renamed "nhis_13.dta" as "urgence_angristpischke.dta"

clear		all
use			"http://www.evens-salies.com/urgence_angristpischke.dta"

* phstat: Excell. 1, V. good 2, Good 3, Fair 4, Poor 5, Refused 7, Don't know 9
* phospy: No 2, Yes 1, Refused 7, Don't know 9
keep		if phstat<=5 & phospy<=2	// Eliminate non-responses
generate	HEALTH=6-phstat				// HEALTH increases with health
by phospy, sort:	summarize HEALTH
generate	GROUP=phospy
replace		GROUP=0 if GROUP==2

* Check the test statistics by hand, assuming equal variances
summarize	HEALTH if GROUP==1
scalar		N1=r(N)
scalar		M1=r(mean)
scalar		V1=r(Var)
summarize	HEALTH if GROUP==0
scalar		N0=r(N)
scalar		M0=r(mean)
scalar		V0=r(Var)
scalar		STNUM=M1-M0
scalar		STDEN1=(1/N1+1/N0)^0.5
scalar		STDEN2=(((N1-1)*V1+(N0-1)*V0)/(N1+N0-2))^0.5
scalar		ST=STNUM/(STDEN1*STDEN2)
display		"La statistique de test vaut " ST

* Assuming equal variances (attention, Stata retire la moy. du grp D=1 a D=0)
ttest		HEALTH, by(GROUP)					// 58.9

* Assuming unequal variances
ttest		HEALTH, by(GROUP) unequal			// -48.9

* IC (Neyman) Pas applicable normalement ici
local			VAR=V0/N0+V1/N1
display			"Neyman :"
display		"IC = [" STNUM-1.96*sqrt(`VAR') " ;" STNUM+1.96*sqrt(`VAR') "]"
