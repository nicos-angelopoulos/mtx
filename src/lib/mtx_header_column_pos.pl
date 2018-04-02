
:- use_module( library(mtx) ). 
	% mtx_header_column_name_pos/4.

%% mtx_header_column_pos( +Hdr, +Cid, -Pos ).
% 
%  Same as mtx_header_column_name_pos( Hdr, Cid, _, Pos ).
%
%==
% ?- mtx_mtcars(M), mtx_header(M,H), mtx:mtx_header_column_pos(H,carb,Pos).
%==
%  @see mtx_header_column_name_pos/4
%
mtx_header_column_pos( Hdr, Cid, Pos ) :-
	mtx_header_column_name_pos( Hdr, Cid, _Cnm, Pos ).
