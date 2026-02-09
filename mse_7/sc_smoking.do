/*	Synthetic control method, Abadie et al. (2010)
	 Chargement de la routine et exemple du papier

	Replication, Evens SALIES 10/2020, 03/2024, 11/2024

	Installe la commande
	 ssc install 	synth, replace all	*/

clear			all
macro			drop _all
matrix			drop _all
set				more off

cd 				"C:\Users\82128\Documents"
use				"sc_smoking.dta", clear

describe
sort		state year

/*	Indices individuel et temporel
		state : 39 Etats ; Californie est encode 3, Alabama 1, Arkansas 2, ...
		La base n'inclut pas les 11 Etats écartés à l'appariement (Alaska, 
		Arizona, Floride, Hawai, Oregon, Maryland, Massachussetts, Michigan, 
		New Jersey, New York, Washington), ni D. Columbia (pas un Etat) 
		year : 31 années ; 1970-2000
	Nombre d'observations
		N = 39*31 = 1209
	Année d'intervention
		T_0 = 1989
	Variable de résultat Y
		cigsale :	chiffre d'aff. des ventes de paquets/hab (env. 120$/hab.1an)
	Variables de confusion/exogènes	X
	  lnincome : 	log(Rev. menages/hab.1an)
      retprice : 	prix de detail moyen en $/100 d'un paquet (taxes incluses)
      age15to24 :	% des 15-24 ans
      beer :		gallons/hab.1an de biere (1 g = 3,78 l) */

/*	Trie les données et rapport sur la nature cylindrée du panel */
tsset			state year

/*	Récupère le nom des Etat */
decode 			state, generate(state_name)

/*	Vérifie l'encodage des pays (Alabama = 1, ..., Wyoming = 39) */
sort 			year state
local			I=1
while 			`I'<=39 {
 display %2.0f		state[`I'], state_name[`I']
 local ++I
}

/*		DiD (panel) */

/*	Deux groupes, N1=6, N0=39-6=33), T>2 periodes
		D'apres la methode du controle synthetique, on connait les Etats qui
		matchent avant l'intervention : 3, 4, 5, 19, 21, 34. On fait comme si
		ils étaient les individus tests (c'est faux, bien sûr car la Californie
		est le seul Etat réellement exposé à la hausse de taxe, pas dans les */
generate	DI=(state==3|state==4|state==5|state==19|state==21|state==34)
generate	DT=(year>=1989)
generate	DIDT=DI*DT
tabulate	state, generate(STATE_)
tabulate	year, generate(YEAR_)

* Graphique
egen			cigsale1=mean(cigsale) if DI==1, by(year)	// Groupe test
egen			cigsale0=mean(cigsale) if DI!=1, by(year)	// Groupe témoin
label variable	cigsale0 "Control"

twoway 	tsline cigsale1, ///
			color(black) lpattern(solid) lwidth(medthick) || ///
		tsline cigsale0, ///
			lpattern(dash) color(black) xline(2008, lpattern(solid)) ///
			lwidth(medthick) ///
		ytitle("per-capita cigarette sales (in packs)") xtitle("year") ///
		xlabel(1970 1975 1980 1985 1990 1995 2000) ///
		xline(1988, lpattern(shortdash)) ///
		xscale(noline titlegap(3)) yscale(titlegap(3)) ///
		plotr(m(zero)) scheme(s1mono) ///
		ylabel(0(20)150) ///
		legend(label(1 "Treated") label(2 "Control") ///
			region(lstyle(none))) ///
 title("Trends in per-capita cig. sales in the U.S.", ///
		size(medsmall)) ///
		saving(sc_smoking_figure2, replace)

/*	Difference-in-Differences avec un effet causal unique (homogène)
		DI=1 si groupe test
			Remarques : - on ne peut pas mettre tous les STATE et la cte
							(virer state=39)
						- on ne peut pas mettre DI et les STATE dummies dans la
						même régression car DI est une combinaison des STATE.
						On met soit DI=1, soit STATE ! Stata virera une des 6
						STATE dummies */
