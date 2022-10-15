
:- use_module( library(mtx) ).

%% mtx_column_kv( +Mtx, +ColumnId, -KVs ).
%% mtx_column_kv( +Mtx, +ColumnId, +Goal, -KVs ).
%
%  Create KV pairs of the form NthColumnValue-Row where N is the position of ColumnId.
%  KVs do not include the header KV.
%
%  When Goal is given, it is called on element to produce the Key of the pair.
%  Thus, the 3 arity version is equivelant to Call = (=).
%
%==
% ?- mtx_data( mtcars, Mt ), mtx_column_kv( Mt, mpg, KVs ).
% KVs = [21.0-row(21.0, 6.0, 160.0, 110.0, 3.9, 2.62, 16.46, 0.0, 1.0, 4.0, 4.0), 21.0-row(21.0, 6.0, 160.0, 110.0, 3.9, 2.875, 17.02, 0.0, 1.0, 4.0, 4.0), 22.8-row(22.8, 4.0, 108.0, 93.0, 3.85, 2.32, 18.61, 1.0, 1.0, 4.0, 1.0), 21.4-row(21.4, 6...)|...].
%
% ?- assert( add(A,B,C):- C is A + B ).
% ?- mtx_data( mtcars, Mt ), mtx_column_kv( Mt, mpg, add(1), KVs ).
% KVs = [22.0-row(21.0, 6.0, 160.0, 110.0, 3.9, 2.62, 16.46, 0.0, 1.0, 4.0, 4.0), 22.0-row(21.0, 6.0, 160.0, 110.0, 3.9, 2.875, 17.02, 0.0, 1.0, 4.0, 4.0), 23.8-row(22.8, 4.0, 108.0, 93.0, 3.85, 2.32, 18.61, 1.0, 1.0, 4.0, 1.0), 22.4-row(21.4, 6....)|...].
%==
%
% @author nicos angelopoulos
% @version  0.2 2014/8/7,  this was csv_kvs_column_row( CId, Csv, KVs )
% @version  0.3 2022/10/15,  added /4 version- and converted the findall call to iteration.
%
mtx_column_kv( MtxIn, Column, KVs ) :-
     mtx_column_kv( MtxIn, Column, (=), KVs ).
     
mtx_column_kv( MtxIn, Column, Goal, KVs ) :-
	mtx_header_body( MtxIn, Hdr, Rows ),
	mtx_header_column_pos( Hdr, Column, N ),
     mtx_column_kv_pos( Rows, N, Goal, KVs ).


mtx_column_kv_pos( [], _N, _G, [] ).
mtx_column_kv_pos( [R|Rs], N, Goal, [K-R|KRs] ) :-
     arg( N, R, Nth ),
     call( Goal, Nth, K ),
     mtx_column_kv_pos( Rs, N, Goal, KRs ).
