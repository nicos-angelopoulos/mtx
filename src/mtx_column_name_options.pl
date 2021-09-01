
:- use_module( library(mtx) ).
:- lib(options).

:- lib(mtx_column_default/4).

%% mtx_column_name_options( +Mtx, +StdCnm, +Def, -Column, +Opts )
% 
% Select data Column from Mtx. StdCnm is the standard/expected name of the column, 
% but this is overriden by Cnm if cnm_StdCnm(Cnm) is in Opts.
% Def is propagated as the 3rd argument to mtx_column_default/4,
% except when it is an atomic different to true and false.
% In the latter case, a ball is prepared which includes Def in its arguments
% with the intution that in that case Def is an atom identifying the 
% matrix or its source, to the user.
%
%==
% ?- Mtx = [r(a,sec,c),r(1,2,3),r(4,5,6)], assert( m(Mtx) ).
% ?- m(Mtx), mtx_column_name_options( Mtx, b, example, Column, [] ).
% ERROR: Unhandled exception: matrix_required_column_missing(example,b)
%
% ?- m(Mtx), mtx_column_name_options( Mtx, b, false, Column, [] ).
% false.
%
% ?- m(Mtx),  mtx_column_name_options( Mtx, b, example, Column, [cnm_b(sec)] ).
% Mtx = [r(a, sec, c), r(1, 2, 3), r(4, 5, 6)],
% Column = [2, 5].
%==
%
% Opts
%
% | cnm_from(From=from)  | from   |
% | cnm_to(To=to)    | to     |
% | cnm_weight(Weight=weight)| weight |
%
% @see mtx_column_default/4
%
mtx_column_name_options( Mtx, StdCnm, MtxDef, Vals, Opts ) :-
	mtx_column_name_options( StdCnm, Cnm, Opts ),
	( (atomic(MtxDef),MtxDef\==true,MtxDef\==false) ->
			Def = throw( matrix_required_column_missing(MtxDef,Cnm) )
			;
			Def = MtxDef
	),
	mtx_column_default( Mtx, Cnm, Def, Vals ).

%% mtx_column_name_options( +StdCnm, -Cnm, +OptS )
% 
% From StdCnm, the standard/expected name of the column, get Cnm
% which is SrdCnm except when cnm_StdCnm(Cnm) is in Opts and Cnm is ground.
%
mtx_column_name_options( StdCnm, Cnm, OptS ) :-
	en_list( OptS, Opts ),
	atom_concat( 'cnm_', StdCnm, CnmName ),
	CTerm =.. [CnmName,CArg],
	( (memberchk(CTerm,Opts),ground(CArg)) ->
		CArg = Cnm
		;
		Cnm = StdCnm
	).
