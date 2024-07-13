/** mtx_columns( +Mtx, +Names, -Columns ).
    mtx_columns( +Mtx, +Names, +Order, -Columns ).

Select data Columns from columns with header names Names (a list). 
Note that headers (ie. Names are not in Columns).
Caution: this version only returns rows that have ALL associated columns.
This now accepts column positions within Names as per column_id_header_nth/3.
Order is a boolean, *true* returns the Columns in header ordered form, whereas
_false_ returns Columns in same order as Names.

Since v.0.2 supports memory csvs.

Since v.0.3 supports Order. Previously Order = true was assumed which remains the default for 
back compatibility

==
?- mtx_read_file( 'example.csv', Ex ), mtx_columns( Ex, [c,b], ABs ).
Ex = [row(a, b, c), row(1, 2, 3), row(4, 5, 6), row(7, 8, 9)],
ABs = [row(2, 3), row(5, 6), row(8, 9)].

?- mtx_read_file( 'example.csv', Ex ), mtx_columns( Ex, [c,b], false, ABs ).
Ex = [row(a, b, c), row(1, 2, 3), row(4, 5, 6), row(7, 8, 9)],
ABs = [row(3, 2), row(6, 5), row(9, 8)].
==

@author nicos angelopoulos
@version 0:2,  2014/2/2
*/
mtx_columns( Csv, Names, Columns ) :-
	mtx_columns( Csv, Names, true, Columns ).

mtx_columns( Csv, NameS, Order, Columns ) :-
	en_list( NameS, Names ),
	% mtx_rows( Csv, [Hdr|Data] ),
	mtx_header( Csv, Hdr ),
	mtx_columns_order_nths( Order, Names, Hdr, Nths ),
     length( Names, Arity ),
     ( length(Nths,Arity) -> true
			; write( some_columns_not_found_in_header(Names,Nths,Hdr) ), nl, abort ),
     functor( Row, row, Arity ),
	mtx_nths_columns( Csv, Row, Nths, Columns ).

mtx_nths_columns( Csv, Row, Nths, Columns ) :-
	mtx_in_memory( Csv ),
	!,
	once( current_predicate( Csv:row/Arity ) ),
	functor( Full, row, Arity ),
	nth_args_stitch( Nths, 1, Full, Row ),
	findall( Row, ( Csv:Full ), Columns ).
mtx_nths_columns( [_|Data], Row, Nths, Columns ) :-
	!,
	% Csv = [_|Data],
     findall( Row,  (  member(D,Data),
	                  maplist(marg(D,Row,Nths),Nths)
                    ),  Columns ).
mtx_nths_columns( CsvF, Row, Nths, Columns ) :-
	mtx( CsvF, Csv ),
	mtx_nths_columns( Csv, Row, Nths, Columns ).

mtx_columns_order_nths( true, Names, Hdr, Nths ) :- !,
	% mtx_column_ids_header_column_order( Names, Hdr, Nths ).
	maplist( mtx:mtx_header_column_pos(Hdr), Names, NestNths ),
	sort( NestNths, Nths ).
mtx_columns_order_nths( false, Names, Hdr, Nths ) :-
	% maplist( header_column_id_nth_all(Hdr), Names, NestNths ),
	maplist( mtx:mtx_header_column_pos(Hdr), Names, Nths ).
	% flatten( NestNths, Nths ).

nth_args_stitch( [], _I, _Full, _Row ).
nth_args_stitch( [N|Ns], I, Full, Row ) :-
	arg( N, Full, Nth ),
	arg( I, Row, Nth ),
	J is I + 1,
	nth_args_stitch( Ns, J, Full, Row ).

marg( Data, Row, Nths, Nth ) :-
     nth1( Pos, Nths, Nth ),
     arg( Nth, Data, Arg ),
     arg( Pos, Row, Arg ).
