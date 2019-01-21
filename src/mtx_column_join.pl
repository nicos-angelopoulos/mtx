
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
    which columns to add (all by default)

  * at(At=[])
    if an integer, additional columns are added from that position onwards.
    Alternatively it can be a list of positions to be used. The default is 
    the empty list which is a token for adding the columns at the end.

  * is_unique(IsUnique=true)
    should we check that only a single row matches

  * match_column(MatchClm)
    column id of MtxExt if different that ClmBase

==
?- mtx_column_join( MtxB, ClmB, MtxM, Mtx, [] ).
==

@author nicos angelopoulos
@version  0.1 2019/1/20

*/
mtx_column_join( MtxBIn, ClmB, MtxM, MtxOut, Args ) :-
    options_append( mtx_column_join, Args, Opts ),
    mtx( MtxBIn, MtxB ),
    mtx( MtxMIn, MtxIn ),
    options( at(AtIn), Opts ),
    ( AtIn == [] ->
        mtx_header( MtxB, MtxBHdr ),
        functor( MtxbHdr, _, Arity ),
        At is Arity + 1
        ;
        AtIn = At
    ),
    options( add_columns(AddCidsIn), Options ),
    mtx( MtxOut, MtxOutPrv ).
