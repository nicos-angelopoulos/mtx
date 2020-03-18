:- use_module( library(lib) ).

:- lib(mtx).

:- debug(mtx(facts)).

facts :-
    mtx_facts( data('mtcars.csv'), Mtcars ),
    debug( mtx(facts), 'Mtcars: ~w', [Mtcars] ),
    debug( mtx(facts), 'Listing of module: ~w', [Mtcars] ),
    listing( Mtcars:_ ),
    mtx_matrices_in_memory( InMem ),
    nl,
    debug( mtx(facts), 'In memory: ~w', [InMem] ).
