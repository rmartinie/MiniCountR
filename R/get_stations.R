#' Récupérer les stations d'un organisme
#'
#' @param idOrganisme ID de l'organisme (ex: "3902" pour Lyon, "857" pour Düsseldorf...)
#' @param code_pratique Facultatif. Un entier (ex: 2 pour vélo) pour filtrer un type spécifique.
#'                      Si NULL (par défaut), toutes les stations sont retournées.
#' @export
#' @export
get_stations <- function(idOrganisme, code_pratique = NULL) {

  url_config <- paste0("https://www.eco-visio.net/api/aladdin/1.0.0/pbl/publicwebpageplus/", idOrganisme)

  response <- httr::GET(url_config)
  if (httr::http_error(response)) stop("Erreur API")

  raw_data <- jsonlite::fromJSON(httr::content(response, "text", encoding = "UTF-8"), flatten = TRUE)

  df <- tibble::as_tibble(raw_data)

  stations_processed <- df |>
    tidyr::unnest(pratique, names_sep = "_")

  if (!is.null(code_pratique)) {
    stations_processed <- stations_processed |>
      dplyr::filter(pratique_pratique == code_pratique)
  }

  stations_final <- stations_processed |>
    dplyr::group_by(idPdc, lat, lon, nom, debut, nomOrganisme, total, lastDay, moyD) |>
    dplyr::summarise(
      flowIds = paste(unique(pratique_id), collapse = ";"),
      codes_pratiques = paste(unique(pratique_pratique), collapse = ","),
      .groups = "drop"
    ) |>
    dplyr::mutate(id_org_tech = idOrganisme) |>
    dplyr::select(idPdc, lat, lon, nom, debut, nomOrganisme, total, lastDay, moyD, flowIds, codes_pratiques, id_org_tech)

  return(stations_final)
}
