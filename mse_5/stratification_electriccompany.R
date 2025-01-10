# Installe la librairie de A. Gelman, 
#	https://cran.r-project.org/web/packages/arm/index.html
# install.packages("arm")
library("arm")
electric <- read.table ("http://www.evens-salies.com/electric.dat", header=T)
View(electric)

# Charge une librairie qui fait gagner de la place dans les commandes
# install.packages("R2WinBUGS")
library("R2WinBUGS")
attach.all(electric)

# Estime l'ECM, arrondi (comme sur le graphique) et sans ajustement
round(mean(treated.Posttest))-round(mean(control.Posttest))
#	Resultat : c'est le calcul arrondi de (77-69)*21+(102-93)*34+(107-106)*20+
#		     (114-110)*21, puis divisé par 96, qui fait env. 6.02 < 5.65,
#		     la vraie difference de moyennes
mean(treated.Posttest)-mean(control.Posttest)

# Trace la Figure 9.4 de Gelman et Hill (2007, p. 174)
onlytext <- function(string){
  plot(0:1, 0:1, bty='n', type='n', xaxt='n', yaxt='n', xlab='', ylab='')
  text(0.5, 0.5, string, cex=1.2, font=2)
}
nf <- layout (matrix(c(0,1:14), 5, 3, byrow=TRUE), c(5, 10, 10),
             c(1, 5, 5, 5, 5), TRUE)
par (mar=c(.2,.2,.2,.2))
onlytext ('Distribution des notes (groupe témoin)')
onlytext ('Distribution des notes (groupe test)')

par (mar=c(1,1,1,1), lwd=0.7)
for (j in 1:4){
  onlytext(paste ('Grade', j))
  hist (control.Posttest[Grade==j], breaks=seq(0,125,5), xaxt='n', yaxt='n',
    main=NULL, col="gray", ylim=c(0,10))
  axis(side=1, seq(0,125,50), line=-.25, cex.axis=1, mgp=c(1,.2,0), tck=0)
  text (2, 6.5, paste ("moyenne =", round (mean(control.Posttest[Grade==j]))), 
	adj=0)
  text (2, 5, paste ("écart-type =", round (sd(control.Posttest[Grade==j]))), 
	adj=0)
  text (2, 3.5, paste ("n =", round (length(control.Posttest[Grade==j]))), 
	adj=0)

  hist (treated.Posttest[Grade==j], breaks=seq(0,125,5), xaxt='n', yaxt='n',
    main=NULL, col="gray", ylim=c(0,10))
  axis(side=1, seq(0,125,50), line=-.25, cex.axis=1, mgp=c(1,.2,0), tck=0)
  text (2, 6.5, paste ("moyenne =", round (mean(treated.Posttest[Grade==j]))), 
	adj=0)
  text (2, 5, paste ("écart-type =", round (sd(treated.Posttest[Grade==j]))), 
	adj=0)
  text (2, 3.5, paste ("n =", round (length(treated.Posttest[Grade==j]))), 
	adj=0)

}

t.test(treated.Posttest[Grade==4], control.Posttest[Grade==4], paired=F, var.equal=F)

