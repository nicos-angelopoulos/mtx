
:- lib( mtx_matrices_in_memory/1 ).

%% mtx_in_memory( ?Mtx ).
%% mtx_in_memory( ?Mtx, -File ).
%
% True iff Mtx is a memory stored matrix, as loaded via mtx_in_memory/2 from File.
% Memory matrices, are kept in Mtx module with one hdr/n and many row/n clauses. 
%
% Version 0.2 added File.
%
%  @author nicos angelopoulos
%  @version 0.2  2014/02/18  
%
mtx_in_memory( Mod ) :-
	mtx_in_memory( Mod, _File ).

mtx_in_memory( Mod, File ) :-
	atomic( Mod ),
	mtx_matrices_in_memory( Mtcs ),
	mtx_in_memory_gen( Mod-File, Mtcs ).

mtx_in_memory_gen( Pair, Mtcs ) :-
	\+ ground( Pair ),
	!,
	member( Pair, Mtcs ).
mtx_in_memory_gen( Pair, Mtcs ) :-
	memberchk( Pair, Mtcs ).
