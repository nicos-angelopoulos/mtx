
:- lib( stoics_lib:list_frequency/2 ).
:- lib( stoics_lib:op_compare/3 ).

/** mtx_column_frequency_threshold( +Mtx, +Cid, +Op, +Thresh, -Reduced ).

Shorten Mtx into Reduced by removing all rows that correspond to Cid identified
column values that occur below or above a threshold value number of times.

Header is assumed.

Op should be a recognisable operator, see stoics_lib: op_compare/).
The predicate will call op_compare( Op, Freq, Thresh ), for the Frequency
of every distinct value on column Cid in Mtx.


==
?- assert( a_mtx([r(a,b,c),r(1,2,1),r(1,2,1),r(1,6,7),r(8,9,10)]) ).
?- a_mtx(Mtx), mtx_column_frequency_threshold( Mtx, a, >, 2, Red ).
Red = [r(a, b, c), r(1, 2, 1), r(1, 2, 1), r(1, 6, 7)].

?- a_mtx(Mtx), mtx_column_frequency_threshold( Mtx, a, <, 2, Red ).
Red = [r(a, b, c), r(8, 9, 10)].

?- a_mtx(Mtx), mtx_column_frequency_threshold( Mtx, a, <, 1, Red ).
Red = [r(a, b, c)].

?- a_mtx(Mtx), mtx_column_frequency_threshold( Mtx, a, =<, 1, Red ).
Red = [r(a, b, c), r(8, 9, 10)].

==

@author nicos angelopoulos
@version 0.1  2017/5/17
@see stoics_lib: op_compare/3

*/

mtx_column_frequency_threshold( MtxIn, Cid, Op, Thresh, Reduced ) :-
    mtx( MtxIn, Mtx ),
    mtx_column( Mtx, Cid, Clm, _, Cpos ),
    list_frequency( Clm, Freqs ),
    Mtx = [Hdr|Rows],
    include( mtx_column_frequency_threshold_test(Freqs,Cpos,Op,Thresh), Rows, RedRows ),
    Reduced = [Hdr|RedRows].

mtx_column_frequency_threshold_test( Freqs, Cpos, Op, Thresh, Row ) :-
    arg( Cpos, Row, Val ),
    memberchk( Val-Freq, Freqs ),
    op_compare( Op, Freq, Thresh ).
