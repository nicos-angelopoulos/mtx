
mtx_sort( MtxF, Column, OutF ) :-
	mtx_sort( MtxF, Column, <, OutF ).

%% mtx_sort( +Mtx, +Column, -Out ).
%% mtx_sort( +Mtx, +Column, +Ord, -Out ).
%  Sort matrix Mtx by Column in order (Ord) into Out.
%  Ord should be either *<* (ascending) or _>_ (since 2.0).
%  Column can be an integer or column name (see mtx_header_column_pos/3).
%  Mtx and Out are passed through mtx/2.
%
%==
% ?- mtx_sort( [row(a,b,c),row(1,2,3),row(7,8,9),row(4,5,6)], b, Ord ).
% Ord = [row(a, b, c), row(1, 2, 3), row(4, 5, 6), row(7, 8, 9)].
%==
%  @author nicos angelopoulos
%  @version 2.0
%  
mtx_sort( Mtx, Column, Whc, OutF ) :-
	mtx( Mtx, [Hdr|Rows] ),
	mtx:mtx_header_column_pos( Hdr, Column, N ),
	% next line is =  mtx_column_kv/3
	findall( Nth-Row, (member(Row,Rows),arg(N,Row,Nth)), Pairs ),
	keysort( Pairs, Sord ),
	mtx_order( Whc, Sord, Pord ),
	findall( V, member(_-V,Pord), OrdRows ),
	mtx( OutF, [Hdr|OrdRows] ).

mtx_order( <, Ord, Ord ).
mtx_order( >, Rev, Ord ) :-
	reverse( Rev, Ord ).
	
