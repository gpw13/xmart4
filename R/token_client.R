#' @inherit xmart4_token title params
#' @inherit xmart4_token_wims params
xmart4_token_client <- function(xmart_id,
                                client_id = NULL,
                                client_secret = NULL,
                                use_cache = TRUE) {

  tenant_id = Sys.getenv("XMART_TENANT_ID")
  assert_tenant_id(tenant_id)

  client_id <- assert_client_id(client_id)
  client_secret <- assert_client_secret(client_secret)

  resp <- AzureAuth::get_azure_token(
    resource = xmart_id,
    tenant = tenant_id,
    app = client_id,
    password = client_secret,
    auth_type = "client_credentials",
    use_cache = use_cache
  )

  token <- resp_to_token(resp[["credentials"]])
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

assert_tenant_id <- function(x) {
  if (identical(x, "") || is.null(x)) {
    stop("Please set the XMART_TENANT_ID environment variable", call. = FALSE)
  }
}
