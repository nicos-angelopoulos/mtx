
:- lib( stoics_lib:list_frequency/2 ).

%
mtx_columns_values_defaults( [has_header(true),header_pair(false),values_as(list)] ).

/** mtx_columns_values( +Mtx, -Values, +Opts ).

Return the Values for each column of Mtx. By default it returns the list of values, but it can <br>
also return pairs where key is the column name, and/or sets of frequencies instead of listed values.

Opts 
  * has_header(HasH=true)
    false indicates that the first element of each column should not be excluded
 
  * header_pair(Hpair=false)
    when Mtx has header and this is true each return element is a pair of Cname-ClmValues

  * values_as(As=list)
    default returns values as lists, alternatively
    * set
      returns sets
    * frequencies/freqs
      returns value-freqs pairs

==
 ?- mtx_data( mtcars, MtCars ), mtx_columns_sets( MtCars, Sets, true ),
    maplist( length, Sets, Lengths ), write( lengths(Lengths) ), nl.

  lengths([25,3,27,22,22,29,30,2,2,3,6])
  ...
==


@author nicos angelopoulos
@version  0.2 2016/01/21,    was mtx_columns_sets/3

*/
mtx_columns_values( Mtx, Values, Args ) :-
	options_append( mtx_columns_values, Args, Opts ),
	mtx_lists( Mtx, Lists ),
	options( has_header(HasH), Opts ),
	options( header_pair(Hair), Opts ),
	options( values_as(As), Opts ),
	% fixme: check options are bools (via pack_errors +/or options ?)
	maplist( mtx_column_list_values(HasH,As,Hair), Lists, Values ).

mtx_column_list_values( true, As, Hair, [Cnm|List], Pair ) :-
	mtx_column_values_as( As, List, Values ),
	mtx_column_values_return_pair( Hair, Cnm, Values, Pair ).
mtx_column_list_values( false, As, _Hair, List, Values ) :-
	mtx_column_values_as( As, List, Values ).

mtx_column_values_as( set, List, Set ) :-
	sort( List, Set ).
mtx_column_values_as( list, List, List ).
mtx_column_values_as( freqs, List, Freqs ) :-
    list_frequency( List, Freqs ).
mtx_column_values_as( frequencies, List, Freqs ) :-
    list_frequency( List, Freqs ).

mtx_column_values_return_pair( true, Cnm, Values, Cnm-Values ).
mtx_column_values_return_pair( false, _Cnm, Values, Values ).
