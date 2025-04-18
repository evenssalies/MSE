* Evens Salies
* PSM, v1.3 10/2019, 12/2020, 12/2021, 04/2023

**********************************************
* Sous-echantillon de Card et Krueger (1994) *
**********************************************

cls
import excel using	"cardkrueger1994_short.xlsx", clear firstrow

rename				unit 	INDI
rename				d 		D
rename				x1 		CHAIN
rename				x2 		JOBINI
rename				y 		JOBFIN
label variable		CHAIN "KFC = 0, BK = 1"

* Score de propension (first period)
logit				D CHAIN JOBINI	// New Jersey (treated) = 1

* Prediction du score avec predict, sans l'option [, xb] car ce n'est pas Xb que
*	l'on souhaite predire, mais Pr(D=1|X=x):=e(x)
predict				PSCORE	// L'option [, pr] est par defaut

* Trie e(x) par ordre decroissant dans chaque groupe 
order				INDI D PSCORE
gsort				-D -PSCORE 

******************************
* Triming (dans les groupes) *
******************************

* Region possible : le max des bornes inf et le min des bornes sup
*	D=1 ].146;.705[ ET D=0 ].013;.595[, donc : [.14;.60]
*	On prend le min=max{min_0,min_1}, max=min{max_0,max_1}
generate			KEEP=(PSCORE>=.14&PSCORE<=.60)
count if 			KEEP==1
order				KEEP, after(PSCORE)

* Overlay histograms of covariates
* 	JOBINI
twoway (histogram JOBINI if D==1, width(1) color(green)) ///
	(histogram JOBINI if D==0, width(1) fcolor(none) lcolor(black)), ///
	legend(order(1 "New Jersey" 2 "Pennsylvania" )) saving(psmbinary1, replace)

twoway (histogram JOBINI if D==1&KEEP==1, width(1) color(green)) ///
	(histogram JOBINI if D==0&KEEP==1, width(1) fcolor(none) lcolor(black)), ///
	legend(order(1 "New Jersey" 2 "Pennsylvania" )) saving(psmbinary2, replace)

graph combine	psmbinary1.gph psmbinary2.gph

* CHAIN (x1 = 0 (KFC) et 1 (BK))
twoway (histogram CHAIN if D==1, discrete xlabel(0(1)1) gap(50) ///
	color(green)) ///
	(histogram CHAIN if D==0, discrete xlabel(0(1)1) gap(50) ///
	fcolor(none) lcolor(black)), ///
	xscale(noline titlegap(3)) yscale(noline titlegap(3)) ///
	graphregion(color(white)) ///
	legend(order(1 "New Jersey" 2 "Pennsylvania" )) saving(psmbinary1, replace)

twoway (histogram CHAIN if D==1&KEEP==1, discrete xlabel(0(1)1) gap(50) ///
	color(green)) ///
	(histogram CHAIN if D==0&KEEP==1, discrete xlabel(0(1)1) gap(50) ///
	fcolor(none) lcolor(black)), ///
	xscale(noline titlegap(3)) yscale(noline titlegap(3)) ytitle("") ///
	graphregion(color(white)) ///
	legend(order(1 "New Jersey" 2 "Pennsylvania" )) saving(psmbinary2, replace)

graph combine	psmbinary1.gph psmbinary2.gph
*	Resultat apres appariement sur le score : NJ (1 BG, 2 KFC), PA (2 BG, 4 KFC)
*		Memes proportions !!! 	

************************************************
* Donnees originales de Card et Krueger (1994) *
************************************************
use				"http://www.evens-salies.com/fastfood.dta", clear

generate		JOBINI=empft+0.5*emppt
drop if			chain>2	// keep BK and KFC
* firstinc : usual amount of first raise ($/hr)
* wage_st : starting wage ($/hr); NA

* Score de propension (first period)
capture drop	SCORE LOGIT KEEP
logit			state JOBINI chain wage_st firstinc, or		// New Jersey (treated) = 1
predict			SCORE
predict			LOGIT, xb
*	There are missing predictions coz there are missing X
keep if			SCORE!=.
order			state SCORE
gsort			-state -SCORE
*		D=1 ].594;.984[ ET D=0 ].160;.939[, donc, au mieux : [.60;.93]
generate		KEEP=(SCORE>=.60&SCORE<=.93)
order			KEEP, after(SCORE)
*					  SCORE>=.713&SCORE<=.894) marche encore mieux !!!

