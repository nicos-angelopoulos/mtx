
:- lib(mtx_matrices_in_memory/1).

:- lib(stoics_lib:locate/3).
:- lib(stoics_lib:expand_spec/2).


/** mtx_facts( +CsvF ).
    mtx_facts( +CsvF, ?Module ).
    mtx_facts( +CsvF, ?Module, +Opts ).

Csv file CsvF is consulted into Module as a set of facts.

When module is missing or is variable, it is taken to be the stem of the base name of CsvF.
When Opts is missing it defaults to the empty list.
If basename(CsvF).pl exists and no option pl_ignore(true) is given, then the .pl file
is consulted into Module with no further questions asked of Opts.
A warning message is printed on user_output except if pl_warning(false) is in Opts.

Opts it should be one, or a list of the following
  * header(Hdr=true)
  does file include headers ?
    * true   
    csv file has header and this is asserted
    * false  
      file has no header and hdr(1,...,n) is asserted
    * void   
      csv file has no header and none is asserted
    * ignore  
      file has a header but this is ignored (nothing asserted)

  * pl_ignore(PlI=false)
  If _true_ predicate does not check for existance of corresponding .pl file.

  * pl_warning(PlW=true) 
  If _false_ the latter case no warning is printed if pre-canned .pl file is loaded "as-is".

  * pl_record(PlR=false)   
  If _true_, record the loaded program to corresponding .pl file. 

Any remaining options are passed to csv_read_file/3.

==
?- debug(mtx(facts)).
true.

?- mtx_facts( data('mtcars.csv'), Mtcars ).
% Expanded facts file to: /home/nicos/.local/share/swi-prolog/pack/mtx/data/mtcars.csv, (type: csv)
% Asserting rows of file:'/home/nicos/.local/share/swi-prolog/pack/mtx/data/mtcars.csv' to module:mtcars.
Mtcars = mtcars.

?- listing( mtcars:_ ).

:- dynamic hdr/11.

hdr(mpg, cyl, disp, hp, drat, wt, qsec, vs, am, gear, carb).

:- dynamic row/11.

row(21.0, 6.0, 160.0, 110.0, 3.9, 2.62, 16.46, 0.0, 1.0, 4.0, 4.0).
row(21.0, 6.0, 160.0, 110.0, 3.9, 2.875, 17.02, 0.0, 1.0, 4.0, 4.0).
...
==

Listens to debug(mtx(facts)).

@author nicos angelopoulos
@version 0.1 2014/02/02
@see was csv_memory/1,2,3

*/
mtx_facts( CsvF ) :-
    mtx_facts( CsvF, _Mod, [] ).

mtx_facts( CsvF, Mod ) :-
    mtx_facts( CsvF, Mod, [] ).

mtx_facts( CsvF, Mod, Opts ) :-
    mtx_facts_file_locate( CsvF, Opts, AbsF, FileType ),
    debug( mtx(facts), 'Expanded facts file to: ~w, (type: ~w)', [AbsF,FileType] ),
    mtx_facts_module( AbsF, Mod ),
    mtx_matrices_in_memory( Defined ),
    mtx_file_memory( AbsF, Mod, FileType, Defined, Opts ).

mtx_file_memory( AbsF, Mod, _FType, Defined, _Opts ) :-
    memberchk( Mod-AbsF, Defined ),
    debug( mtx(facts), 'Csv already in memory (not re-loading), file:~p, in module:~p.', [Mod,AbsF] ),
    !.
mtx_file_memory( AbsF, Mod, _FType, Defined, _Opts ) :-
    memberchk( Mod-Other, Defined ),
    throw( csv_already_in_memory_from_other_file(Mod,Other,AbsF) ), nl,
    !.
mtx_file_memory( AbsF, Mod, FType, _Defined, Opts ) :-
    mtx_type_file_memory( FType, AbsF, Mod, Opts ).

mtx_type_file_memory( pl, AbsF, Mod, _Opts ) :-
    mtx_facts_module( AbsF, Mod ),
    debug( mtx(facts), 'Loading Prolog file:~p to module:~p.', [AbsF,Mod] ),
    Mod:consult( AbsF ),
    mtx_matrices_in_memory( Defined ),
    nb_setval( mtxs_in_memory, [Mod-AbsF|Defined] ).

mtx_type_file_memory( csv, AbsF, Mod, Opts ) :-
    mtx_facts_module(AbsF, Mod ),
    debug( mtx(facts), 'Asserting rows of file:~p to module:~p.', [AbsF,Mod] ),
    ( select(hdr(HdrOval),Opts,CsvOpts) -> true; HdrOval = true, CsvOpts = Opts ),
    csv_read_file( AbsF, Csv, CsvOpts ),   % temporarily until this can assert directly
    mtx_facts_record_stream( Opts, AbsF, PlOut ),
    % nb_getval( matrices_in_memory, Defined ),
    % we could reuse defined from above, but we keep it here, 
    % as we might want to go multi-threaded safe later on ?
    assert_header( HdrOval, Csv, Mod, PlOut, Rows ),
    foreach( member(Row,Rows), assert(Mod:Row) ),
    foreach( member(Row,Rows), portray_clause(PlOut,Row) ),
    close( PlOut ),
    mtx_matrices_in_memory( Defined ),
    nb_setval( mtxs_in_memory, [Mod-AbsF|Defined] ).

mtx_facts_file_locate( CsvF, Opts, PlAbsF, FType ) :-
    \+ memberchk( pl_ignore(true), Opts ),
    expand_spec( CsvF, ExpF ),
    ( catch(locate(ExpF,['',csv,tsv],AbsF),_,fail) ->
        file_name_extension( Stem, _Ext, AbsF ),
        file_name_extension( Stem, pl, PlAbsF )
        ;
        catch(locate(ExpF,pl,PlAbsF),_,fail)
    ),
    exists_file( PlAbsF ),
    !,
    ( memberchk(pl_warning(true),Opts) -> 
        write( '!!!! using Prolog rows in:' ), nl
        ;
        true
    ),
    FType = pl.
mtx_facts_file_locate( CsvF, _Opts, AbsF, csv ) :-
    expand_spec( CsvF, ExpF ),
    catch(locate(ExpF,[csv,tsv,txt],AbsF),_,fail),
    !.

mtx_facts_record_stream( Opts, AbsF, Out ) :-
    memberchk( pl_record(true), Opts ),
    !,
    file_name_extension( Stem, _Ext, AbsF ),
    file_name_extension( Stem, pl, PlAbsF ),
    open( PlAbsF, write, Out ).
mtx_facts_record_stream( _Opts, _AbsF, Out ) :-
    open_null_stream( Out ).

assert_header( true, [Hdr|Rows], Mod, Out, Rows ) :-
    Hdr =.. [_HdrN|Hargs],
    ModHdr =.. [hdr|Hargs],
    assert( Mod:ModHdr ),
    portray_clause( Out, ModHdr ).
assert_header( false, [Hdr|Rows], Mod, Out, Rows ) :-
    functor( Hdr, _Name, Arity ),
    findall( I, between(1,Arity,I), Is ),
    ModHdr =.. [hdr|Is],
    assert( Mod:ModHdr ),
    portray_clause( Out, ModHdr ).
assert_header( void, Rows, _Mod, Rows ).
assert_header( ignore, [_|Rows], _Mod, Rows ).

mtx_facts_module( AbsF, Mod ) :-
    var( Mod ), 
    !,
    file_base_name( AbsF, File ),
    file_name_extension( Mod, _, File ).
mtx_facts_module( _AbsF, _Mod ).

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
