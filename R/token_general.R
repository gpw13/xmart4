#' Request xMart4 access token
#'
#' xMart4 access tokens can be generated to access marts either through using a
#' WHO WIMS account or using pre-configured Azure client ID and secret. The package
#' automatically manages the tokens behind the scenes for you, so unless you need to test
#' multiple client access in a single R session, you do not need to manually create tokens.
#' More detailed instructions can be found on the
#' [ xmart4 package GitHub page](https://github.com/caldwellst/xmart4).
#'
#' For more details on the WIMS and client methods of authentication, see their relevant
#' vignettes:
#' * \href{../doc/token_setup.html}{\code{vignette("token_setup", package = "xmart4")}}
#' @param use_cache Use Azure cache if TRUE (default), otherwise bypass cache.
#' @param client_id Azure client ID. Only required if `auth_type == 'client'`.
#' @param client_secret Azure client secret. Only required if `auth_type == 'client'`.
#' @inheritParams xmart4_api
#'
#' @return List with two values, token and time of expiration, which is 60 minutes
#'     from time of generation.
#'
#' @export
xmart4_token <- function(auth_type = "client",
                         use_cache = TRUE,
                         client_id = NULL,
                         client_secret = NULL,
                         xmart_server = c("UAT", "PROD")) {
  xmart_server <- rlang::arg_match(xmart_server)
  xmart_id <- get_xmart_id(xmart_server)
  auth_type <- rlang::arg_match(auth_type)

  if (auth_type == "wims") {
    xmart4_token_wims(
      xmart_id,
      xmart_server
    )
  } else {
    xmart4_token_client(
      xmart_id,
      client_id,
      client_secret
    )
  }
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
check_raw_token <- function(token, auth_type, xmart_server) {
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
    refresh_xmart_token(auth_type, xmart_server)
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
  token <- list(
    token = resp[["access_token"]],
    expires = lubridate::as_datetime(as.numeric(resp[["expires_on"]]))
  )
  token
}

#' @noRd
refresh_xmart_token <- function(auth_type, xmart_server) {
  nm <- server_to_token_name(xmart_server)
  valid <- check_xmart_env(nm)
  if (!valid) {
    token <- xmart4_token(
      auth_type = auth_type,
      xmart_server = xmart_server
    )
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
      call. = FALSE
    )
  }
}

#' @noRd
token_header <- function(token) {
  httr::add_headers(Authorization = paste("Bearer", token))
}
