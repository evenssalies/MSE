/* Evens SALIES

		Affectation aléatoire dans le l'évaluation TICELEC
		Members:	N. LAZARIC (CNRS)
					E. SALIES (OFCE, Sciences Po)
					S. ALLEGRET (UBINODE)
					Commune de Biot.
		Funding: 	Conseil Régional PACA, projet "Agir pour l'énergie".
			
		Les données sont anonymisées 
		On a retiré les adresses mél des données originales : 
			
			use 			".../ticelec_2011_Subscriptions_2.dta", clear
			drop			addressemail
			save			"ticelec.dta" */

set more off					
drop	_all
local	URL0="https://raw.githubusercontent.com/evenssalies/MSE/main/mse_2/"
local	FILEIN="`URL0'"+"ticelec.dta"
use		`FILEIN', clear

/* Renomme, arrange les données du fichier plat */
drop			internet floors accomodation surface ///
				billestiindiv income groupfinal
rename			(indiv distance)(INDIV DIST)

/* Crée les étiquettes utiles pour les indicatrices */
label define	LABEL 0 "Non" 1 "Oui"
label define	METERLABEL 0 "Roue" 1 "Numérique"

/*	Le ménage a-t-il répondu au pré-questionnaire ? Si non, on ne sait pas s'il
	a Internet, ni quel est son type de compteur */
generate		PREQUEST=1 if prequest=="Oui"
replace			PREQUEST=0 if prequest=="Non"
drop			prequest
label values	PREQUEST LABEL

/*	A-t-il répondu au questionnaire ? */
generate		QUEST=1 if quest=="Oui"
replace			QUEST=0 if quest=="Non"
drop			quest
label values	QUEST LABEL

/*	A-t-il un compteur à roue ou numérique ? */
encode			meter, generate(TEMP1)
replace			TEMP1=0 if TEMP1==2
rename			TEMP1 METER
drop			meter
label values	METER METERLABEL

/* 	Virer les ménages qui n'ont pas répondu au pré-questionnaire. 
		N = 165 -> N = 134 */
drop if			PREQUEST==0
drop			PREQUEST

/*	Et ceux qui n'ont pas répondu au questionnaire
		N = 134 -> N = 115 */
drop if			QUEST==0
drop			QUEST

/* 	Parmi tous les ménages qui ont répondu au pré-questionnaire, certains n'ont
	pas renseigné le type de compteur, ni la distance entre le compteur et la
	box Internet */
drop			if METER==.|DIST==.				

/*	Fixe la taille des différents groupes 
		On a besoin de la taille de l'échantillon -> NTOTA */
summarize		INDIV
scalar			NTOTA=r(N)
scalar			NGRP3=25					// Groupe 3
scalar			NGRP2=25					// Groupe 2
scalar			NGRP1=NTOTA-NGRP3-NGRP2		// Groupe 1

/*	Association d'un nombre aléatoire à chaque ménage.
 	Très important pour casser l'effet d'auto-sélection et l'effet "date
	d'entrée dans l'expérimentation" (les premiers entrés sont plus motivés)
	Dans l'article, j'ai associé 1+int(NTOTA*runiform()) plutôt que runiform().
	Cela calcule le nouveau rang. Des ménages sont ex-aequo (même rang) */ 
set seed		21041971
*generate		RANDN=runiform()
generate		RANDN=1+int(NTOTA*runiform())

/*	L'option stable conserve le rang des ex aequo tels qu'ils étaient dans la
	base avant de trier les valeurs */ 
sort			RANDN, stable

/*	Ces individus doivent aller dans le groupe de contrôle, pas le choix */
generate		CONTROL=1 if METER==0|DIST>20

/* 	Place d'abord les 54 ménages qui ne peuvent pas être équipés */
sort			CONTROL, stable					

/*	Vont dans le groupe 1 les ménages dont le numéro de ligne est <= 60 */
generate		IGRP=_n						// Indice  de 1 à N
generate		GRP=1 if IGRP<=NGRP1		// [1,NGRP1] 	<- 1

/*	Tous les ménages suivants vont dans le groupe 2 */
replace			GRP=2 if IGRP>NGRP1			// [NGRP1+1,N]	<- 2

/*	Les 25 derniers vont en fait dans le grouep 3 */
replace			GRP=3 if IGRP>NTOTA-NGRP2	// [NGRP2+1,N]	<- 3

drop			IGRP RANDN CONTROL
sort			INDIV