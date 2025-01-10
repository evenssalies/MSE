# Diane Barat, 29/04/2021

# Packages
# install.packages("panelr")  #Panel
# Library
library(tidyverse)          #Graphique  
library(panelr)

#	Download the data
gas<-read.table("http://www.evens-salies.com/baltagigriffin1983.txt", header=T)
#attach(gas)
colnames(gas)
#	Rename/create variables
gas= gas %>%
  rename(temp = INDI,               #Country
         LGC = LGASPCAR,            #Gasoline consumption per auto
         LYN= LINCOMEP,	            #Per capita income
         LPP= LRPMG,		            #Gasoline price, deflated by GDP
         LCN= LCARPCAP )            #Per capita stock of cars

# Order the dataset by Country
gas<-gas[order(gas$temp),]

#Create Pays
for (i in 1:length(gas$YEAR)){
  gas$PAYS[i] = as.character(gas$temp[i])
}
typeof(gas$temp)
typeof(gas$PAYS)

#Equivalent ? Encode
gas$COUN<-match(gas$temp, unique(gas$temp))
View(gas)
typeof(gas$COUN)

#Declare data as panel format and order the data by INDI
gas=panel_data(gas,id=COUN, wave=YEAR)

plot(x=gas$LYN,y=gas$LGC,type="p",xlab= "LINCOMEP",  ylab= "LGASPCAR", col="dark blue", font=1)

# Note: 	On voit que dans l'ensemble, la correlation est negative, alors 
#		qu'elle devrait etre positive. 
# 	Rq: 	Un biais de variable omise (LPP, LCN) explique certainement la 
#		correlation negative dans certains pays, qui contamine l'ensemble.

# Time series regressions, find countries with positively sign. C=f(Y)

for (i in 1:18) {
  reg=lm(gas$LGC[gas$COUN==i]~gas$LYN[gas$COUN==i])
  COEFFB=coefficients(reg)
  COEFFV=vcov(reg)
  Coeff1=(COEFFB[2])/(sqrt(COEFFV[2,2]))
    if (Coeff1> 1.644) {
    print(c(gas$PAYS[which(gas$COUN==i)],i))
       }
    else {}
}

#6 8 18

#	Resultat pour ces pays 6, 8 et 18
reg6=lm(gas$LGC[gas$COUN==6]~gas$LYN[gas$COUN==6])
summary(reg6)
reg8=lm(gas$LGC[gas$COUN==8]~gas$LYN[gas$COUN==8])
summary(reg8)
reg18=lm(gas$LGC[gas$COUN==18]~gas$LYN[gas$COUN==18])
summary(reg18)

#Graphiques
#Un sous-groupe de la base de donn?es qui contient les pays concern?s Allemagne, Irlande et E.U.A.
gas2=subset(gas, gas$PAYS=="GERMANY" | gas$PAYS=="IRELAND" | gas$PAYS=="U.S.A." )

ggplot(gas, aes(x=LGC, y=LYN))+
  geom_smooth(method = "lm")+
  ggtitle("Relation consommation d'essence=f(revenu)") +
  xlab("Revenu par tete") +
  ylab("Consommation d'essence")

ggplot(gas2, aes(x = LGC, y = LYN, color = PAYS))+
  geom_smooth(method = "lm")+
  ggtitle("Relation consommation d'essence=f(revenu)") +
  xlab("Revenu par tete") +
  ylab("Consommation d'essence")