
/** mtx_dims( +Mtx, -Nrows, -Ncols ).
    mtx_dims( -Mtx, +Nrows, +Ncols ).
    mtx_dims( -Mtx, +Nrows, +Ncols, +Value ).

Mtx has Nrows number of rows and Ncols number of columns.
Mtx is a mtx/1. Predicate can also being used to generate a matrix
of given dimensions. In that mode, when Value is missing it is defaulted to 0.

==
?- mtx_data( mtcars, Mt ), mtx_dims( Mt, Nr, Nc ).
Mt = ..., 
Nr = 33,
Nc = 11.

?- mtx_dims( Mtx, 2, 3 ).
Mtx = [row(0, 0, 0), row(0, 0, 0)].

==
@author  nicos angelopoulos
@version 0:2   2016/12/08, added -++ mode

*/
mtx_dims( Mtx, Nrows, Ncols ) :-
	var( Mtx ),
	!,
	mtx_dims( Mtx, Nrows, Ncols, 0 ).

mtx_dims( File, Nrows, Ncols ) :-
	mtx( File, Rows ),
	mtx_rows_dims( Rows, Nrows, Ncols ).

mtx_dims( Mtx, Nrows, Ncols, Val ) :-
	findall( Val, between(1,Ncols,_), Vals ),
	Row =.. [row|Vals],
	findall( Row, between(1,Nrows,_), Mtx ).

mtx_rows_dims( Rows, Nrows, Ncols ) :-
     length( Rows, Nrows ), 
     Rows = [Hdr|_],
     functor( Hdr, _, Ncols ).
