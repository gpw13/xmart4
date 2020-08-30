#' Request xMart4 access token
#'
#' Using pre-configured Azure client ID and secret, xMart4 access tokens can be generated
#' to access marts your client has permissions for. Detailed instructions
#' from the xMart4 development team on setting up a remote client to consume
#' xMart4 API data is available on the
#' [ xMart4 Slack](https://xmartcollaboration.slack.com/files/TJF6QTLE4/F019WGZSSD7?origin_team=TJF6QTLE4).
#'
#' Unless you need to test multiple clients in your R session, you do not need
#' to manually create tokens, the package will automatically generate and manage
#' your tokens if you have properly configured your R environment. Your client ID
#' and client secret should be set in your .Renviron file. More detailed
#' instructions can be found on the
#' [ xmart4 package GitHub page](https://github.com/caldwellst/xmart4).
#'
#' @param client_id Azure client ID
#' @param client_secret A
#' @inheritParams xmart4_api
#'
#' @return List with two values, token and time of expiration, which is 60 minutes
#'     from time of generation.
#'
#' @export
xmart4_token <- function(client_id = NULL,
                             client_secret = NULL,
                             xmart_server = "UAT") {
  xmart_id <- get_xmart_id(xmart_server)
  client_id <- assert_client_id(client_id)
  client_secret <- assert_client_secret(client_secret)

  resp <- httr::POST(url = "https://login.microsoftonline.com/f610c0b7-bd24-4b39-810b-3dc280afb590/oauth2/token",
                     body = list(
                       grant_type = "client_credentials",
                       client_id = client_id,
                       client_secret = client_secret,
                       resource = xmart_id
                     ))
  resp <- httr::content(resp)

  token <- resp_to_token(resp)
  token
}

#' Get time left on xMart API token
#'
#' xMart API tokens are short-term tokens that last for 60 minutes after generation.
#' This returns time until token expires. You should only need this if you are
#' manually managing token generation, which is not recommended.
#'
#' @inheritParams xmart4_api
#'
#' @return Time left until token expiration
#'
#' @export
xmart4_token_time <- function(token) {
  assert_list_token(token)
  expires <- token[["expires"]]
  expires - lubridate::now()
}

#' @noRd
check_raw_token <- function(token, xmart_server) {
  if (!is.null(token)) {
    if (is.character(token)) {
      token
    } else if (is.list(token)) {
      invalid <- xmart4_token_time(token) <= 0
      if (invalid) {
        stop("Manually supplied `xmart_token` is expired, please generate another using `xmart4_token()`")
      }
      token[["xmart_token"]]
    }
  } else {
    refresh_xmart_token(xmart_server)
    retrieve_xmart_token(xmart_server)
  }
}

#' @noRd
retrieve_xmart_token <- function(xmart_server) {
  nm <- server_to_token_name(xmart_server)
  token <- get(nm, envir = .xmart_env)
  token[["token"]]
}

#' @noRd
resp_to_token <- function(resp) {
  token <- list(token = resp[["access_token"]],
                expires = lubridate::as_datetime(as.numeric(resp[["expires_on"]])))
  token
}

#' @noRd
refresh_xmart_token <- function(xmart_server) {
  nm <- server_to_token_name(xmart_server)
  valid <- check_xmart_env(nm)
  if (!valid) {
    token <- xmart4_token(xmart_server = xmart_server)
    assign(nm, token, envir = .xmart_env)
  }
}

#' @noRd
server_to_token_name <- function(xmart_server) {
  tokens <- c("XMART_UAT_TOKEN", "XMART_PROD_TOKEN")
  servers <- c("UAT", "PROD")
  tokens[match(xmart_server, servers)]
}

#' @noRd
check_xmart_env <- function(nm) {
  ex <- exists(nm, envir = .xmart_env, inherits = FALSE)
  if (ex) {
    token <- get(nm, envir = .xmart_env, inherits = FALSE)
    !(xmart4_token_time(token) <= 0)
  } else {
    ex
  }
}

#' @noRd
get_xmart_id <- function(xmart_server) {
  if (xmart_server == "UAT") {
    "b85362d6-c259-490b-bd51-c0a730011bef"
  } else if (xmart_server == "PROD") {
    "712b0d0d-f9c5-4b7a-80d6-8a83ee014bca"
  } else {
    stop("`xmart_server` must be either 'UAT' or 'PROD'",
         call. = FALSE)
  }
}

#' @noRd
token_header <- function(token) {
  httr::add_headers(Authorization = paste("Bearer", token))
}
