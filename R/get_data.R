#' Récupérer les données d'un seul compteur
#'
#' @param station Une ligne (data.frame) issue de get_stations() OU l'ID du point de comptage.
#' @param flowIds Facultatif si 'station' est fourni. Chaîne des flux (ex: "123;456").
#' @param debut Date de début (JJ/MM/AAAA).
#' @param fin Date de fin (JJ/MM/AAAA).
#' @param interval Code intervalle (5: Semaine, 4: Jour (default), 3: Heure).
#' @param idOrganisme Facultatif si 'station' est fourni. ID de l'organisme.
#' @export
get_eco_data <- function(station, flowIds = NULL, debut, fin, interval = "4", idOrganisme = NULL) {

  # Gestion de l'entrée flexible : Si 'station' est un data.frame, on extrait les infos
  if (is.data.frame(station)) {
    idPdc       <- station$idPdc[1]
    flowIds     <- station$flowIds[1]
    idOrganisme <- station$id_org_tech[1]
    nom_station <- station$nom[1]
  } else {
    idPdc       <- station
    nom_station <- NULL
  }

  url <- paste0("https://www.eco-visio.net/api/aladdin/1.0.0/pbl/publicwebpageplus/data/", idPdc)

  query_params <- list(
    idOrganisme = idOrganisme,
    idPdc       = idPdc,
    debut       = debut,
    fin         = fin,
    interval    = interval,
    flowIds     = flowIds
  )

  tryCatch({
    res <- httr::GET(url, query = query_params)
    if (httr::http_error(res)) return(NULL)

    content_text <- httr::content(res, "text", encoding = "UTF-8")

    if (content_text == "[]" || content_text == "") return(NULL)

    data <- jsonlite::fromJSON(content_text)

    if (is.null(data) || length(data) == 0) return(NULL)


    # Transformation en data.frame
    df <- as.data.frame(data) |>
      stats::setNames(c("date", "count"))

    # PARSING SÉCURISÉ (Format US prioritaire pour cette API)
    # On utilise 'mdy' car l'API renvoie 03/13/2015 pour le 13 Mars
    df$date <- lubridate::parse_date_time(
      df$date,
      orders = c("mdy HMS", "mdy", "dmy HMS", "dmy"),
      quiet = TRUE
    )

    # Conversion du count
    df$count <- as.numeric(df$count)

    # On s'assure que count est bien numérique
    df$count <- as.numeric(df$count)
    df$idPdc <- as.character(idPdc)

    if (!is.null(nom_station)) {
      df$nom_station <- nom_station
    }

    return(df)
  }, error = function(e) {
    message("Erreur sur le compteur ", idPdc, " : ", e$message)
    return(NULL)
  })
}

#' Récupérer les données de plusieurs compteurs (Bulk)
#'
#' @param stations_df Le data.frame généré par get_stations().
#' @param debut Date de début (JJ/MM/AAAA).
#' @param fin Date de fin (JJ/MM/AAAA).
#' @param interval Code intervalle (5: Semaine, 4: Jour (default), 3: Heure).
#' @export
get_multi_eco_data <- function(stations_df, debut, fin, interval = "4") {

  # Vérification des colonnes nécessaires
  required_cols <- c("idPdc", "flowIds", "id_org_tech")
  if (!all(required_cols %in% colnames(stations_df))) {
    stop("Le data.frame doit contenir les colonnes: idPdc, flowIds et id_org_tech")
  }

  # Utilisation de purrr pour boucler sur chaque ligne du tableau
  purrr::map_df(1:nrow(stations_df), function(i) {
    row <- stations_df[i, ]
    message("Extraction en cours : ", row$nom)

    # On passe directement la ligne 'row' à la nouvelle fonction get_eco_data
    get_eco_data(
      station  = row,
      debut    = debut,
      fin      = fin,
      interval = interval
    )
  })
}
