# Tableau 2.4
# Evens Salies, v1: 11/2017, v2: 12/2024, v3: 08/2026
# Données fictives

# Librairies
#   Pour afficher les tableaux de données dans Viewer. Remarque : chaque fois
#   qu'on exécute datatable(), un nouveau tableau est créé. La librairie Shiny
#   permet de rafraichir le tableau sans en créer un de nouveau.
#install.packages("DT")

# Données originelles
setwd("C:/Users/82128/Documents/GitHub/MSE/mse_2/")
elec <- read.csv2("mapr56.csv")
library("DT")
datatable(elec)

# Démarre avec le vecteur (0,0,0,1,1,1,1,1) pour remplir le tableau
elec$d <- c(0,0,0,1,1,1,1,1)
elec$y <- elec$d*elec$y1+(1-elec$d)*elec$y0
datatable(elec)

# Une routine automatique pour les C(8,5) affectations
#   Combien d'affectations possibles de 5 individus parmi 8 ?
choose(n=8,k=5)

# Charge la librairie des combinaisons (une seule fois)
# install.packages("combinat")
library(combinat)

# Liste les individus à traiter dans chacune des combinaisons
tvector <- combn(elec$unit,5,simplify=T)
tvector

# Déclare un vecteur de 56 colonnes et le remplit de 0 (56 EMT)
meandiffvector <- array(0, dim=c(1,56))
meandiffvector

# Calcul des 56 statistiques
for(J in 1:ncol(tvector)) {

 # Vide le vecteur de traitement (le remplit de 0)
 elec$d <- 0

 # Sélection random (valeurs de t vector) des traités, les autres éléments = 0
 for(I in 1:nrow(tvector)) {
  elec$d[tvector[I,J]] <- 1
  }

 elec$y <- elec$d*elec$y1+(1-elec$d)*elec$y0
 mean1 <- sum(elec$y[elec$d==1])/5
 mean0 <- sum(elec$y[elec$d==0])/3
 meandiff <- mean1-mean0
 meandiffvector[1,J] <- meandiff
}

meandiffvector