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

/* Imputations */
replace			RDINV=. if alpha2=="DK"&YEAR==2020
ipolate			RDINV YEAR if alpha2=="DK", epolate generate(TEMP)
replace			RDINV=TEMP if alpha2=="DK"&YEAR==2020
drop			TEMP

/* Graphiques */
replace			RDINV=log(1+RDINV)
replace			BINDEX=1-BINDEX
rename			(RDINV BINDEX)(Y X)

/*	Retire les pays qui ont des valeurs de R&D basses (Y < 0,4) : LU, HU*/
drop if			alpha2=="LU"|alpha2=="HU"

/*	Declare data as panel format and order the data by INDI */
encode			alpha2, generate(COUN) 
	
/* Time series regressions, find countries with sign. pos. coeff. in c=f(y) */
cls
matrix define	COEFFB=J(2,1,0)
matrix define	COEFFV=J(2,2,0)
forvalues		I=1(1)11 {
 regress 		Y X if COUN==`I'
 matrix 		COEFFB=e(b)
 matrix 		COEFFV=e(V)
 local			COEFF=COEFFB[1,1]/COEFFV[1,1]^0.5
 if 			(COEFFB[1,1]!=0)&(abs(`COEFF')>2.326) {		// Fractile invnormal(0.99)
  display		`I' ", " `COEFF'
 }
}


/*	Tout les pays */
xtset			COUN YEAR
xtreg			Y X, fe
predict			YHAT, xb

#delimit;
graph twoway	(scatter Y X if COUN==3,	mfcolor(gs0%70) msymbol(o) mlwidth(none))
				(lfit Y X if COUN==3, 		color(gs0%70))
				(scatter Y X if COUN==8,	mfcolor(gs5%70) msymbol(o) mlwidth(none))
				(lfit Y X if COUN==8, 		color(gs5%70))
				(scatter Y X if COUN==1, 	mfcolor(gs13%70) msymbol(o) mlwidth(none) mcolor(gs13%70))
				(scatter Y X if COUN==2, 	mfcolor(gs13%70) msymbol(o) mlwidth(none) mcolor(gs13%70))
				(scatter Y X if COUN==4, 	mfcolor(gs13%70) msymbol(o) mlwidth(none) mcolor(gs13%70))
				(scatter Y X if COUN==5,	mfcolor(gs13%70) msymbol(o) mlwidth(none) mcolor(gs13%70))
				(scatter Y X if COUN==6, 	mfcolor(gs13%70) msymbol(o) mlwidth(none) mcolor(gs13%70))
				(scatter Y X if COUN==7, 	mfcolor(gs13%70) msymbol(o) mlwidth(none) mcolor(gs13%70))
				(scatter Y X if COUN==9, 	mfcolor(gs13%70) msymbol(o) mlwidth(none) mcolor(gs13%70))
				(scatter Y X if COUN==10, 	mfcolor(gs13%70) msymbol(o) mlwidth(none) mcolor(gs13%70))
				(scatter Y X if COUN==11, 	mfcolor(gs13%70) msymbol(o) mlwidth(none) mcolor(gs13%70))
				(lfit Y X, color(gs10) lpattern(dot) lwidth(medium))
				(lfit YHAT X, color(gs10) lpattern(longdash) lwidth(vthin)),
				legend(off)
				/* Pas de bande grise , ni cadre autour du graphique */
				graphregion(fcolor(white) lpattern(blank))
				/* Pas de grille */
				xscale(titlegap(3))
				xlabel(0 "0" .1 "10" .2 "20" .3 "30" .4 "40" .5 "50", nogrid labsize(small))
				yscale(titlegap(3))
				ylabel(5.30 "0,2" 6.68 "0,8" 8.07 "3,2" 9.46 "12,8" 10.84 "51,2" 12.23 "204,8", nogrid labsize(small))
				aspectratio(1)
				xsize(5) ysize(5)
				xtitle("Centimes de réduction sur 1 € de R&D investi", size(small))
				ytitle("R&D (Mds €)", size(small));
#delimit cr

/*	Espagne et Pays-Bas */
keep if			COU==3|COU==8
drop			YHAT
xtreg			Y X, fe
predict			YHAT, xb

#delimit;
graph twoway	(scatter Y X if COUN==3,	mfcolor(gs0%70) msymbol(o) mlwidth(none))
				(lfit Y X if COUN==3, 		color(gs0%70))
				(scatter Y X if COUN==8,	mfcolor(gs5%70) msymbol(o) mlwidth(none))
				(lfit Y X if COUN==8, 		color(gs5%70))
				(lfit Y X, color(gs10) lpattern(dot) lwidth(medium))
				(lfit YHAT X, color(gs10) lpattern(longdash) lwidth(vthin)),
				legend(off)
				/* Pas de bande grise , ni cadre autour du graphique */
				graphregion(fcolor(white) lpattern(blank))
				/* Pas de grille */
				xscale(titlegap(3))
				xlabel(0 "0" .1 "10" .2 "20" .3 "30" .4 "40" .5 "50", nogrid labsize(small))
				yscale(titlegap(3))
				ylabel(6.68 "0,8" 8.07 "3,2" 9.46 "12,8", nogrid labsize(small))
				ymlabel(7.38 "1,6" 8.76 "6,4" 10.15 "25,6")
				aspectratio(1)
				xsize(5) ysize(5)
				xtitle("Centimes de réduction sur 1 € de R&D investi", size(small))
				ytitle("R&D (Mds €)", size(small));
#delimit cr