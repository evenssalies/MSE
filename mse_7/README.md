Lien vers l'article de [Abadie et al. (2010)](https://economics.mit.edu/sites/default/files/publications/Synthetic%20Control%20Methods.pdf).

## Utilisation du package pins avec les données de séries temporelles

Le fichier [pins_timeseries_example.R](pins_timeseries_example.R) démontre comment utiliser le package R `pins` pour versionner et partager des données de séries temporelles. Cette approche est particulièrement utile pour :

- **Versionner les données** : Suivre les changements dans vos jeux de données au fil du temps
- **Partager les données** : Collaborer avec d'autres chercheurs en partageant des données versionnées
- **Compatibilité RATS** : Exporter des données dans un format compatible avec le logiciel RATS (Regression Analysis of Time Series)
- **Reproductibilité** : Assurer que vos analyses sont reproductibles avec des métadonnées complètes

### Installation du package pins

```r
install.packages("pins")
```

### Exemple d'utilisation

Le script montre comment :
1. Créer un "board" local pour stocker les pins
2. Épingler les données Kiel-McClain avec métadonnées
3. Lire et versionner les données
4. Exporter au format compatible RATS
5. Créer et épingler des transformations de séries temporelles
6. Partager des données entre projets R et RATS

Pour plus d'informations sur le package pins, consultez : https://pins.rstudio.com/
