# xmart 0.3.0

* WIMS `auth_type` is depricated following recommendations from the xMart team
* Documentation updated to reflect the removal of the WIMS access.

# xmart4 0.2.2

* Implement format argument to allow for streaming or CSV output formats direct from the xMart4 API, which do not have row limits. This should be used if loading an extremely large table that is encountering performance issues on the standard load. Details on the [API available here in the xMart4 documentation](https://portal-uat.who.int/xmart4/docs/xmart_api/use_API.html).


# xmart4 0.2.1

* Fix issue with xMart4 API using different orderings depending on if `$skip=` is included in the API query, so downloading a full table using OData nextLink duplicated some records and excluded others.

# xmart4 0.2

* The xMart4 API now limits user calls to 100,000 rows per call. This update ensures that the default behavior of the xmart4 package is to continually repeat calls to an xMart4 table until all rows have been downloaded. This is controlled through the `full_table` argument in the `xmart4_table()` function.

# xmart4 0.0.1

* Added a `NEWS.md` file to track changes to the package.
* Updated `xmart4_table()` to take `readr::col_types()`

# xmart4 0.1

* Implemented WIMS account authentication so there is no need to set up a separate Azure client