* Overlay histograms of the predictions (SCORE)
twoway 			(histogram SCORE if state==1, width(.02) color(green)) ///
				(histogram SCORE if state==0, width(.02) fcolor(none) ///
				lcolor(black)), legend(order(1 "New Jersey" 2 "Pennsylvania" )) ///
				saving(psmbinary1, replace)
twoway 			(histogram SCORE if state==1&KEEP==1, width(.02) color(green)) ///
				(histogram SCORE if state==0&KEEP==1, width(.02) fcolor(none) ///
				lcolor(black)), legend(order(1 "New Jersey" 2 "Pennsylvania" )) ///
				saving(psmbinary2, replace)
graph combine	psmbinary1.gph psmbinary2.gph

* Overlay histograms of the predictions (LOGIT)
twoway 			(histogram LOGIT if state==1, width(.1) color(green)) ///
				(histogram LOGIT if state==0, width(.1) fcolor(none) ///
				lcolor(black)), legend(order(1 "New Jersey" 2 "Pennsylvania" )) ///
				saving(psmbinary1, replace)
twoway 			(histogram LOGIT if state==1&KEEP==1, width(.1) color(green)) ///
				(histogram LOGIT if state==0&KEEP==1, width(.1) fcolor(none) ///
				lcolor(black)), legend(order(1 "New Jersey" 2 "Pennsylvania" )) ///
				saving(psmbinary2, replace)
graph combine	psmbinary1.gph psmbinary2.gph

*****************************************************************************
* Sous-echantillon de Dehejia et Wahba (2002) des donnees de Lalonde (1986) *
* Algorithme de Dehejia et Wahba pour l'estimation du Score de Propension   *
*****************************************************************************

cls

/* 

Donnees avec les deux groupes randomisés, les HOMMES seulement

	Echantillon de Lalonde (1986) du National Supported Work (NSW) program
		acces direct : http://users.nber.org/~rdehejia/data/nsw.dta

		use 	"http://www.evens-salies.com/nsw.dta", clear
		table	treat	// N_1=297, N_0=425, N=722
		des
		
		Contient les variables listees dans l'encadre du cours,
			sauf re74 (salaire en 74). Ces variables :
		treat (formation ou pas), age, education (#annees d'etudes), black,
		hispanic, married, nodegree (pas de diplome de niveau lycee+, re75 
		(salaire en 75), re78 (en 78, la variable de resultat) 

	Sous-echantillon de Dehejia et Wahba (2002) de Lalonde (1986),
		acces direct : http://users.nber.org/~rdehejia/data/nsw_dw.dta

		use		"http://www.evens-salies.com/nsw_dw.dta", clear
		table	treat	// N_1=185, N_0=260, N=445
		des
		
		Contient une variable de plus : re74

		Comparaison de quelques variables de pre-traitement */
estpost tabstat		age education black hispanic married nodegree re74 re75, ///
					by(treat) statistics(mean semean) columns(statistics) ///
					listwise nototal
esttab ., main(mean) aux(semean) unstack

/*		Remarque :	on peut utiliser l'option label si les variables ont des
					étiquettes. Les noms sont deja suffisemment explicites */

/*
	Sous-echantillon de Imbens et Rubin (2015, p. 144-145), qui est le meme que
		celui de Dehejia et Wahba (2002), mais avec deux variables en plus :
			dummy de salaire nul associée à re74=0
			dummy de salaire nul associée à re75=0

		Attention à l'unite des salaires (millier ?) */

