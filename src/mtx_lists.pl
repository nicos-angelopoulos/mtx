
:- lib( stoics_lib:skim/3 ).
:- lib( head/2 ).

/** mtx_lists( ?Mtx, ?Lists ).

   Dismantle or construct matrix Mtx to and from list of nested Lists.

*/

mtx_lists( Csv, Lists ) :-
	head( Csv, Head ), 
	\+ var( Head ),
	is_list( Head ),
	!,
	Lists = Csv.

mtx_lists( Csv, Lists ) :-
	ground( Csv ), 
	var( Lists ),
	!,
	mtx( Csv, [Hdr|Rows] ),
	% we assume Hdr is maximal here,...
	functor( Hdr, _Name, Arity ),
	findall( [ClmH], (between(1,Arity,I),arg(I,Hdr,ClmH)), Acc ), 
	mtx_rows_dismantle( Rows, Acc, Lists ).
mtx_lists( Csv, Lists ) :-
	atomic( Csv ),
	ground( Lists ),
	!,
	mtx_lists_rows( Lists, Rows ),
	mtx( Csv, Rows ).
mtx_lists( [], [] ) :- !. % captures mtx_lists( X, [] ).
mtx_lists( Csv, Lists ) :-
	mtx_lists_rows( Lists, Csv ).

% to lists
mtx_rows_dismantle( [], Acc, Lists ) :-
	maplist( reverse, Acc, Lists ).
mtx_rows_dismantle( [H|T], Acc, Lists ) :-
	H =.. [_Name|Args], 
	thread_list_on_nested( Args, Acc, Nxt ),
	mtx_rows_dismantle( T, Nxt, Lists ).

thread_list_on_nested( [], Nxt, Nxt ).
thread_list_on_nested( [H|T], [F|M], [[H|F]|R] ) :-
	thread_list_on_nested( T, M, R ).

% from lists

mtx_lists_rows( Lists, Rows ) :-
	skim( Lists, Scum, Remains ),
	!,
	HRow =.. [row|Scum],
	Rows = [HRow|TRows],
	mtx_lists_rows( Remains, TRows ).
mtx_lists_rows( _, [] ).
