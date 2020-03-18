%% mtx_matrices_in_memory( +Mtcs ).
% 
% Mtcs is the list of matrices currently loaded in memory in the form of Module-AbsF.
% Each matrix is loaded in a separate module (see mtx_in_memory/2).
%
%==
% ?- mtx_facts( data('mtcars.csv'), Mtcars ).
% ?- mtx_matrices_in_memory( Mtcs ).
% Mtcs = [mtcars-'/home/nicos/.local/share/swi-prolog/pack/mtx/data/mtcars.csv'].
%==
%
% @author nicos angelopoulos
% @version  2.1  2014/02/09.
% @tbd get all nb_ access to a single file, probably rename this with _facts_
%
mtx_matrices_in_memory( Defined ) :-
	nb_current( mtxs_in_memory, InMemPairs ), 
	!,
	% maplist( arg(1), InMemPairs, InMemMods ),
	partition( mtx_current_memory_module, InMemPairs, Defined, Dangling ),
	mtxs_in_memory_report_dangling( Dangling, Defined ).
mtx_matrices_in_memory( [] ) :-
	nb_setval( mtxs_in_memory, [] ).

mtxs_in_memory_report_dangling( [], _Def ) :- !.
mtxs_in_memory_report_dangling( Dangles, Defined ) :-
	write( user_error, dangling_mtx_modules(Dangles) ), nl,
	nb_setval( mtxs_in_memory, Defined ).
	
mtx_current_memory_module( Mod-_AbsF ) :-
	current_module( Mod ).