/*	Montrer que la part des salaires nuls en 74 et 75 est un vrai problème */
qui {
		count if	treat==1
		local		N1=r(N)
		count if	treat==0
		local		N0=r(N)
		count if 	re74==0
noi:	display		"Salaires de 74 nuls : " r(N)/_N		
		count if 	re74==0&treat==1
noi:	display		"Salaires de 74 nuls chez Treated : " r(N)/`N1'		
		count if	re74==0&treat==0
noi:	display		"Salaires de 74 nuls chez Controls : " r(N)/`N0'		
		count if	re75==0
noi:	display		"Salaires de 75 nuls : " r(N)/_N		
		count if	re75==0&treat==1
noi:	display		"Salaires de 75 nuls chez treated : " r(N)/`N1'		
		count if	re75==0&treat==0
noi:	display		"Salaires de 75 nuls chez controls : " r(N)/`N0'		
noi:	display		" "
		count if	re78==0
noi:	display		"Salaires de 78 nuls : " r(N)/_N		
		count if	re78==0&treat==1
noi:	display		"Salaires de 78 nuls chez treated : " r(N)/`N1'		
		count if	re78==0&treat==0
noi:	display		"Salaires de 78 nuls chez controls : " r(N)/`N0'		
}
/* 		Résultat : on retrouve .75 .68 .71 .6 d'I&R (2015, Tbl. 14.6, p. 329) */

/*	Moins pour les salaires de 78, mais ça aura un effet sur l'évaluation */
summarize			re78
summarize			re78 if re78!=0	// env. 7658

*	Estimation du Score de Propension, grp temoin randomise (NSW)
*		(I&R, 2015, Tbl. 14.5, p. 329), on s'approche de I&R en divisant par 1000
cls
replace		re74=re74/1000			
replace		re75=re75/1000
generate	RE740=(re74==0)
generate	RE750=(re75==0)
generate	VIA1=nodegree*education	// Interaction (recommende !!!)
generate	VIA2=re74*nodegree
generate	VIA3=RE750*education

/*	Les variables du logit sont celles retenues apres utilisation d'un algo
	de selection de type stepwise par exemple (I&R, 2015, ch. 13.3).
		Nous utilisons un simple stepwise sur les variables finales plus
		age, black.
		
		Le fait que les groupes soient randomisés (appariés du coup), devrait
		rendre certaines variables explicatives non-significatives. */
stepwise	, pr(.4): ///
 logit		treat age (re74 re75) (RE740 RE750) hispanic black ///
		 		  (nodegree education) (VIA*)

/*	Prediction du modele et du score */
predict				SCORE, pr
predict				LOGIT, xb
order				treat SCORE LOGIT
count if			SCORE==.	// Toutes les predictions sont calculees

/*	Etendue dans chaque groupe */
gsort				-treat -SCORE
/*		Résultat : ??? */

/*	En passant, verifie qu'il y a plus de D=1 pour des niveaux plus eleves du
		score, le seuil etant la mediane (#Pr(D=1|X) > mediane) */
sort				SCORE
display				SCORE[_N/2]	// Score median
count if			treat==1&_n<=_N/2
count if			treat==1&_n>_N/2

/*	Histogrammes du score linearise par groupe avant triming
		(I&R, 2015, Figures 14.5a, 14.5b) */
generate		Y=LOGIT	// Plus court pour les manip !
set seed		123456789
generate		NORMAL=rnormal()
graph twoway 	(histogram NORMAL if (NORMAL>-3)&(NORMAL<3), ///
					gap(10) color(green*.2) fcolor(none)) ///
				(kdensity Y if (Y>-3)&(Y<3)&(treat==0), ///
					kernel(epanechnikov) bwidth(0.5) lcolor(gs10) ///
					lwidth(medthin)) ///
				(kdensity Y if (Y>-3)&(Y<3)&(treat==1), ///
					kernel(epanechnikov) bwidth(0.5) lcolor(black) ///
					lwidth(medthick)), ///
				xtitle("Score de propension linéarisé") ytitle("Densité") ///
				xscale(noline titlegap(3)) xlabel() yscale(titlegap(3)) ///
				legend(label(1 "N(0,1)") ///
					   label(2 "Sans formation") ///
					   label(3 "Avec formation") ///
				region(lstyle(none)) rows(1)) ///
				scheme(s1color) ///
				plotregion(fcolor(white)) graphregion(fcolor(white))