* DiD
regress		cigsale	DIDT	DI               		YEAR_1-YEAR_30
* DiD = LSD
regress		cigsale DIDT		STATE_1-STATE_38	YEAR_1-YEAR_30
* Two-Way FE
xtreg		cigsale DIDT                  			YEAR_1-YEAR_30, fe
capture drop	FE
predict			FE, u
* 	Problème : je n'arrive pas à retrouver les effets fixes du modèle précédent

drop		DI DT DIDT YEAR_* cigsale0 cigsale1 FE
*/
*************************
* Abadie et alii (2010) *
*************************

* Figure 1 : controle non-synthetique
egen			cigsalenosc=mean(cigsale) if ///
							state_name!="California", by(year)
label variable	cigsalenosc "rest of the U.S."
twoway 	tsline cigsale if state_name=="California", ///
			color(black) lpattern(solid) lwidth(medthick) || ///
		tsline cigsalenosc, ///
			lpattern(dash) color(black) xline(2008, lpattern(solid)) ///
			lwidth(medthick) ///
		ytitle("per-capita cigarette sales (in packs)") xtitle("year") ///
		xlabel(1970 1975 1980 1985 1990 1995 2000) ///
		xline(1988, lpattern(shortdash)) ///
		xscale(noline titlegap(3)) yscale(titlegap(3)) ///
		plotr(m(zero)) scheme(s1mono) ///
		ylabel(0(20)150) ///
		legend(label(1 "California") label(2 "rest of the U.S.") ///
			region(lstyle(none))) ///
 title("Trends in per-capita cig. sales: Calif. vs. the rest of the U.S.", ///
		size(medsmall)) ///
		saving(sc_smoking_figure2, replace)

* Figure 2 : controle synthetique
sort			state year
synth			cigsale ///
				beer lnincome retprice age15to24 ///
				cigsale(1988) cigsale(1980) cigsale(1975), ///
				trunit(3) trperiod(1989) xperiod(1980(1)1988) ///
				nested ///
				keep(sc_smoking_placebo_3) replace ///
				fig
				*unitnames(state_name)
				*counit(1 2 4) maxiter(20)

