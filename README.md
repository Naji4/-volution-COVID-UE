# Évolution des données COVID-19 dans l'Union Européenne

## Description
Ce projet analyse l'évolution des données COVID-19 dans les pays de l'Union Européenne. Grâce à R et Shiny, il offre des visualisations interactives (cartes, courbes épidémiques) et des analyses statistiques basées sur des fichiers Excel consolidés.

Les données proviennent du dépôt [CSSEGISandData/COVID-19](https://github.com/CSSEGISandData/COVID-19), reconnu pour son exactitude et sa fiabilité.

## Fonctionnalités principales
1. **Carte choroplèthe** : Visualisation de la mortalité par pays dans l'UE.
2. **Courbe épidémique** : Suivi temporel des décès cumulés.
3. **Graphique à barres empilées** : Comparaison des cas confirmés et des décès.
4. **Tableau interactif** : Exploration des données par pays avec filtres et options d'export.

## Structure du projet
Le projet est divisé en trois documents principaux :

1. **datachallengeR** : Contient le code principal pour l'analyse et les visualisations.
2. **download_data_covid** : Code utilisé pour télécharger les données à partir du dépôt [CSSEGISandData/COVID-19](https://github.com/CSSEGISandData/COVID-19).
3. **app** : Fichier contenant le tableau de bord interactif pour exécuter l'application.

En complément, un dossier nommé **covid_data** contient les fichiers résultants de l'exécution de `download_data_covid`.

Un rapport détaillé en **R Markdown** est inclus sous forme de fichier PDF. Ce rapport explique chaque étape du projet avec des commentaires pour chaque graphique ou analyse effectuée. Il constitue une référence complète pour comprendre le processus et les résultats.

## Exécution

1. **Option 1 : Utilisation directe des données fournies**  
   Le dossier `covid_data` est déjà inclus dans ce dépôt. Vous pouvez l'utiliser directement sans exécuter le script `download_data_covid.R`. Passez directement à l'étape 2.

2. **Option 2 : Télécharger les données manuellement**  
   Si vous souhaitez télécharger les données les plus récentes, exécutez le script `download_data_covid.R`. Cela stockera les données mises à jour dans le dossier `covid_data`.

3. **Étape 2 : Analyse et visualisations**  
   Lancez le script `datachallengeR.R` pour analyser les données et générer les visualisations.

4. **Étape 3 : Tableau de bord interactif**  
   Exécutez le script `app.R` pour lancer le tableau de bord interactif avec Shiny.

## AUTEUR
Ce projet a été réalisé par [Naji4](https://github.com/Naji4).  
Pour toute question ou suggestion, contactez-moi à : **nmoha253@gmail.com**
