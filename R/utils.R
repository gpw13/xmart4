#' Get names of xMart4 columns
#'
#' Returns a character vector with the names of all the columns expected by xMart.
#'
#' @return character vector
#' @export
xmart_cols <- function() {
  c("iso3", "year","ind", "upload_date", "value", "lower", "upper", "use_dash",
    "use_calc", "source", "type", "type_detail", "other_detail", "upload_detail")
}


#' Check data frame for xMart4 columns
#'
#' Tests to see if the given data frame has all the columns required by xMart4.
#' The test does not take column order into consideration
#' (i.e., a,b,c and c,a,b will post them)
#'
#' @param df data.frame
#'
#' @return bool
#' @export
has_xmart_cols <- function(df) {
  condition = identical(
    sort(names(df)),
    sort(xmart_cols())
  )
  if (!condition) {
    stop("This data frame does not have all the columns required by xMart.")
  }
}