* Personnel : calcul manuel du RMSPE (detailler !!!) pour plus tard,
*  et verification qu'on a compris ce qu'est le RMSPE dans Abadie et al (2010)
*
* 	Une idee du format des vecteurs et matrices sauves
ereturn list
*	Notre propre calcul des vecteurs et matrices necessaires au calcul du RMSPE
matrix			TEMP1=e(Y_synthetic)
matrix			TEMP2=e(Y_treated)
matrix define	RMSPE=J(1,1,0)
matrix define	RMSPE3=J(1,1,0)
matrix define	RMSPE[1,1]=e(RMSPE)		// Cette ligne declar. auto. RMSPE
*matrix define	RMSPE3[1,1]=e(RMSPE)	// Pour plus tard
matrix rownames RMSPE3 = 3				// La Californie est l'Etat 3 
local			RMSPE=RMSPE[1,1]
svmat			TEMP1, names(YS)		// On met Cal. et Cal synth dans les 
svmat			TEMP2, names(YT)		//  lignes 1 a 31
rename			(YT1 YS1)(YT YS)  
generate		DIFF=YT-YS
generate		DIFFQ=DIFF^2
summarize		DIFFQ if year<=1988		// Post-P99 commence en 1989
display			sqrt(r(mean)) " et " `RMSPE'	
*matrix 			dir
*macro 			list _all

* Figure 3, p. 501, ecart entre Y_1 et Y_1(0)
tsline			DIFF, ///
				ytitle("Ecart") xtitle("Année") ///
				yline(0) xline(1988) ///
				tlabel(1970(5)2000, angle(forty_five)) ///
				legend(off) scheme(s1color) xscale(noline)

* Placebo
*	Sauve le fichier avec le vrai individu traite (Californie)
*		CHECK THE FOLDER !!!!!!!!!!!!!!!!!!
preserve
 keep			in 1/31
 keep			year YT YS
 generate		state = 3		// Californie
* order			state year YT YS
 save			"sc_smoking_placebo_3", replace
restore

/*
synth 	Y					//	Dependante 
		Z 					//	Explicatives classiques (X de Xb)
		Y(0),				//	Pre-traitement (Y avant la date d'interv.)
			Rq : Z et Y(0) sont transformes : moyennes de t=1 à T_0 par defaut
				 On peut aussi specifier les periodes : 
					Z : moyenne de 1 a T_0 (defaut) ou de () dans xperiod()
					Z(a1) : 		une annee (pas de moy.)
					Z(a1&Za3) : 	moy. sur deux annees
					Z(a1(1)an) : 	moy. sur an-a1+1 annees (sans trou)
						Si sur que Z pas affecte par D, alors a>=T_0+1 possib.
						miss. val.ignorees (la moy. calc. sur les t restantes)
		trunit(#) 			// 	unite test
		trperiod(#)			// 	# = annee d'interv. 
		counit(numlist)		//	unites temoins (toutes par defaut, ou >=2)  
		xperiod(numlist)	//	per. incluse dans celle de pre-trait. po. moy
!		mspeperiod()		//	per. (pre-trait. par defa.) de min. de SCEP(*)
		resultsperiod()		//	per. d'affichage po. le graph. (1-T par def.)
		nested				//	optim. plus precise/lente pour calc. V (diag.)
			Rq : le prg s'appuyant sur maximize, on peut utiliser iterate(#)
		allopt				//	optimisation encore plus precise/lente
		unitnames(varname)	//	variable string des unites qu'on a encodees
		figure				//	graphe la prediction
		keep(file)			//	sauve dans file (faire pwd pour savoir ou) :
			_time : 			time variable
			_Y_treated : 		Y_{1,t}
			_Y_synthetic : 		Y_{1,t}(0) predit
			_Co_Number :		unites temoins
			_W_weight :			W
		replace				//	replace "file" de keep
		customV(numlist)	//	matrice V de depart perso (diag.)
		optsettings			//	options d'optim.
			margin(real) :		seuil de tolerance (0.05 par defaut)
			maxiter(#) :		# = nombre d'iterations (1000 par defaut)
				Rq : si l'option nested active, maxiter ne sert a rien
			sigf(#) :			# = nombre de decimales
			bound(#) :			Clipping bound for the variables (10 par def.)
		ereturn list		//	liste des matrices recuperables :
			e(V_matrix) : 		poids des variables normalisees
			e(X_balance) :		Z1,Y1(0) et Zj,Yj(0)
			e(W_weights) :		w_j, j
			e(Y_treated) :		Y_{1,t}, 1-T ou les t de resultsperiod()
			e(Y_synthetic) :	Y_{1,t}(0), idem
			e(RMSPE) :			la SCEP (scalaire)
(*) : somme des carres des erreurs de prevision

Le code Placebo :
		This is a code example to run placebo studies by
        iteratively reassigning the intervention in space
        to the first four states. To do so, we simply run
        a four loop each where the trunit() setting is
        incremented in each iteration. Thus, in the n of
        synth state number one is assigned to the
        intervention, in the second run state number two,
        etc, etc. In each run we store the RMSPE and
        display it in a matrix at the end.
*/


* STOP !!!!!!!!!!!!!!!!!!!

cls
set 			more off
tempname 		resmat			// Nom de la matrice
forvalues 		I = 1/39 {
 if `I'!=3&`I'!=34 {			// L'individu 34 bugue
  synth			cigsale ///
				beer lnincome retprice age15to24 ///
				cigsale(1988) cigsale(1980) cigsale(1975), ///
				trunit(`I') trperiod(1989) xperiod(1980(1)1988) ///
				nested ///
				keep(sc_smoking_placebo_`I') replace
  matrix 		`resmat' = nullmat(`resmat') \ e(RMSPE)	// Augmente d'une ligne
  local			names `"`names' `"`I'"'"'				// Concatene les "I"
  }
}

