#' @noRd
assert_client_id <- function(x) {
  if (is.null(x)) {
    x <- Sys.getenv("XMART_REMOTE_CLIENT_ID")
    if(identical(x, "")) {
      stop("Please set env var XMART_REMOTE_CLIENT_ID to your remoteClientID or manually provide `client_id`.",
           call. = FALSE)
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
    if(identical(x, "")) {
      stop("Please set env var XMART_REMOTE_CLIENT_SECRET to your remoteClientSecret or manually provide `client_secret`.",
           call. = FALSE)
    }
    x
  } else {
    x
  }
}

#' @noRd
assert_query <- function(qry) {
  if (!is.null(qry) && !is.na(qry)) {
    if (length(qry) > 1 || !is.character(qry)) {
      stop("`query` needs to be a single string, not a vector")
    } else if (substr(qry, 0, 8) != "$filter=") {
      stop("`query` needs to start with '$filter='",
           call. = FALSE)
    }
  }
}

#' @noRd
assert_json <- function(resp) {
  type <- httr::http_type(resp)
  if (type != "application/json") {
    stop("xMart API did not return json.",
         call. = FALSE)
  }
}

#' @noRd
assert_status_code <- function(resp) {
  status <- httr::http_status(resp)
  msg <- status[["message"]]
  sc <- httr::status_code(resp)
  general <- "xMart API request failed with status code %s and message: %s."
  if (sc == 401) {
    stop(sprintf(paste(general, "You need to give your client access to this mart."),
                 sc,
                 msg),
         call. = FALSE)
  } else if (sc == 404) {
    stop(sprintf(paste(general, "Check spelling of mart and table names."),
                 sc,
                 msg),
         call. = FALSE)
  } else if (sc != 200) {
    stop(sprintf(general, sc, msg),
         call. = FALSE)
  }
}

#' @noRd
assert_content <- function(parsed) {
  if (identical(parsed[["value"]], list())) {
    stop("xMart API returned no content. Check the name of the mart.",
         call. = FALSE)
  }
}

#' @noRd
assert_top <- function(top) {
  num_type <- is.numeric(top)
  if (!is.null(top) && !num_type) {
    stop(sprintf("`top` must be either NULL or numeric, not %s",
                 class(top)),
         call. = FALSE)
  } else if (num_type && length(top) > 1) {
    stop("If provided, `top` must be a single numeric value, not a vector.",
         call. = FALSE)
  }
}

#' @noRd
assert_mart <- function(mart) {
  if (!is.character(mart) || length(mart) > 1) {
    stop(sprintf("`mart` must be a single string of length 1, not a %s vector of length %s.",
                 class(mart),
                 length(mart)),
         call. = FALSE)
  }
}

#' @noRd
assert_table <- function(mart, table) {
  if (!is.null(table)) {
    if (!is.character(table) || length(table) > 1) {
      stop(sprintf("`table` must be a single string of length 1, not a %s vector of length %s.",
                   class(table),
                   length(table)),
           call. = FALSE)
    } else {
      tbls <- xmart4_mart(mart)
      if (!(table %in% tbls)) {
        stop(sprintf("`table` %s is not a valid table code in `mart` %s. Use `xmart4_mart('%s')` to access a list of all valid table codes.",
                     table,
                     mart,
                     mart),
             call. = FALSE)
      }
    }
  }
}

#' @noRd
assert_list_token <- function(token) {
  if (!(is.list(token) && (names(token) == c("token", "expires")))) {
    stop("To check time left on token, it must be in the format returned by `get_xmart4_token()`")
  }
}