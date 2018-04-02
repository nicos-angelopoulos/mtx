
:- lib(mtx_option_header_remove/4).
:- lib(mtx_option_header_attach/4).

mtx_column_include_rows_defaults( [header(true)] ).

/** mtx_column_include_rows( +Mtx, +Cid, +Call, -Incl ).
    mtx_column_include_rows( +Mtx, +Cid, +Call, -Incl, +Opts ).

Filter matrix Mtx according to the values in its column Cid.
Call, is called on all Column values and only rows for which this
succeeds make it to matrix Out.

Mtx and Out can be either files or read in rows: see mtx/3.
Opts are passed to the two calls.

Opts
  * header(Hdr=true)
     shall we preserve Mtx's first row ?

  * excludes(Excl=_)
     if present, returns the excluded rows

==
?- assert( mtx1([row(a,b,c),row(1,2,3),row(4,5,6)]) ).
?- mtx1( Mtx1 ), mtx_column_include_rows( Mtx1, 2, =:=(2), Rows ).
Rows = [row(a, b, c), row(1, 2, 3)].

?- mtx1( Mtx1 ), mtx_column_include_rows( Mtx1, 2, =:=(4), Rows ).
Mtx1 = [row(a, b, c), row(1, 2, 3), row(4, 5, 6)],
Rows = [row(a, b, c)].

?- mtx1( Mtx1 ), mtx_column_include_rows( Mtx1, 2, =:=(2), Rows, excludes(Exc) ).
Mtx1 = [row(a, b, c), row(1, 2, 3), row(4, 5, 6)],
Rows = [row(a, b, c), row(1, 2, 3)],
Exc = [row(4, 5, 6)].

==

@author nicos angelopoulos
@version  0.2 2014/10/15   renamed from csv_filter_by_column/4
@version  0.3 2017/10/25   implement via loop rather than 3 meta calls 
@version  0.4 2018/2/3     added options header(Hdr) and excludes(Excl)

*/
mtx_column_include_rows( MtxIn, Cid, Call, Out ) :-
    mtx_column_include_rows( MtxIn, Cid, Call, Out, true ).
mtx_column_include_rows( MtxIn, Cid, Call, Out, Args ) :-
    options_append( mtx_column_include_rows, Args, Opts ),
    mtx( MtxIn, Mtx, Opts ),
    options( header(HasHdr), Opts ),
    mtx_option_header_remove( HasHdr, Mtx, Hdr, Rows ),
    mtx_include_option_column_position( HasHdr, Cid, Hdr, Cps ),
    ( memberchk(excludes(Exc),Opts) -> ExclB = true; ExclB = false ),
    mtx_column_include_rows_sieve( Rows, Cps, Call, ExclB, Exc, ResRows ),
    mtx_option_header_attach( HasHdr, ResRows, Hdr, ResPrv ),
    mtx( Out, ResPrv ).

mtx_column_include_rows_sieve( [], _Pos, _Call, _, [], [] ).
mtx_column_include_rows_sieve( [R|Rs], Pos, Call, ExclB, Excls, IncRs ) :-
    arg( Pos, R, Arg ),
    ( call(Call,Arg) ->
        IncRs = [R|TIncRs],
        Excls = TExcls
        ;
        IncRs = TIncRs,
        mtx_column_include_excludes_row( ExclB, R, Excls, TExcls )
    ),
    mtx_column_include_rows_sieve( Rs, Pos, Call, ExclB, TExcls, TIncRs ).

mtx_column_include_excludes_row( true, R, [R|TExcls], TExcls ).
mtx_column_include_excludes_row( false, _R, _, _ ).

mtx_include_option_column_position( HasHdr, Cid, Hdr, Cps ) :-
	mtx_include_option_column_position_known( HasHdr, Cid, Hdr, Cps ),
	!.
mtx_include_option_column_position( HasHdr, Cid, Hdr, _Cps ) :-
	throw( cannot_identify_column_position_for(HasHdr,Cid,Hdr) ).

mtx_include_option_column_position_known( false, Cps, _Hdr, Cps ) :-
	number( Cps ).
mtx_include_option_column_position_known( true, Cid, Hdr, Cps ) :-
	( arg(Cps,Hdr,Cid) ->
		true
		;
		number(Cid),
		Cps is Cid
	).
