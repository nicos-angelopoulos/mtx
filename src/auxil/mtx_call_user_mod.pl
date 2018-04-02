%% mtx_call_user_mod( Call, Add, MoedCall ).
%
% Prepend 'user':Call to a non-moed Call if Name/Arity is defined in 'user'.
% Name is the functor name of Call and Arity is the arity of Call + Add.
% If Call is not moed and Name/Arity not defined in 'user' MoedCall = Call.
% This predicate is necessary as SWI prepends mtx: .
%
mtx_call_user_mod( Mod:Call, _Add, Mod:Call ) :- !.
mtx_call_user_mod( Call, Add, user:Call ) :-
	functor( Call, Name, Arity ),
	Full is Arity + Add,
	current_predicate( user:Name/Full ),
	!.
mtx_call_user_mod( Call, _Add, Call ).
