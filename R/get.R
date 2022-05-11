#' Access the xMart4 API
#'
#' Function that provides access to the xMart4 API. Currently functionality is
#' limited to accessing lists of tables within marts and the data within them,
#' but additional functionality can be built-in as requested.
#'
#' @param mart Name of the xMart4 mart
#' @param table Name of a table within the mart, otherwise `NULL` (the default)
#' @param xmart_server Either 'UAT' (the default) or 'PROD'
#' @param top Number of rows of a table to return
#' @param query A single string fitting the [Odata protocol](https://www.odata.org/documentation/odata-version-2-0/uri-conventions/)
#'     that must start with \code{"$filter="}.
#' @param format Specification of the output format to be returned by the xMart API.
#'     Defaults to `"none"`, but consider switching to `"csv"` if you are having
#'     loading an extremely large table. See the
#'     [xMart4 API documentation](https://portal-uat.who.int/xmart4/docs/xmart_api/use_API.html)
#'     for details on the three options.
#' @param auth_type Type of authorization to use for the token authorization.
#' If "client" (the default), it uses an AzureAD client setup. The old "wims"
#' method has been discontinued.
#' @param full_table Logical, whether or not to load all the rows in a specified table,
#'     defaults to `TRUE`. If no format is provided, the xMart4 API limits calls to 100,000 rows at a time, so
#'     if `full_table == TRUE`, the function automatically repeats the API call to
#'     extract all rows within the xMart4 table. Ignored if `format="streaming"` or
#'     `format="csv"`.
#' @param token Access token for xMart4 server. If NULL (the default), the package automatically creates and manages access for the user if Azure client ID and secret set up properly. See `vignette("token_setup")` for instructions and details.
#'
#' @return A data frame.
xmart4_api <- function(mart,
                       table = NULL,
                       xmart_server = c("UAT", "PROD"),
                       top = NULL,
                       query = NULL,
                       format = c("none", "csv", "streaming"),
                       full_table = TRUE,
                       auth_type = "client",
                       token = NULL) {
  assert_mart(mart)
  xmart_server <- rlang::arg_match(xmart_server)
  assert_table(mart, table, auth_type, xmart_server)
  assert_query(query)
  assert_top(top)
  format <- rlang::arg_match(format)
  auth_type <- rlang::arg_match(auth_type)

  query <- modify_query(query)
  t_q <- join_top_query(top, query)
  t_q <- join_tq_skip(t_q, full_table)
  t_q <- join_format(t_q, format)
  token <- check_raw_token(token, auth_type, xmart_server)
  url <- xmart_url(
    mart,
    table,
    xmart_server
  )

  xmart4_get(
    url,
    t_q,
    token,
    full_table,
    format
  )
}

#' @noRd
server_to_base_url <- function(xmart_server) {
  urls <- c(
    "https://portal-uat.who.int/xmart-api/odata",
    "https://extranet.who.int/xmart-api/odata"
  )
  servers <- c("UAT", "PROD")
  urls[match(xmart_server, servers)]
}

#' @noRd
xmart_url <- function(mart,
                      table,
                      xmart_server) {
  base_url <- server_to_base_url(xmart_server)
  httr::modify_url(base_url, path = paste("xmart-api/odata",
    mart,
    table,
    sep = "/"
  ))
}

#' @noRd
modify_query <- function(qry) {
  if (is.na(qry) || is.null(qry)) {
    NULL
  } else {
    gsub(" ", "%20", qry)
  }
}

#' @noRd
join_top_query <- function(top, query) {
  if (!is.null(top)) {
    top <- paste0("$top=", top)
  }
  x <- c(query, top)
  x <- x[!is.null(x)]
  paste(x, collapse = "&")
}

#' @noRd
join_tq_skip <- function(tq, full_table) {
  if (full_table) {
    x <- c("$skip=0", tq)
    x <- x[!is.null(x) & x != ""]
    tq <- paste(x, collapse = "&")
  }
  tq
}

#' @noRd
join_format <- function(tq, format) {
  if (format == "csv") {
    tq <- paste(c(tq, "$format=csv"), collapse = "&")
  } else if (format == "streaming") {
    tq <- paste(c(tq, "$format=streaming"), collapse = "&")
  }
  tq
}

#' @noRd
xmart4_get <- function(url, t_q, token, full_table, format) {
  resp <- httr::GET(httr::modify_url(url),
    token_header(token),
    ua,
    query = t_q
  )
  assert_status_code(resp)
  assert_resp(resp, format)

  rl <- xmart4_parse(resp, format)
  df <- rl[[1]]
  next_link <- rl[[2]]

  if (full_table & !is.null(next_link)) {
    params <- unlist(stringr::str_match_all(next_link, "(.+?)\\?(\\$.+)"))
    df <- dplyr::bind_rows(df, xmart4_get(params[2], params[3], token, full_table, format))
  }
  df
}

#' @noRd
xmart4_parse <- function(resp, format) {
  if (format %in% c("streaming", "none")) {
    parsed <- httr::content(resp,
      as = "parsed",
      type = "application/json",
      encoding = "UTF-8"
    )
    assert_content(parsed)
    df <- parsed_to_df(parsed)
    next_link <- parsed[["@odata.nextLink"]]
  } else {
    df <- httr::content(resp,
      as = "parsed",
      type = "text/csv",
      encoding = "UTF-8"
    )
    next_link <- NULL
  }
  list(df, next_link)
}
