/** alias_data.

Assertz all pack/<Pack>/data directories and data/ as data aliases.

The core of this code comes from a load assert fragment.<br>
Now it can be shared with other stoics packs.<br>
data/ is added first so local data/ files will be found first.

It will probably be moved to pack(stoics_lib)- can even modularise to alias_pack_sub(Sub[,As]).

To use call a load directive in your code.

==
?- file_search_path( data, DataD ).
DataD = '/usr/local/users/nicos/data' ;
?- alias_data.
?- file_search_path( data, DataD ).
DataD = '/usr/local/users/nicos/data' ;
DataD = data ;
DataD = '/home/nicos/.local/share/swi-prolog/pack/mtx/data' ;
DataD = '/home/nicos/.local/share/swi-prolog/pack/sanger/data' ;
DataD = '/home/nicos/.local/share/swi-prolog/pack/bio_db_repo/data' ;
DataD = '/home/nicos/.local/share/swi-prolog/pack/gbn/data'.
==

@author nicos angelopoulos
@version  0.1 2020/3/17
*/
alias_data :-
    assertz(user:file_search_path(data,data)),
    fail.
alias_data :-
    member( Alias, [swi,user_app_data] ),
    user:file_search_path( Alias, Search ), 
    directory_file_path( Search, pack, PackD ),
    exists_directory( PackD ),
    directory_files( PackD, Files ),
    member( Dir, Files ),
    Dir \== '.', Dir \=='..',
    directory_file_path( PackD, Dir, AbsDir ),
    directory_file_path( AbsDir, data, DataD ),
    exists_directory( DataD ),
    alias_assert( data, DataD ),
    fail.
alias_data.

/** alias_assert( +Alias, +Loc )

Only assertz Loc as an Alias if this does n't already exist.

@author nicos angelopoulos
@version  0.1 2020/3/17

*/
alias_assert( Alias, Loc ) :-
    user:file_search_path( Alias, Loc ),
    !.
alias_assert( Alias, Loc ) :-
    assertz( user:file_search_path(Alias,Loc) ).
