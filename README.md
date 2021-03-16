
<!-- README.md is generated from README.Rmd. Please edit that file -->

# xmart4 <a href='https://github.com/caldwellst/xmart4'><img src='man/figures/logo.png' align="right" height="139" /></a>

<!-- badges: start -->

[![R build
status](https://github.com/caldwellst/xmart4/workflows/R-CMD-check/badge.svg)](https://github.com/caldwellst/xmart4/actions)
<!-- badges: end -->

The goal of xmart4 is to provide easy access to the World Health
Organization’s xMart4 API by managing client access to the xMart. Once a
machine is connected to the database, xmart4 provides a simple interface
to interact with the OData API by pulling in tables and marts directly
into R.

## Installation

You can install xmart4 from [GitHub](https://github.com/) with:

``` r
remotes::install_github("caldwellst/xmart4", build_vignettes = TRUE)
```

## Connection types

To get setup with the xmart4 package, there are two ways to authenticate
your machine with the Azure database. For most users, they will want to
use their WIMS account to allow their personal machine to access xMart
databases. The guide for this setup can be found below or in the
relevant vignette:

-   `vignette("azure-wims-setup", package = "xmart4")`

However, for some use cases, particularly dashboards, Shiny
applications, or other non-interactive R pipelines, we isntead want to
setup a separate Azure client to connect to the xMart4 database. The
instructions for both of these are in the following vignettes:

-   `vignette("azure-client-setup", package = "xmart4")`
-   `vignette("azure-token-setup", package = "xmart4")`

## Azure WIMS Setup

Accessing the xMart4 databases using your WIMS authentication is a
simple process. This packages builds on the
[AzureAuth](https://github.com/Azure/AzureAuth) package, one developed
and maintained by the Azure developers, to ease the access for the user.

### Azure cache directory

Once the xmart4 package is installed, the first thing the user can do is
run `make_azure_rdir()`. This creates a file directory on your machine
that will cache WIMS authentication and limit the need to login to WIMS
in your browser every R session. This mimics the behavior on AzureAuth’s
`onLoad()` function.

``` r
library(xmart4)
make_azure_rdir()
#> AzureR_dir created at /Users/username/Library/Application Support/AzureR
```

### Azure password

From here, your WIMS account needs to ping the xMart4 Azure servers. To
do this, we need to supply the passwords for the UAT and PROD servers
separately. However, this is not exported with this package because
these values are private. You can contact the maintainer of the package
to get these values.

Once received, you need to add them to your `.Renviron` file, which can
easily be edited using the usethis package with
`usethis::edit_r_environ()`. Once the file is opened, just add two lines
to the file and save like below (with the hashes replaced with the
actual passwords):

    XMART_UAT_PASSWORD = "##########"
    XMART_PROD_PASSWORD = "##########"

Once saved, restart your R session. You can test that this has
successfully worked by running:

``` r
xmart4_token(auth_type = "wims")
```

If this is successful, you can now start exploring any marts that your
WHO WIMS account has access to. Please note you need to work with the
specific mart managers to get your WHO WIMS account access before this
setup will work.

## Getting data

Once you have sorted out access to the xMart4 database using one of the
two methods above, you can start using the simple functions available in
the package to access xMart4 marts and tables.

-   `xmart4_mart()` provides a character vector of all available tables
    and views in a specified mart.
-   `xmart4_table()` retrieves data from a specified mart or table.

Using both should just require you to specify mart name, server (UAT or
PROD), and table name (if applicable). It’s as easy as opening an R
session and going:

``` r
library(xmart4)

head(xmart4_mart("GPW13"))
#> Loading cached token
#> [1] "CONVERT"                   "CONVERT_T"                
#> [3] "FACT_BILLION_HE_EVENT"     "FACT_BILLION_HE_INDICATOR"
#> [5] "FACT_BILLION_HP_COUNTRY"   "FACT_BILLION_HP_INDICATOR"
```

Let’s access the CONVERT table.

``` r
xmart4_table(mart = "GPW13", table = "CONVERT", xmart_server = "UAT")
#> 
#> ── Column specification ────────────────────────────────────────────────────────
#> cols(
#>   INPUT = col_character(),
#>   OUTPUT = col_double()
#> )
#> # A tibble: 12 x 2
#>    INPUT  OUTPUT
#>    <chr>   <dbl>
#>  1 C      0.0689
#>  2 B      0.195 
#>  3 D     19.1   
#>  4 A     28.6   
#>  5 E     88.8   
#>  6 D     91     
#>  7 C      0.667 
#>  8 B      0.568 
#>  9 A     39.0   
#> 10 B      0.0123
#> 11 D     23.4   
#> 12 E     12.9
```

And I can request the top *n* rows of a table and even supply OData
filters with my request. This is especially useful in instances where
tables or views have many rows and requests may take a long time, so you
can explore the table on a small subset and find useful OData queries to
reduce the size of the data requested.

``` r
xmart4_table(mart = "GPW13",
             table = "CONVERT",
             top = 2,
             query = "$filter=Input eq 'A'",
             xmart_server = "PROD")
#> Loading cached token
#> 
#> ── Column specification ────────────────────────────────────────────────────────
#> cols(
#>   INPUT = col_character(),
#>   OUTPUT = col_double()
#> )
#> # A tibble: 2 x 2
#>   INPUT OUTPUT
#>   <chr>  <dbl>
#> 1 A       28.6
#> 2 A       39.0
```

Note above, I seamlessly moved between consuming data from PROD and UAT
servers.

## Memoisation

`xmart4_api()`, the function underlying requests to the xMart4 API, has
cached functionality based on `memoise::memeoise()` so that calls to the
`xmart4_api()` function are cached in your local memory in a single
session. This means that once you’ve made a call to access an xMart mart
or table/view, running an identical request will use the cached data
rather than re-request the data from the xMart4 API. This provides large
advantages when working with big tables and views, as the API requests
grow quite time consuming as the number of rows grows. Load the xmart4
package explicitly through `library(xmart4)`, rather than simply callin
functions via `xmart4::fun()`.

This could be problematic if using the xmart4 package to test or consume
data from marts that are being updated throughout an R session. If you
need to ensure that the xmart4 package is making new requests to the API
each time, then you will need to run
`memoise::forget(xmart4:::xmart4_api)` to clear the cache prior to
repeating a call. See the documentation of the [memoise
package](https://github.com/r-lib/memoise) for more details.

## Contributions

Additional feature requests should be made through the [GitHub issues
page](https://github.com/caldwellst/xmart4/issues). Any contributions
appreciated and encouraged, but please create an open issue first for
discussion before proceeding with a pull request.
