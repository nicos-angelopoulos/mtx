/** mtx_value_column_frequencies( +Mtx, +Value, -VCFreqs ).

VCFreqs are the frequencies of Value in each column of Mtx.<br>
The result is a KV pair list where the key (K) is the column name.<br>
It was part of mtx_value_plot/3.

==
?- Mtx = [r(a,b,c,d),r(1,0,0,0),r(1,1,0,0),r(1,1,1,0)], maplist(writeln,Mtx), 
   mtx_value_column_frequencies(Mtx,1,VC).
r(a,b,c,d)
r(1,0,0,0)
r(1,1,0,0)
r(1,1,1,0)
Mtx = [r(a, b, c, d), r(1, 0, 0, 0), r(1, 1, 0, 0), r(1, 1, 1, 0)],
VC = [a-3, b-2, c-1, d-0].
==

@author nicos angelopoulos
@version  0.1 2018/02/16
@see mtx_value_plot/3

*/
mtx_value_column_frequencies( Inx, Value, VCFreqs ) :-
    MCVopts = [values_as(frequencies),header_pair(true)],
    mtx_columns_values( Inx, ClmsFrqsPrs, MCVopts ),
    findall( Clm-Cnt, ( member(Clm-ClmFreqs,ClmsFrqsPrs),
                        ( memberchk(Value-Cnt,ClmFreqs) -> true; Cnt is 0)
                  ),
                        VCFreqs ).
