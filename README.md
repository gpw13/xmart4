
<!-- README.md is generated from README.Rmd. Please edit that file -->

# xmart4 <a href='https://github.com/gpw13/xmart4'><img src='man/figures/logo.png' align="right" height="139" /></a>

<!-- badges: start -->

[![R build
status](https://github.com/gpw13/xmart4/workflows/R-CMD-check/badge.svg)](https://github.com/gpw13/xmart4/actions)
[![test-coverage](https://github.com/gpw13/xmart4/actions/workflows/test-coverage.yaml/badge.svg)](https://github.com/gpw13/xmart4/actions/workflows/test-coverage.yaml)
<!-- badges: end -->

The goal of xmart4 is to provide easy access to the World Health
Organization’s xMart4 API by managing client access to the xMart. Once a
machine is connected to the database, xmart4 provides a simple interface
to interact with the OData API by pulling in tables and marts directly
into R.

## Installation

You can install xmart4 from [GitHub](https://github.com/gpw13/xmart4)
with:

``` r
remotes::install_github("gpw13/xmart4", build_vignettes = TRUE)
```

## Connection types

To get setup with the xmart4 package, there are two ways to authenticate
your machine with the Azure database. Following xMart’s team
recommendations, the package has switched to use the client
authentification as a default (it was WIMS access before). The guide for
this setup can be found below or in the relevant vignette:

-   `vignette("azure-client-setup", package = "xmart4")`

However, for some use cases, particularly dashboards, Shiny
applications, or other non-interactive R pipelines, we instead want to
setup a separate Azure client to connect to the xMart4 database. The
instructions for these are in the following vignette:

-   `vignette("azure-token-setup", package = "xmart4")`

## Azure Client Setup

If a remote client application needs to securely access an xMart4
database, specific permissions must be set up in the WHO AzureAD. The
below tutorial takes you through the steps to establish this connection.

## Remote client app configuration

<figure>
<img src="vignettes/xmart4-azure-setup_insertimage_2.png" style="width:80.0%" alt="Create or retrieve AzureAD app clientID." /><figcaption aria-hidden="true">Create or retrieve AzureAD app clientID.</figcaption>
</figure>

In the [AzureAD
portal](https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/RegisteredApps)
get the Application (client ID) of the application that needs access to
the xMart API. If the application does not exist, create it or request
it to Chris Tantillo. Let’s call this clientID `remoteClientID` for
future references.

<figure>
<img src="vignettes/xmart4-azure-setup_insertimage_3.png" style="width:50.0%" alt="Generate a client secret." /><figcaption aria-hidden="true">Generate a client secret.</figcaption>
</figure>

In the same AzureAD page, click Certificates & Secrets > New client
secret. We’ll refer to this secret by `remoteClientSecret`.

## xMart API app configuration

This step should be done by the xMart API owner (one of Chris Tantillo,
Chris Faulkner, or Thyiag) in Azure in order to allow your application
to consume xMart API data.

<figure>
<img src="vignettes/xmart4-azure-setup_insertimage_4.png" style="width:50.0%" alt="Expose an API in xMart &gt; Add a Client application" /><figcaption aria-hidden="true">Expose an API in xMart &gt; Add a Client application</figcaption>
</figure>

In WHO AzureAD Portal, find xMart API (Env) in App Registrations. Get
the clientID, we’ll call it `xmartapiClientID`. It will need to provided
to the remote app developer.

-   Value for UAT,
    `xmartapiClientID: b85362d6-c259-490b-bd51-c0a730011bef`
-   Value for PROD,
    `xmartapiClientID: 712b0d0d-f9c5-4b7a-80d6-8a83ee014bca`

Open the app and select **Expose an API**, click **Add a client
application** and paste the `remoteClientID`.

<figure>
<img src="vignettes/xmart4-azure-setup_insertimage_5.png" style="width:50.0%" alt="Configure xMart role &gt; Add Client Application" /><figcaption aria-hidden="true">Configure xMart role &gt; Add Client Application</figcaption>
</figure>

In xMart Admin UI of your mart, create or use an existing role that has
DATA_VIEW permission for the mart or view(s) that need to be consumed by
the remote app. Then, in Users, click the Add a Client
application button. Fill in the remoteClientID received from previous
step and wisely chosen friendly name. From here, you will be shown how
to use the `remoteClientID` and `remoteClientSecret` in the xmart4 R
package.

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

    #> Loading cached token
    #> [1] "CONVERT"                   "CONVERT_T"                
    #> [3] "FACT_BILLION_HE_EVENT"     "FACT_BILLION_HE_INDICATOR"
    #> [5] "FACT_BILLION_HP_COUNTRY"   "FACT_BILLION_HP_INDICATOR"

Let’s access the CONVERT table.

    #> 
    #> -- Column specification --------------------------------------------------------
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

And I can request the top
![n](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;n "n")
rows of a table and even supply OData filters with my request. This is
especially useful in instances where tables or views have many rows and
requests may take a long time, so you can explore the table on a small
subset and find useful OData queries to reduce the size of the data
requested.

    #> 
    #> -- Column specification --------------------------------------------------------
    #> cols(
    #>   INPUT = col_character(),
    #>   OUTPUT = col_double()
    #> )
    #> # A tibble: 2 x 2
    #>   INPUT OUTPUT
    #>   <chr>  <dbl>
    #> 1 A       28.6
    #> 2 A       39.0

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
page](https://github.com/xmart4/xmart4/issues). Any contributions
appreciated and encouraged, but please create an open issue first for
discussion before proceeding with a pull request.
