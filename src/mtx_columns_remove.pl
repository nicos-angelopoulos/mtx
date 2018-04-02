
:- lib( options ).

/** mtx_columns_remove( +Mtx, +CidsOrGoal, -Out, +Opts )

Remove a number of columns from Mtx resulting to Out.


==
?- mtx_data( mtcars, Mt ), mtx_columns_remove( Mt, [wt,cyl], Red ).
Mt = [row(mpg, cyl, disp, hp, drat, wt, qsec, vs, am, gear, carb), row(21.0, 6.0, 160.0, 110.0, 3.9, 2.62, 16.46, 0.0, 1.0, 4.0, 4.0), .... ],
Red = [row(mpg, disp, hp, drat, qsec, vs, am, gear, carb), row(21.0, 160.0, 110.0, 3.9, 16.46, 0.0, 1.0, 4.0, 4.0), row(21.0, 160.0, 110.0, 3.9, 17.02, 0.0, 1.0, 4.0, 4.0), ...].

?- mtx_data( mtcars, Mt ), mtx_columns_remove( Mt, [wt,cyl], Red ), 
   mtx_dims( Mt, MtR, MtC ), mtx_dims( Red, RdR, RdC ).

MtR = RdR, RdR = 33,
MtC = 11,
RdC = 9.

?- assert( mtx1( [row(a,b,c,c), row(1,2,3,4), row(1,5,6,7), row(1,8,9,10)] ) ).true.
?- assert( ( below_min_length_of_factor(Min,Clm) :- Clm = [_|Vals], sort( Vals, Ord ), length( Ord, Len ), Len < Min) ).
true.

?- mtx1( Mtx1 ), mtx_columns_remove( Mtx1, below_min_length_of_factor(2), Red ).
Mtx1 = [row(a, b, c, c), row(1, 2, 3, 4), row(1, 5, 6, 7), row(1, 8, 9, 10)],
Red = [row(b, c, c), row(2, 3, 4), row(5, 6, 7), row(8, 9, 10)].

?- lib(stoics_lib:has_at_least/3).

?- mtx1( Mtx1 ), mtx_columns_remove( Mtx1, has_at_least(2,1), Red ).
Red = [row(b, c, c), row(2, 3, 4), row(5, 6, 7), row(8, 9, 10)].

?- lib(stoics_lib:has_at_most/3).
?- mtx1( Mtx1 ), mtx_columns_remove( Mtx1, has_at_most(2,1), Red ).
==

@version  0.0.2 2015/12/01 added goals 
@see mtx_header_cids_order/3

*/

mtx_columns_remove( Mtx, CNameS, Out ) :-
	mtx( Mtx, [Hdr|Rows] ),
	( (is_list(CNameS); ( functor(CNameS,Name,Arity),
					  OfCall is Arity + 1,
					  \+ current_predicate(user:Name/OfCall) % fixme: deal with module prefixes
				     ) )  ->
		en_list( CNameS, CNames ),
		Type = list,
		mtx_header_cids_order( Hdr, CNames, COrder )
		;
		Type = goal,
		COrder = CNameS
	),
	mtx_lists( [Hdr|Rows], Lists ),
	mtx_remove_columns_lists( Lists, Type, COrder, 1, RemLists ),
	mtx_lists( Out, RemLists ).

mtx_remove_columns_lists( [], _Type, _COrder, _I, [] ).
mtx_remove_columns_lists( [Clm|T], Type, COrder, I, Remains ) :-
	( mtx_remove_column_in_lists(Type,COrder,I,Clm) ->
		Remains = Temains
		;
		Remains = [Clm|Temains]
	),
	J is I + 1,
	mtx_remove_columns_lists( T, Type, COrder, J, Temains ).

mtx_remove_column_in_lists( list, COrder, I, _Clm ) :-
	ord_memberchk( I, COrder ),
	debug( mtx_columns_remove, 'Removing column at position: ~d', I ).
mtx_remove_column_in_lists( goal, Goal, _, Clm ) :-
	call( user:Goal, Clm ),
	Clm = [Hdr|_],
	debug( mtx_columns_remove, 'Removing column with header: ~w', Hdr ).
