/* Contrôle des variables. Simulation
	Evens SALIES
	2020, 01/2023, 01/2025
  
  Variables :
		Y  : variable de resultat correlee a D, X1, X2
		D  : traitement correle a Y, X1 
		X1 : variable de confusion correlee a D et Y
		X2 : correle a Y seulement */
			
clear
set		obs 10000
do		"http://www.evens-salies.com/localhost.do"

/* La matrice de correlation
                      Y,    D,   X1,   X2 */
matrix          R=(1.00,  .75,  .50,  .25\ ///
                    .75, 1.00,  .50,  .00\ ///
                    .50,  .50, 1.00,  .00\ ///
                    .25,  .00,  .00, 1.00)

/* Une simulation d'essai */
matlist		R
drawnorm	Y D X1 X2, corr(R)

/* 	Transforme D en dummy et X1 en variable catégorielle */
replace		D=(D>0)							
replace		X1=1+autocode(X1,4,-2.0,2.0)	
/*	Note : 4 categ.
        upper bound de (-2,-1] (-1,0] (0,1] (1,2] et +1, ce qui donne
                            0      1     2     3} */

regress		Y D X1 X2
corr		Y D X1 X2
drop		Y D X1 X2

local		REP=500
matrix		V1=J(3,`REP',0)
set		seed 21041971

forvalue	I=1(1)`REP' {
 quietly {
    set obs	        10000
    drawnorm		Y D X1 X2, corr(R)
    replace		D=(D>0)
    replace		X1=1+autocode(X1,4,-2.0,2.0)
  * Le modele complet
    regress		Y D X1 X2
	matrix define 	V1[1,`I']=_b[D]
  * Le modele sans X2
    regress		Y D X1
	matrix define 	V1[2,`I']=_b[D]
  * Le modele sans X1
    regress		Y D X2
	matrix define 	V1[3,`I']=_b[D]
 }
 drop			Y D X1 X2
}

matrix 		V2=V1'
svmat 		V2, names(F)
quietly sum	F1
local		MEAN=r(mean)
hist	F1, xlabels(0.95 1.25) bin(18) fcolor(none) frac xline(`MEAN') ///
			scheme(s1mono) subtitle("Modèle sans variable omise") ///
			saving(control1, replace) xscale(noline) yscale(noline)
hist	F2, xlabels(0.95 1.25) bin(18) fcolor(none) frac xline(`MEAN') ///
			scheme(s1mono) subtitle("Variable X2 omise") ///
			saving(control2, replace) xscale(noline) yscale(noline)
hist	F3, xlabels(0.95 1.25) bin(18) fcolor(none) frac xline(`MEAN') ///
			scheme(s1mono) subtitle("Variable de confusion omise") ///
			saving(control3, replace) xscale(noline) yscale(noline)
graph 	combine	control1.gph control2.gph control3.gph, scheme(s1mono)
graph 	export control.png, width(400) replace
