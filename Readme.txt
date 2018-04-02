mtx: Working with data matrices

This is an SWI-Prolog pack for working with data matrices, taking off from where library(csv) ends.
The library will hopefully grow to become useful tool for logic programming based data science.

Install via SWI's package manager:
==
?- pack_install(mtx).  % it will install pack(lib) if not present in your system
?- use_module(library(lib)).
?- lib(mtx).
?- mtx(data(mtcars),MtCars).
Mtcars = [row(mpg, cyl, disp, hp, ....
==

---+ Input/Output:
At the very least library(mtx) can be viewed as an addition/enhancement io of matrices to files via mtx/2.
The library can interrogate the data/ subdirectory of all installed packs for csv files using alias data.

==
?- mtx( data(mtcars), Mtcars ).
Mtcars = [row(mpg, cyl, disp, hp, ....
==

Where =mtcars.csv= is in some pack's data directory.

==
?- mtx_data( mtcars, Mtcars ).
Mtx = [row(mpg, cyl, disp, hp, ....)|...]
==

Where mtcars.csv is in pack(mtx) data subdirectory.

mtx/2 works both as input and output.

If the 2nd argument is ground, mtx/2 with output the 2nd argument to the file pointed by the 1st.
Else, the 1st argument is taken as the input file or matrix, and the 2nd argument is the same matrix in standard form.

==
?- tmp_file( mtc, TmpF ), mtx( pack('mtx/data/mtcars'), Mtc ), mtx( TmpF, Mtc ).
TmpF = '/tmp/pl_mtc_14092_0',
Mtc = [row(mpg, cyl,
==

The first call to mtx/2 above, inputs the test csv mtcars.csv, to Mtc (instantiated to list of rows).
The second call, outputs Mtc to the temporary file TmpF.

mtx/3 provides a couple of options on top of csv_read_file/3 and csv_write_file/3.
 * sep(Sep)
   is short for separator, that also understands comma, tab and space (see mtx_sep/2).
 * match(Match)
   is short for match_arity(Match)

==
?- mtx( data(mtcars), Mtcars, sep(comma) ).
Mtcars = [row(mpg, cyl, disp, hp, ....)|...]
==

---+ Good places to start:

  * mtx/3
  * mtx_column/3
  * mtx_column_select/4
  * mtx_column_add/4
  * mtx_column_include_rows/4
  * mtx_column_kv/3
  * mtx_read_table/4
  * mtx_rows_partition/5
  * mtx_value_column_frequencies/3
  * mtx_columns_cross_table/5
  * mtx_apply/4
  * mtx_lists/2

---+  materials

web-page: http://stoics.org.uk/~nicos/sware/mtx
doc: http://stoics.org.uk/~nicos/sware/mtx/doc/html/mtx.html
source: http://stoics.org.uk/~nicos/sware/packs/mtx/
github: https://github.com/nicos-angelopoulos/mtx

licence: MIT
---

Nicos Angelopoulos
http://stoics.org.uk/~nicos
April 2018
