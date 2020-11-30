#' @inherit xmart4_token title params
xmart4_token_client <- function(xmart_id,
                                client_id = NULL,
                                client_secret = NULL) {
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
