/** mtx_has_header_add( +HasH, +Header, +Body, -Rows ).

Add Header and Body to create Rows iff HasH = _true_.
For any other value of HasH, Body = Rows.

The predicate is meant as a companion to mtx_header_body/5.

@author nicos angelopoulos
@version  0.1 2016/2/17
@see mtx_header_body/5

*/
mtx_has_header_add( true, Header, Body, [Header|Body] ) :- !.
mtx_has_header_add( _, _Header, Body, Body ).
