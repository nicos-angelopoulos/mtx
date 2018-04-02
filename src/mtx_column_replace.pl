
:- lib(nth_replace/5).
:- lib(stoics_lib:mod_goal/4).

%% mtx_column_replace( +Mtx, +Cid, +NewVals, -OldVals, -NewMtx ).
%% mtx_column_replace( +Mtx, +Cid, ?NewClmName, +NewVals, -OldVals, -NewMtx ).
%
% Replace a column in a Mtx. When there is no NewClmName (or when it is an unbound variable), 
% then the existing column name is used. <br>
% NewClmName can be atomic or a compound, when the latter it is called with
% =|NewClmName(ClmName,New)|= where _New_ is used as the new column name.<br>
% NewVal could be a list of values, (equal length as Cid's?);
% a _|@(Goal)|_ term where _Goal_ will be maplist applied to Cid's elements to produce the new values; <br>
% _Goal_ which will be applied to the list of Cid's elements to produce the list of new values. <br>
% By default, _Goal_s are called in module _user_ if they are no module prepended. See mod_goal/4, with _false_ in 3rd argument.
% 
%== 
% ?- assert( (plus_one(A,B):-B is A + 1) ).   % plus/3 only works on integers...
% ?- mtx( pack('mtx/data/mtcars'), Mtx, cache(mtcars) ),
%    mtx_column_replace( Mtx, mpg, mpgp1, @(user:plus_one()), _, New ).
%
% Mtx = [row(mpg, cyl, disp, hp, drat, wt, qsec, vs, am, gear, carb), row(21.0, 6.0, 160.0, 110.0, 3.9, 2.62, 16.46, 0.0, 1.0, 4.0, 4.0), 
%        row(21.0, 6.0, 160.0, 110.0, 3.9, 2.875, 17.02, 0.0, 1.0, 4.0, 4.0), row(22.8, 4.0, 108.0, 93.0, 3.85, 2.32, 18.61, 1.0, 1.0, 4.0, 1.0), 
%        row(21.4, 6.0, 258.0, 110.0, 3.08, 3.215, 19.44, 1.0, 0.0, 3.0, 1.0), row(18.7, 8.0, 360.0, 175.0, 3.15, 3.44, 17.02, 0.0, 0.0, 3.0, 2.0), 
%        row(18.1, 6.0, 225.0, 105.0, 2.76, 3.46, 20.22, 1.0, 0.0, 3.0, 1.0), row(14.3, 8.0, 360.0, 245.0, 3.21, 3.57, 15.84, 0.0, 0.0, 3.0, 4.0), 
%        row(..., ..., ..., ..., ..., ..., ..., ..., ..., ..., ...)|...],
% New = [row(mpgp1, cyl, disp, hp, drat, wt, qsec, vs, am, gear, carb), row(22.0, 6.0, 160.0, 110.0, 3.9, 2.62, 16.46, 0.0, 1.0, 4.0, 4.0), 
%        row(22.0, 6.0, 160.0, 110.0, 3.9, 2.875, 17.02, 0.0, 1.0, 4.0, 4.0), row(23.8, 4.0, 108.0, 93.0, 3.85, 2.32, 18.61, 1.0, 1.0, 4.0, 1.0), 
%        row(22.4, 6.0, 258.0, 110.0, 3.08, 3.215, 19.44, 1.0, 0.0, 3.0, 1.0), row(19.7, 8.0, 360.0, 175.0, 3.15, 3.44, 17.02, 0.0, 0.0, 3.0, 2.0), 
%        row(19.1, 6.0, 225.0, 105.0, 2.76, 3.46, 20.22, 1.0, 0.0, 3.0, 1.0), row(15.3, 8.0, 360.0, 245.0, 3.21, 3.57, 15.84, 0.0, 0.0, 3.0, 4.0), 
%        row(..., ..., ..., ..., ..., ..., ..., ..., ..., ..., ...)|...].
% 
% ?- assert( (psfx_one(Name,Psfxed) :- atomic_list_concat([Name,one],'_',Psfxed)) ).
% ?- mtx_column_replace( mtcars, mpg, user:psfx_one(), @(user:plus_one()), _, New ).
% New = [row(mpg_one, cyl, disp, hp, drat, wt, qsec, vs, am, gear, carb), 
%        row(22.0, 6.0, 160.0, 110.0, 3.9, 2.62, 16.46, 0.0, 1.0, 4.0, 4.0), 
%        row(..., ..., ..., ..., ..., ..., ..., ..., ..., ..., ...)|...].
%
% ?- mtx_column_replace( mtcars, mpg, mpgp1, @(plus_one()), _, New ).
% New = [row(mpgp1, cyl, disp, hp, drat, wt, qsec, vs, am, gear, carb), 
%        row(22.0, 6.0, 160.0, 110.0, 3.9, 2.62, 16.46, 0.0, 1.0, 4.0, 4.0), 
%        row(..., ..., ..., ..., ..., ..., ..., ..., ..., ..., ...)|...].
%==
%
% @author nicos angelopoulos
% @version  0.2 2017/9/11
% @tbd check NewVals list is equal to Column list ?
% 
mtx_column_replace( MtxIn, Cid, NewVals, OldVals, NewMtx ) :-
    mtx_column_replace( MtxIn, Cid, _NewClmName, NewVals, OldVals, NewMtx ).
	% mtx_column_replace_pos( Mtx, Pos, Cnm, NewVals, OldVals, NewMtx ).

mtx_column_replace( MtxIn, Cid, NewCnmIn, NewVals, OldVals, NewMtx ) :-
    mtx( MtxIn, Mtx ),
    % mtx_header_body( Mtx, Hdr, Body ),
    mtx_header( Mtx, Hdr ),
    mtx_header_column_name_pos( Hdr, Cid, Cnm, Pos ),
    mtx_column_replace_new_column_name( NewCnmIn, Cnm, NewCnm ),
    mtx_column_replace_values( NewVals, Mtx, Pos, OldVals, NewCnm, NewMtx ).

mtx_column_replace_new_column_name( NewCnmIn, Cnm, NewCnm ) :-
    var( NewCnmIn ),
    !,
    NewCnm = Cnm.
mtx_column_replace_new_column_name( Goal, Cnm, NewCnm ) :-
    compound( Goal ),
    !,
    call( Goal, Cnm, NewCnm ).
mtx_column_replace_new_column_name( NewCnm, _Cnm, NewCnm ).

mtx_column_replace_values( @(GoalIn), Mtx, Pos, OldVals, NewCnm, NewMtx ) :-
    !,
    mod_goal( user, GoalIn, false, Goal ),
    mtx_column( Mtx, Pos, PosOldVals ),
    maplist( Goal, PosOldVals, NewVals ),
    mtx_column_replace_values( NewVals, Mtx, Pos, OldVals, NewCnm, NewMtx ).
mtx_column_replace_values( [V|Vs], Mtx, Pos, OldVals, NewCnm, NewMtx ) :-
    !,
    mtx_header_body( Mtx, Hdr, Body ),
    mtx_column_rows_pos_replace( Body, [V|Vs], Pos, OldVals, NewBody ),
    mtx_nth_arg_replace( Hdr, Pos, NewCnm, _OldCnm, NewHdr ),
    NewMtx = [NewHdr|NewBody].
mtx_column_replace_values( GoalIn, Mtx, Pos, OldVals, NewCnm, NewMtx ) :-
    compound( GoalIn ),
    mod_goal( user, GoalIn, false, Goal ),
    mtx_column( Mtx, Pos, PosOldVals ),
    call( Goal, PosOldVals, NewVals ),
    mtx_column_replace_values( NewVals, Mtx, Pos, OldVals, NewCnm, NewMtx ).

mtx_column_rows_pos_replace( [], [], _Pos, [], [] ).
mtx_column_rows_pos_replace( [Row|Rows], [V|Vs], Pos, [OldV|OldVs], [NewRow|NewRows] ) :-
    mtx_nth_arg_replace( Row, Pos, V, OldV, NewRow ),
    mtx_column_rows_pos_replace( Rows, Vs, Pos, OldVs, NewRows ).

mtx_nth_arg_replace( Term, Pos, New, Old, NewTerm ) :-  % fixme: library ?
    Term =.. [Name|Args],
    nth_replace( Pos, Args, New, Old, NewArgs ),
    NewTerm =.. [Name|NewArgs].
