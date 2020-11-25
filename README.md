
<!-- README.md is generated from README.Rmd. Please edit that file -->

# xmart4

<!-- badges: start -->

[![Travis build
status](https://travis-ci.com/caldwellst/xmart4.svg?branch=master)](https://travis-ci.com/caldwellst/xmart4)
<!-- badges: end -->

The goal of xmart4 is to provide easy access to the World Health
Organization’s xMart4 API by managing client access tokens for the user
and providing simple functions to view mart and table contents.

## Installation

You can install xmart4 from [GitHub](https://github.com/) with:

    remotes::install_github("caldwellst/xmart4", build_vignettes = TRUE)

## Initial setup

Most of the work in getting access to the xMart4 API has to be done
outside of R. This primarily consists of setting up a client application
in WHO AzureAD and supplying that client’s ID and secret to the xMart4
API. Once your client has access to the xMart4 API, mart permissions can
be managed by the admin of each mart individually. Full details on this
process can be found on the [xMart4 Slack
Wiki](https://xmartcollaboration.slack.com/files/TJF6QTLE4/F019WGZSSD7?origin_team=TJF6QTLE4).

This package works to streamline the process on the R side by making
access to xMart4 as simple as possible. If the client configuration is
properly done, then this package allows you full access to xMart4 by
only editing your `.Renviron` file once. Add your `remoteClientID` and
`remoteClientSecret` from WHO AzureAD to that by running
`usethis::edit_r_environ()` and adding these two lines (replacing hashes
with actual client ID and secret values):

    XMART_REMOTE_CLIENT_ID = "############"
    XMART_REMOTE_CLIENT_SECRET = "############"

Save the file and restart your R session. You will now be able to access
all xMart4 marts your client app has been granted permission to access
by mart admins. Unless your client changes, you should not have to run
this setup ever again and tokens will be managed in the background for
you by the `xmart4` package.

## Underlying functionality

So how does this work in practice? The first time you call the
`xmart4_api()` in a session (either directly or by using any function to
access marts or tables), if a token is not manually provided, a token
will be automatically generated. `get_xmart_token()` will be run to get
an access token for either the xMart4 UAT or PROD server, depending on
the API call. This will then be stored in the package environment,
`xmart4:::.xmart_env`.

Every subsequent time an API call is made, that environment is searched
for the correct token (UAT or PROD), and if the token doesn’t exist or
has expired, a new token will be generated. All of this should never
require you to directly request a token or manage token access. Separate
tokens are managed for both UAT and PROD servers simultaneously.

Once setup, in every session, you can just directly start requesting
access to marts and tables with `xmart4` functions, without having to
specify the token

    xmart4_mart(..., token = NULL) # don't actually need to specify token = NULL, it's the default
    xmart4_table(..., token = NULL)

## Directly managing token access

The only instance where you might want to personally manage token access
would be if you’re attempting to access the xMart4 API through multiple
clients. You could still let your primary client defined in your
`.Renviron` run automatically, by calling the xMart4 API without
specifying the token.

For additional clients not setup this way, you can just directly request
your tokens. For instance, to set up and use a new access token for the
UAT server:

    token_uat_2 <- xmart4_token(client_id = "#######",
                                client_secret = "#######",
                                xmart_server = "UAT")

    xmart4_mart(..., token = token_uat_2)
    xmart4_table(..., token = token_uat_2)

You can check the time left on your token using
`xmart_token_time(token_uat_2)` (they come with 60 minutes of validity
once generated). Hopefully you don’t need to manually manage your
tokens, but these wrappers should still make the process as painless as
possible as xmart4 streamlines the POST requests and expiry checks.

## Getting data

Once you have sorted out the client tokens, you can start using the
simple functions available in the package to access xMart4 marts and
tables.

-   `xmart4_mart()` provides a character vector of all available tables
    and views in a specified mart.
-   `xmart4_table()` retrieves data from a specified mart or table.

Using both should just require you to specify mart name, server (UAT or
PROD), and table name (if applicable). It’s as easy as opening an R
session and going:

    library(xmart4)

    head(xmart4_mart("GPW13"))
    #> [1] "CONVERT"                   "CONVERT_T"                
    #> [3] "FACT_BILLION_HE_EVENT"     "FACT_BILLION_HE_INDICATOR"
    #> [5] "FACT_BILLION_HP_COUNTRY"   "FACT_BILLION_HP_INDICATOR"

Let’s access the CONVERT table.

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
    #>  1 A     39.0   
    #>  2 C      0.0689
    #>  3 D     19.1   
    #>  4 B      0.568 
    #>  5 D     91     
    #>  6 E     12.9   
    #>  7 D     23.4   
    #>  8 B      0.0123
    #>  9 B      0.195 
    #> 10 E     88.8   
    #> 11 A     28.6   
    #> 12 C      0.667

And I can request the top n rows of a table and even supply OData
filters with my request. This is especially useful in instances where
tables or views have many rows and requests may take a long time, so you
can explore the table on a small subset and find useful OData queries to
reduce the size of the data requested.

    xmart4_table(mart = "GPW13",
                 table = "CONVERT",
                 top = 2,
                 query = "$filter=Input eq 'A'",
                 xmart_server = "PROD")
    #> 
    #> ── Column specification ────────────────────────────────────────────────────────
    #> cols(
    #>   Input = col_character(),
    #>   Output = col_double()
    #> )
    #> # A tibble: 2 x 2
    #>   Input Output
    #>   <chr>  <dbl>
    #> 1 A       28.6
    #> 2 A       39.0

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
