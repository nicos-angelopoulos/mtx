
mtx_column_join_defaults( Defs ) :-
    Defs = [
                add_columns([]),
                at([]),
                is_unique(true),
                is_exhaustive(false)
    ].

/**  mtx_column_join( +MtxBase, +ClmBase, +MtxMatch, -Mtx, +Opts ).

Mtx is the join of MtxBase and MtxMatch based on the column values of 
two columns in those matrices. By default all other columns of MtxMatch
are added at the end
position and 

Opts
  * add_columns([])
    which columns to add (by default all but ClmBase and ClmMatch)

  * at(At=[])
    if an integer, additional columns are added from that position onwards.
    Alternatively it can be a list of positions to be used. The default is 
    the empty list which is a token for adding the columns at the end.

  * is_exhaustive(IsExh=false)
    should we check that all rows of MtxMatch were used ? 
    if false matched lines are not "consumed"

  * is_unique(IsUnique=true)
    should we check that only a single row matches, _true_ throws a ball, 
    _false_ creates a new row for each matching row and first selects the first matching one
    (debug(mtx(column_join(multi)) triggers the printing of discarded matching rows))

  * match_column(ClmMatch)
    column id of MtxExt if different that ClmBase

==
?- assert( mtx1([r(a,b,c),r(1,2,3),r(4,5,6)]) ).
?- assert( mtx2([r(a,e,f),r(1,7,7),r(4,8,8)]) ).
?- mtx1(Mtx1),mtx2(Mtx2),mtx_column_join(Mtx1, a, Mtx2, Mtx, []).
?- mtx1(Mtx1),mtx2(Mtx2),mtx_column_join(Mtx1, a, Mtx2, Mtx, [at(2)]).
==

@author nicos angelopoulos
@version  0.1 2019/1/20

*/
mtx_column_join( MtxB, ClmB, MtxM, MtxOut, Args ) :-
    options_append( mtx_column_join, Args, Opts ),
    mtx( MtxB, [HdrB|RowsB] ),
    mtx( MtxM, [HdrM|RowsM] ),
    options( at(AtOpt), Opts ),
    ( memberchk(match_column(ClmM),Opts) -> true; ClmM = ClmB ),
    mtx_header_column_name_pos( HdrM, ClmM, _CnmM, PosM ),
    mtx_header_column_name_pos( HdrB, ClmB, _CnmB, PosB ),
    options( add_columns(AddCidsIn), Opts ),
    mtx_column_join_add_columns( AddCidsIn, HdrM, PosM, MIdcs ),
    mtx_column_join_at_list( AtOpt, HdrB, MIdcs, Ats ),
    options( [is_unique(IsUnq),is_exhaustive(IsExh)], Opts ),
    write( midcs(MIdcs) ), nl,
    mtx_column_join_rows( RowsB, PosB, RowsM, PosM, MIdcs, Ats, IsUnq, IsExh, RowsOut ),
    HdrB =.. [Rn|RbArgs],
    mtx_column_join_rows_add_1( [HdrM], Rn, RbArgs, MIdcs, Ats, [HdrOut], _ ),
    % mtx_column_join_rows_add_args( Ats, 1, MIdcs, M, RbArgs, RoArgs ),

    mtx( MtxOut, [HdrOut|RowsOut] ).

mtx_column_join_rows( [], _PosB, RowsM, _PosM, _MIdcs, _Ats, _IsUnq, IsExh, [] ) :-
    ( (IsExh == true, RowsM \== []) -> 
        length( RowsM, Len ), 
        thow( mtx_column_join(non_exhaustive_match_mtx(res_legth(Len))) ) % fixme: error
        ;
        true
    ).
mtx_column_join_rows( [Rb|Rbs], PosB, RowsM, PosM, MIdcs, Ats, IsUnq, IsExh, RowsOut ) :-
   arg( PosB, Rb, JoinVal ),
   partition( at_arg(PosM,JoinVal), RowsM, JoinRowsM, RemRowsM ),
   length( JoinRowsM, MatchLen ),
   debug( mtx(column_join), 'Doing join value: ~w, match length: ~d', [JoinVal,MatchLen] ),
   mtx_column_join_rows_add( IsUnq, JoinRowsM, JoinVal, Rb, MIdcs, Ats, RowsOut, TRowsOut ),
   ( IsExh == true -> NextRowsM = RemRowsM ; NextRowsM = RowsM ),
   mtx_column_join_rows( Rbs, PosB, NextRowsM, PosM, MIdcs, Ats, IsUnq, IsExh, TRowsOut ).

