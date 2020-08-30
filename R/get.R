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
#' @param query A single string fitting the [Odata protocol](https://www.odata.org/documentation/odata-version-2-0/uri-conventions/) that must start with \code{"$filter="}.
#' @param token Access token for xMart4 server. If NULL (the default), the package automatically creates and manages access for the user.
#'
#' @return List of parsed JSON returned from the API.
xmart4_api <- function(mart,
                       table = NULL,
                       xmart_server = c("UAT", "PROD"),
                       top = NULL,
                       query = NULL,
                       token = NULL) {
  assert_mart(mart)
  assert_table(mart, table)
  xmart_server <- rlang::arg_match(xmart_server)
  assert_query(query)
  assert_top(top)

  query <- modify_query(query)
  t_q <- join_top_query(top, query)

  token <- check_raw_token(token, xmart_server)
  url <- xmart_url(mart,
                   table,
                   xmart_server)

  resp <- httr::GET(url,
                    token_header(token),
                    ua,
                    query = t_q)
  assert_status_code(resp)
  assert_json(resp)
  parsed <- httr::content(resp,
                          as = "parsed",
                          type = "application/json")
  assert_content(parsed)
  parsed
}

#' @noRd
server_to_base_url <- function(xmart_server) {
  urls <- c("https://portal-uat.who.int/xmart-api/odata",
            "https://extranet.who.int/xmart-api/odata")
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
                                          sep = "/"))
}

#' @noRd
modify_query <- function(qry) {
  if(is.na(qry) || is.null(qry)) {
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
null_to_na <- function(l) {
  sapply(l, function(x) ifelse(is.null(x), NA, x))
}
