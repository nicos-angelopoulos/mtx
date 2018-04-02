
% :- lib( options ).
:- lib( stoics_lib:list_frequency/2 ).

mtx_factors_defaults( [by(column),max(-1),frequency(false),sort(false)] ).

/** mtx_factors( +Mtx, -FactorPairs,  +Opts ).

Get and possibly report sets of values appearing in Mtx columns (default) or rows.

Opts 
 * by(By=column)
   use row to get the report row-wise

 * frequency(Freq=false)
   to report factors, or add number each factor appeared

 * max(Max=0)
   if positive, the maximum number of items to be displayed for each vector. if negative no reporting takes place.

==
?- mtx( pack(mtx/data/mtcars), Cars ), mtx_factors( Cars, _,  [max(5)] ), fail.
mpg: [10.4,13.3,14.3,14.7,15.0,...]
cyl: [4.0,6.0,8.0]
disp: [71.1,75.7,78.7,79.0,95.1,...]
hp: [52.0,62.0,65.0,66.0,91.0,...]
drat: [2.76,2.93,3.0,3.07,3.08,...]
wt: [1.513,1.615,1.835,1.935,2.14,...]
qsec: [14.5,14.6,15.41,15.5,15.84,...]
vs: [0.0,1.0]
am: [0.0,1.0]
gear: [3.0,4.0,5.0]
carb: [1.0,2.0,3.0,4.0,6.0,...]
false.

?- mtx( pack(mtx/data/mtcars), Cars ), mtx_factors( Cars, _,  [max(3),frequency(true)] ), fail.
mpg: [21.0-2,22.8-2,21.4-2,...]
cyl: [6.0-7,4.0-11,8.0-14]
disp: [160.0-2,108.0-1,258.0-1,...]
hp: [110.0-3,93.0-1,175.0-3,...]
drat: [3.9-2,3.85-1,3.08-2,...]
wt: [2.62-1,2.875-1,2.32-1,...]
qsec: [16.46-1,17.02-2,18.61-1,...]
vs: [0.0-18,1.0-14]
am: [1.0-13,0.0-19]
gear: [4.0-12,3.0-15,5.0-5]
carb: [4.0-10,1.0-7,2.0-10,...]
false.


==

@author nicos angelopoulos
@version  0.1 2015/11/25
@see this started as mtx_factors_report/2

*/
mtx_factors( Mtx, Facts, Args ) :-
	options_append( mtx_factors, Args, Opts ),
	options( [max(Max),frequency(Frq)], Opts ),
	options( [sort(Sort),by(By)], Opts ),
	Ostr = opts(Frq,Sort,Max),
	mtx_factors_by( By, Ostr, Mtx, Facts ).

mtx_factors_by( column, Opts, Mtx, Facts ) :-
	mtx_lists( Mtx, Lists ),
	maplist( mtx_factors_vector_list(Opts), Lists, Facts ).

mtx_factors_by( row, Opts,  Mtx, Facts ) :-
	maplist( mtx_factors_vector_row(Opts), Mtx, Facts ).

mtx_factors_vector_list( opts(Frq,Sort,Max), [Hdr|Vals], Hdr-Facts ) :-
	mtx_factor_values( Frq, Sort, Vals, Facts ),
	mtx_factors_vector_report( Max, Hdr, Facts ).

mtx_factors_vector_row( opts(Frq,Sort,Max), Row, Hdr-Facts ) :-
	Row =.. [Hdr|Vals], 
	mtx_factor_values( Frq, Sort, Vals, Facts ),
	mtx_factors_vector_report( Max, Hdr, Facts ).

mtx_factor_values( false, Sort, Vals, Facts ) :-
	( Sort == true ->
		sort( Vals, Facts )
		;
		list_to_ord_set(Vals,Facts)
	).
mtx_factor_values( true, Sort, Vals, Facts ) :-
	list_frequency( Vals, FactsPrv ),
	( Sort == true ->
		sort( FactsPrv, Facts )
		;
		Facts = FactsPrv
	).

mtx_factors_vector_report( -_, _Hdr, _Facts ) :- !.
mtx_factors_vector_report( 0, Hdr, Facts ) :-
	!,
	format( '~w: ~w\n', [Hdr,Facts] ).
mtx_factors_vector_report( X, Hdr, Facts ) :-
	integer( X ),
	X > 0,
	!,
	( once((length(AList,X),append(AList,Rem,Facts))) ->
		( Rem = [_|_] -> append(AList,['...'],List); AList = List )
		;
		List = Facts
	),
	format( '~w: ~w\n', [Hdr,List] ).
