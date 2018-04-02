
:- lib(mtx).
:- lib( nth_replace/5 ).

/** mtx_pos_elem( +Mtx, ?I, ?J, -Elem, +Opts ).
    mtx_pos_elem( +Mtx, +I, +J, +Elem, -Out, +Opts ).

Access or change matrix's Mtx the element at position (I,J). 
In the latter case Out is Mtx with the element at position (I,J) set to Elem.

mtx_pos_elem/5 can be used to generate all positions and elements

Please note this uses the canonical representation and not optimised 
for other formats.

Opts 
  * has_header(HasH)
    default as per mtx_header_body/5.

==
?- Mtx = [row(a,b,c),row(1,2,3),row(4,5,6)], assert( a_mtx(Mtx) ).
?- a_mtx(Amtx), mtx_pos_elem(Amtx,I,J,Elem,true).
Amtx = [row(a, b, c), row(1, 2, 3), row(4, 5, 6)],
I = J, J = Elem, Elem = 1 ;
...
?- a_mtx(Amtx), mtx_pos_elem(Amtx,2,3,0,Bmtx,true).
Amtx = [row(a, b, c), row(1, 2, 3), row(4, 5, 6)],
Bmtx = [row(a, b, c), row(1, 2, 3), row(4, 5, 0)].

==

*/
mtx_pos_elem( Mtx, I, J, Elem, Opts ) :-
	mtx_header_body( Mtx, _Header, Body, _HasH, Opts ),
	nth1( I, Body, Row ),
	arg( J, Row, Elem ).

mtx_pos_elem( Mtx, I, J, Elem, New, Opts ) :-
	mtx_header_body( Mtx, Header, Body, HasH, Opts ),
	mtx_body_pos_new_elem( Body, I, J, Elem, NewBody ),
	mtx_has_header_add( HasH, Header, NewBody, New ).

mtx_body_pos_new_elem( Body, I, J, Elem, NewBody ) :-
	nth_replace( I, Body, NewIth, Ith, NewBody ),
	Ith =.. [Name|Args],
	nth_replace( J, Args, Elem, _Arg, NewArgs ),
	NewIth =.. [Name|NewArgs].
