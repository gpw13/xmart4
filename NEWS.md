# xmart4 0.2

* The xMart4 API now limits user calls to 10,000 rows per call. This update ensures that the default behavior of the xmart4 package is to continually repeat calls to an xMart4 table until all rows have been downloaded. This is controlled through the `full_table` argument in the `xmart4_table()` function.

# xmart4 0.0.1

* Added a `NEWS.md` file to track changes to the package.
* Updated `xmart4_table()` to take `readr::col_types()`

# xmart4 0.1

* Implemented WIMS account authentication so there is no need to set up a separate Azure client
