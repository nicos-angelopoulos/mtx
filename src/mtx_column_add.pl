
:- lib( break_nth/4 ).
:- lib( mtx_call_user_mod/3 ).
:- lib( nths_add/4 ).

%% mtx_column_add( +Mtx, +N, +Values, -Out ).
%
%  Add Values as the Nth column in Out with input columns taken from Mtx.
% 
%  Values should be a list of values, or a term of the form:
%  * transform(K,Goal,Hdr)
%     K is the input column id, Goal transform in to out, Hdr is either an atom or a goal that is applied to the input header to produce output header
%  * transform(K,WholeG,Goal,Hdr) 
%     in this case WholeG is called with call(WholeG,AllClmdata), where AllClmData is the whole Kth Column (minus header).
%  * transform(Ks,Goal,Hdr) 
%     take input from many columns (Ks) to produce a single output column
%  * derive(Goal,InpPos,OutPos,Cnm)
%     derives the column from applying goal to each row of Mtx by inserting the Row at place InpPos and the result in OutPos of Goal
%  * derive(Goal,InpPos,OutPos,Cnm,false)
%     as derive/4, but converts row to list before calling Goal
%
%  Note that for callable K, all columns of Mtx that succeed on the K(Cid) are transformed.
%  N is taken to be relative to each input and can be an expression except if 
%  of the form abs_pos(Abs) (see mtx_relative_pos/5).
% 
% As of v0.3 N can be a variable, in which Values should be a list of column values (plus header value as first item).
% This is a shorthand 
% 
%==
% ?- Mtx = [row(a, b, d), row(1, 2, 4), row(5, 6, 8)], assert( an_mtx(Mtx) ).
%
% ?- an_mtx(Mtx), mtx_column_add( Mtx, 3, [c,3,7], New ).
% New = [row(a, b, c, d), row(1, 2, 3, 4), row(5, 6, 7, 8)].
%
% ?- an_mtx(Mtx), mtx_column_add( Mtx, 1+2, [c,3,7], New ).
% New = [row(a, b, c, d), row(1, 2, 3, 4), row(5, 6, 7, 8)].
%
% ?- an_mtx(Mtx), mtx_column_add( Mtx, -1, [c,3,7], New ).
% New = [row(a, b, c, d), row(1, 2, 3, 4), row(5, 6, 7, 8)].
%
% ?- an_mtx(Mtx), mtx_column_add( Mtx, d, [c,3,7], New ).
% New = [row(a, b, c, d), row(1, 2, 3, 4), row(5, 6, 7, 8)].
%
% ?- an_mtx(Mtx), mtx_column_add( Mtx, 3, transform(3,plus(1),plus1), New ).
% New = [row(a, b, d, plus1), row(1, 2, 4, 5), row(5, 6, 8, 9)].
% 
% ?- Mtx = [hdr(a,b,a,c), row(1,2,1,3), row(2,3,2,4)],
%    mtx_column_add( Mtx, +(1), transform(=(a),plus(2),plus2), Out ).
% Out = [hdr(a, plus2, b, a, plus2, c), row(1, 3, 2, 1, 3, 3), row(2, 4, 3, 2, 4, 4)].
%
% ?- Mtx = [hdr(a,b,a,c), row(1,2,1,3), row(2,3,2,4)],
% mtx_column_add( Mtx, 1, transform(=(a),plus(2),atom_concat('2+')), Out  ).
% Out = [hdr(a, '2+a', b, a, '2+a', c), row(1, 3, 2, 1, 3, 3), row(2, 4, 3, 2, 4, 4)].
%
% ?- Mtx = [hdr(a, b, c), row(1, 2, 3), row(4,5,6)],
% mtx_column_add( Mtx, 4, transform([1,2],sum_list,atom_concat('a+b')), Out  ).
% Out = [hdr(a, b, c, ab), row(1, 2, 3, 3), row(4, 5, 6, 9)].
%
% ?- ['/home/nicos/pl/lib/src/meta/aggregate'].
% ?- Mtx = [r(a,b,c,d),r(x,1,2,3),r(y,4,5,6),r(z,7,8,9)],
%    mtx_column_add( Mtx, 5, derive(aggregate(plus(),0,indices([3,2,4])),1,3,sum), Otx ).
% Otx = [r(a, b, c, d, sum), r(x, 1, 2, 3, 6), r(y, 4, 5, 6, 15), r(z, 7, 8, 9, 24)].
% 
%==
%
% As of version v0.3 can use variable N for adding at end of matrix.
%==
% ?- an_mtx(Mtx), mtx_column_add( Mtx, After, [e,5,10], Ntx ).
% After = 4,
% Ntx = [row(a, b, d, e), row(1, 2, 4, 5), row(5, 6, 8, 10)].
%==
% 
% To add at the end of the matrix in general, use
%==
% ?- an_mtx(Mtx), mtx_header_body(Mtx, Header, Rows), Clm = [e,5,10],
%    mtx_relative_pos( -1, 0, Header, 1, After ), mtx_column_add( [Header|Rows], After, Clm, Ntx ).
%
% Ntx = [row(a, b, d, e), row(1, 2, 4, 5), row(5, 6, 8, 10)].
%==
%
% @author nicos angelopoulos
% @version  0.1 2014/6/5  added comments. 
% @version  0.2 2014/6/16 added transform(K,G,H) terms as 3rd argument
% @version  0.3 2025/10/5 var(N) as shorthand for adding at end of matrix
% @tbd      complete the documentation
%
mtx_column_add( Mtx, Nid, VTerm, Out ) :-
     mtx_header_body( Mtx, Hdr, Rows ),
     ( var(Nid) -> 
                    mtx_relative_pos( -1, 0, Hdr, 1, Nid ),
                    NVs = [Nid-VTerm]
                 ; 
	               findall( N-Values, ( mtx_column_add_vterm_values(VTerm,Rows,Hdr,K,Values),
	     				 % R is K + Nid,
	                         mtx_relative_pos(Nid,K,Hdr,+1,N)% ,mtx_header_column_pos(Hdr,R,N)
	                    ), NVs )
     ),
	mtx_rows_column_pairs_add( NVs, Mtx, Extended ),
	mtx( Out, Extended ).

