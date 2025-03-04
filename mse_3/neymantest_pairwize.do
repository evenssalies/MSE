* Neyman test of causal inference & Tirage par paires

cls
clear all
set more off
import delimited "http://www.evens-salies.com/electric.company.short.csv", delimiters(";")

* Mise en forme des variables y y1 y0
rename			(y y0 y1)(Y Y0 Y1)
replace			Y=regexr(Y,",",".")
replace			Y0=regexr(Y0,",",".")
replace			Y1=regexr(Y1,",",".")
destring		Y Y0 Y1, replace

rename			(unit treatment)(UNIT D)

* Moyenne et variance dans le groupe test
summarize		Y if D==1
local			MEAN1=r(mean)
local			VAR1=r(sd)*r(sd)
local			N1=r(N)

* Moyenne et variance dans le groupe temoin
summarize		Y if D==0
local			MEAN0=r(mean)
local			VAR0=r(sd)*r(sd)
local			N0=r(N)

* Estimateur de la variance (Neyman ; Imbens et Rubin, 2015)
local			VAR=`VAR0'/`N0'+`VAR1'/`N1'
display			`VAR'

* Application a tout l'echantillon et analyse pairwaise randomized experiment
*	(Imbens et Rubin, 2015, ch. 10).
cls
import delimited "C:\Users\evens\Downloads\electric.company.csv", delimiters(";") clear

keep			treatedposttest controlposttest
rename			(treatedposttest controlposttest)(Y1 Y0)
replace			Y0=regexr(Y0,",",".")
replace			Y1=regexr(Y1,",",".")
destring		Y0 Y1, replace

* Calcul de la difference
generate		DIFF=Y1-Y0
summarize		DIFF
local			MEAN=r(mean)
di				`MEAN'

* Estimateur de la variance à la Neyman (pairwise)
generate		DIFFCQ=(DIFF-`MEAN')^2
total			DIFFCQ
matrix define	MAT=e(b)
local			TOTAL=MAT[1,1]
local			DDL=(e(N)/1)*(e(N)/1-1) // Attention e(N) est déjà N/2
local			VAR=`TOTAL'/`DDL'
di				`VAR'
di				"Neyman (pairwise) :"
di				"IC=[" `MEAN'-1.96*sqrt(`VAR') " ;" `MEAN'+1.96*sqrt(`VAR') "]"
                                                                
* Estimateur de la variance à la Neyman (pas pairwise)
summarize		Y1
local			MEAN1=r(mean)
local			VAR1=r(sd)*r(sd)
local			N1=r(N)
summarize		Y0
local			MEAN0=r(mean)
local			VAR0=r(sd)*r(sd)
local			N0=r(N)
local			VAR=`VAR0'/`N0'+`VAR1'/`N1'
display			`VAR'
display			"Neyman :"
display			"IC = [" `MEAN'-1.96*sqrt(`VAR') " ;" `MEAN'+1.96*sqrt(`VAR') "]"
display			"IC = [" `MEAN'-1.65*sqrt(`VAR') " ;" `MEAN'+1.65*sqrt(`VAR') "]"

* Estimateur de la variance à la Student (pairwise)
display			"Student (pairwise) :"
ci means		DIFF, level(95)

* ANOVA (1 facteur)
keep			Y0 Y1
generate		SCHOOL=_n
order			SCHOOL Y0
reshape	long	Y, i(SCHOOL) j(D)
gsort			-D SCHOOL

putdocx			begin
oneway			Y D
putdocx save	onewaytable, replace
by D, sort: su 	Y
regress			Y D
ttest			Y, by(D)
