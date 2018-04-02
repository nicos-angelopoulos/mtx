
:- lib( goal_expression/3 ).

/** mtx_columns_partition( +Mtx, +Goal, -Incl, -Excl ).
    mtx_columns_partition( +Mtx, +Goal, +ClmPart, -Incl, -Excl ).

Partitions Mtx to columns for which Goal succeeds (Incl) against 
those that fails (Excl). ClmPart should be one of *body*, _head_ or _whole_.

Goal is elliptically expanded to an expresssion.

==
?- assert( mtx1([row(a,b,c),row(1,2,3),row(4,5,6),row(7,8,9)] ) ).
?- lib(lists).    % this is needed for sum_list/2
?- mtx1( Mtx1 ), mtx_columns_partition( Mtx1, sum_list > 0, Mtx2, Excl ).
Mtx1 = Mtx2, Mtx2 = [row(a, b, c), row(1, 2, 3), row(4, 5, 6), row(7, 8, 9)],
Excl = [].

?- mtx1( Mtx1 ), mtx_columns_partition( Mtx1, sum_list > 12, body, Acc, Rej ).
Mtx1 = [row(a, b, c), row(1, 2, 3), row(4, 5, 6), row(7, 8, 9)],
Acc = [row(b, c), row(2, 3), row(5, 6), row(8, 9)],
Rej = [row(a), row(1), row(4), row(7)].

?- mtx1( Mtx1 ), mtx_columns_partition( Mtx1, sum_list > 15, body, Acc, Rej ).
Mtx1 = [row(a, b, c), row(1, 2, 3), row(4, 5, 6), row(7, 8, 9)],
Acc = [row(c), row(3), row(6), row(9)],
Rej = [row(a, b), row(1, 2), row(4, 5), row(7, 8)].

?- assert( (chkmember(List,Elem):-memberchk(Elem,List)) ).
?- mtx1( Mtx1 ), mtx_columns_partition( Mtx1, chkmember([a,c]), head, Acc, Rej ).

==

@author nicos angelopoulos
@version  0.1 2015/12/2
@see goal_expression/3
@tbd use options apply_on(AppOn) see mtx/0

*/

mtx_columns_partition( Mtx, Goal, Incl, Excl ) :-
	mtx_columns_partition( Mtx, Goal, body, Incl, Excl ).

mtx_columns_partition( Mtx, Goal, ClmPart, Incl, Excl ) :-
	mtx_lists( Mtx, MtxLs ),
	partition( mtx_column_call(ClmPart,Goal), MtxLs, InclLs, ExclLs ),
	maplist( mtx_lists, [Incl,Excl], [InclLs,ExclLs] ).

mtx_column_call( whole, Goal, Clm ) :-
	goal_expression( Clm, Goal, Call ),
	call( Call ).
mtx_column_call( head, Goal, [Hdr|_Clm] ) :-
	goal_expression( Hdr, Goal, Call ),
	call( Call ).
mtx_column_call( body, Goal, [_Hdr|Body] ) :-
	goal_expression( Body, Goal, Call ),
	call( Call ).
