# environment to store API tokens
.xmart_env <- new.env(parent = emptyenv())

# user agent
ua <- httr::user_agent("https://github.com/caldwellst/xmart4")

.onLoad <- function(lib, pkg) {
  xmart4_api <<- memoise::memoise(xmart4_api)
}
