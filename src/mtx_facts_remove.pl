/** mtx_facts_remove( +FileOrModule ).

Remove from a memory module an Mtx represented as facts.

FileOrModule can be either the absolute filename of the input matrix file or the module
the facts are.


==
% assumes example on mtx_facts/2 has ran, then:

?- debug(mtx(facts)).
?- mtx_facts_remove(mtcars).
% Removing mod: mtcars, from file:'/home/nicos/.local/share/swi-prolog/pack/mtx/data/mtcars.csv'
true.

?- listing(mtcars:_).
true.
==

@see mtx_facts/2

*/
mtx_facts_remove( Either ) :-
    mtx_matrices_in_memory( Defined ),
    mtx_facts_defined_remove( Either, Defined, Mod ),
    mtx_facts_module_abolish_predicates( Mod ).

mtx_facts_defined_remove( Mod, Defined, Mod ) :-
    select( Mod-AbsF, Defined, Rem ),
    !,
    mtx_facts_located_remove( Mod, AbsF, Rem ).
mtx_facts_defined_remove( AbsF, Defined, Mod) :-
    select( Mod-AbsF, Defined, Rem ),
    !,
    mtx_facts_located_remove( Mod, AbsF, Rem ).
mtx_facts_defined_remove( Mod, Defined, Mod ) :-
    throw( not_a_known_module_or_file_in(Mod,Defined) ).

mtx_facts_located_remove( Mod, AbsF, Rem ) :-
    nb_setval( mtxs_in_memory, Rem ),
    debug( mtx(facts), 'Removing mod: ~w, from file:~p', [Mod,AbsF] ).

%% mtx_facts_module_abolish_predicates( M ).
%
%  To be done, remove from defined too.
%
mtx_facts_module_abolish_predicates( M ) :-
    (   current_predicate(M:P/A),
        abolish(M:P,A),
        fail
    ;   true
    ).
