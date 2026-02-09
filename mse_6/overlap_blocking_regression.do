use	"http://www.evens-salies.com/overlap_blocking_regression.dta", clear
* This short program shows:
*	- distributions that do not overlap
*	- blocking recovers the true treatment effect

label variable		X "Variable X"

* Perfectly balanced X
by D, sort: sum		X

* Overlap
generate			ONE=1
egen				XN=count(X), by(D)
egen				XFREQ=count(ONE), by(D X)
generate			XFRAC=100*XFREQ/XN
label variable		XFRAC "Relative frequency (%)"
twoway (bar XFRAC X if D==1, barwidth(.2) lcolor(gs15) fcolor(gs15) ///
		ylabel(0(10)100)) ///        
       (bar XFRAC X if D==0, barwidth(.2) lcolor(red) fcolor(none)), ///   
       legend(order(1 "Treatment group" 2 "Control group" ) ///
	   region(lstyle(none))) ///
	   scheme(s1mono)

* After assignment to treatment groups
* 	Observed outcome
generate			YTRUE=C+D+.5*X

* Plus some noise (V is a r.v. taking 3 values, -.01, 0, .01)
generate			Y=YTRUE+V
order				Y
scatter				Y X, scheme(s1mono) || ///
					lfit Y X if D==0 || ///
					lfit Y X if D==1

* LS regression E(Y|D,X)=beta1*1+beta2*D+beta3*X, estimate for beta2 = 1
regress				Y D X	

* Now, drop one value of X in group 1, so that there is not longer overlap
replace				X=. if _n==10
regress				Y D X	

drop				XN XFREQ XFRAC
egen				XN=count(X), by(D)
egen				XFREQ=count(ONE), by(D X)
generate			XFRAC=100*XFREQ/XN
label variable		XFRAC "Relative frequency (%)"
twoway (bar XFRAC X if D==1, barwidth(.2) lcolor(gs15) fcolor(gs15) ///
		ylabel(0(10)100)) ///        
       (bar XFRAC X if D==0, barwidth(.2) lcolor(red) fcolor(none)), ///   
       legend(order(1 "Treatment group" 2 "Control group") ///
	   region(lstyle(none))) ///
	   scheme(s1mono)

* Neither there is balance
by D, sort: sum		X
	   
* We can recover beta2 een though we lose 2 observations: blocking
generate			KEEP=(X!=5&X!=.)
regress 			Y D X if KEEP==1
