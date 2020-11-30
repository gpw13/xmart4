#' @inherit xmart4_token title params
xmart4_token_wims <- function(xmart_id) {
  pw <- get_wims_password(xmart_id)
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
get_wims_password <- function(xmart_id) {
  if (xmart_id == "712b0d0d-f9c5-4b7a-80d6-8a83ee014bca") {
    "qQKa]APZ_0q.OwO.Oq1H3ndnFNsa16u7"
  } else if (xmart_id == "b85362d6-c259-490b-bd51-c0a730011bef") {
    "utNZAZb8823NaRexQl[VPU=gK[YD/H1E"
  } else {
    stop("Invalid `xmart_id` supplied to `get_wims_password()`.",
         call. = FALSE)
  }
}

#' Create Azure cache directory
#'
#' `make_azure_rdir()` is a simple wrapper function that creates the Azure
#' cache directory on a local machine once, to enable caching of WIMS account
#' authentication. This replicates the `onLoad()` behavior of the AzureAuth
#' package when called using `library(AzureAuth)`.
#'
#' @return Nothing, but creates directory if it does not already exist.
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
