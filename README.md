## Méthodes statistiques d'évaluation

<img src="http://www.evens-salies.com/pagedegarde.png" alt="Page de garde" width="200">

Manuel de Méthodes statistiques d'évaluation de politiques publiques, programmes pilotes, interventions dans différentes discplines scientifiques.

La dernière version est par là : [MSE](http://www.evens-salies.com/2024_MSE.pdf). Le manuel contient suffisamment de méthodes, d'applications et d'exercices pour fournir 30 h de cours en Master 1 ou Master 2 en Science économique et sociale, Science de l'éducation, mais aussi Science des données, Apprentissage automatique, même si je dois reconnaître que le modèle causal de Pearl n'est pas couvert. Je n'ai recours qu'à quelques *graphes acycliques dirigés* pour formaliser les relations entre des variables.

J'ai monté ce manuel à l'occason d'un cours que j'ai enseigné en Master 2 d'&Eacute;conomie, Parcours Expertise et Analyse des Données &Eacute;conomiques de l'Université Côte d'Azur, à l'&Eacute;cole Universitaire de Recherche &Eacute;conomie et Management.

**Note importante :** le chapitre 9 est encore incomplet sur le biais de sélection à la Heckman pour les situations de troncature.


<!--1.	Introduction : plan de cours	1
1.1.	Objet du cours « Méthodes Statistiques d’Évaluation »	1
1.1.1.	Clarifier le titre	1
1.1.2.	Pourquoi évaluer ?	3
1.1.2.1.	Exemples concrets d’actions publiques (CICE, CIR, et PDV)	3
1.1.2.2.	L’évaluation dans la loi	4
1.1.2.3.	Encadrer les E3P au quotidien	5
1.2	A qui s’adresse ce cours, niveau requis	5
1.3	Compétences à l’issue de la formation	5
1.4	Débouchés	8
1.5	Déroulement de la formation [et annonce du plan]	9
1.5.1	L’évaluation … des étudiants	9
1.5.2	Conseil de lecture, formations	9
1.5.3	Les chapitres du cours	10
1.6	Exercices sur le chapitre 1	11
Correction des exercices du chapitre 1	13
2.	Méthodologie de l’évaluation	15
2.1.	Une question causale	15
2.1.1.	La corrélation n’est pas une condition suffisante de la causalité	17
2.1.2.	Le paradoxe de Yule-Simpson	17
2.1.3.	Le contrôle des facteurs	21
2.2.	Le modèle causal de Rubin	23
2.2.1.	Traitement, résultats potentiel et contrefactuel	23
2.2.2.	Résultat observé et l’équation de Rubin	24
2.2.3.	Effet causal individuel et problème fondamental de l’évaluation	25
2.2.4.	Effet causal moyen	26
2.2.5.	Stabilité des individus (SUTVA)	27
2.3.	Des types d’expérimentations possibles	28
2.3.1.	Expérimentation de pensée	28
2.3.2.	L’expérimentation de laboratoire	29
2.3.3.	L’expérimentation de terrain	30
2.3.4.	L’expérimentation naturelle	30
2.3.5.	L’expérimentation sociale	34
2.4.	Exercices sur le chapitre 2	35
2.5.	Notes	36
Correction des exercices du chapitre 2	37
3.	Sélection aléatoire des individus, inférence	39
3.1.	Mécanisme d’affectation des traitements	39
3.2.	Problème du MAT confondu	40
3.3.	Vertus du MAT aléatoire contrôlé	41
3.3.1.	A l’origine, l’EX de Fisher de la buveuse de thé	41
3.3.2.	Le MATAC en pratique, l’affectation des traitements ?	43
3.3.3.	MATAC et biais de l’EMT	43
3.4.	Tests de causalité pour MAT pleinement aléatoire	44
3.4.1.	Test Exact de Fisher : application aux données de The Electric Company	44
3.4.2.	Test de Neyman	46
3.4.3.	ANOVA (Analyse de la Variance)	48
3.5.	Exercices sur le chapitre 3	49
3.6.	Annexe (estimateur de Neyman de la variance)	51
Corrections des exercices du chapitre 3	53
4.	Les études observationnelles	55
4.1.	Inconvénients et avantages des études observationnelles	55
4.1.1.	Les inconvénients des EO	55
4.1.2.	Les avantages relativement aux études randomisées	56
4.2.	Illustration et détection du biais de sélection	57
4.2.1.	Biais de sélection	57
4.2.2.	Déséquilibre	61
4.2.3.	Absence de recouvrement (lack of overlap)	64
4.3.	Supposition d’indépendance conditionnelle et recouvrement	65
4.4.	Exercices de TP (4.4.1-4.4.4), et à l’oral (4.4.5)	66
5.	Stratification exacte	71
5.1.	Introduction	71
5.2.	L’estimateur de l’ECM sur données stratifiées (approche à la Neyman)	73
5.2.1.	Effet causal moyen	73
5.2.2.	Effet causal moyen sur les traités et les non-traités	74
5.2.3.	Biais de l’estimateur de l’ECMT stratifié	75
5.3.	Application au projet STAR	76
5.3.1.	Version de STAR d’Imbens et Rubin (2015)	77
5.3.2.	Réplication sous Stata	78
5.4.	Exercices sur le chapitre 5	79
Corrections des exercices du chapitre 5	80
6.	Appariement	81
6.1.	Motivations théoriques	81
6.2.	Estimateur d’appariement de l’effet du traitement	86
6.2.1.	Appariement exact et inexact	86
6.2.2.	L’évaluation par Card et Krueger (1994) de la hausse du SMIC	89
6.2.3.	Implémentation de l’estimateur dans Stata	91
6.2.4.	Grossissement du maillage des X	94
6.3.	Appariement et équilibrage via le score de propension	96
6.3.1.	Modèles pour le score de propension : logit, probit, …	96
6.3.2.	Théorème du score de propension : conditionner sur le SP atténue le BS	97
6.3.3.	Applications	98
6.4.	Score de propension généralisé	102
6.4.1.	Le modèle statistique	103
6.5.	Vérification de l’indépendance conditionnelle et analyse de sensibilité	105
6.5.1.	Etape 1 : vérification de la supposition d’indépendance conditionnelle	105
6.5.2.	Etape 2 : analyse de sensibilité	106
6.6.	Exercices sur le chapitre 6	107
Corrections des exercices du chapitre 6	109
7.	Ajustement par régression	111
7.1.	Modèle de régression résultat observé-traitement	112
7.1.1.	Quelques rappels sur la régression	112
7.1.2.	Randomisation et exogénéité de D	112
7.1.3.	Relation entre ϵ et les RP	113
7.1.4.	L’estimateur des MC identifie l’ECM (cas bivarié)	116
7.2.	Estimateur paramétrique polynomial (on introduit X)	117
7.3.	Régression en discontinuité	118
7.3.1.	Modèle avec protocole sharp	118
7.3.2.	Application (Khandker, 2005)	120
	  Encadré : Microfinance et pauvreté	121
7.4.	Exercice	122
Correction de l’exercice du chapitre 7	123
8.	Différence de différences et contrôle synthétique	125
8.1.	Exemples d’applications	126
8.1.1.	Politique de prix dans la vente au détail	126
8.1.2.	Politique locale d’urbanisme	127
8.2.	Discussion théorique	129
8.2.1.	Différence de différences et MCR	130
8.2.2.	Protocole DiD et contrôle d’effets groupe et temporel cachés	130
8.2.3.	Identification de l’ECMT dans le protocole avant-après	132
8.2.4.	Questions de spécification du modèle	132
8.2.5.	Hypothèses d’identification : « ignorabilité », « tendance commune »	133
8.3.	Contrôle synthétique	135
8.3.1.	Protocole	136
8.3.2.	Estimation	137
8.3.3.	Estimation de W*	139
8.3.4.	Application	140
8.4.	Exercices	140
Corrections des exercices du chapitre 8	142
9.	Sélection sur facteurs non-observables et variables instrumentales	145
9.1.	Estimateur à VI : approche classique	146
9.1.1.	Trois situations théoriques	146
9.1.2.	Illustrations	150
La relation éducation-salaire	151
9.2.	Estimateur LATE	152
9.3.	Estimateur heckit	157
9.3.1.	BS à la Heckman (1979)	157
9.3.2.	Problème de troncature	158
Exemple de problème de biais de sélection à la Heckman (1979)	162
9.4.	Exercices … à développer	163
Bibliographie	164

<!-- https://syllabus.univ-cotedazur.fr/fr/course-info/bbd08666-ad1e-41ff-a8c3-db6bd155e4a6/view/light >
