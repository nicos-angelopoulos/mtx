
:- lib( mtx_in_memory/1 ).
% fixme: :- lib( mtx/2 ).

mtx_header_body_defaults( has_header(true) ).

/** mtx_header_body( +Mtx, -Header, -Body ).
    mtx_header_body( +Mtx, -Header, -Body, -HasH, Opts ).

True iff Header is the header of Mtx and Body are the data rows.
HasH is taken from iff has_header(HasH) in Options. 
If HasH  is false, Header is a made up row of the shape row(1,...,N)

Opts
  * has_header(HasH=true)
    If true, first line is removed before partitioning and added to both Incl and Excl

@author nicos angelopoulos
@version 0.1 2014/9/24
*/
mtx_header_body( Mtx, Header, Body, HasH, Args ) :-
	options_append( mtx_header_body, Args, Opts ),
	options( has_header(HasH), Opts ),
	mtx_has_header_body( HasH, Mtx, Header, Body, Opts ).


mtx_has_header_body( true, Mtx, Header, Body, _Opts ) :- !,
	mtx_header_body( Mtx, Header, Body ).
mtx_has_header_body( false, Mtx, Header, Body, _Opts ) :- !,
	mtx( Mtx, Body ),
	!,
	Body = [Row|_],
	functor( Row, Rn, Rarity ),
	findall( I, between(1,Rarity,I), Is ),
	Header =.. [Rn|Is].
mtx_has_header_body( _Other, _Mtx, _Header, _Body, Opts ) :-
	Err = opt_mismatch(has_header,[true,false],Opts),
	throw( pack_error(mtx,mtx_header_body/5,Err) ).

mtx_header_body( Mtx, Header, Body ) :-
	mtx_in_memory( Mtx ), % fixme: should this move to mtx/2 ???
	!,
	mtx_memory_header_body( Mtx, Header, Body ).
mtx_header_body( Mtx, Header, Body ) :-
	mtx( Mtx, [Header|Body] ).

mtx_memory_header_body( Mtx, Header, Body ) :-
	once( current_predicate( Mtx:hdr/N ) ),
	functor( Header, hdr, N ),
	once( call(Mtx:Header) ),
	mtx_memory_body( Mtx, Body ).
mtx_memory_header_body( Mtx, Header, Body ) :-
	mtx_memory_body( Mtx, [Header|Body] ).

mtx_memory_body( Mtx, Body ) :-
	member( Dname, [row,data,_X] ),
	current_predicate( Mtx:Dname/N ),
	Dname \== hdr,
	!,
	% fixme; should we printing a waring if \== row and \== data ?
	functor( Data, Dname, N ),
	findall( Data, call(Mtx:Data), Body ).
