
:- lib(stoics_lib:locate/3).

/** mtx_type( +Mtx, -Type ).

Mtx is of type Type.

Types:

 * asserted  (atomic)
   when Mtx is not a current handle and given that predicate Mtx/1 exists with its argument
   instantiating to a list, this list is taken to be a matrix in canonical representation

 * by_column (list of lists)
   which is assumed to be a per-column representation (see mtx_lists/2)

 * by_row    (list of compounds)
   such as those read in with csv_read_file/2 but there is no
   restriction on term name and arity. this is the canonical
   representation and each term is a row of the matrix

 * predicated (Pid of the form Pname/Arity)
   where the atom Pname corresponds to a predicate name and the predicate
   with arity N is defined to succeeds with the returned arguments

 * predfile (atomic)
   when Mtx is not a current mtx handle and given that predicate Mtx/1 exists with its argument
   instantiating to a non-list; this argument is taken to be the stem (with possible exts csv and tsv)
   or filename of a csv/tsv file which csv_read_file/3 can read as a canonical matrix

 * on_file (ground; non-list)
   (atomic or compound: csv file or its stem) as possible to be read by csv_read_file/2
   alias paths and normal delimited file extension can be ommitted

 * asserted (atomic)
   atomic, when mtx was cached at loading time (see option cache(Cache) in mtx/3)

If Mtx is a list, its contents are first checked for sublists (_by_column_) and then
for compounds (by_row). When Mtx is a predicate identifier of the form Pname/Arity, 
it is taken to define the corresponding Mtx (predicated). If Mtx is atomic the options are
 * Mtx matrix handle exists (see mtx/2)
   then the type is _in_memory_ 
 * Mtx/1 is defined and returns a list
   type is _asserted_ 
 * Mtx/1 is defined and returns a non list
   type on_file(File)

==
?- mtx_type( [[a],[b],[c]], Type ).
Type = by_column.

?- mtx_type( [r(a,b,c),r(1,2,3),r(4,5,6)], Type ).
Type = by_row.

?- mtx_type( pack(mtx/data/mtcars), Type ).
Type = on_file.
% was: Type = on_file('/usr/local/users/na11/local/git/lib/swipl-7.3.29/pack/mtx/data/mtcars.csv').

?- assert( mc_file(pack(mtx/data/mtcars)) ).
?- mtx_type( mc_file, Type ).

?- mtx( pack(mtx/data/mtcars), Mtx, cache(mtcars) ), assert(mc(Mtx)).
?- mtx_type( mtcars, Type ).
Type = handled.

?- mtx_type( mc, Type ).
Type = asserted.

?- mtx( mc, Mc ), findall( _, (member(Row,Mc),assert(Row)), _ ).
?- mtx( mc, [Hdr|_Rows] ), functor( Hdr, Pname, Arity ), mtx_type( Pname/Arity, Type ).
Hdr = ...,
Rows = ...,
Pname = row,
Arity = 11,
Type = predicated.
==

@author nicos angelopoulos
@version  0.1   2016/11/10
@see mtx/1, mtx/2, mtx/3

*/
mtx_type( Mtx, Type ) :-
	is_list( Mtx ),
	!,
    mtx_type_list( Mtx, Type ).
mtx_type( Mtx, Type ) :-
	atomic( Mtx ),
	mtx:mtx_data_handle_file( Mtx, _ ),
	!,
	Type = handled.
mtx_type( Mtx/N, Type ) :-
	atomic( Mtx ),
	functor( Goal, Mtx, N ),
	member( Mod, [user,mtx] ),
	predicate_property( Mod:Goal, defined ),
	!,
	Type = predicated.
mtx_type( Mtx, Type ) :-
	atomic( Mtx ),
	functor( Goal, Mtx, 1 ),
	member( Mod, [user,mtx] ),
	predicate_property( Mod:Goal, defined ),
	!,
	mtx_type_asserted( Mod:Goal, Type ).
mtx_type( Mtx, Type ) :-
	ground( Mtx ),
    mtx_type_ground( Mtx, Type ).


mtx_type_ground( Mtx, Type ) :-
	catch( once(mtx:locate(Mtx,['',csv,tsv],File)), _, fail ),
	exists_file( File ), % fixme: locate/3 already does this ?
	!,
	Type = on_file(File).
mtx_type_ground( Mtx, Type ) :-
    absolute_file_name( Mtx, File, [extensions(['',csv,tsv,txt]),file_errors(fail),access(read)] ),
    !,
    Type = on_file(File).

mtx_type_list( [], by_row ).
mtx_type_list( [H|_T], Type ) :-
	mtx_type_list_head( H, Type ).

mtx_type_list_head( H, Type ) :-
	is_list( H ),
	!,
	Type = by_column.
mtx_type_list_head( H, Type ) :-
	compound( H ),
	Type = by_row.

mtx_type_asserted( Mod:Goal, Type ) :-
	arg( 1, Goal, [_|_] ),
	call( Mod:Goal ),
	!,
	Type = asserted.
mtx_type_asserted( _, predfile ).
