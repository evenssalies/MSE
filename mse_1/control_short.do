/* Contrôle des variables. Simulation
	Evens SALIES
	2020, 01/2023, 01/2025
  
  Variables :
		Y  : variable de resultat corrélée a D, X1, X2
		D  : traitement correle a Y, X1 
		X1 : variable de confusion correlee a D et Y
		X2 : correle a Y seulement */

clear
set			obs 10000
do			"http://www.frequency.fr/localhost.do"


/* La matrice de correlation théorique
 				  Y,    D,   X1,   X2 */
matrix		R=(1.00,  .75,  .50,  .25\ ///
				.75, 1.00,  .50,  .00\ ///
				.50,  .50, 1.00,  .00\ ///
				.25,  .00,  .00, 1.00)

/*	Une simulation d'essai */
matlist		R
drawnorm	Y D X1 X2, corr(R)

/*		Transforme D en variable dichotomique */
replace		D=(D>0)

/*		Transforme X1 en variable catégorielle */
replace		X1=1+autocode(X1,4,-2.0,2.0)
/*	Note : 4 catégories, des intervalles de taille (2 - (-2))/4 = 1.
						{(-2,-1] (-1,0] (0,1] (1,2]}
		Upper bound :	{-1, 0, 1, 2}
				+1	:	{0, 1, 2, 3} */

/*		Affiche la corrélation après ces transformations */
corr		Y D X1 X2
/*	Note : il y a peu de différence avec le R de départ */

/*		Modèle complet (le coefficient d'intérêt est celui devant D) */
regress		Y D X1 X2
drop		Y D X1 X2

/*	Simulation de trois modèles */
/*		Nombre de tirages */
local		REP=500

/*		Matrice 3 (lignes) x REP (colonnes) */
matrix		V1=J(3,`REP',0)

/*		Fixe la graine pour obtenir toujours cette simulation */
set			seed 21041971

forvalue	I=1(1)`REP' {
 quietly {
	set obs			10000			// Taille de la pop. dans chaque tirage */
    drawnorm		Y D X1 X2, corr(R)
    replace			D=(D>0)
    replace			X1=1+autocode(X1,4,-2.0,2.0)
    regress			Y D X1 X2		// Modèle complet
	matrix define 	V1[1,`I']=_b[D]
    regress			Y D X1			// Modèle sans la variable exogène
	matrix define 	V1[2,`I']=_b[D]
    regress			Y D X2			// Modèle sans la variable de confusion
	matrix define 	V1[3,`I']=_b[D]
 }
 drop				Y D X1 X2
}

/*	Affiche la distribution du traitement D dans les trois modèles */
/*		Transpose V1 */ 
matrix 		V1=V1'

/*		Crée une base de données de 500 obsrvations, 3 variables */
svmat 		V1, names(M)

/*		Sauve la vraie valeur du coefficient devant D du modèle complet */ 
quietly sum	M1
local		MEAN=r(mean)

hist	M1, frac bin(16) barwidth(0.005) fcolor(gs10%50) color(none) ///
			xlabels(0.90 "  " 1.0 "  " 1.1 "  " 1.2 "  " 1.3 "   ", noticks labsize(medsmall)) ///
			ylabels(0 "0" 0.05 "0,05" 0.1 "0,1" 0.15 "0,15", labsize(medsmall)) ///
			plotregion(lwidth(none)) scheme(s1mono) aspectratio(0.41) ysize(4) xsize(5) ///
			xline(`MEAN', lcolor(gs0%50) lpattern(shortdash)) ///
			xtitle("") ytitle("") subtitle("Pas de variables omises", size(medlarge)) ///
			saving(control1, replace) 
hist	M2, frac bin(16) barwidth(0.005) fcolor(gs10%50) color(none) ///
			xlabels(0.90 "   " 1.0 "   " 1.1 "   " 1.2 "   " 1.3 "   ", noticks labsize(medsmall)) ///
			ylabels(0 "0" 0.05 "0,05" 0.1 "0,1" 0.15 "0,15", labsize(medsmall)) ///
			plotregion(lwidth(none)) scheme(s1mono) aspectratio(0.41) ysize(4) xsize(5) ///
			xline(`MEAN', lcolor(gs0%50) lpattern(shortdash)) ///
			xtitle("") ytitle("") subtitle("Variable exogène omise", size(medlarge)) ///
			saving(control2, replace)
hist	M3, frac bin(16) barwidth(0.005) fcolor(gs10%50) color(none) ///
			xlabels(0.90 "0,9" 1.0 "1,0" 1.1 "1,1" 1.2 "1,2" 1.3 "1,3", labsize(medsmall)) ///
			xmlabel(`MEAN' "0,98", labgap(0pt)) ///
			ylabels(0 "0" 0.05 "0,05" 0.1 "0,1" 0.15 "0,15", labsize(medsmall)) ///
			plotregion(lwidth(none)) scheme(s1mono) aspectratio(0.4) ysize(4) xsize(5) ///
			xline(`MEAN', lcolor(gs0%50) lpattern(shortdash)) ///
			xtitle("") ytitle("") subtitle("Variable de confusion omise", size(medlarge)) ///
			saving(control3, replace)
graph 	combine	control1.gph control2.gph control3.gph, col(1) ///
			scheme(s1mono) ysize(4) xsize(3) imargin(zero)
graph 	export control.png, width(400) replace

















