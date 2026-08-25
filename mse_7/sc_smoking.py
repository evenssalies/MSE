# Méthode du contrôle synthétique
#   La librairie utilisée est pysyncon : Fordham, S. (2022), pysyncon: a Python package for the Synthetic Control Method, https://github.com/sdfordham/pysyncon

# https://sdfordham.github.io/pysyncon/synth.html

import pandas as pd
from pysyncon import Dataprep, Synth

df = pd.read_csv(
    "C:/Users/82128/Documents/GitHub/MSE/datasets/sc_smoking.csv", dtype={"state": "string"}
    )

# Informations générales sur le DataFrame et les 5 premières lignes
print(df.info())
print(df.head())

# Affiche les états, leur indice et les années pour vérifier l'ordre
for j in range(len(df)):
    print(f"{df.at[j, 'state']:<16} {df.at[j, 'state_id']:<4} {df.at[j, 'year']}")

dataprep = Dataprep(
    foo=df,
    predictors=["beer", "lnincome", "retprice", "age15to24"],
    predictors_op="mean",
    time_predictors_prior=range(1980, 1988),
    special_predictors=[
        ("cigsale", [1988], "mean"),
        ("cigsale", [1980], "mean"),
        ("cigsale", [1975], "mean")
    ],
    dependent="cigsale",
    unit_variable="state_id",
    time_variable="year",
    treatment_identifier=3,
    controls_identifier=[i for i in df["state_id"].unique() if i != 3],
    time_optimize_ssr=range(1980, 1988),
)

# Affiche les informations sur l'objet Dataprep
print(dataprep)

# Charge l'objet Synth
synth = Synth()

# Estime le modèle synthétique avec les paramètres spécifiés
synth.fit(dataprep=dataprep, optim_method="BFGS", optim_initial="ols")

# Affiche les poids des unités de contrôle dans le modèle synthétique
print(synth.weights(threshold=0.01))

# Figure 2 du papier d'Abadie et al. (2010)
synth.path_plot(time_period=range(1970, 2000), treatment_time=1988)

# Corriger la spécification du modèle et des paramètres et continuer plus tard !