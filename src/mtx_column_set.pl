
/** mtx_column_set( +Mtx, ?Cid, -Set ).
    mtx_column_set( +Mtx, ?Cid, -Column, -Set ).

A shortcut for mtx_column/3 followed by sort/2 on the column values to produce Set

@see mtx_column/3

*/
mtx_column_set( Mtx, Cid, Set ) :-
	mtx_column( Mtx, Cid, Column ),
	sort( Column, Set ).
mtx_column_set( Mtx, Cid, Column, Set ) :-
	mtx_column( Mtx, Cid, Column ),
	sort( Column, Set ).
