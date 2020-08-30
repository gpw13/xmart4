#' Get overview of a specific mart
#'
#' Get names of all available tables and views in a single mart.
#'
#' @inheritParams xmart4_api
#'
#' @return Character vector
#'
#' @export
xmart4_mart <- function(mart,
                        xmart_server = c("UAT", "PROD"),
                        token = NULL) {
  parsed <- xmart4_api(mart = mart,
                       xmart_server = xmart_server,
                       token = token)
  df <- parsed_to_df(parsed)
  df[['url']]
}

#' Get data from xMart table or view
#'
#' Retrieves data from an xMart table or view, and returns it as a tibble. For
#' views, returns the entire data frame from the mart. For tables, can choose to
#' return only data columns (the default), all columns, or only the system columns.
#'
#' @inheritParams xmart4_api
#' @param return_cols Return data columns only (default), all columns, or system data columns. Only works on tables, as views have no system columns.
#'
#' @return A tibble.
#'
#' @export
xmart4_table <- function(mart,
                         table,
                         top = NULL,
                         query = NULL,
                         xmart_server = c("UAT", "PROD"),
                         return_cols = c("data", "all", "sysdata"),
                         token = NULL) {
  return_cols <- rlang::arg_match(return_cols)
  parsed <- xmart4_api(mart = mart,
                       table = table,
                       top = top,
                       query = query,
                       xmart_server = xmart_server,
                       token = token)
  df <- parsed_to_df(parsed)
  process_table(df, return_cols)
}

#' @noRd
process_table <- function(df, return_cols) {
  pivot <- "_RecordID"
  df_nms <- colnames(df)
  if (return_cols == "all" | !(pivot %in% df_nms)) {
    df
  } else {
    i <- which(df_nms == pivot)
    if (return_cols == "data") {
      idx <- -(i:ncol(df))
    } else {
      idx <- -(1:(i-1))
    }
    df[,idx]
  }
}

#' @noRd
parsed_to_df <- function(parsed) {
  parsed <- lapply(parsed[["value"]], null_to_na)
  purrr::reduce(parsed, dplyr::bind_rows)
}


