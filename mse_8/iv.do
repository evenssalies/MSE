* OVB, Measurement Error, 2SLS, IV
* 04/2019, 02/2020, 02/2021

* Illustration : relation salaire-education
insheet using	"http://www.evens-salies.com/MROZ.txt", tab clear

* v1  (infl):		woman gets a wage outside home during the year
* v3  (kidslt6):	#kids < 6
* v4  (kidsge6):	#kids 6-18
* v5  (age):		woman's age
* v6  (educ):		years of education
* v7  (wage):		woman's wage
* v15 (motheduc):	mother's years of schooling
* v16 (fatheduc):	father's years of schooling
* v19 (exper):		past years of labor market experience
* v20 (nwifeinc):	non-wife income
* v21 (lwage):		log(wage)
* v22 (expersq):	v19 squared

cls

****************************************
* OVB (ability is unobserved - omited) *
****************************************

* OLS
regress				v21 v6 if v7!=.

* 2SLS
*
* 	First stage IV
*		Mother's years of schooling:
*	 	- correlated with woman's education,
*	 	- but not with (intrinsic) ability (mother did not chose
*		  education on the basis of her future child's ability)
regress				v6 v15 if v7!=.
predict				v6hat, xb
regress				v21 v6hat if v7!=.

* One command for all
ivregress 2sls		v21 (v6 = v15)
*	Note: 2SLS estimator is the IV estimator

*****************************************************
* Error-in-Variabless (educ (V6) = educ* + epsilon) *
*****************************************************

*	Remarque : on considere le modele V21=f(v6, v19)
ivregress 2sls		v21 v19 (v6 = v15 v16)

regress				v6 v15 v16 v19
drop				v6hat
predict				v6hat, xb
regress				v21 v6hat v19



















