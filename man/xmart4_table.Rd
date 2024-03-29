% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mart_access.R
\name{xmart4_table}
\alias{xmart4_table}
\title{Get data from xMart table or view}
\usage{
xmart4_table(
  mart,
  table,
  top = NULL,
  query = NULL,
  format = c("none", "csv", "streaming"),
  col_types = NULL,
  full_table = TRUE,
  xmart_server = c("UAT", "PROD"),
  return_cols = c("data", "all", "sysdata"),
  auth_type = "client",
  token = NULL
)
}
\arguments{
\item{mart}{Name of the xMart4 mart}

\item{table}{Name of a table within the mart, otherwise \code{NULL} (the default)}

\item{top}{Number of rows of a table to return}

\item{query}{A single string fitting the \href{https://www.odata.org/documentation/odata-version-2-0/uri-conventions/}{Odata protocol}
that must start with \code{"$filter="}.}

\item{format}{Specification of the output format to be returned by the xMart API.
Defaults to \code{"none"}, but consider switching to \code{"csv"} if you are having
loading an extremely large table. See the
\href{https://portal-uat.who.int/xmart4/docs/xmart_api/use_API.html}{xMart4 API documentation}
for details on the three options.}

\item{col_types}{One of NULL, a \code{\link[readr:cols]{readr::cols()}} specification, or a string. This
is passed to \code{\link[readr:type_convert]{readr::type_convert()}}, so see documentation there for more details.}

\item{full_table}{Logical, whether or not to load all the rows in a specified table,
defaults to \code{TRUE}. If no format is provided, the xMart4 API limits calls to 100,000 rows at a time, so
if \code{full_table == TRUE}, the function automatically repeats the API call to
extract all rows within the xMart4 table. Ignored if \code{format="streaming"} or
\code{format="csv"}.}

\item{xmart_server}{Either 'UAT' (the default) or 'PROD'}

\item{return_cols}{Return data columns only (default), all columns, or system data columns. Only works on tables, as views have no system columns.}

\item{auth_type}{Type of authorization to use for the token authorization.
If "client" (the default), it uses an AzureAD client setup. The old "wims"
method has been discontinued.}

\item{token}{Access token for xMart4 server. If NULL (the default), the package automatically creates and manages access for the user if Azure client ID and secret set up properly. See \code{vignette("token_setup")} for instructions and details.}
}
\value{
A tibble.
}
\description{
Retrieves data from an xMart table or view, and returns it as a tibble. For
views, returns the entire data frame from the mart. For tables, can choose to
return only data columns (the default), all columns, or only the system columns.
}
