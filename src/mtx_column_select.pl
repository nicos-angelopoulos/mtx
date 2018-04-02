
:- lib( stoics_lib:list_transpose/2 ).
:- lib( stoics_lib:mod_goal/4 ).

%% mtx_column_select( +Mtx, +ColumnS, -Rem, -Sel ).
%% mtx_column_select( +Mtx, +CallStr, -Rem, -Sel ).
%
% Select column or columns (header(s) or number(s) of) from Mtx to produce Sel with remainder Rem.
% Sel is the removed column(s), and Rem is the remainder of Mtx.
% Rem is a matrix whereas Sel is a list of values if ColumnS was atomic or a list of list values if 
% ColumnS was a list.
% When CallStr is of the form @(Goal) or call(Goal), it will be applied to each column, with
% succeeding columns Selected for Sel.
% (Note that dealing with presence/absence of column name is delegated to Goal).
% Goal is called in user if it is not module prepended (see mod_goal/4).
%
%==
% ?- Mtx = [row(a,b,c,d),row(1,1,1,1),row(1,1,2,3),row(2,2,2,2)], assert( ex_mtx(Mtx) ).
% ?- ex_mtx(Mtx), mtx_column_select( Mtx, b, Red, Sel ).
% Mtx, = [row(a,b,c,d),row(1,1,1,1),row(1,1,2,3),row(2,2,2,2)],
% 
% ?- mtx_column_select( Mtx, [a,b], Red, Sel ).
% Red = [row(c, d), row(1, 1), row(2, 3), row(2, 2)],
% Sel = [[a, b], [1, 1], [1, 1], [2, 2]].
% 
% ?- assert( ( has_at_least(Tms,Val,List) :- findall( 1, member(Val,List), Ones ), sum_list(Ones,Sum), Tms =< Sum) ).
% ?- has_at_least(2,a,[a,b,c,a] ).
% true.
% ?- has_at_least(2,b,[a,b,c,a] ).
% false.
%
% ?- ex_mtx(Mtx), mtx_column_select( Mtx, call(has_at_least(2,1)), Red, Sel ).
% Mtx = [row(a, b, c, d), row(1, 1, 1, 1), row(1, 1, 2, 3), row(2, 2, 2, 2)],
% Red = [row(c, d), row(1, 1), row(2, 3), row(2, 2)],
% Sel = [[a, b], [1, 1], [1, 1], [2, 2]].
%==
%
% @author nicos angelopoulos
% @version  0.2 2014/6/3,      fixed ColumnS = [b] bug
%
mtx_column_select( CsvF, Column, MtxOut, Sel ) :-
	mtx( CsvF, Mtx ),
	mtx_column_select_by( Column, Mtx, Out, Sel ),
	mtx( MtxOut, Out ).

mtx_column_select_by( @(Goal), Mtx, Out, Sel ) :-
    !,
    mtx_column_select_by( call(Goal), Mtx, Out, Sel ).
mtx_column_select_by( call(Goal), Mtx, Out, Sel ) :-
	!,
	mtx_lists( Mtx, Columns ),
	mod_goal( user, Goal, false, Moal ),
	partition( Moal, Columns, SelClms, RemClms ),
	mtx_lists( Out, RemClms ),
	list_transpose( SelClms, Sel ).
mtx_column_select_by( Column, Mtx, Out, Sel ) :-
	Mtx = [Hdr|_],
	column_single_ns( Column, Hdr, Single, Ns ),
     select_nth_args( Mtx, Ns, Single, Sel, Out ).

column_single_ns( Columns, Hdr, Single, Ns ) :-
	is_list(Columns), 
	!,
	Single = false,
	% maplist( header_column_id_nth(Hdr), Columns, Ns ).
	maplist( mtx:mtx_header_column_pos(Hdr), Columns, Ns ).
	% sort( NsU, Ns ).
	% sort( NsU, AscNs ),
	% reverse( AscNs, Ns ).
column_single_ns( Column, Hdr, Single, Ns ) :-
	Single = true,
	mtx:mtx_header_column_pos( Hdr, Column, Ns ).
	% header_column_id_nth( Hdr, Column, Ns ).

select_nth_args( [], _Ns, _Single, [], [] ).
select_nth_args( [H|T], Ns, Single, [Nths|More], [O|Tout] ) :-
     H =.. [Name|Args],
	single_select_term_args( Single, Ns, Args, Nths, NewArgs ),
     O =.. [Name|NewArgs],
     select_nth_args( T, Ns, Single, More, Tout ).

single_select_term_args( true, N, Args, Nth, NewArgs ) :-
     nth1( N, Args, Nth, NewArgs ).

single_select_term_args( false, Ns, Args, Nths, NewArgs ) :-
	length( Args, Len ),
	multi_select_term_args( 1, Len, Ns, Args, Nths, NewArgs ).
	% reverse( RevNewArgs, NewArgs ).

multi_select_term_args( Over, Len, _, _Args, [], [] ) :-
	Over > Len,
	!.
multi_select_term_args( I, Len, Ns, Args, Nths, RemArgs ) :-
	memberchk( I, Ns ),
     nth1( I, Args, Nth ),
	!,
	Nths = [Nth|TNths],
	J is I + 1,
	multi_select_term_args( J, Len, Ns, Args, TNths, RemArgs ).
multi_select_term_args( I, Len, Ns, Args, Nths, RemArgs ) :-
	nth1( I, Args, RemA ),
	RemArgs = [RemA|TRemAs],
	J is I + 1,
	multi_select_term_args( J, Len, Ns, Args, Nths, TRemAs ).
