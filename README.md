# Évolution des données COVID-19 dans l'Union Européenne

## Description
Ce projet analyse l'évolution des données COVID-19 dans les pays de l'Union Européenne. Grâce à R et Shiny, il offre des visualisations interactives (cartes, courbes épidémiques) et des analyses statistiques basées sur des fichiers Excel consolidés.

## Fonctionnalités principales
1. **Carte choroplèthe** : mortalité par pays.
2. **Courbe épidémique** : évolution temporelle des décès.
3. **Graphique à barres empilées** : comparaison cas confirmés/décès.
4. **Tableau interactif** : exploration des données par pays.

## Structure du projet
Le projet est divisé en trois documents principaux :

1. **datachallengeR** : Contient le code principal pour l'analyse et les visualisations.
2. **download_data_covid** : Code utilisé pour télécharger les données à partir du dépôt [CSSEGISandData/COVID-19](https://github.com/CSSEGISandData/COVID-19).
3. **app** : Fichier contenant le tableau de bord interactif pour exécuter l'application.

En complément, un dossier nommé **covid_data** contient les fichiers résultants de l'exécution de `download_data_covid`.

Un rapport détaillé en **R Markdown** est inclus sous forme de fichier PDF. Ce rapport explique chaque étape du projet avec des commentaires pour chaque graphique ou analyse effectuée. Il constitue une référence complète pour comprendre le processus et les résultats.
