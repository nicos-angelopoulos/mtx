
:- lib( stoics_lib:compound/3 ).

/** goal_expression( +Inp, +Expr, -Goal ).

Expand an elliptic Expr-ession involving input argument Inp to a Goal. 

For instance, sum_list > 10 --> sum_list(Inp,X), X > 10

==
?- sum_list( [1,2,3], X ).  % autoloads sum_list/2.

?- goal_expression( [1,3,5,7], sum_list > 10, Goal ), call( Goal ).
Goal =  (sumlist([1, 3, 5, 7], 16), 16>10).

?- goal_expression( [1,3,5], sumlist > 10, Goal ), call( Goal ).
false.

?- goal_expression( [1,3,5,7], append(X,Y), Goal ), call( Goal ), sum_list( X, S ).
X = [],
Y = [1, 3, 5, 7],
Goal = user:append([], [1, 3, 5, 7], [1, 3, 5, 7]),
S = 0 ;
X = [1],
Y = [3, 5, 7],
Goal = user:append([1], [3, 5, 7], [1, 3, 5, 7]),
S = 1 ;
X = [1, 3],
Y = [5, 7],
Goal = user:append([1, 3], [5, 7], [1, 3, 5, 7]),
S = 4 ;
X = [1, 3, 5],
Y = [7],
Goal = user:append([1, 3, 5], [7], [1, 3, 5, 7]),
S = 9 ;
X = [1, 3, 5, 7],
Y = [],
Goal = user:append([1, 3, 5, 7], [], [1, 3, 5, 7]),
S = 16 ;

==

@author nicos angelopoulos
@version  0.1 2015/12/2
@version  0.2 2016/02/16, clean-up, tidy-up, comments

*/
goal_expression( Inp, Expr, Goal ) :-
	goal_expression( Inp, Expr, PreGs, ExprGoal ),
	goal_expression_collect( PreGs, ExprGoal, Goal ).

goal_expression( Inp, Expr, PreGs, Mod:Goal ) :-
	goal_mod_name_args( Expr, Mod, Name, Args, NArgs ),
	Adds is NArgs + 1,
	current_predicate( Mod:Name/Adds ),
	!,
	append( Args, [Inp], ExpArgs ),
	Goal =.. [Name|ExpArgs], 
	PreGs = [].

goal_expression( Inp, Expr, PreGs, Otp ) :-
	goal_mod_name_args( Expr, Mod, Name, Args, NArgs ),
	Adds is NArgs + 2,
	current_predicate( Mod:Name/Adds ),
	!,
	append( Args, [Inp,Otp], ExpArgs ),
	Extra =.. [Name|ExpArgs], 
	PreGs = [Extra].

goal_expression( Inp, Expr, [], Goal ) :-
	compound( Expr, Name, Args ),
	!,
	maplist( goal_expression(Inp), Args, CallsL, Ergs ),
	Eoal =.. [Name|Ergs],
	flatten( CallsL, Calls ),
	goal_expression_collect( Calls, Eoal, Goal ).
goal_expression( _Inp, Expr, [], Expr ).

goal_expression_collect( [], Goal, Goal ).
goal_expression_collect( [C|Cs], Goal, (C,Rest) ) :-
	goal_expression_collect( Cs, Goal, Rest ).

goal_mod_name_args( Expr, Mod, Name, Args, NArgs ) :-
	Expr = Mod:NkExpr,
	!,
	goal_name_args( NkExpr, Name, Args, NArgs ).
goal_mod_name_args( Expr, user, Name, Args, NArgs ) :-
	goal_name_args( Expr, Name, Args, NArgs ).

goal_name_args( Expr, Name, Args, NArgs ) :-
	atom( Expr ),
	!,
	Name = Expr, Args = [], NArgs is 0.
goal_name_args( Expr, Name, Args, NArgs ) :-
	compound( Expr, Name, Args ),  % is there room for a goal_expressing/3 Args ? 
	length( Args, NArgs ).
