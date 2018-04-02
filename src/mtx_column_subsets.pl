/** mtx_column_subsets( +Mtx, +Cid, -Subsets ).

Create Value-SubMtx pair list Subsets where Value is each distinct 
value for column Cid of matrix Mtx. Each SubMtx does not include the header.

==
?- mtx_column_subsets( [w(c1,c2),w(a,1),w(a,2),w(b,1),w(b,2),w(c,3)], 1, Subs ).
Subs = [a-[w(a, 1), w(a, 2)], b-[w(b, 1), w(b, 2)], c-[w(c, 3)]].
==

@author nicos angelopoulos
@version  0.1 2017/5/8

*/
mtx_column_subsets( Mtx, Cid, Subsets ) :-
    mtx( Mtx, Rows ), 
    mtx_column( Mtx, Cid, Clm, _, Cpos ),
    sort( Clm, Vals ),
    findall( Val-_A, member(Val,Vals), Subsets ),
    mtx_header_body( Rows, _Hdr, Body ),
    mtx_column_values_subsets( Body, Cpos, Subsets ).

mtx_column_values_subsets( [], _Cpos, Accs ) :-
    mtx_column_values_subsets_zip( Accs ).
mtx_column_values_subsets( [R|Rs], Cpos, Accs ) :-
    arg( Cpos, R, RVal ),
    mtx_column_values_update_acc( Accs, RVal, R, NxtAccs ),
    mtx_column_values_subsets( Rs, Cpos, NxtAccs ).

mtx_column_values_update_acc( [], Rval, _Row, _ ) :-
    throw( internally_inconsistent_mtx_subset_value(Rval) ).
mtx_column_values_update_acc( [RVal-Rows|T], RVal, Row, NxtAccs ) :-
    !,
    Rows = [Row|TRows],
    NxtAccs = [RVal-TRows|T].
mtx_column_values_update_acc( [Val-Rows|T], RVal, Row, [Val-Rows|NxtAccs] ) :-
    mtx_column_values_update_acc( T, RVal, Row, NxtAccs ).

mtx_column_values_subsets_zip( [] ).
mtx_column_values_subsets_zip( [_-[]|T] ) :-
    mtx_column_values_subsets_zip( T ).
