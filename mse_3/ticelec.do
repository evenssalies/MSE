/* Evens SALIES

	Random assignement for TICELEC project
		Members:	N. LAZARIC (CNRS)
				E. SALIES (OFCE, Sciences Po)
				S. ALLEGRET (UBINODE)
				Commune de Biot.
		Funding: 	Conseil Régional PACA.
			
	Data are anonymized */

set more off					
drop			_all

/*	Remove email adresses from the original data
use 			"ticelec_2011_Subscriptions_2.dta", clear
drop			addressemail
save			"ticelec.dta"
*/

use 			"/mse_3/ticelec.dta", clear

/* Rename, arrange raw data */
drop			surface accomodation billestiindiv income floors
rename			(indiv distance)(INDIV DIST)

/* Convert string variables to numeric; label "Oui"/"Non" */
label define		LABEL 0 "Non" 1 "Oui"

generate		PREQUEST=1 if prequest=="Oui"
replace			PREQUEST=0 if prequest=="Non"
drop			prequest
label values		PREQUEST LABEL

generate		QUEST=1 if quest=="Oui"
replace			QUEST=0 if quest=="Non"
drop			quest
label values		QUEST LABEL

generate		INTERNET=1 if internet=="Oui"
replace			INTERNET=0 if internet=="Non"
drop			internet
label values		INTERNET LABEL

encode			meter, generate(TEMP1)
replace			TEMP1=0 if TEMP1==2
rename			TEMP1 METER
drop			meter
label define		METERLABEL 0 "Roue" 1 "Numérique"
label values		METER METERLABEL

/* 	This automatically drops individuals who do not answer to METER and DIST */
drop if			PREQUEST==0

/* 	We add these two lines as some people who answered the pre-questionnaire 
	left blank either METER or DIST or bothmight have */
drop			if METER==.				
drop			if DIST==.				
drop			if QUEST==0
drop			QUEST PREQUEST groupfinal INTERNET

/* Set the size of the different groups */
summarize		INDIV
scalar			NTOTA=r(N)			// Size of our sample -> NTOTA
scalar			NGRP3=25			// Group 3's size
scalar			NGRP2=25			// Group 2's size
scalar			NGRP1=NTOTA-NGRP3-NGRP2		// Group 1's size

/* Random assignment */
/* 	First random draw to avoid the time-of-subscription effect */
set seed		21041971
generate		RANDN=1+int(NTOTA*runiform())
sort			RANDN

/* Individuals who have to be in the control group anyway */
generate		CONTROL=1 if METER==0|DIST>20

/* Pool them as they appear in the data set (stable option) */
sort			CONTROL, stable					
generate		IGRP=_n				// Index from 1 to N
generate		GRP=1 if IGRP<=NGRP1		// [1,NGRP1] 	<- 1
replace			GRP=2 if IGRP>NGRP1		// [NGRP1+1,N]	<- 2
replace			GRP=3 if IGRP>NTOTA-NGRP2	// [NGRP2+1,N]	<- 3
drop			IGRP RANDN CONTROL
