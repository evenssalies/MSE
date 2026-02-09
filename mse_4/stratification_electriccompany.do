* IC (Neyman) dans le Grade 4
cls
import delimited "http://www.evens-salies.com/electric.company.csv", ///
				delimiters(";") ///
				clear

keep			treatedposttest controlposttest grade city
rename			(treatedposttest controlposttest grade city)(Y1 Y0 X C)
replace			Y0=regexr(Y0,",",".")
replace			Y1=regexr(Y1,",",".")
destring		Y0 Y1, replace

order			X C
sort			X C
* 	Moyenne et variance dans le groupe test
summarize		Y1 if X==4
local			MEAN1=r(mean)
local			VAR1=r(sd)*r(sd)
local			N1=r(N)
* 	Moyenne et variance dans le groupe temoin
summarize		Y0 if X==4
local			MEAN0=r(mean)
local			VAR0=r(sd)*r(sd)
local			N0=`N1'

*	Difference de moyennes
local			DIFF=`MEAN1'-`MEAN0'
display			"Différence de moyennes : " `DIFF'

* 	Estimateur de la variance (Neyman)
local			VAR=`VAR0'/`N0'+`VAR1'/`N1'

*	IC
cls
display			"Neyman avec fractile normal :"
display		"IC = [" `DIFF'-1.96*sqrt(`VAR') " ;" `DIFF'+1.96*sqrt(`VAR') "]"

display			"Neyman avec fractile de Student :"
local			CV=invt(42,0.975)
display		"IC = [" `DIFF'-`CV'*sqrt(`VAR') " ;" `DIFF'+`CV'*sqrt(`VAR') "]"
