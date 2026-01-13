
<!-- README.md is generated from README.Rmd. Please edit that file -->

# MiniCountR

**MiniCountR** est un mini package R conçu pour extraire facilement les
données de fréquentation (vélos, piétons, etc.) depuis l’API publique
d’Eco-Compteur.

Il permet de récupérer la configuration des stations et les données
historiques sans avoir besoin d’une clé API privée, en utilisant les
identifiants d’organismes publics. Il a été initialement conçu pour le
suivi des flux cyclistes à Lyon, mais est normalement modulaire pour
d’autres villes.

## Installation

Vous pouvez installer depuis GitHub avec :

    # install.packages("remotes")
    remotes::install_github("rmartinie/MiniCountR")

## Fonctionnalités

`get_stations()` : Récupère la liste des compteurs d’une ville avec
leurs coordonnées GPS, leurs métadonnées et leurs identifiants
techniques (flowIds).

`get_eco_data()` : Télécharge les données pour un compteur spécifique
(au pas horaire, journalier, hebdomadaire ou mensuel).

`get_multi_eco_data()` : Télécharge les données pour une liste complète
de compteurs en une seule commande.

## Exemple d’utilisation

### Récupérer les stations

Voici comment récupérer tous les compteurs vélo de la ville de Lyon (ID
organisme : 3902)

``` r
library(MiniCountR)

# Récupérer uniquement les compteurs vélo (code pratique 2 pour Lyon)
stations_lyon <- get_stations(idOrganisme = "3902", code_pratique = 2)
```

### Télécharger les données de fréquentation

Une fois les stations récupérées, vous pouvez extraire les données pour
une période donnée :

``` r
# Extraire les données journalières pour tout Lyon
donnees_lyon <- get_multi_eco_data(
  stations_df = stations_lyon,
  debut = "01/01/2026",
  fin = "13/01/2026",
  interval = "4" # 4 = Quotidien,
)
```

------------------------------------------------------------------------

# MiniCountR (English)

**MiniCountR** is a lightweight R package designed to easily extract
mobility data (bikes, pedestrians, etc.) from the public Eco-Compteur
API.

It allows retrieving station configurations and historical data
**without a private API key**, using public organisation identifiers.
Originally developed for tracking bike flows in Lyon, it is modular and
can be adapted for other cities.

## Installation

You can install from GitHub with:

``` r
# install.packages("remotes")
remotes::install_github("rmartinie/MiniCountR")
```

## Features

`get_stations()` : Retrieves the list of counters in a city with GPS
coordinates, metadata, and technical identifiers (flowIds).

`get_eco_data()` : Downloads data for a specific counter (hourly, daily,
weekly, or monthly).

`get_multi_eco_data()` : Downloads data for a complete list of counters
in a single call.

## Usage example

### Retrieve stations

Example for fetching all bike counters in Lyon (Organisation ID: 3902):

    library(MiniCountR)

    # Retrieve only bike counters (practice code 2 for Lyon)
    stations_lyon <- get_stations(idOrganisme = "3902", code_pratique = 2)

### Download mobility data

Once stations are retrieved, you can extract data for a given period:

    # Extract daily data for all Lyon counters
    lyon_data <- get_multi_eco_data(
      stations_df = stations_lyon,
      debut = "01/01/2026",
      fin = "13/01/2026",
      interval = "4" # 4 = Daily
    )
