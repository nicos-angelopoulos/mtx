
:- use_module(library(lists)).  % select/3.
:- use_module(library(lib)).

:- lib(mtx).
:- lib(real).
:- lib(options).
:- lib(debug_call).

iris_defaults([debug(true)]).

/** iris(+Opts).

Create the iris.csv pack(mtx) dataset from R via pack(real).

Opts
  * debug(Dbg=true)
    informational, progress messages

Examples
==
?- iris([]).
==

@author nicos angelopoulos
@version  0.1 2024/03/23

*/

iris( Args ) :-
     Self = iris,
     options_append( Self, Args, _Opts ),
     % Names = ['Sepal.Length', 'Sepal.Width', 'Petal.Length', 'Petal.Width', 'Species'].
     Names <- names(iris),
     ( select('Species',Names,Rames) -> true; throw(no_species_in_iris(Names)) ),
     SpeciesClm <- 'as.character'(iris$'Species'),
     debuc( Self, length, species_column/SpeciesClm ),
     findall( [Cid|List], (member(Cid,Rames),List <- iris$Cid), ClmLists ),
     mtx_lists( 'iris.csv', [['Species'|SpeciesClm]|ClmLists] ),
     debuc( Self, end, true ).