mtx_column_add_vterm_values( derive(Goal,Ipos,Opos,Cnm,false), Rows, _Hdr, 0, [Cnm|Vals] ) :-
	mtx_column_add_on_row_callable( Goal, Ipos, Opos, RowL, Val, Callable ),
	findall( Val, (member(Row,Rows),Row=..[_|RowL],once(user:Callable)), Vals ).

mtx_column_add_vterm_values( derive(Goal,Ipos,Opos,Cnm), Rows, _Hdr, 0, [Cnm|Vals] ) :-
	mtx_column_add_on_row_callable( Goal, Ipos, Opos, Row, Val, Callable ),
	findall( Val, (member(Row,Rows),once(user:Callable)), Vals ).

mtx_column_add_vterm_values( transform(Kid,WholeG,Goal,KHdrG), Rows, Hdr, K, Values ) :-
	Trans = 'Transforming rule, ClmnID: ~w, WholeG: ~w, Goal: ~w, Hdr: ~w',
	debug( mtx_column_add, Trans, [Kid,WholeG,Goal,KHdrG] ),
	% mtx_header_column_pos( Hdr, Kid, K ),
	mtx_header_column_multi_pos( Hdr, Kid, Knms, Ks ),
	nth1( Ki, Ks, K ),
	nth1( Ki, Knms, Knm ),
	findall( Kth, (member(R,Rows),arg(K,R,Kth)), Kths ),
	mtx_call_user_mod( WholeG, 1, WholeModG ),
	call( WholeModG, Kths ),
	mtx_call_user_mod( Goal, 2, ModG ),
	maplist( ModG, Kths, Mapped ),
	mtx_column_add_vterm_values_column_name( KHdrG, Knm, HdrAtm ),
	Values = [HdrAtm|Mapped].
