# Guide d'utilisation du package pins pour les analyses statistiques

## Introduction

Le package R `pins` permet de publier, versionner et partager des données et des modèles de manière reproductible. Ce guide explique comment l'utiliser dans le contexte des méthodes statistiques d'évaluation, notamment pour les analyses de séries temporelles compatibles avec le logiciel RATS (Regression Analysis of Time Series).

## Pourquoi utiliser pins ?

### Avantages principaux

1. **Versionnement automatique** : Chaque fois que vous mettez à jour un jeu de données, pins crée une nouvelle version tout en conservant les anciennes
2. **Métadonnées riches** : Ajoutez des informations sur la source, la citation, les variables, etc.
3. **Partage facile** : Partagez des données entre projets, collaborateurs, ou même entre R et d'autres logiciels comme RATS
4. **Reproductibilité** : Assurez-vous que vos analyses utilisent toujours la bonne version des données

### Cas d'usage dans ce cours

- Partager des jeux de données entre les chapitres du cours
- Versionner les données au fur et à mesure des mises à jour
- Exporter des données vers RATS pour l'analyse de séries temporelles
- Créer une bibliothèque de données de référence pour les exercices

## Installation

```r
install.packages("pins")
library(pins)
```

## Concepts de base

### Les "boards"

Un "board" est un emplacement de stockage pour vos pins. Plusieurs types existent :

- `board_folder()` : Stockage local sur le système de fichiers
- `board_url()` : Lecture seule depuis une URL
- `board_connect()` : RStudio Connect (pour l'entreprise)
- `board_s3()`, `board_gcs()`, `board_azure()` : Stockage cloud

### Opérations principales

```r
# Créer un board local
board <- board_folder(path = "~/mes_pins", versioned = TRUE)

# Épingler des données
board %>% pin_write(
  mon_dataset,
  name = "nom_du_pin",
  title = "Titre descriptif",
  description = "Description détaillée"
)

# Lire des données
donnees <- board %>% pin_read("nom_du_pin")

# Voir les métadonnées
board %>% pin_meta("nom_du_pin")

# Voir toutes les versions
board %>% pin_versions("nom_du_pin")

# Lister tous les pins
board %>% pin_list()
```

## Utilisation avec RATS

### Format des données RATS

RATS utilise généralement des fichiers texte avec :
- Séparateur : espaces ou tabulations
- En-têtes : noms de variables en première ligne
- Format : numérique avec points décimaux

### Exemple d'export pour RATS

```r
# Préparer les données
donnees_rats <- mon_dataset %>%
  select(annee, variable1, variable2, variable3)

# Exporter au format RATS
fichier_rats <- tempfile(fileext = ".dat")
write.table(donnees_rats, 
            file = fichier_rats,
            row.names = FALSE,
            col.names = TRUE,
            sep = " ",
            quote = FALSE)

# Épingler le fichier
board %>%
  pin_upload(
    paths = fichier_rats,
    name = "donnees_rats_format",
    title = "Données au format RATS",
    description = "Fichier compatible avec RATS"
  )
```

## Exemples pratiques

### Exemple 1 : Versionner des données de panel

```r
library(pins)
library(dplyr)

# Créer un board
board <- board_folder("~/pins_mse")

# Charger et épingler des données
data_panel <- read.csv("mon_fichier.csv")

board %>% pin_write(
  data_panel,
  name = "panel_education",
  title = "Données de panel sur l'éducation",
  description = "Panel d'établissements scolaires 2015-2020",
  metadata = list(
    source = "Ministère de l'Éducation",
    annees = c(2015, 2020),
    n_obs = nrow(data_panel),
    variables = colnames(data_panel)
  )
)
```

### Exemple 2 : Partager des résultats de régression

```r
# Estimer un modèle
modele <- lm(y ~ x1 + x2, data = mes_donnees)

# Créer un résumé
resultats <- list(
  coefficients = coef(modele),
  vcov = vcov(modele),
  r_squared = summary(modele)$r.squared,
  n_obs = nobs(modele)
)

# Épingler les résultats
board %>% pin_write(
  resultats,
  name = "regression_resultats",
  title = "Résultats de la régression principale",
  type = "rds"
)
```

### Exemple 3 : Créer un catalogue de données

```r
# Lister tous les pins disponibles
catalogue <- board %>% pin_list()

# Créer un tableau descriptif
pins_info <- lapply(catalogue, function(pin_name) {
  meta <- board %>% pin_meta(pin_name)
  data.frame(
    nom = pin_name,
    titre = meta$title %||% "",
    description = meta$description %||% "",
    type = meta$type,
    created = meta$created
  )
}) %>% bind_rows()

print(pins_info)
```

## Compatibilité avec les chapitres du cours

### Chapitre 3 : Tests de causalité
- Épingler les données d'expériences randomisées
- Partager les résultats de tests de Fisher

### Chapitre 5 : Stratification
- Versionner les données stratifiées
- Partager les estimateurs par strate

### Chapitre 6 : Appariement
- Épingler les scores de propension
- Partager les données appariées

### Chapitre 7 : Régression
- Versionner les données de régression discontinue
- Partager les résultats de régression

### Chapitre 8 : Différence de différences
- Épingler les données de panel (voir exemple dans mse_8)
- Exporter vers RATS pour analyse complémentaire
- Versionner les données au fil des mises à jour

### Chapitre 9 : Variables instrumentales
- Partager les instruments et leurs validations
- Versionner les données avec instruments

## Ressources supplémentaires

- Documentation officielle : https://pins.rstudio.com/
- Guide de démarrage : https://pins.rstudio.com/articles/pins.html
- Exemples : https://pins.rstudio.com/articles/

## Notes sur RATS

RATS (Regression Analysis of Time Series) est un logiciel spécialisé dans l'analyse économétrique et les séries temporelles. Le package pins facilite :

1. **L'export de données R vers RATS** : Format texte compatible
2. **Le versionnement** : Suivre les mises à jour de données temporelles
3. **La reproductibilité** : Documenter quelle version des données a été utilisée
4. **Le workflow hybride** : Combiner les forces de R (manipulation de données, graphiques) et RATS (modèles de séries temporelles avancés)

## Support

Pour des questions ou suggestions concernant l'utilisation de pins dans ce cours, veuillez ouvrir une issue sur le dépôt GitHub.
