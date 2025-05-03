Lien vers l'article de [Krueger (1999)](http://piketty.pse.ens.fr/files/Krueger1999.pdf).

Back to Markdown again.
&nbsp;&nbsp;&nbsp;Cette partie inclut une réflexion théorique post-cours, suite à l'intervention d'(Adam Sebti)[https://fr.linkedin.com/in/adam-sebti-2abb94105], sur l'estimateur stratifié équivalent à une régression de type Least Squares Dummy Variables. Adam fut l'un de mes étudiants dans ce cours durant l'année académique 2020-2021.
&nbsp;&nbsp;&nbsp;Il a trouvé empiriquement que l'estimateur stratifié de l'ECMT pouvait s'obtenir en faisant une régression sur variables indicatrices avec l'option de pondération, ```[, weight]``` dans ```Stata```. Sur les données de Krueger (1999), dans le programme ```krueger1999.do```, les variables indicatrices portent sur les écoles et les poids de pondération sont la proportion de *regular classes* dans l'ensemble {*regular*, *small*}.