mtx_column_add_vterm_values( transform(Kids,Goal,HdrG), Rows, Hdr, 0, Values ) :-
	is_list( Kids ),
	!,
	Trans = 'Transforming rule, ClmnIDs: ~w, Goal: ~w, Hdr: ~w',
	debug( mtx_column_add, Trans, [Kids,Goal,HdrG] ),
	maplist( mtx_header_column_name_pos(Hdr), Kids, Knms, Poss ),
	findall( KList, ( member(R,Rows),
	                  findall( Kth, ( member(Pos,Poss),
				                   arg(Pos,R,Kth) ), KList
				          )
				 ),
							  KNest ),
	mtx_call_user_mod( Goal, 2, ModG ),
	maplist( ModG, KNest, Mapped ),
	mtx_column_add_vterm_values_column_name( HdrG, Knms, HdrAtm ),
	Values = [HdrAtm|Mapped].
mtx_column_add_vterm_values( transform(Kid,Goal,HdrG), Rows, Hdr, K, Values ) :-
	!,
	% use maplist/3 rather than embeding the goal in findall so 
	% predicate will fail on maplist failure
	Trans = 'Transforming rule, ClmnID: ~w, Goal: ~w, Hdr: ~w',
	debug( mtx_column_add, Trans, [Kid,Goal,HdrG] ),
	% mtx_header_column_pos( Hdr, Kid, K ),
	mtx_header_column_multi_pos( Hdr, Kid, Knms, Ks ),
	nth1( Ki, Ks, K ),
	nth1( Ki, Knms, Knm ),
	findall( Kth, (member(R,Rows),arg(K,R,Kth)), Kths ),
	maplist( Goal, Kths, Mapped ),
	mtx_column_add_vterm_values_column_name( HdrG, Knm, HdrAtm ),
	Values = [HdrAtm|Mapped].
mtx_column_add_vterm_values( Values, _Rows, _Hdr, 0, Values ) :-
	is_list( Values ).

mtx_column_add_vterm_values_column_name( G, _Knm, Name ) :-
	atomic( G ),
	\+ current_predicate( G/2 ),
	!,
	Name = G.
mtx_column_add_vterm_values_column_name( G, Knm, Name ) :-
	call( G, Knm, Name ).

mtx_rows_column_pairs_add( Pairs, Mtx, Out ) :-
	sort( Pairs, Asc ),
	reverse( Asc, Dsc ),
	mtx_rows_column_pairs_add_dsc( Dsc, Mtx, Out ).

mtx_rows_column_pairs_add_dsc( [], Mtx, Mtx ).
mtx_rows_column_pairs_add_dsc( [Pos-Values|T], Mtx, Out ) :-
	Brk is Pos - 1,
	mtx_rows_column_add( Mtx, Brk, Values, Mid ),
	mtx_rows_column_pairs_add_dsc( T, Mid, Out ).

mtx_rows_column_add( [], _N, Values, [] ) :-
	( Values == []  -> true; throw( mtx_rows_column_add(remaining_values(Values)) ) ).
mtx_rows_column_add( [R|Rs], N, Values, [X|Xs] ) :-
	R =.. [Name|Args],
	break_nth( N, Args, Largs, Rargs ),
	mtx_rows_column_add_value( Values, Value, RemValues ),
	append( Largs, [Value|Rargs], NewArgs ),
	X =.. [Name|NewArgs],
	mtx_rows_column_add( Rs, N, RemValues, Xs ).
	
mtx_rows_column_add_value( [], '', [] ).
mtx_rows_column_add_value( [H|T], H, T ).

mtx_column_add_on_row_callable( Goal, Ipos, Opos, Row, Val, Callable ) :-
	sort( [Ipos-ipos,Opos-opos], Order ),
	mtx_column_add_on_row_args( Order, Goal, Row, Val, Callable ).

mtx_column_add_on_row_args( [Fpos-Which1,Spos-Which2], Goal, Row, Val, Call ) :-
	mtx_column_add_on_row_which_arg( Which1, Row, Val, First ),
	mtx_column_add_on_row_which_arg( Which2, Row, Val, Secon ),
	mtx_column_add_on_row_at_args( Goal, [Fpos,Spos], [First,Secon], Call ).

mtx_column_add_on_row_at_args( Goal, Poss, Args, New ) :-
	Goal =.. [Name|GArgs],
	nths_add( Poss, GArgs, Args, NewArgs ),
	New =.. [Name|NewArgs].

mtx_column_add_on_row_which_arg( ipos, Row, _Val, Row ).
mtx_column_add_on_row_which_arg( opos, _Row, Val, Val ).
