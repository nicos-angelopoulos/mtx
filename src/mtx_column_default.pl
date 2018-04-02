
:- use_module( library(mtx) ).

%% mtx_column_default( +Csv, +Cid, +DefGoal, -Clm ).
%
% As mtx_column/3, but if Cid is not in Csv, instead of propagating the 
% mtx_header_column_name_pos/4 ball DefGoal is called.
%
%==
% ?- mtx_data( mtcars, Mt ), mtx_column_default( Mt, mpg, true, Mpg ).
% Mt =...,
% Mpg = [21.0, 21.0, 22.8, 21.4, 18.7, 18.1, 14.3, 24.4, 22.8|...].
%
% ?- mtx_data( mtcars, Mt ), mtx_column( Mt, typo, NaL ).
% ERROR: Unhandled exception: could_not_locate_column_in_header_row(typo,row(mpg,cyl,disp,hp,drat,wt,qsec,vs,am,gear,carb))
% 
% ?- G = ( Mpg=[] ),
%    mtx_data( mtcars, Mt ), mtx_column_default( Mt, typo, G, Mpg ).
% G = ([]=[]),
% Mpg = [],
% Mt = ... .
%==
% @see mtx_column/3
%
mtx_column_default( Csv, Cid, DefGoal, Clm ) :-
	mtx_header_body( Csv, Hdr, Rows ),
	( catch( mtx_header_column_name_pos(Hdr,Cid,_Cnm,Cpos),_,fail) ->
		maplist( arg(Cpos), Rows, Clm )
		;
		call( DefGoal )
	).