mtx_column_join_rows_add( true, [_A,_B|C], JoinVal, _Rb, _MIdcs, _Ats, _RowsOut, _TRowsOut ) :-
    length( C, LenC ),
    JoinMLen is LenC + 2,
    throw( mtx_column_join(non_unique_rows_match(JoinVal,JoinMLen)) ). % fixme: error
mtx_column_join_rows_add( first, [First|TMatch], JoinVal, Rb, MIdcs, Ats, RowsOut, TRowsOut ) :-
    Rb =.. [Rn|RbArgs],
    ( TMatch == [] -> true
                    ; 
                    Mess = 'For join value: ~w, ignoring match row: ~w',
                    findall( _, ( member(Row,TMatch),
                                  debug(mtx(column_join(multi)),Mess,[JoinVal,Row])
                                ), _)
    ),
    mtx_column_join_rows_add_1( [First], Rn, RbArgs, MIdcs, Ats, RowsOut, TRowsOut ).
mtx_column_join_rows_add( false, JoinMs, _JoinVal, Rb, MIdcs, Ats, RowsOut, TRowsOut ) :-
    Rb =.. [Rn|RbArgs],
    mtx_column_join_rows_add_1( JoinMs, Rn, RbArgs, MIdcs, Ats, RowsOut, TRowsOut ).

mtx_column_join_rows_add_1( [], _Rn, _RbArgs, _MIdcs, _Ats, RowsOut, RowsOut ).
mtx_column_join_rows_add_1( [M|Ms], Rn, RbArgs, MIdcs, Ats, [H|RowsOut], TRowsOut ) :-
    mtx_column_join_rows_add_args( Ats, 1, MIdcs, M, RbArgs, RoArgs ),
    H =.. [Rn|RoArgs],
    mtx_column_join_rows_add_1( Ms, Rn, RbArgs, MIdcs, Ats, RowsOut, TRowsOut ).

mtx_column_join_rows_add_args( [], _At, [], _RowM, RbArgs, RbArgs ).
mtx_column_join_rows_add_args( [At|Ats], At, [Idx|Idcs], RowM, RbArgs, RoArgs ) :-
    !,
    arg( Idx, RowM, Marg ),
    RoArgs = [Marg|TRoArgs],
    J is At + 1,
    mtx_column_join_rows_add_args( Ats, J, Idcs, RowM, RbArgs, TRoArgs ).
mtx_column_join_rows_add_args( [At|Ats], I, Idcs, RowM, [RbArg|RbArgs], RoArgs ) :-
    RoArgs = [RbArg|TRoArgs],
    J is I + 1,
    mtx_column_join_rows_add_args( [At|Ats], J, Idcs, RowM, RbArgs, TRoArgs ).


mtx_column_join_add_columns( AddCidsIn, HdrM, PosM, CIdcs ) :-
    ( AddCidsIn == [] -> 
                functor( HdrM, _, MArity ),
                numlist( 1, MArity, AllPossM ),
                nth1( PosM, AllPossM, _, CIdcs )
                ; 
                mtx_header_cids_order( HdrM, AddCidsIn, CIdcs )
    ).

% mtx_column_join_at_list( AtOpt, HdrB, %HdrM, Idcs, At ) :-
mtx_column_join_at_list( AtOpt, HdrB, Idcs, At ) :-
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
            % functor( HdrM, _, ArityM ),
            % MLim is ArityM - 1,
            length( Idcs, Len ),
            findall( AnAt, (between(1,Len,I), AnAt is I + AtIn - 1), At )
            ;
            throw( unknown_type_for_at(AtIn) )  % fixme: pretty print
        )
    ).

at_arg( Pos, Val, Term ) :- arg( Pos, Term, Val ).
