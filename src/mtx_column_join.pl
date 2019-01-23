
mtx_column_join_defaults( Defs ) :-
    Defs = [
                at([]),
                is_unique(true)
    ].

/**  mtx_column_join( +MtxBase, +ClmBase, +MtxMatch, -Mtx, +Opts ).

Mtx is the join of MtxBase and MtxMatch based on the column values of 
two columns in those matrices. By default all other columns of MtxMatch
are added at the end
position and 

Opts
  * add_columns([])
    which columns to add (all exept ClmBase/ClmMatch by default)

  * at(At=[])
    if an integer, additional columns are added from that position onwards.
    Alternatively it can be a list of positions to be used. The default is 
    the empty list which is a token for adding the columns at the end.

  * is_unique(IsUnique=true)
    should we check that only a single row matches

  * match_column(ClmMatch)
    column id of MtxExt if different that ClmBase

==
?- mtx_column_join( MtxB, ClmB, MtxM, Mtx, [] ).
==

@author nicos angelopoulos
@version  0.1 2019/1/20

*/
mtx_column_join( MtxBIn, ClmB, MtxM, MtxOut, Args ) :-
    options_append( mtx_column_join, Args, Opts ),
    mtx( MtxBIn, [HdrB|RowsB] ),
    mtx( MtxMIn, [HdrM|RowsM] ),
    options( at(AtOpt), Opts ),
    mtx_column_join_at_list( AtOpt, HdrB, HdrM, Ats ),
    options( add_columns(AddCidsIn), Options ),
    mtx_column_join_add_columns( AddCidsIn, HdrM, CIdcs ),

    mtx( MtxOut, MtxOutPrv ).

mtx_column_join_add_columns( AddCidsIn, HdrM, CIdcs ),
    ( AddCidsIn == [] -> AddCids = 

mtx_column_join_at_list( AtOpt, HdrB, HdrM, At ) :-
    \+ var(AtOpt), % fixme: error
    ( AtOpt == [] ->
        functor( HdrB, _, ArityB ),
        AtIn is ArityB + 1
        ;
        AtIn = AtOpt
    ),
    ( AtIn = [_|_] ->
        At = AtIn
        ;
        ( integer(AtIn) ->
            functor( HdrM, _, ArityM ),
            MLim is ArityM - 1,
            findall( AnAt, between(1,MLin,AnAt), At )
            ;
            throw( unknown_type_for_at(AtIn) )  % fixme: pretty print
        )
    ).
