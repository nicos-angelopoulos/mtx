
:- lib( stoics_lib:compare/4 ).

mtx_column_values_select_defaults( [compare(term),csv_write_rejected([])] ).

%% mtx_column_values_select( +Csv, +Cid, +ValS, -Sel, -Rej, +Opts ).
%
% Select rows from Csv that have matching values ValS in column identified by Cid.
% Sel is the selected rows and Rej are all the other rows.
% 
% Hdr is protected and added to both Sel and Rej.
%
% Opts 
% * mtx/2
%   Opts are passed to mtx/2 for input and output of selected rows: Sel
%
% * csv_write_rejected(CWRejOpts=[])
%   Opts passed to mtx/2 for rejected rows
%
% * compare(Compare=term)
%   or arithmetic see compare/4
%==
% ?- Csv = [row(a,b,c),row(1,2,3),row(4,5,6)], 
%    csv_column_values_select( Csv, c, 3, Red, _ ).
% Csv = [row(a, b, c), row(1, 2, 3), row(4, 5, 6)],
% Red = [row(a, b, c), row(1, 2, 3)].
%==
%
% @author nicos angelopoulos
% @version  0.2 2015/2/16   was csv_select_rows_on_column_values/5
% @version  0.1 2014/6/3
%
mtx_column_values_select( CsvF, Cid, ValS, SelF, RejF, Args ) :-
	options_append( mtx_column_values_select, Args, Opts ),
	en_list( ValS, AllVals ),
	sort( AllVals, Vals ),
	mtx( CsvF, [Hdr|Rows], Opts ),
	mtx:mtx_header_column_pos( Hdr, Cid, CPos ),
	options( compare(CompMeth), Opts ),
	partition( row_has_column_values(CPos,Vals,CompMeth), Rows, Sel, Rej ),
	mtx( SelF, [Hdr|Sel], Opts ),
	options( csv_write_rejected(ROpts), Opts ),
	mtx( RejF, [Hdr|Rej], ROpts ).

row_has_column_values( Pos, Vals, CompMeth, Row ) :-
	arg( Pos, Row, Cell ),
	member( Val, Vals ),
	compare( CompMeth, =, Cell, Val ),
	!. % fixme: is probably not needed, check with partition/4.
