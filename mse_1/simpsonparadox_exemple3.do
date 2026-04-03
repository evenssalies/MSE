/*
 Paradoxe de Simpson 
  Evens SALIES
  04/2026
   Data source: JRC, OCDE
*/

/* No need de press spacebar' when the results are showing */
set more off

/* Import the data */
do				"http://www.frequency.fr/localhost" doc
use				"scoreboard_panel.dta", clear

/*	Rename/create variables */
collapse		(sum) RDINV (mean) BINDEX, by(alpha2 YEAR)
drop if			alpha2=="CY"|alpha2=="RO" // missing
drop if 		alpha2=="BE"|alpha2=="IE"|alpha2=="MT"|alpha2=="PL"| ///
				alpha2=="PT"|alpha2=="SI" // zeros

/*	Declare data as panel format and order the data by INDI */
encode			alpha2, generate(COUN) 

/* Graphiques */
replace			RDINV=log(1+RDINV)
replace			BINDEX=1-BINDEX
rename			(RDINV BINDEX)(Y X)
	
/* Time series regressions, find countries with sign. pos. coeff. in c=f(y) */
matrix define	COEFFB=J(2,1,0)
matrix define	COEFFV=J(2,2,0)
forvalues		I=1(1)13 {
 regress 		Y X if COUN==`I'
 matrix 		COEFFB=e(b)
 matrix 		COEFFV=e(V)
 local			COEFF=COEFFB[1,1]/COEFFV[1,1]^0.5
 if 			abs(`COEFF')>2.326 {		// Fractile invnormal(0.99)
  display		`I'
 }
}

/* Superpose les droites de régression */
#delimit;
graph twoway	(lfit Y X if COUN==3, color(gs0))
				(lfit Y X if COUN==10, color(gs6))
				(lfit Y X if COUN==1, color(gs15))
				(lfit Y X if COUN==4, color(gs15))
				(lfit Y X if COUN==5, color(gs15))
				(lfit Y X if COUN==6, color(gs15))
				(lfit Y X if COUN==7, color(gs15))
				(lfit Y X if COUN==8, color(gs15))
				(lfit Y X if COUN==9, color(gs15))
				(lfit Y X if COUN==11, color(gs15))
				(lfit Y X if COUN==12, color(gs15))
				(lfit Y X if COUN==13, color(gs15))
				(lfit Y X, color(gs10) lpattern(solid)),
				legend(off)
				/* Pas de bande grise , ni cadre autour du graphique */
				graphregion(fcolor(white) lpattern(blank))
				/* Pas de grille */
				xlabel(0 "0" .1 "10" .2 "20" .3 "30" .4 "40" .5 "50", nogrid labsize(small))
				ylabel(5.99 "0,4" 6.68 "0,8" 7.38 "1,6" 8.07 "3,2" 8.76 "6,4" 9.46 "12,8", nogrid labsize(small))
				ymlabel(9.84 "18,8")
				aspectratio(1)
				xtitle("Centimes de réduction sur 1 € de R&D investi") ytitle("Dépense de R&D (milliards d'euros)")
				subtitle("Espagne (noir), Pays-Bas (gris foncé), autres pays (gris très clair)", size(small) position(6)) ;
#delimit cr