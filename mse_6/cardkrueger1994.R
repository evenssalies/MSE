# Replication of Card & Krueger in Imbens & rubin (2015)
# Evens Salies 11/2017, 02/2020, 12/2020, 11/2021, 02/2024

# Il s'agit de données Stata
library(foreign)

# Charger les données
data0 <- read.dta("http://www.evens-salies.com/fastfood.dta")
View(data0)

# Observations and variables
nrow(data0); ncol(data0)

# state: 	1 if New Jersey (NJ), 0 Pennsylvania (PA)
# empft: 	#full-time employees; NA
# emppt: 	#part-time employees; NA
# chain: 	1 if Burger King, 2 KFC, 3 Roy Rogers, 4 Wendys
# wage_st: 	initial wage
# inctime: 	time until first raise (months)
# empft2: 	#full-time employees (after intervention); NA
# emppt2: 	#part-time employees (after intervention); NA

# Create initial and final employment variables
data0$iniem <- data0$empft+0.5*data0$emppt
data0$finem <- data0$empft2+0.5*data0$emppt2

# Keep these 6 variables in the following order
data0 <- data0[c("state", "chain", "iniem", "finem", "wage_st", "inctime")]

# Sort ascendingly and these variables accordingly
data1 <- data0[order(-data0$state, data0$chain, data0$iniem, data0$finem),]

# Drop all observations which have at least one NA  
data2 <- data1[complete.cases(data1), ]
nrow(data2); ncol(data2)
View(data2)
#	Note: I get N=347 obs., as in I&R (2015), great !!! 

# Check the fraction of each chain in the groups
prop.table(table(data2$chain[data2$state==1]))
prop.table(table(data2$chain[data2$state==0]))

# Différence normalisée pour l'emploi initial
ybar1 	<- mean(data2$iniem[data2$state==1])
ybar0 	<- mean(data2$iniem[data2$state==0])
s2bar1 	<- sd(data2$iniem[data2$state==1])
s2bar0 	<- sd(data2$iniem[data2$state==0])
diffnorm 	<- (ybar1-ybar0)/sqrt((s2bar1^2+s2bar0^2)/2)
ybar1-ybar0; diffnorm

# Overlap pour la variable d'emploi initial ?
#   Jette un oeil dans la feuille de données
data2 <- data2[order(data2$iniem, -data2$state),]
View(data2)
#   Tableau de statistiques descriptives
by(data2$iniem, data2$state, summary)
#   Calcul précis
min(data2$iniem[data2$state==1])-min(data2$iniem[data2$state==0])
max(data2$iniem[data2$state==1])-max(data2$iniem[data2$state==0])
#		La distribution NJ à droite de PA !!!

# On souhaite reproduire I&R (2004, tableau 18.3)
#   Ne garder que BK, KFC (les observations for chains 1 and 2)
data3 <- data2[which(data2$chain !=3 & data2$chain !=4),]
View(data3)
nrow(data3)

# ... Feuille Excel, car trop dur de retrouver les contraintes permettant
#			   d'extraire la base reproduite dans le tableau 18.3