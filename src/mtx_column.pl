
:- lib( mtx_in_memory/1 ).
% :- lib(stoics_lib:en_list/2).

%% mtx_column( +Mtx, ?Cid, -Column ).
%% mtx_column( +Mtx, ?Cid, -Column, -Cname, -Cpos ).
%
%  Select column data from Csv for column identified by Cid.
%  Cid identifies a column in Mtx either by means of its name or 
%  an integer corresponding to its position.
%  Note that name of selected header (Nhdr) is not in Column.
%  Cpos is the position of Cid and Cname is its column name.
% 
%  When Cid is an unbound all possible values are erumerated,
%  whic Cid = Cname.
%
%==
% ?- mtx_mtcars(Mtc), mtx_column( Mtc, carb, Carbs ).
% Carbs = [4.0, 4.0, 1.0, 1.0, 2.0, 1.0, 4.0, 2.0, 2.0|...].
%==
% @see The order of the args 4 and 5 was swapped on 15.1.26
%
mtx_column( Csv, Cid, Clm ) :-
	mtx_column( Csv, Cid, Clm, _Cnm, _Cpos ).

mtx_column( Csv, Cid, Clm, Cnm, Cpos ) :-
	mtx_header_body( Csv, Hdr, Rows ),
	% mmtx_matrices_in_memorytx_header_column_pos( Hdr, Column, Nhdr, Nclm ),
	mtx_header_column_name_pos( Hdr, Cid, Cnm, Cpos ),
	maplist( arg(Cpos), Rows, Clm ).

/** mtx_column_set( +Mtx, ?Cid, -Set ).
    mtx_column_set( +Mtx, ?Cid, -Column, -Set ).

A shortcut for mtx_column/3 followed by sort/2 on the column values to produce Set

@see mtx_column/3

*/
mtx_column_set( Mtx, Cid, Set ) :-
	mtx_column( Mtx, Cid, Column ),
	sort( Column, Set ).
mtx_column_set( Mtx, Cid, Column, Set ) :-
	mtx_column( Mtx, Cid, Column ),
	sort( Column, Set ).

%% mtx_columns( +Mtx, +Names, -Columns ).
%% mtx_columns( +Mtx, +Names, +Order, -Columns ).
%
%  Select data Columns from columns with header names Names (a list). 
%  Note that headers (ie. Names are not in Columns).
%  Caution: this version only returns rows that have ALL associated columns.
%  This now accepts column positions within Names as per column_id_header_nth/3.
%  Order is a boolean, *true* returns the Columns in header ordered form, whereas
%  _false_ returns Columns in same order as Names.
%  
%  Since v.0.2 supports memory csvs.
%
%  Since v.0.3 supports Order. Previously Order = true was assumed which remains the default for 
%  back compatibility
%
% % fixme: use the cars csv from pac()
%==
% ?- mtx_read_file( 'example.csv', Ex ), mtx_columns( Ex, [c,b], ABs ).
% Ex = [row(a, b, c), row(1, 2, 3), row(4, 5, 6), row(7, 8, 9)],
% ABs = [row(2, 3), row(5, 6), row(8, 9)].
% 
% % fixme: use the cars csv from pac()
% ?- mtx_read_file( 'example.csv', Ex ), mtx_columns( Ex, [c,b], false, ABs ).
% Ex = [row(a, b, c), row(1, 2, 3), row(4, 5, 6), row(7, 8, 9)],
% ABs = [row(3, 2), row(6, 5), row(9, 8)].
%==
%  
%  @author nicos angelopoulos
%  @version 0:2,  2014/2/2
% 
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
