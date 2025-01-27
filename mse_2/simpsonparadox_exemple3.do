/*
 Paradoxe de Yule-Simpson 
  Evens SALIES
  10/2020, 01/2023, 01/2025
   Data source: 
	 https://www.wiley.com/legacy/wileychi/baltagi/supp/Gasoline.dat
   Paper: 
	 Baltagi & Griffin (1983), 'Gasoline demand in the OECD', EER, Vol. 22, pp.
    117--137. */

/* No need de press spacebar' when the results are showing */
set more off

/* Import the data */
insheet using "http://www.evens-salies.com/baltagigriffin1983.txt", clear

/*	Rename/create variables */
rename			indi TEMP		// Country
rename			year YEAR		// Years of observation
rename			lgaspcar lGC	// Gasoline consumption per auto
rename			lincomep lYN	// Per capita income
rename			lrpmg lPP		// Gasoline price, deflated by GDP
rename			lcarpcap lCN	// Per capita stock of cars
encode			TEMP, generate(COUN)

/*	Declare data as panel format and order the data by INDI */
xtset			COUN YEAR

/* Graphiques */
scatter			lGC lYN
* Note: 	On voit que dans l'ensemble, la corrélation est négative, alors 
*			qu'elle devrait être positive. 
* 		 	Un biais de variable omise (LPP, LCN) explique certainement la 
*			corrélation négative dans certains pays, qui contamine l'ensemble.

/* Time series regressions, find countries with sign. pos. coeff. in c=f(y) */
matrix define	COEFFB=J(2,1,0)
matrix define	COEFFV=J(2,2,0)
forvalues		I=1(1)18 {
 regress 		lGC lYN if COUN==`I'
 matrix 		COEFFB=e(b)
 matrix 		COEFFV=e(V)
 local			COEFF=COEFFB[1,1]/COEFFV[1,1]^0.5
 if 			`COEFF'>1.644 {		// Fractile invnormal(0.95)
  display		`I'
 }
}

/* Résultat pour ces pays 6, 8 et 18 */
foreach			I in 6 8 18 {
 display		`I'
 regress 		lGC lYN if COUN==`I'
}

/* Superpose les droites de régression */
#delimit;
graph twoway	(scatter lGC lYN if COUN==6, ms(o) mcolor(cyan))(lfit lGC lYN if COUN==6)
				(scatter lGC lYN if COUN==8, ms(oh))(lfit lGC lYN if COUN==8)
				(scatter lGC lYN if COUN==18, ms(h) mcolor(green))(lfit lGC lYN if COUN==18)
				(lfit lGC lYN),
				legend(off)
				/* Pas de bande grise , ni cadre autour du graphique */
				graphregion(fcolor(white) lpattern(blank))
				/* Pas de grille */
				ylabel(, nogrid) 
 subtitle("Irlande (cercles verts), Allemagne (disques bleus), {c E'}tats.-Unis (disques verts)", size(small) position(6))
 xtitle("Revenu par t{c e^}te (ln)") ytitle("Consommation d'essence par voiture (ln)");
#delimit cr