* Affiche une matrice des RMSPE, un pour chaque j de `names' du test placebo
*	(hors Californie, donc) 
matrix			colnames `resmat' = "RMSPE"
matrix			rownames `resmat' = `names'
matlist 		`resmat', row("Treated Unit")
matrix			RESMAT = `resmat'	// Copie la matrice pour plus tard
*	Resultat : on remarque qu'il y a d'autres etats candidats du point de vue du
*		RMSPE : 7, 14, 18, 26, 28, 30, 36


************
* Graphiques
************

* Pour chaque numero de la liste `names', sauve un fichier propre
foreach I in `names' {
  local			FILENAME = "sc_smoking_placebo_"+"`I'"
  use			"`FILENAME'", clear
  drop			_Co_Number _W_Weight
  keep 			in 1/31
  rename		(_Y_treated _Y_synthetic _time)(YT YS year)
  generate		state=`I'
  order			state year YT YS
  save			"`FILENAME'", replace
}

* Empile les fichiers
*	Note : comme Utah (34) bugue, il y a un trou dans la suite des noms des
*	 fichiers, donc on fait remonter le 39 a la place du 34
drop			_all
use				"sc_smoking_placebo_39.dta", clear
replace			state = 34 if state == 39
save			"sc_smoking_placebo_34.dta", replace
erase			"sc_smoking_placebo_39.dta"
use				"sc_smoking_placebo_3.dta", clear
forvalues I=1(1)38 {
 if `I'!=3 {
  local			FILENAME = "sc_smoking_placebo_"+"`I'"
  append		using "`FILENAME'"
 }
}
		
* Figure 4, p. 502
*	La courbe 34 est en fait la 39. synth plante pour l'Utah (34), il n'y a
*   donc pas de sc_smoking_placebo_34. Mais xtline a besoin que les plot#opts 
*	se suivent, sans trou (... plot33opts, plot34opts, plot35opts ...). J'ai
*	donc renome le 39 en 34. Il y a une solution plus sale, pour laquelle je
*	n'ai pas besoin de renomer state 39 en 34 : xtline numerote en interne
*	les time series successives de 1 a 38, puisqu'il n'y en a que 38,
*	le 34 est en fait le 35, ..., et le 38 est en fait 39. Donc,
*	si je numerote les plot#opts sans trou de 1 a 38, c'est bon.
sort			state year
xtset			state year
*drop			DIFF
generate		DIFF=YT-YS
*drop 			DIFF2
generate		DIFF2=DIFF
generate		DIFFQ=DIFF^2			// Pour plus tard (Figure 8)
* Les courbes sont en deca de -30 et au-dela de 30, trimer avec missing
replace			DIFF2=. if DIFF>30 
replace			DIFF2=. if DIFF<-30
xtline			DIFF2, overlay i(state) t(year) ///
				ytitle("Ecart") xtitle("Année") ///
				yline(0, lcolor(black) lpattern(dash)) ///
				yscale(axis(1) r(0 30)) ylabel(-30(10)30) ///
				tline(1988, lcolor(black) lpattern(dash)) ///
				tlabel(1970(5)2000 1988, angle(forty_five)) ///
				legend(off) scheme(s1color) ///
				plot1opts(lcolor(gs10)) ///
				plot2opts(lcolor(gs10)) ///
				plot3opts(lcolor(black) lwidth(medthick)) ///
				plot4opts(lcolor(gs10)) ///				
				plot5opts(lcolor(gs10)) ///
				plot6opts(lcolor(gs10)) /// 
				plot7opts(lcolor(gs10)) ///
				plot8opts(lcolor(gs10)) ///
				plot9opts(lcolor(gs10)) ///
				plot10opts(lcolor(gs10)) ///
				plot11opts(lcolor(gs10)) ///
				plot12opts(lcolor(gs10)) ///
				plot13opts(lcolor(gs10)) ///
				plot14opts(lcolor(gs10)) ///
				plot15opts(lcolor(gs10)) ///
				plot16opts(lcolor(gs10)) ///
				plot17opts(lcolor(gs10)) ///
				plot18opts(lcolor(gs10)) ///
				plot19opts(lcolor(gs10)) ///
				plot20opts(lcolor(gs10)) ///
				plot21opts(lcolor(gs10)) ///
				plot22opts(lcolor(gs10)) ///
				plot23opts(lcolor(gs10)) ///
				plot24opts(lcolor(gs10)) ///
				plot25opts(lcolor(gs10)) ///
				plot26opts(lcolor(gs10)) ///
				plot27opts(lcolor(gs10)) ///
				plot28opts(lcolor(gs10)) ///
				plot29opts(lcolor(gs10)) ///
				plot30opts(lcolor(gs10)) ///
				plot31opts(lcolor(gs10)) ///
				plot32opts(lcolor(gs10)) ///
				plot33opts(lcolor(gs10)) ///
				plot34opts(lcolor(gs10)) ///
				plot35opts(lcolor(gs10)) ///
				plot36opts(lcolor(gs10)) ///
				plot37opts(lcolor(gs10)) ///
				plot38opts(lcolor(gs10))

				
