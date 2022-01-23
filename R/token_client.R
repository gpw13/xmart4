#' @inherit xmart4_token title params
#' @inherit xmart4_token_wims params
xmart4_token_client <- function(xmart_id,
                                client_id = NULL,
                                client_secret = NULL) {
  client_id <- assert_client_id(client_id)
  client_secret <- assert_client_secret(client_secret)

  resp <- httr::POST(
    url = "https://login.microsoftonline.com/f610c0b7-bd24-4b39-810b-3dc280afb590/oauth2/token",
    body = list(
      grant_type = "client_credentials",
      client_id = client_id,
      client_secret = client_secret,
      resource = xmart_id
    )
  )
  resp <- httr::content(resp)

  token <- resp_to_token(resp)
  token
}

#' @noRd
assert_client_id <- function(x) {
  if (is.null(x)) {
    x <- Sys.getenv("XMART_REMOTE_CLIENT_ID")
    if (identical(x, "")) {
      stop("Please set env var XMART_REMOTE_CLIENT_ID to your remoteClientID or manually provide `client_id`.",
        call. = FALSE
      )
    }
    x
  } else {
    x
  }
}

#' @noRd
assert_client_secret <- function(x) {
  if (is.null(x)) {
    x <- Sys.getenv("XMART_REMOTE_CLIENT_SECRET")
    if (identical(x, "")) {
      stop("Please set env var XMART_REMOTE_CLIENT_SECRET to your remoteClientSecret or manually provide `client_secret`.",
        call. = FALSE
      )
    }
    x
  } else {
    x
  }
}