/* 	Le score est-il équilibre ? Différence normalisée sur le score linearisé
		I&R (2015, section 14.4) */
qui {
 cls
 sum			LOGIT if treat==0
 local			M0=r(mean)
 local			V0=r(sd)^2
 sum			LOGIT if treat==1
 local			M1=r(mean)
 local			V1=r(sd)^2
 local			D=(`M1'-`M0')/sqrt(0.5*(`V0'+`V1'))
 noi: 
 noi: di 		_newline(5) ///
				"**"
 noi: di 		"* La différence norm. (du score linéarisé) est égale à : " `D'
*
 if				`D'>1 {
  noi: di 		"* Les groupes de traitement sont déséquilibrés"
 }
 else {
  noi: di 		"* Les groupes de traitement sont équilibrés"
 }
 noi: di 		"**"
}

/*	Estimateur d'appariement de l'ECMT au plus proche voisin 
		
		En retirant la variable pas retenue par le logit black !!! */
replace		re78=re78/1000
nnmatch		re78 treat nodegree education hispanic re74 re75 RE* VIA* ///
			if SCORE>=0.12&SCORE<=0.76, ///
			tc(ate) m(3)
regress		re78 treat
ttest		re78, by(treat) unequal
regress		re78 treat nodegree education hispanic re74 re75 RE* VIA* ///
			if SCORE>=0.12&SCORE<=0.76
/* 	Note : refaire nnmatch avec ate pour voir qu'on est proche de regress */

/*
	Groupe(s) de contrôle non-randomise(s) de Dehejia et Wahba (2002), qui ont
		essayé de reconstruire les groupes de Lalonde, avec +- de succès

		psid_controls.dta, issu du Population Survey of Income Dynamics (PSID)
		 acces direct : http://www.nber.org/~rdehejia/data/psid_controls.dta

		psid_controls2 et 3 (memes acces), des sous-echantillons du premier

		cps_controls.dta, issu du Current Population Survey (CPS)
		 acces direct : http://www.nber.org/~rdehejia/data/cps_controls.dta
		 
		cps2_controls.dta (meme acces) et cps3_controls.dta (plus d'acces !) */

/*	Estimation du Score de Propension, grp temoin non-randomise (CPS) */
drop if				treat==0
drop				RE740 RE750 VIA* SCORE LOGIT Y NORMAL

append using		"http://www.evens-salies.com/cps_controls.dta"
replace				re74=re74/1000 if treat==0
replace				re75=re75/1000 if treat==0
generate			RE740=(re74==0)
generate			RE750=(re75==0)
generate			VIA1=age*age
generate			VIA2=RE740*RE750
generate			VIA3=re74*age
generate			VIA4=re75*married
generate			VIA5=RE740*re75

/*	Les variables retenues ont été sélectionnées par l'algorithme d'I&R (2015,
		Tbl. 14.7, p. 331) ; il n'y a plus la variable education
	
		Je vérifie qu'éducation saute.
		
		Remarque : je contraint plus la sélection avec pr(.2) car avec un
		groupe groupe de contrôle non-apparié, on améliore forcément la
		significativité des variables explicatives. */
stepwise			, pr(.2): ///
 logit		treat age married (re74 re75) (RE740 RE750) black hispanic ///
					nodegree education (VIA*)
predict				SCORE, pr
predict				LOGIT, xb
count if			SCORE==.
order				SCORE LOGIT, after(treat)

/* 	Le score est-il équilibré ? Différence normalisée sur le score linéarisé */
qui {
 cls
 sum			LOGIT if treat==0
 local			M0=r(mean)
 local			V0=r(sd)^2
 sum			LOGIT if treat==1
 local			M1=r(mean)
 local			V1=r(sd)^2
 local			D=(`M1'-`M0')/sqrt(0.5*(`V0'+`V1'))
 noi: 
 noi: di 		_newline(5) ///
				"**"
 noi: di 		"* La différence norm. (du score linéarisé) est éale à : " `D'
*
 if				`D'>1 {
  noi: di 		"* Les groupes de traitement sont déséquilibrés"
 }
 else {
  noi: di 		"* Les groupes de traitement sont équilibrés"
 }
 noi: di 		"**"
}

save			"file1.dta", replace

/*	Distance de Mahalanobis en comparaison (bien plus complique !!!)
		Formule dans I&R (2015, p. 314)
		On considere les variables du logit (hors constante !!!) :
			re74 RE740 re75 RE750 black married nodegree hispanic age VIA* */
clear all
set maxvar		20000
use				"file1.dta"
keep 		treat re74 RE740 re75 RE750 black married nodegree hispanic age ///
					VIA*
rename			(*)(v#), addnumber(0)
xpose			, clear

/*		On centre les observations */
qui {
 egen			ROWMEAN1=rowmean(v1-v185) if _n>1
 egen			ROWMEAN0=rowmean(v186-v16177) if _n>1
 forvalues		I=2(1)15 {
  forvalues		J=1(1)185 {
   replace		v`J'=v`J'-ROWMEAN1 if _n==`I'
  }
  forvalues		J=186(1)16177 {
   replace		v`J'=v`J'-ROWMEAN0 if _n==`I'
  }
 }
}

/*		Matrice de variance covariance (14*14) pour chaque groupe */
/*			Groupe test */
matrix define	SIGMA1=J(14,14,0)
forvalues		J=1(1)185 {
 mkmat			v`J' if _n>1, matrix(V)
 matrix			P=V*V'
 matrix			SIGMA1=SIGMA1+P
 matrix drop	V P
}
matrix list		SIGMA1

/*			Groupe temoin */
matrix define	SIGMA0=J(14,14,0)
forvalues		J=186(1)16177 {
 mkmat			v`J' if _n>1, matrix(V)
 matrix			P=V*V'
 matrix			SIGMA0=SIGMA0+P
 matrix drop	V P
}
matrix list		SIGMA0

/*			Calcul de la distance */
matrix			SIGMA=0.5*(SIGMA0/(185-1)+SIGMA1/(16177-185-1))
generate		ROWMEANDIFF=ROWMEAN1-ROWMEAN0 if _n>1
mkmat			ROWMEANDIFF if _n>1, matrix(D)
matrix			M=D'*inv(SIGMA)*D
local			M=sqrt(M[1,1])
display			"La distance de Mahalanobis vaut " sqrt(`M')

/*	Verification de CIA apres Triming : OSQ Y(0) = re75 !!!
		Imbens (2007, p. 40) 
		
		Remarque : c'est comme une évaluation avant
			I&R omettent RE750=(re75==0) sans trop de raison */
use				"file1.dta", clear
nnmatch			re75 treat age education black hispanic married nodegree ///
				re74 RE740, ///
				tc(att) m(1)
/*			CIA pas vérifiée : E(Y(0)|D,X) =/= E(Y(0)|X) */

gsort			-treat -SCORE
by				treat, sort: ///
				su SCORE, d
keep if			SCORE>0.1&SCORE<0.9
/*		Remarque : 	on perd énormément d'observations, mais c'est normal car
						il y avait beaucoup de scores dans les extrêmes */

nnmatch			re75 treat age education black hispanic married nodegree ///
				re74 RE740, tc(att) m(1)
/*			CIA vérifiée */

/*	Check à nouveau l'équilibre sur le score linéarisé,
		après le triming d'avant */
qui {
 cls
 sum			LOGIT if treat==0
 local			M0=r(mean)
 local			V0=r(sd)^2
 sum			LOGIT if treat==1
 local			M1=r(mean)
 local			V1=r(sd)^2
 local			D=(`M1'-`M0')/sqrt(0.5*(`V0'+`V1'))
 noi: 
 noi: di 		_newline(5) ///
				"**"
 noi: di 		"* La différence norm. (du score linéarisé) est égale à : " `D'

 if				`D'>1 {
  noi: di 		"* Les groupes de traitement sont déséquilibrés"
 }
 else {
  noi: di 		"* Les groupes de traitement sont équilibrés"
 }
 noi: di 		"**"
}
			
/*	Estimation de l'ECMT par l'estimateur d'appariement au plus proche voisin,
		après le triming d'avant */
replace		re78=re78/1000 if treat==0
nnmatch		re78 treat ///
			age education black hispanic married nodegree re74 RE740, ///
			tc(att) m(1)

/*	Essai une autre specification avec correction de biais */
nnmatch		re78 treat ///
			age education black hispanic married nodegree re74 re75 RE* VIA*, ///
			tc(att) m(1) biasadj(bias)
/*		On n'arrive pas à retrouver le résultat de l'évaluation randomisée */

/*	Estimation de l'ECM avec regress */
regress		re78 treat ///
			age education black hispanic married nodegree re74 re75 RE* VIA*
/*	Résultat :	ce n'est pas très loin de l'estimation de l'ECM dans la cas
				randomisé, mais ce n'est pas ce qui nous intéresse !!! et
				c'est trop éloigné de l'estimation de l'ECM par NNM */
nnmatch		re78 treat ///
			age education black hispanic married nodegree re74 re75 RE* VIA*, ///
			tc(ate) m(1) biasadj(bias)
		
/*	Estimation de l'ECMT avec regress (Ch. 7) */
regress		re78 ///
			age education black hispanic married nodegree re74 re75 RE* VIA* ///
			if treat==0
predict		RE780 if treat==1, xb
generate	DIFF=re78-RE780 if treat==1
ttest		DIFF=0
/*		Résultat : encore trop élevé !!! */
			
/* pscore.ado (version 2.02, 13 mai 2005), Becker et Ichino (2003)
	Estimation de l'ECMT par l'estimateur d'appariement sur le score 
		OSQ overlap (support commun des scores)
		On commance avec une specification parcimonieuse */
use			"file1.dta", clear
replace		re78=re78/1000
drop		SCORE LOGIT
cls
set more off

pscore	treat age education black hispanic married nodegree re74 re75 RE*, ///
			pscore(SCORE) ///	// generate la variable du score
			blockid(BLOC) ///	// generate la variable de strate
			numblo(5) ///		// Nombre de strates/blocs au depart
			logit ///			// Probit par defaut
			comsup /// 			// generate une dummy de support commun
			level(0.01)			// Seuil pour le balancing dans les blocs
*			detail

/*	Logit plus flexible (on ajoute VIA*) */
use			"file1.dta", clear
replace		re78=re78/1000 if treat==0
drop		SCORE LOGIT
cls
set more off

pscore		treat ///
		age education black hispanic married nodegree re74 re75 RE* VIA*, ///
			pscore(SCORE) ///	// generate la variable du score
			blockid(BLOC) ///	// generate la variable de strate
			numblo(5) ///		// Nombre de strates au depart
			logit ///			// Probit par defaut
			comsup /// 			// generate une dummy de support commun
			level(0.01) 		// Seuil pour le balancing dans les blocs
*			detail

count if	comsup==1
/*		Résultat : 	on perd beaucoup d'observation, mais moins qu'avec le
					triming !!! */

/*	Estimateur d'appariement au plus proche (score) voisin */
attnd		re78 treat ///
		age education black hispanic married nodegree re74 re75 RE* VIA*, ///
			pscore(SCORE) ///	// Pas besoin de l'option logit
			comsup
*			bootstrap reps(100) dots

/*	Estimateur stratifie de l'ECMT du chapitre 5 (sous-classification) */
atts		re78 treat, ///
			pscore(SCORE) ///
			blockid(BLOC) ///
			comsup
*			bootstrap reps(100) dots

/*
***************
* Ponderation *
*************** (exercice 6.4.5)

* Rappel estimateur Horvitz-Thompson (code "horvitzthompson.do" + tard M1)
use			"file1.dta", clear
teffects ipw (re78) ///
			 (treat age education black hispanic married nodegree ///
			 re74 re75 RE* VIA*, ///
			 logit), ///
			 atet ///
			 pstolerance(1e-5) ///	// Seuil pour le common support 
			 osample(OSAMPLE)		// generate une dummy de support commun
*			 pomeans ///			// Estime les RP ponderes (vire atet)			
*/
