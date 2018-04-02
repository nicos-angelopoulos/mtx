:- module( mtx,  [
				mtx/1, mtx/2, mtx/3,
				mtx_facts/1,mtx_facts/2,mtx_facts/3,
				mtx_header/2, mtx_header_body/3,  mtx_header_body/5,
				mtx_has_header_add/4,
				mtx_header_column_name_pos/4, mtx_header_column_pos/3,
				mtx_header_column_multi_pos/4, mtx_relative_pos/4,
				mtx_header_cids_order/3,
				mtx_name_prefix_column/5,

				mtx_lists/2,
				mtx_facts_remove/1,  % ?
				mtx_in_memory/1, mtx_in_memory/2, mtx_matrices_in_memory/1,

				mtx_column/3, mtx_column/5, mtx_column_default/4, 
				mtx_column_set/3, mtx_column_set/4,
				mtx_column_name_options/5, mtx_column_name_options/3,
				mtx_column_select/4, 
				mtx_columns/3,mtx_columns/4,mtx_column_kv/3,mtx_columns_kv/6,
				mtx_column_add/4,
				mtx_column_replace/5, mtx_column_replace/6,
				mtx_column_threshold/5, mtx_column_threshold/6, 
                mtx_column_frequency_threshold/5,
				mtx_column_include_rows/4, mtx_column_include_rows/5,         % +Mtx, +Cid, +Call, -Incl[, +Opts]
				mtx_column_values_select/6,

				mtx_columns_copy/4,
				mtx_columns_partition/4,
				mtx_columns_partition/5,
				mtx_rows_partition/5,
				mtx_columns_remove/3,
				mtx_columns_values/3,
                mtx_value_plot/3,
                mtx_value_column_frequencies/3,
                mtx_columns_cross_table/5,

                mtx_read_table/4,    % +CsvF, +RowsName, -Table, +Opts

				mtx_pos_elem/5, mtx_pos_elem/6,
				mtx_apply/4,
				mtx_data/2, mtx_dims/3,
				mtx_factors/3, mtx_transpose/2,
				mtx_prolog/3,
				mtx_sort/3, mtx_sort/4, mtx_type/2,
                mtx_sep_type/1, mtx_sep/2,
                mtx_version/2
			  ]
		).


:- use_module(library(lib)).
:- lib( source(mtx), homonyms(true) ).

:- lib(debug).  	% this is auto-load, keeping here to encourage usage. 
                    % src/mtx.pl has started using debug/3. use mtx(Pname), also move to pack(debug_call)

:- lib(os_lib).
:- lib(options).
:- lib(pack_errors).
:- lib(stoics_lib).

:- dynamic( mtx:mtx_data_store/2 ).
:- dynamic( mtx:mtx_data_handle_file/2 ).

:-  assertz(user:file_search_path(data,data)).

:- ( member(Alias,[swi,app_data]),
     user:file_search_path(Alias,Search), 
     directory_file_path(Search,pack,PackD),
     exists_directory(PackD),
     directory_files(PackD,Files),
     member(Dir,Files),
     Dir \== '.', Dir \=='..',
     directory_file_path(PackD,Dir,AbsDir),
     directory_file_path(AbsDir,data,DataD),
     exists_directory(DataD),
     debug( upsh,'assert-zing:~w',[user:file_search_path(upsh,DataD)] ),
     assertz(user:file_search_path(data,DataD)),
    fail
   ;
   true
   ).


:- lib(mtx/1).
:- lib(mtx_column_kv/3).
:- lib(mtx_header/2).
:- lib(mtx_header_body/3).
:- lib(mtx_has_header_add/4).
:- lib(mtx_header_column_name_pos/4).
:- lib(mtx_header_column_pos/3).
:- lib(mtx_header_column_multi_pos/4).
:- lib(mtx_in_memory/2).
:- lib(mtx_sort/3).
:- lib(mtx_facts/3).
:- lib(mtx_column_add/4).
:- lib(mtx_column/3).
:- lib(mtx_column_default/4).
:- lib(mtx_column_name_options/3).
:- lib(mtx_column_name_options/5).
:- lib(mtx_column_include_rows/4).
:- lib(mtx_column_select/4).
:- lib(mtx_column_threshold/5).
:- lib(mtx_column_frequency_threshold/5).
:- lib(mtx_column_replace/5).
:- lib(mtx_column_values_select/6).
:- lib(mtx_name_prefix_column/5).
:- lib(mtx_relative_pos/4).
:- lib(mtx_lists/2).
:- lib(mtx_transpose/2).
:- lib(mtx_factors/3).
:- lib(mtx_columns_copy/4).
:- lib(mtx_columns_kv/6).
:- lib(mtx_header_cids_order/3).
:- lib(mtx_columns_remove/3).
:- lib(mtx_dims/3).
:- lib(mtx_prolog/3).
:- lib(mtx_columns_partition/5).
:- lib(mtx_rows_partition/5).
:- lib(mtx_columns_values/3).
:- lib(mtx_value_plot/3).
:- lib(mtx_value_column_frequencies/3).
:- lib(mtx_columns_cross_table/5).
:- lib(mtx_errors/0).
:- lib(mtx_pos_elem/5).
:- lib(mtx_apply/4).
:- lib(mtx_type/2).
:- lib(mtx_read_table/4).

:- lib(end(mtx)).

