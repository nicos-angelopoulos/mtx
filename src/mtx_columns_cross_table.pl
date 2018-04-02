
:- lib( stoics_lib:kv_decompose/3 ).

mtx_columns_cross_table_defaults( Defs ) :-
    Defs = [ binary(true), 
             sort_rows(true), sort_columns(true),
             option_types([binary-boolean,sort_rows(boolean),sort_columns(boolean)])
           ].

/** mtx_columns_cross_table( +Mtx, +Cid1, +Cid2, -Tbl, +Opts ).

Get the matrix Tbl showing cross reference abundance of values
from two columns (Cid1 and Cid2) in Mtx.

Opts 
  * binary(Bin=true)
      when _true_ only record absense/presense, 
      else record number of occurances

  * sort_rows(Sr=true)
      sorts 
      rows according to row name

  * sort_columns(Sc-trye)
      sorts 
      columns according to column names

==
?- Mtx = [w(lets,nums),w(a,1),w(a,2),w(b,3),w(c,2),w(c,3)], 
        mtx_columns_cross_table( Mtx, lets, nums, Tbl, true ),
        maplist( writeln, Mtx ),
        maplist( writeln, Tbl ).
w(lets,nums)
w(a,1)
w(a,2)
w(b,3)
w(c,2)
w(c,3)
hdr(,1,2,3)
row(a,1,1,0)
row(b,0,0,1)
row(c,0,1,1)
Mtx = [w(lets, nums), w(a, 1), w(a, 2), w(b, 3), w(c, 2), w(c, 3)],
Tbl = [hdr('', 1, 2, 3), row(a, 1, 1, 0), row(b, 0, 0, 1), row(c, 0, 1, 1)].

==

@author nicos angelopoulos
@version  0.1 2017/1/17

*/
mtx_columns_cross_table( Mtx, Cid1, Cid2, Tbl, Args ) :-
    options_append( mtx_columns_cross_table, Args, Opts, check_types(true) ),
    mtx_columns_kv( Mtx, Cid1, Cid2, KVs, _KVCnms, _KVCposs ),
    kv_decompose( KVs, RowNameS, ClmNameS ),
    options( sort_rows(Sr), Opts ),
    options( sort_columns(Sc), Opts ),
    mtx_columns_cross_table_sort( Sr, RowNameS, RowNames ),
    mtx_columns_cross_table_sort( Sc, ClmNameS, ClmNames ),
    options( binary(Bin), Opts ),
    findall( Row,
                    ( member(RowName,RowNames),
                      mtx_columns_cross_row( ClmNames, RowName, Bin, KVs, RowVals ),
                      Row =.. [row,RowName|RowVals]
                    ) 
                , TblRows ),
    Hdr =.. [hdr,''|ClmNames],
    Tbl = [Hdr|TblRows].

mtx_columns_cross_row( [], _RowName, _Bin, _KVs, [] ).
mtx_columns_cross_row( [ClmName|T], RowName, Bin, KVs, [Cnt|Cnts] ) :-
    mtx_columns_cross_count( Bin, ClmName, RowName, KVs, Cnt ),
    mtx_columns_cross_row( T, RowName, Bin, KVs, Cnts ).

mtx_columns_cross_count( true, ClmName, RowName, KVs, Cnt ) :-
    ( memberchk(RowName-ClmName,KVs) -> Cnt is 1 ; Cnt is 0 ).
mtx_columns_cross_count( false, ClmName, RowName, KVs, Cnt ) :-
    findall( 1, member(RowName-ClmName,KVs), Ones ),
    length( Ones, Cnt ).

mtx_columns_cross_table_sort( true, Vals, Ord ) :- 
    sort( Vals, Ord ).
mtx_columns_cross_table_sort( false, Vals, Ord ) :- 
    list_to_set( Vals, Ord ).
