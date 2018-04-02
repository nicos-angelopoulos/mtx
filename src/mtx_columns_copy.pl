
:- use_module( library(mtx) ).
:- use_module( library(options) ).

mtx_columns_copy_defaults([]).

%% mtx_columns_copy( +MtxFrom, +MtxTo, -MtxOut, +Opts ).
%
% For each column(CidIn,PosOut) term in Opts column
% with Cid, CidIn, is copied from Mtx to MtxOut. 
% In MtxOut, the column is placed in position PosOut.
% The predicate scans Opts as they come, so PosOut should
% take account of all operation to its left.
%
%==
% ?- M1 = [r(a,b,c),r(1,2,3),r(4,5,6)],
%    M2 = [r(d,e,f),r(7,8,9),r(10,11,12)],
%    mtx_columns_copy( M1, M2, M3, column_copy(c,2) ).
% M3 = [r(d, c, e, f), r(7, 3, 8, 9), r(10, 6, 11, 12)].
%==
% @author nicos angelopoulos
% @version  0.1 2014/01/22
% @see mtx_column_add/4.
% @tbd add rem(Rem) option- to return remaining options
%
mtx_columns_copy( Min, Mto, Mout, Args ) :-
	options_append( mtx_columns_copy, Args, Opts ),
	select( column_copy(Cid,Pos), Opts, Rem ),
	!,
	options_debug( 'Copy column option found- Cid: ~w, Pos: ~w', [Cid,Pos], Opts ), 
	mtx_column( Min, Cid, Clm, _Nclm, Cnm ),
	options_debug( 'Picked column: ~w.', [Cnm], Opts ), 
	mtx_column_add( Mto, Pos, [Cnm|Clm], Mid ),
	options_debug( 'Added to position: ~w.', [Pos], Opts ), 
	mtx_columns_copy( Min, Mid, Mout, Rem ).

mtx_columns_copy( _Min, Mout, Mout, Opts ) :-
	options_debug( 'Finished copying columns.', Opts, Opts ).
