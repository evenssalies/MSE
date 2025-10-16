## Méthodes statistiques d'évaluation

<img src="http://www.frequency.fr/pagedegarde.png" alt="Page de garde" width="200">

### Note

&nbsp;&nbsp;Manuel de Méthodes statistiques d'évaluation de politiques publiques, programmes pilotes, expérimentations dans différentes disciplines des sciences humaines et sociales (sciences économique, de l'éducation, etc.). Les méthodes incluses dans ce cours sont aussi appropriées pour l'évaluation dans les sciences biomédicales, d'où elles sont souvent issues.</br>
&nbsp;&nbsp;La dernière version est par là : [MSE](http://www.frequency.fr/2024_MSE.pdf). Le manuel contient suffisamment de méthodes, d'applications et d'exercices pour fournir 30 h de cours en Master 1 ou Master 2 en Science économique et sociale, Science de l'éducation, mais aussi Science des données, Apprentissage automatique, même si je dois reconnaître que le modèle causal de Pearl n'est pas couvert. Je n'ai recours qu'à quelques *graphes acycliques dirigés* pour formaliser les relations entre des variables.</br>
&nbsp;&nbsp;J'ai monté ce manuel à l'occason d'un cours que j'ai enseigné en Master 2 d'&Eacute;conomie, Parcours Expertise et Analyse des Données &Eacute;conomiques de l'Université Côte d'Azur, à l'&Eacute;cole Universitaire de Recherche &Eacute;conomie et Management.

**Note importante :** le chapitre 9 est encore incomplet sur le biais de sélection à la Heckman pour les situations de troncature.

### Nouveau : Support du package pins

Ce dépôt inclut maintenant des exemples d'utilisation du package R `pins` pour versionner et partager des données de séries temporelles. Ceci est particulièrement utile pour la compatibilité avec le logiciel RATS (Regression Analysis of Time Series) et pour assurer la reproductibilité des analyses.

- **Guide complet** : Voir [PINS_GUIDE.md](PINS_GUIDE.md) pour une documentation détaillée
- **Exemple pratique** : Voir [mse_8/pins_timeseries_example.R](mse_8/pins_timeseries_example.R) pour un exemple d'utilisation avec les données de différence-de-différences

Le package pins permet de :
- Versionner automatiquement les jeux de données
- Partager des données entre projets R et RATS
- Documenter les sources et métadonnées
- Assurer la reproductibilité des analyses

### Plan
<sub>
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Introduction : plan de cours<br/>
1.1&nbsp;&nbsp;Objet du cours<br/>
1.2&nbsp;&nbsp;A qui s’adresse ce cours, niveau requis<br/>
1.3&nbsp;&nbsp;Compétences à l’issue de la formation<br/>
1.4&nbsp;&nbsp;Débouchés<br/>
1.5&nbsp;&nbsp;Déroulement de la formation et annonce du plan<br/>
1.6&nbsp;&nbsp;Exercices sur le chapitre 1<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Correction des exercices du chapitre<br/>
2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Méthodologie de l’évaluation<br/>
2.1&nbsp;&nbsp;Une question causale<br/>
2.2&nbsp;&nbsp;Le modèle causal de Rubin<br/>
2.3&nbsp;&nbsp;Des types d’expérimentations possibles<br/>
2.4&nbsp;&nbsp;Exercices sur le chapitre 2<br/>
2.5&nbsp;&nbsp;Notes<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Correction des exercices du chapitre 2<br/>
3&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Sélection aléatoire des individus, inférence<br/>
3.1&nbsp;&nbsp;Mécanisme d’affectation des traitements<br/>
3.2&nbsp;&nbsp;Problème du MAT confondu<br/>
3.3&nbsp;&nbsp;Vertus du MAT aléatoire contrôlé<br/>
3.4&nbsp;&nbsp;Tests de causalité pour MAT pleinement aléatoire<br/>
3.5&nbsp;&nbsp;Exercices sur le chapitre 3<br/>
3.6&nbsp;&nbsp;Annexe (estimateur de Neyman de la variance)<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Corrections des exercices du chapitre 3<br/>
4&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Les études observationnelles<br/>
4.1&nbsp;&nbsp;Inconvénients et avantages des études observationnelles<br/>
4.2&nbsp;&nbsp;Illustration et détection du biais de sélection<br/>
4.3&nbsp;&nbsp;Supposition d’indépendance conditionnelle et recouvrement<br/>
4.4&nbsp;&nbsp;Exercices de TP (4.4.1-4.4.4), et à l’oral (4.4.5)<br/>
5&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Stratification exacte<br/>
5.1&nbsp;&nbsp;Introduction<br/>
5.2&nbsp;&nbsp;L’estimateur de l’ECM sur données stratifiées (approche à la Neyman)<br/>
5.3&nbsp;&nbsp;Application au projet STAR<br/>
5.4&nbsp;&nbsp;Exercices sur le chapitre 5<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Corrections des exercices du chapitre 5<br/>
6&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Appariement<br/>
6.1&nbsp;&nbsp;Motivations théoriques<br/>
6.2&nbsp;&nbsp;Estimateur d’appariement de l’effet du traitement<br/>
6.3&nbsp;&nbsp;Appariement et équilibrage via le score de propension<br/>
6.4&nbsp;&nbsp;Score de propension généralisé<br/>
6.5&nbsp;&nbsp;Vérification de l’indépendance conditionnelle et analyse de sensibilité<br/>
6.6&nbsp;&nbsp;Exercices sur le chapitre 6<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Corrections des exercices du chapitre 6<br/>
7&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Ajustement par régression<br/>
7.1&nbsp;&nbsp;Modèle de régression résultat observé-traitement<br/>
7.2&nbsp;&nbsp;Estimateur paramétrique polynomial (on introduit X)<br/>
7.3&nbsp;&nbsp;Régression en discontinuité<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Encadré : Microfinance et pauvreté<br/>
7.4&nbsp;&nbsp;Exercices sur le chapitre 7<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Correction de l’exercice du chapitre 7<br/>
8&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Différence de différences et contrôle synthétique<br/>
8.1&nbsp;&nbsp;Exemples d’applications<br/>
8.2&nbsp;&nbsp;Discussion théorique<br/>
8.3&nbsp;&nbsp;Contrôle synthétique<br/>
8.4&nbsp;&nbsp;Exercices<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Corrections des exercices du chapitre 8<br/>
9&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Sélection sur facteurs non-observables et variables instrumentales<br/>
9.1&nbsp;&nbsp;Estimateur à VI : approche classique<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Encadré : La relation éducation-salaire<br/>
9.2&nbsp;&nbsp;Estimateur LATE<br/>
9.3&nbsp;&nbsp;Estimateur heckit<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Exemple de problème de biais de sélection à la Heckman (1979)<br/>
9.4&nbsp;&nbsp;Exercices ... à développer<br/><br/>
Bibliographie</sub>
<!-- https://syllabus.univ-cotedazur.fr/fr/course-info/bbd08666-ad1e-41ff-a8c3-db6bd155e4a6/view/light >
