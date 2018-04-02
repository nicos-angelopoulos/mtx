%% mtx_relative_pos( +N, +K, +Hdr, -Pos ).
%% mtx_relative_pos( +N, +K, +Hdr, +Nadj, -Pos ).
%
% R is the absolute position of the Nth position relative to K.
% If N is compound it is assumed to be the RHS of an addition which
% is evaluated- LHS is K. If relative position evalutes to a negative
% is assumed to mean right relative postion in Hdr and thus 
% mapped to the absolute position of that. In this case Nadj is also 
% added. This provides a convenient method for referring to 
% negative location of transformed (relative to Hdr) matrices.
%
%==
% ?- mtx_relative_pos( 2, 2, _, Pos ).
% Pos = 4.
% ?- mtx_relative_pos( -2, 0, c(a,b,c), Pos ).
% Pos = 2.
% ?- mtx_relative_pos( -2, 0, c(a,b,c), Nadj, Pos ).
% Pos = 2.
%==
% @version  0.1 2014/9/22
%
mtx_relative_pos( N, K, Hdr, Pos ) :-
	mtx_relative_pos( N, K, Hdr, 0, Pos ).

mtx_relative_pos( abs_pos(R), _K, _Hdr, _Nadj, R ) :-
	number( R ), 
	!.
mtx_relative_pos( N, K, Hdr, Nadj, Abs ) :-
	R is K + N,
	mtx_absolute_position( R, Hdr, Nadj, Abs ).

mtx_absolute_position( R, _Hdr, _Nadj, Abs ) :- 0 =< R, !, Abs is R.
mtx_absolute_position( R, Hdr, Nadj, Abs ) :- 
	functor( Hdr, _, Arity ),
	Abs is Arity + R + 1 + Nadj.