* Figure 8, p. 503, Calcul du ratio Post-P99/Pre-P99
matrix define	RMSPERATIO=J(38,3,0)
forvalues		I=1(1)38 {				// 39-1, rappel qu'on a perdu l'Utah 
 summarize		DIFFQ if state==`I'&year<=1988
 local			RMSPEPRE=r(mean)
 summarize		DIFFQ if state==`I'&year>1988
 local			RMSPEPOS=r(mean)
 matrix			RMSPERATIO[`I',1]=`RMSPEPRE'
 matrix			RMSPERATIO[`I',2]=`RMSPEPOS'
 matrix			RMSPERATIO[`I',3]=`RMSPEPOS'/`RMSPEPRE'
}

matlist			RMSPERATIO
preserve
 sort			year state
 keep			in 1/38
 keep			state
 svmat			RMSPERATIO, names(RMSPERATIO_)
 tostring 		state, generate(state_name)
 replace 		state_name="California" if state_name=="3"
 save			"sc_smoking_RMSPERATIO.dta", replace
 hist 			RMSPERATIO_3, ///
					scheme(s1mono) lwidth(none) width(1) frequency ///
					xlabel(0(20)120) addlabopts() mlabel(state_name) ///
					mlabposition(12)
restore

**************************
* Intervalles de confiance
**************************

* Intervalle de confiance bootstrap du RMSPE a 90 %
preserve
 sort			year state
 keep			in 1/38
 keep 			state
 matrix define	RMSPEV = RESMAT \ RMSPE3
 svmat			RMSPEV, names(RMSPE_)
 save			"sc_smoking_RMSPE.dta", replace
 summarize		RMSPE_		// Statistiques de l'echantillon observe
 set 			seed 21041971
 bootstrap		MEAN=r(mean), size(38) reps(10000) level(90) ///
  saving(sc_smoking_bootstrap, replace): summarize RMSPE
 use			"sc_smoking_bootstrap.dta", clear
 matlist		e(b), row("Moy. echant.")
 matlist		e(b_bs), row("Moy. bootst.")
 matlist		e(V), row("Erreur type ")
 matlist		e(ci_normal), row("Frac. N(0,1)")
 matrix			CIN=J(2,1,0)
 matrix			CIN=e(ci_normal)
 local			CING=CIN[1,1]
 local			CIND=CIN[2,1]
 local			RMSPE3=RMSPE3[1,1]
 display		`RMSPE3'
 summarize 		MEAN, d		// Statistiques de re-echantillonnage
 matlist		e(ci_percentile), row("Frac. boots.")
 twoway hist	MEAN, bin(20) lwidth(none) fcolor(gs10) ///
			title("Intervalle de confiance du RMSPE (90 %)") ///
			subtitle("Bootstrap (continue), Gauss (tirets)") ///
			ytitle("Frq. relative") xtitle("RMSPE") ///
			xlabel(0(2)12 1.75, alternate) ///
			xline(`r(p5)' `r(p95)', lcolor(black) lpattern(solid)) ///
			xline(`CING' `CIND', lcolor(black) lpattern(dash)) ///
			xline(`RMSPE3', lcolor(red) lpattern(shortdash)) ///
			legend(off) scheme(s1color) xscale(noline)
restore
// Sauve le graphique
