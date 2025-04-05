/* Evens SALIES

		Consommation dans les groupes équipés 2 et 3.

		TICELEC project:
		Members:	N. LAZARIC (CNRS)
					E. SALIES (OFCE, Sciences Po)
					S. ALLEGRET (UBINODE)
					Commune de Biot.
		Funding: 	Conseil Régional PACA.
			
	Data are anonymized */

set more off					
label drop		_all

/*	Overlap du compteur et de la distance */
cls
clear			all

global			GITHUB="https://raw.githubusercontent.com/"
global			MYREPO="$GITHUB"+"evenssalies/MSE/main/mse_6/"
local			FILEIN="$MYREPO"+"ticelec_consumption_bimonthly_final.dta"
use 			"`FILEIN'", clear

/*	Nomme les groupes */
label define		LABEL1 0 "Control" 1 "Treated"
label values		GROUP LABEL1

label define		LABEL2 0 "wheel" 1 "digital"
label values		METER LABEL2

/*	Ménage sans information */
drop if			METER==.&DIST==.

/*	Groupes */
cls
keep			GROUP METER DIST INDIV
table			GROUP METER 

/* Nuage de points DIST p/ METER */
egen			NINDIV=count(INDIV), by(METER DIST GROUP)	
*save			"ticelec_consumption_bimonthly_final.dta", replace
scatter 		DIST METER, by(GROUP) ///
				 mlabel(NINDIV) mcolor(none) mfcolor(black) mlwidth(none) ///
				 xscale(noline range(-.5 1.5)) xlabel(0(1)1) yline(20) ///
				 legend(off) scheme(s1color)

* Distribution de la consommation chez les deux groupes traités
use				"http://www.evens-salies.com/ticelec_veryshort.dta", clear

* Consommation moy./periode sans disting. GRP 
*by 				MYPERIOD, sort:	egen CONSOA=mean(CONSO)	
summarize		CONSO CONSOA, d
tsline			CONSOA if CONSOA<.02, ///
				tlabel(, format(%tcdmy)) ///
				xtitle("Temps (intervalles de 10mn)") ytitle("kW/m².uc") ///
				lwidth(vvthin) lcolor(blue*.4) ///
				scheme(s1mono) ///
				xscale(noline titlegap(3)) ///
				yscale(noline titlegap(3))

/* Standardiser
generate		CONSOD=log(CONSO)	
quie: summarize	CONSOD
replace			CONSOD=(CONSOD-r(mean))/r(sd)
order			GROUP INDIV MYPERIOD CONSO*
keep			GROUP INDIV MYPERIOD CONSO*
save			"ticelec_veryshort.dta", replace*/

* Histogramme kernel des groupes de traitement 2 et 3
set seed		21041971
generate		NORMAL=rnormal()
graph twoway 	(histogram NORMAL if (NORMAL>-4)&(NORMAL<4), ///
					width(0.2) color(green*.1) lcolor(none)) ///
				(kdensity CONSOD if (CONSOD>-4)&(CONSOD<4)&GROUP==2, ///
					lcolor(gs10)) ///
				(kdensity CONSOD if (CONSOD>-4)&(CONSOD<4)&GROUP==3, ///
					lcolor(black)), ///
				xtitle("Consommation standardisée") ytitle("Densité") ///
				xscale(noline titlegap(3)) xscale(titlegap(3)) ///
				yscale(noline) ///
				legend(label(1 "N(0,1)") ///
					   label(2 "Sans prise") ///
					   label(3 "Prise") ///
				region(lstyle(none)) cols(3)) ///
				scheme(s1color) ///
				plotregion(fcolor(white)) graphregion(fcolor(white))
