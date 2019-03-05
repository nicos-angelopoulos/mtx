
:- lib( mtx_call_user_mod/3 ).

%% mtx_header_column_multi_pos( +Hdr, +Cid, -Cnms, -Poss ).
%
% Findall Cnms and Poss corresponding to Cid. Cid could be a number (Cnms and Poss are then 
% singletons), a list of Cids (numbers or column names) or predicate that can be called 
% on all Hdr args (then Cnms and Poss correspond to the column names that were true).
%
%==
% ?- mtx_header_column_multi_pos( hdr(a,b,a,c), =(a), Cnms, Poss ).
%  Cnms = [a, a],
%  Poss = [1, 3].
%
% ?- mtx_header_column_multi_pos( hdr(a,b,a,c), [b,c], Cnms, Pos ).
% Cnms = [b, c],
% Pos = [2, 4].
%==
%
% @author nicos angelopoulos
% @version  0.1 2014/9/22
%
mtx_header_column_multi_pos( Hdr, Cid, Cnms, Poss ) :-
	is_list( Cid ),
	!,
	maplist( mtx_header_column_name_pos(Hdr), Cid, Cnms, Poss ).
mtx_header_column_multi_pos( Hdr, Cid, Cnms, Poss ) :-
	atomic( Cid ),
	( number(Cid); \+ (current_predicate(Cid/1); current_predicate(user:Cid/1)) ),
	!,
	maplist( mtx_header_column_name_pos(Hdr), [Cid], Cnms, Poss ).
mtx_header_column_multi_pos( Hdr, Cid, Cnms, Poss ) :-
	functor( Hdr, _, Arity ),
	mtx_call_user_mod( Cid, 1, Call ),
	findall( Pos, (between(1,Arity,Pos),arg(Pos,Hdr,Cnm),call(Call,Cnm)), Poss ),
	findall( Cnm, (member(Pos,Poss),arg(Pos,Hdr,Cnm)), Cnms ),
	!.
mtx_header_column_multi_pos( Hdr, Cid, _Cnms, _Poss ) :-
	% fixme
	throw( could_not_locate_multi_column_in_header_row(Cid,Hdr) ).
