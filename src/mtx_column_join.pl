
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
mtx_column_join( MtxB, ClmB, MtxM, MtxOut, Args ) :-
    options_append( mtx_column_join, Args, Opts ),
    mtx( MtxB, [HdrB|RowsB] ),
    mtx( MtxM, [HdrM|RowsM] ),
    options( at(AtOpt), Opts ),
    mtx_column_join_at_list( AtOpt, HdrB, HdrM, Ats ),
    ( memberchk(match_column(ClmM),Opts) -> true; ClmM = ClmB ),
    mtx_header_column_name_pos( HdrM, ClmM, _CnmM, PosM ),
    options( add_columns(AddCidsIn), Opts ),
    mtx_column_join_add_columns( AddCidsIn, HdrM, PosM, MIdcs ),

    here( RowsB, Ats, RowsM, MIdcs, RowsOut ),
    here_heders( HdrB, HdrM, HdrOut ),
    mtx( MtxOut, [HdrOut|RowsOut] ).

mtx_column_join_add_columns( AddCidsIn, HdrM, PosM, CIdcs ) :-
    ( AddCidsIn == [] -> 
                functor( HdrM, _, MArity ),
                numlist( 1, MArity, AllPossM ),
                nth1( PosM, AllPossM, _, CIdcs )
                ; 
                mtx_header_cids_order( AddCidsIn, CIdcs )
    ).

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
            findall( AnAt, between(1,MLim,AnAt), At )
            ;
            throw( unknown_type_for_at(AtIn) )  % fixme: pretty print
        )
    ).
