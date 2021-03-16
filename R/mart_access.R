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
                        auth_type = c("wims", "client"),
                        token = NULL) {
  df <- xmart4_api(mart = mart,
                   xmart_server = xmart_server,
                   format = "none",
                   auth_type = auth_type,
                   token = token)
  df[['url']]
}

#' Get data from xMart table or view
#'
#' Retrieves data from an xMart table or view, and returns it as a tibble. For
#' views, returns the entire data frame from the mart. For tables, can choose to
#' return only data columns (the default), all columns, or only the system columns.
#'
#' @inheritParams xmart4_api
#' @param col_types One of NULL, a [readr::cols()] specification, or a string. This
#'     is passed to [readr::type_convert()], so see documentation there for more details.
#' @param return_cols Return data columns only (default), all columns, or system data columns. Only works on tables, as views have no system columns.
#'
#' @return A tibble.
#'
#' @export
xmart4_table <- function(mart,
                         table,
                         top = NULL,
                         query = NULL,
                         format = c("none", "csv", "streaming"),
                         col_types = NULL,
                         full_table = TRUE,
                         xmart_server = c("UAT", "PROD"),
                         return_cols = c("data", "all", "sysdata"),
                         auth_type = c("wims", "client"),
                         token = NULL) {
  return_cols <- rlang::arg_match(return_cols)

  df <- xmart4_api(mart = mart,
                   table = table,
                   top = top,
                   query = query,
                   format = format,
                   xmart_server = xmart_server,
                   auth_type = auth_type,
                   token = token)
  df <- process_table(df, return_cols)
  readr::type_convert(df, col_types = col_types)
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
  purrr::map_df(parsed[["value"]], null_to_na)
}

#' @noRd
null_to_na <- function(l) {
  sapply(l, function(x) ifelse(is.null(x), NA, x))
}
