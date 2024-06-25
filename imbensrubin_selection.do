/****************************************************************************************/
/*	In progress.									*/
/*	Select variables of the propensity score by using the 3-stage I&R's 2015	*/
/*	stepwise procedure. Use a logit prediction model		         	*/
/*		Todo list: make the command program for any number of variables.	*/
/* 		+ Note about stage 2: needs to be optimized			 	*/
/*		+ link to the right template file					*/
/*											*/
/*	FR:	Je n'ai pas besoin de parcourir les 6 variables de TEMP. Une	 	*/
/*		fois VL augmentée de la variable ayant le plus grand LR, puis		*/
/*		augmentée de la variable ayant le deuxième plus grand LR, ...,		*/
/*		l'algorithme ne mettra plus la liste à jour une fois arrivée à la 	*/
/*		dernière variable passant le test. C'est cette variable qui sera 	*/
/*		sélectionnée tout le temps, car toutes les autres qui restent ne 	*/
/*		passent pas le test 							*/
/*											*/
/*	Application:	Tran, T., Salies, E. (2023). How important is open-source	*/
/*			science for invention speed?					*/
/*			https://sciencespo.hal.science/hal-04239561/			*/
/****************************************************************************************/

cls
macro drop			_all
use				"opensourcescience.dta", clear

/*	Stage 1: basic covariates */
global				VB phasecode outward funding

/*	Stage 2: additional linear terms */ 
global				VL patents
global				TEMP cited collaborators co_author funding0 publications trials
capture drop			inward_score bloc comsup
scalar				CL=invchi2(1,.90)	/* I&R (2015) set CL to 1; give same result */
local				I=1
while				`I'<=6 {
 scalar				CHI2=0
 foreach			x in $TEMP {
  qui: logit			inwardb $VB $VL
  estimates store		M0
  qui: logit			inwardb $VB $VL `x'
  estimates store		M1
  lrtest			M0 M1
  if				r(chi2)>CL {		/* Does the covariate pass the test? */
   if				r(chi2)>CHI2 {		/* Add the covariate with the largest LR statistic */
    scalar			CHI2=r(chi2)
    local			CHI2VAR="`x'"
   }
  }
 }
 global				VL $VL `CHI2VAR'				/* Transfer the covariate */
 global				TEMP : list global(TEMP) - CHI2VAR		/*  from TEMP to VL */
 local				++I
}
global				VL : list uniq global(VL)			/* Withdraw repeated variables (*) */
display				"$VL" _newline(1) "$TEMP"
drop				_est*

/*	Stage 3: quadratic and interaction terms */		
/*		Create the variables */
capture drop			VAR*
macro drop			TEMP
local				I=1
foreach				x in $VL {
 local				J=1
 foreach			y in $VL {
  if				`I'<=`J' {
   generate			VAR`I'`J'=`x'*`y'
   global			TEMP $TEMP VAR`I'`J'
   }
  local				++J
 }
 local				++I
}
local				VAR22="VAR22"
global				TEMP : list global(TEMP) - VAR22	
drop				VAR22
display				"$TEMP"
scalar				CQ=invchi2(1,.90)	/* CQ: Pr(|N(0,1)|>CQ^.5)=Pr(chi²>CQ)=.1 */
local				I=1
while				`I'<=9 {
 scalar				CHI2=0
 foreach			x in $TEMP {
  qui: logit			inwardb $VB $VL
  estimates store		M0
  qui: logit			inwardb $VB $VL `x'
  estimates store		M1
  lrtest			M0 M1
  if				r(chi2)>CQ {		/* Does the covariate pass the test? */
   if				r(chi2)>CHI2 {		/* Add the covariate with the largest LR statistic */
    scalar			CHI2=r(chi2)
    local			CHI2VAR="`x'"
   }
  }
 }
 global				VQI $VQI `CHI2VAR'				/* Transfer the covariate */
 global				TEMP : list global(TEMP) - CHI2VAR		/*  from TEMP to VQI */
 local				++I
}
global				VQI : list uniq global(VQI)
display				"$VQI"
drop				_est*
	
/*	Estimate the score */
cls
capture drop			inward_score bloc comsup

/* From here, you can use the variables in a Stata command (regress, logit, ...) */
logit 				Y $VB $VL $VQI