/** <module> Working with data matrices

This is a library for working with data matrices, taking off from where library(csv) ends. <br>
The library will hopefully grow to become useful tool for logic programming based data science.

In theory the library supports polymorphic representations of matrices, but in its 
current form is best to assume that the canonical form (see mtx/1) is the only one supported. <br>
The library should be considered as still in developmental flux.

License: MIT.

---+ Input/Output:
At the very least library(mtx) can be viewed as an addition/enhancement io of matrices to files via mtx/2.<br>
The library can interrogate the data/ subdirectory of all installed packs for csv files using alias data.<br>

==
?- mtx( data(mtcars), Mtcars ).
Mtcars = [row(mpg, cyl, disp, hp, ....
==

Where =mtcars.csv= is in some pack's data directory.

==
?- mtx_data( mtcars, Mtcars ).
Mtx = [row(mpg, cyl, disp, hp, ....
==

Where mtcars.csv is in pack(mtx) data subdirectory.

mtx/2 works both as input and output.<br>

If 2nd argument is ground, mtx/2 with output the 2nd argument to the file pointed by the 1st.<br>
Else, the 1st argument is inputed to the 2nd argument in standard form.

==
?- tmp_file( mtc, TmpF ), mtx( pack('mtx/data/mtcars'), Mtc ), mtx( TmpF, Mtc ).
TmpF = '/tmp/pl_mtc_14092_0',
Mtc = [row(mpg, cyl,
==

The first call to mtx/2 above, inputs the test csv mtcars.csv, to Mtc (instantiated to list of rows).<br>
The second call, outputs Mtc to the temporary file TmpF.

mtx/3 provides a couple of options on top of csv_read_file/3 and csv_write_file/3.<br>
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

---+ Notes for developers

---++ Variable naming conventions
  * MtxIn  matrix in any acceptable representation (1st arg of mtx/2)
  * Mtx    canonical Mtx  (2nd arg of mtx/2)
  * Hdr    header
  * Clm    column data
  * Cnm    column name
  * Cps    column position (also Cpos)

If a predicate definition has both Cnm and Cps define them in that order.

---++ Options
  * has_header(HasH=true)
     false, indicates columns do not have header
  * apply_on(AppOn=whole)
     for predicate calling on columns or rows, which part to use: *whole*, _head_ or _body_

See documentation for the individual predicates. 
Good starting points are the documentation for mtx/1 and mtx/3.

@author nicos angelopoulos
@version  0.1 2018/2/3    first public version
@tbd add more debug(mtx(Pred)) messages (see src/mtx.pl for a start on this)

*/

%% mtx_data( +Set, -Data ).
%
% Access tinned example datasets from pack(mtx/data).
% Data is in canonical Mtx format.
%
% SetName
% * mtcars
%   from the mtcars variable in R
% 
%==
% ?- mtx( pack(mtx/data/mtcars), Mtcars ), mtx_data(mtcars, Mtcars).
% Mtcars = [row(mpg, cyl, disp, hp, drat, wt, qsec, vs, am, gear, carb), row(21.0, 6.0, 160.0, 110.0, 3.9, 2.62, 16.46, 0.0, 1.0, 4.0, 4.0), row(21.0, 6.0, 160.0, 110.0, 3.9, 2.875, 17.02, 0.0, 1.0, 4.0, 4.0), row(22.8, 4.0, 108.0, 93.0, 3.85, 2.32, 18.61, 1.0, 1.0, 4.0, 1.0), row(21.4, 6.0, 258.0, 110.0, 3.08, 3.215, 19.44, 1.0, 0.0, 3.0, 1.0), row(18.7, 8.0, 360.0, 175.0, 3.15, 3.44, 17.02, 0.0, 0.0, 3.0, 2.0), row(18.1, 6.0, 225.0, 105.0, 2.76, 3.46, 20.22, 1.0, 0.0, 3.0, 1.0), row(14.3, 8.0, nle.360.0, 245.0, 3.21, 3.57, 15.84, 0.0, 0.0, 3.0, 4.0), row(..., ..., ..., ..., ..., ..., ..., ..., ..., ..., ...)|...]
%==
%
mtx_data( mtcars, Mtcars ) :-
	mtx( pack(mtx/data/mtcars), Mtcars ).

/** mtx_sep_type(+SepType).

True iff SepType is a recognised mtx separator.

@author nicos angelopoulos
@version  0.1 2017/06/27
@see mtx_sep/2

*/
mtx_sep_type( Sep ) :-
    mtx_sep( Sep, _ ).

/** mtx_sep( +Sep, -Code ).

Code is the code representation (as accepted by csv/4) of the mtx_separator Sep.

Sep can be a code, or one of: 

  * tab
     for tab delimeted files

  * comma
     for csvs (comma separated)

  * space
     for space separated files (eg. GOBNILP data files)

@author nicos angelopoulos
@version  0.2 2018/03/07, added space

*/
mtx_sep( Sep, Code ) :-
    mtx_sep_known( Sep, Code ),
    !.
mtx_sep( Code, Code ) :-
    integer( Code ).  % fixme: better check ?

mtx_sep_known( tab,   0'\t ).
mtx_sep_known( comma, 0',  ).
mtx_sep_known( space, 0'   ).

/** mtx_version( -Version, -Date ).

Current version and release date for pack =mtx=.

The pack is distributed under the MIT license.

==
?- mtx_version( Ver, Date ).
Ver = 0:1:0,
Date = date(2018, 4, 2).
==

@version 0.1
@license MIT

*/
mtx_version( 0:1:0, date(2018,4,2) ).
