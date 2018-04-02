
:- lib( mtx_in_memory/1 ).

%% mtx_header( +Mtx, -Header ).
%% mtx_header( +Mtx, -Header, -Template ).
%
% True iff Header is the header of Mtx. Template shares functor
% details with Header, with all its arguments being free variables.
% We start supporting memory files here.
%
% @author nicos angelopoulos
% @version 0.1 2014/02/02
% @tbd add specialist clause for the case Mtx is a file. no need then to use mtx/2.
% 
%
mtx_header( Mtx, Header ) :-
	mtx_header( Mtx, Header, _Template ).

mtx_header( Mtx, Header, Template ) :-
	mtx_in_memory( Mtx ),
	!,
	once( current_predicate( Mtx:hdr/N ) ),
	functor( Header, hdr, N ),
	once( call(Mtx:Header) ),
	functor( Template, hdr, N ),
	!.
mtx_header( Mtx, Header, Template ) :-
	mtx( Mtx, [Header|_] ),
	functor( Header, Name, Arity ),
	functor( Template, Name, Arity ).
