# RToolShed 0.1.5

* New functions:
  - `write_df_to_hive3()`: upload a dataframe to hive 3 as a managed table. All side effects removed at the end of the function call.
  - `write_csv_to_hive3()`: upload a dataframe to hive 3 as a managed table. All side effects removed at the end of the function call.
  
* Bug fix:
  - `write_df_to_hive()`: 
    - removed static path to write to and replaced with code that will build and delete a new directory where the dataframe will be saved on the server. Updated docs.  
    - replace `file` with `csv_file` so that it conforms with `write_csv_to_hive()`
  - `write_csv_to_hive()`: removed static path to write to and replaced with code that will build and delete a new directory where the dataframe will be saved on the server. Update docs.
  - `test_na`: fixed issues in import to importFrom  

* Feature Request:
  - Parameter: add parameter to the `write_to_*` functions that will allow appending instead of overwrite.  The default will remain overwrite.
  
* Function update:
  - change function name from lag_it to lag_vars, and diff_it to diff_vars.

# RToolShed 0.1.4

*  Functions added in this version:
 * - `geom_mean()`
 * - `df_name_dot_csv()`
 * - `rad2deg()` 
 
* Functions removed in this version:
 * - `nest_it()`
 * - `prep_multidplyr()`
 * - `ts_exposed` - in development  

# RToolShed 0.1.3

* Functions added in this version:
 * - `lag_it()` 
 * - `diff_it()`
* Fixed errors in description file
* Fixed errors with namespace file
  
# RToolShed 0.1.2

* Test for R-3.6.3
* Functions added in this version:
 * - `install.pkgs.user_lib()`

# RToolShed 0.1.1

* Functions added in this version:
 * - `nest_it()`
 * - `ts_exposed` - in development
 * - `write_csv_to_hive()`
 * - `write_df_to_hive()`
 * - `prep_multidplyr()`

# RToolShed 0.1.0

* Build package directory.  
* Added a `NEWS.md` file to track changes to the package.
* Added a `README.md` file for documentation.
* Added `Package_Development_Script.R` to track package build.
* Added vignette doc.
* Functions added in this version:
 * - `to_postgres()`
 * - `rm_db_name()
 * - `dbCreatePrimaryIndex()``
