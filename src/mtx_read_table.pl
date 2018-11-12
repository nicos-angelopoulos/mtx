
:- ensure_loaded(library(csv)).
% :- lib(stoics_lib:en_list/2).
:- lib(mtx_options_csv/4). 

/** mtx_read_table( +CsvF, +RowsName, -Table, +OptS ).

Reads a table in from a file (CsvF). A table is a delimited file in which the first row is one short than the rest.<br>
RowsName is added as the first argument in the read-in Table's first row.

OptS
  * match(Match=true)
     whether to match_arity(Match) rows read in (see csv//2 options).

  * sep(Sep=_)
     the mtx/2 version of separator(Sep) option of csv//2 (mtx_sep/2). Defaults to csv//2 version which is based on filename extension.

Any other OptS are passed to csv//2.<br>
As per mtx/3 convention OptS can be a single option (un-listed) or a list of options.

==
?-  tmp_file( testo, TmpF ),
    csv_write_file( TmpF, [row(c_a,c_b),row(1,a,b),row(2,aa,bb)], [match_arity(false),separator(0'\t)] ),
    mtx_read_table( TmpF, samples, Tbl, sep(tab) ).

TmpF = '/tmp/pl_testo_12445_0',
Tbl = [row(samples, c_a, c_b), row(1, a, b), row(2, aa, bb)].
==

@author nicos angelopoulos
@version  0.1 2018/2/3
@see  mtx_sep/2, csv//2

*/
mtx_read_table( File, RowsName, Table, OptionS ) :-
    en_list( OptionS, Options ),
    mtx_options_csv( Options, File, RecOptionsPrv, Options3 ),
    setup_call_cleanup(
        open(File, read, Stream, Options3),
        ( 
            csv_read_row(Stream, Row0, RecOptionsPrv),
            ( Match == true -> 
                % fixme: this hacking:
                RecOptionsPrv = csv_options(CopA,CopB,CopC,CopD,CopE,CopF,HdrAri,CopH),
                RowsAri is HdrAri + 1,
                RecOptions    = csv_options(CopA,CopB,CopC,CopD,CopE,CopF,RowsAri,CopH)
                ;
                RecOptionsPrv = RecOptions
            ),
            functor( Row0, _, HdrArity ),
            Arity is HdrArity + 1,
            Row0 =.. [Row0Nm|Row0Args],
            Hdr =.. [Row0Nm,RowsName|Row0Args],
            mtx_read_table_stream_rows(Hdr, Stream, Match, Arity, Table, RecOptions)
        ),
        close(Stream)).

mtx_read_table_stream_rows( end_of_file, _Stream, _Match, _Arity, Rows, _Opts ) :-
    !,
    Rows = [].
mtx_read_table_stream_rows(Row, Stream, Match, Arity, [Row|Rows], Opts ) :-
    mtx_read_table_row_match_arity( Match, Arity, Row ),
    csv_read_row( Stream, NxtRow, Opts ),
    mtx_read_table_stream_rows(NxtRow, Stream, Match, Arity, Rows, Opts ).

mtx_read_table_row_match_arity( false, _Arity, _Row ).
mtx_read_table_row_match_arity( true, Arity, Row ) :-
    functor( Row, _, Rarity ),
    ( Rarity =:= Arity -> true; throw(arity_mismatch(Arity,Rarity,Row)) ).

