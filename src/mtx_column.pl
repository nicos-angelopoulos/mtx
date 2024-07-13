
:- lib( mtx_in_memory/1 ).
% :- lib(stoics_lib:en_list/2).

%% mtx_column( +Mtx, ?Cid, -Column ).
%% mtx_column( +Mtx, ?Cid, -Column, -Cname, -Cpos ).
%
%  Select column data from Csv for column identified by Cid.
%  Cid identifies a column in Mtx either by means of its name or 
%  an integer corresponding to its position.
%  Note that name of selected header (Nhdr) is not in Column.
%  Cpos is the position of Cid and Cname is its column name.
% 
%  When Cid is an unbound all possible values are erumerated,
%  with Cid = Cname.
%
%==
% ?- mtx_mtcars(Mtc), mtx_column( Mtc, carb, Carbs ).
% Carbs = [4.0, 4.0, 1.0, 1.0, 2.0, 1.0, 4.0, 2.0, 2.0|...].
%==
% @see The order of the args 4 and 5 was swapped on 15.1.26
%
mtx_column( Csv, Cid, Clm ) :-
	mtx_column( Csv, Cid, Clm, _Cnm, _Cpos ).

mtx_column( Csv, Cid, Clm, Cnm, Cpos ) :-
	mtx_header_body( Csv, Hdr, Rows ),
	% mmtx_matrices_in_memorytx_header_column_pos( Hdr, Column, Nhdr, Nclm ),
	mtx_header_column_name_pos( Hdr, Cid, Cnm, Cpos ),
	maplist( arg(Cpos), Rows, Clm ).

