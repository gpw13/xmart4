#' @inherit xmart4_token title params
#' @param xmart_id Resource and app ID for authentication.
xmart4_token_wims <- function(xmart_id,
                              xmart_server) {
  pw <- get_wims_password(xmart_server)
  resp <- AzureAuth::get_azure_token(resource = xmart_id,
                                     tenant = "f610c0b7-bd24-4b39-810b-3dc280afb590",
                                     app = xmart_id,
                                     auth_type = "authorization_code",
                                     password = pw,
                                     use_cache = TRUE)

  token <- resp_to_token(resp[["credentials"]])
  token
}

#' @noRd
get_wims_password <- function(xmart_server) {
  nm <- paste0("XMART_", xmart_server, "_PASSWORD")
  x <- Sys.getenv(nm)
  if (identical(x, "")) {
    stop(sprintf("Please set env var %s in your .Renviron file. See `vignette('azure-wims-setup', package = 'xmart4')` for more details.",
                 nm),
         call. = FALSE)
  }
  x
}

#' Create Azure cache directory
#'
#' `make_azure_rdir()` is a simple wrapper function that creates the Azure
#' cache directory on a local machine once, to enable caching of WIMS account
#' authentication. This replicates the `onLoad()` behavior of the AzureAuth
#' package when called using `library(AzureAuth)`.
#'
#' @return Nothing, but creates directory if it does not already exist.
#'
#' @export
make_azure_rdir <- function() {
  dir <- AzureAuth::AzureR_dir()
  if (dir.exists(dir)) {
    message(paste0("AzureR_dir already exists at ", dir))
  } else{
    dir.create(dir)
    message(paste("AzureR_dir created at ", dir))
  }
  invisible(NULL)
}
