* Evens Salies, v1.3 12/2020, 11/2021
*findit nnmatch // ... puis cliquer sur st0072

********************************************
* Sous-echantillon de Card et Krueger (1994)
********************************************

import excel using	"cardkrueger1994_short.xlsx", ///
	clear firstrow

rename				(unit d x1 x2 y)(INDI D CHAIN JOBINI JOBFIN)

* Il n'y a pas d'effet par construction dans cet ex. (je verifie avec un ttest)				
ttest				JOBFIN, by(D)
regress				JOBFIN D

*	Verification que nnmatch fait le meme appariement des individus 1-4
*		pour l'estimation de l'ECMT
nnmatch				JOBFIN D CHAIN JOBINI, ///
	tc(att) m(1) exact(CHAIN) keep(matchingsave, replace)

***********************************************
* Donnees artificielles d'Abadie et alii (2004)
***********************************************

use 				"http://www.evens-salies.com/artificial.dta", clear

* Desequilibre
summarize			x if w==1
local				MEAN1=r(mean)
local				S1=r(sd)^2
summarize			x if w==0
local				MEAN0=r(mean)
local				S0=r(sd)^2
local				MEANDIFF=`MEAN1'-`MEAN0'
local				NORMDIFF=abs(`MEANDIFF'/sqrt(0.5*(`S1'+`S0')))
cls
display				"Difference des moyennes des X: " `MEANDIFF' 		
display				""
display				"Difference normalisee : " `NORMDIFF' 		

ttest				y, by(w)		// Estimateur naif
nnmatch				y w x			// Estimation de l'ECM et M = 1 par defaut
*nnmatch			y w x, tc(ate) m(1)	
nnmatch				y w x, tc(att) keep(matchingsave, replace)
nnmatch				y w x, tc(atc) keep(matchingsave, replace)
