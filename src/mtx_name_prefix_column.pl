
:- use_module( library(mtx) ).

:- lib( stoics_lib:which/3 ).
:- lib( stoics_lib:prefix_atom/2 ).

%% mtx_name_prefix_column( +Mtx, +Prefix, -Pos, -Cnm, -Clm ).
%
%  Retrieve the column data (Clm) from Mtx for the column 
%  with name prefixed by Prefix.
%  Pos, Cnm and Clm are the position in the
%  header, the fulll column name and the column data respectively.
%  If there are more than 1 matching columns the predicate throws an
%  error, if there are no matching columns the predicate fails
%  as to allow alternatives to be tried.
%
%==
% % throws error
% ?- Mtx = [hdr(aa,ab,ba,bb),row(1,2,3)], 
%    mtx_name_prefix_column( Mtx, a, Pos, Cnm, Clm ).
%
% ?- Mtx = [hdr(aa,ab,ba,bb),row(1,2,3)], 
%    mtx_name_prefix_column( Mtx, aa, Pos, Cnm, Clm ).
% Pos = 1,
% Cnm = aa,
% Clm = [1].
%==
% @author nicos angelopoulos
% @version  0.1 2014/10/8
%
mtx_name_prefix_column( Mtx, Prefix, Pos, Cnm, Clm ) :-
	mtx_header( Mtx, Hdr ),
	which( prefix_atom(Prefix), Hdr, Poss ),
	mtx_name_prefix_column_position( Poss, Prefix, Pos ),
	mtx_column( Mtx, Pos, Clm, Cnm, Pos ).

mtx_name_prefix_column_position( [Pos], _Prefix, Pos ) :- !.
mtx_name_prefix_column_position( [], _Prefix, _Pos ) :- !, fail.
mtx_name_prefix_column_position( Poss, Prefix, _Pos ) :-
	throw( prefix_didnot_match_to_unique_header_position(Poss,Prefix) ).
