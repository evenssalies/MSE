# Prépare les données pour la méthode du contrôle synthétique
# Méthode du contrôle synthétique
# Data source: Abadie, A., Diamond, A., & Hainmueller, J. (2010). Synthetic control methods for comparative case studies: Estimating the effect of California’s tobacco control program. Journal of the American Statistical Association, 105(490), 493–505. https://doi.org/10.1198/jasa.2009.ap08746

import pandas as pd

# Chargement du jeu de données à partir d'un fichier Stata
df = pd.read_stata("C:/Users/82128/Documents/GitHub/MSE/datasets/sc_smoking.dta")

# informations générales
print(df.info())

# Trie les données par état et par année pour une meilleure lisibilité
df = df.sort_values(by=["state", "year"]).reset_index(drop=True)

# Ajoute à côté de chaque état un identifiant numérique unique pour faciliter l'analyse (ajoute 1 pour que l'identifiant commence à 1 au lieu de 0)
df["state_id"] = df["state"].cat.codes + 1

# Place state_id à côté de state pour une meilleure lisibilité
df.insert(df.columns.get_loc("state") + 1, "state_id", df.pop("state_id"))

# Les 5 premières lignes
print(df.head())

# Affiche les états, leur indice et les années pour vérifier l'ordre
for j in range(len(df)):
    print(f"{df.at[j, 'state']:<16} {df.at[j, 'state_id']:<4} {df.at[j, 'year']}")

df.to_csv("C:/Users/82128/Documents/GitHub/MSE/datasets/sc_smoking.csv", index=False)