/*	Khandker, S. R., Koolwal, G. B., & Hussain, A. S. (2010). 
	Handbook on Impact Evaluation: Quantitative Methods and Practices. 
	In The World Bank (Ed.), (pp. 262). 

	Data source: https://microdata.worldbank.org/index.php/catalog/436/get-microdata

	 Description:
	 			hh_91.dta:		CS		of 826	households in 1991
				hh_98.dta:		CS		of 1129	households in 1998
				hh_9198.dta:	CSTS	of 826 	households in 1991 and 1998 	

 There are treated and control villages identified by two variables:
  dmmfd (male treated) and dfmfd (female treated). Unit of observation is
  the household. Other variables used in this program are:
	sexhead: genre du ou de la chef de famille
 	exptot: total expenditure en Tk/(capita.year)
	hhland: surface en decimals
	thanaid: `quartier' */
clear all

use				"mse/datasets/hh_98.dta", clear

summarize		sexhead
*	Resultat : 90,8 % d'hommes, 9,2 % de femmes 
by sexhead, sort: summarize		hhland
*	Resultat : les femmes ont des surfaces plus grandes de 1,49 decimals, soit
*		environ 60,3 m²

* Variables creation and transformations
*	On commence par s'interesser a la variable de placement du programme de
*	microfinance dans les villages (log pour les elasticites)
generate		lnland=ln(1+hhland/100)	// Rq : ln(1+50/100)=0,405 ...

* Sharp design, donc vire les menages, hommes ou femmes, dont la surface est :
*	< 50 ET qui ne participent pas, >= 50 ET qui participent
drop if 		(hhland<50&(dmmfd==0|dfmfd==0))|(hhland>=50&(dmmfd==1|dfmfd==1))
*	Resultat : ne reste que 21,5 % des observations
*		Il semble que dans la deuxieme enquete, il y ait beaucoup d'attrition

* 	Le traitement
generate		D=(hhland<50)

* 	Variables jusqu'a l'odre 2
generate		Zl=ln(1+(hhland-50)/100)	// La variable Z-z_0 en log_e
generate		Zl2=Zl*Zl
generate		DZl=Zl*D
generate		DZl2=DZl*DZl

* Fixe la longueur de la bande a 10 : de 45 a 55
generate		lexptotl=ln(1+exptot)		// Pour les elasticites
regress			lexptot D Zl DZl if D==1&hhland>=45|D==0&hhland<=55
*	Resultat : 2.13 mais trop peu d'observations : 7 !!!
*		Pourtant, significativite bonne, c'est incroyable !!!

* Sans bande, les resultats ne sont pas bons, meme avec correction
*	polynomiale
regress			lexptot D Zl DZl
regress			lexptot D Zl DZl Zl2
regress			lexptot D Zl DZl Zl2 DZl2
predict			mylecptot, xb

* On fait connaissance avec locpoly (regression polynomiale locale)
capture drop	outrd
locpoly			lexptot lnland, ///
				degree(2) ///			// Degre du polynome (kernel)
				width(.5) ///			// Bande +-
				at(lnland) ///			// Pour la variable lnland
				generate(outrd) ///		// generate predictions
				tri ///					// Type de kernel
				adoonly					// Regressions dans la com., pas regress

graph twoway  scatter outrd lnland, mcolor(blue) msize(small) xline(0.4) || ///
				scatter	lexptot lnland if hhland<50, ///
					mcolor(green) || ///  
				scatter	lexptot lnland if hhland>=50, mcolor(red) msize(1)|| ///
				lfit lexptot lnland if hhland<50, lcolor(black) || ///
				lfit lexptot lnland if hhland>=50, lcolor(gs10) ///
				scheme(s1mono) xscale(noline)

* Un test local, sur la base d'un seul polynome
ttest			outrd if hhland>=45&hhland<=55, by(D)
regress			outrd D if hhland>=45&hhland<=55, vce(bootstrap)

* Un test, avec regression a gauche et a droite du seuil
locpoly 		lexptot lnland if hhland<50, gen(outrd1) at(lnland) nogr ///
				tri w(3) d(2) adoonly
locpoly 		lexptot lnland if hhland>=50, gen(outrd0) at(lnland) nogr ///
				tri w(3) d(2) adoonly
summarize		outrd1 if hhland>=45&hhland<50, meanonly
scalar			outcome1=r(mean)
summarize		outrd0 if hhland>=50&hhland<55, meanonly
scalar			outcome0=r(mean)
scalar			diff_outcome=outcome1-outcome0
display			diff_outcome
ttest			outrd1=outrd0
ttest			outrd1=outrd0 if hhland>=45&hhland<=55
drop			outrd1 outrd0

