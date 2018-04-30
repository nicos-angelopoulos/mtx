/** mtx_columns_collapse( +MtxIn, +Cids, +Cnm, +RowGoal, +Pos, -Mtx ).
    
    Collapse a number of columns into a single column.<br>
MtxIn is the input matrix, Cids are the column identifiers for the columns to be collapsed,<br>
Cnm is the column name of the new, collapsed column, Pos is the position of the new column <br>
and Mtx is the new matrix.

==
?- assert( ( or_gate(List,And) :- sum_list(List,Sum), ( Sum > 0 -> And is 1; And is 0)) ).
?- Mtx = [r(a,b1,b2,c),r(0,1,0,1),r(0,0,1,0),r(1,0,0,1),r(1,1,1,0)], 
   mtx_columns_collapse( Mtx, [b1,b2], b, or_gate, 2, OutMtx ).

Mtx = ...
OutMtx = [r(a, b, c), r(0, 0, 1), r(0, 0, 0), r(1, 0, 1), r(1, 1, 0)].

==

@author nicos angelopoulos
@version  0.1 2018/04/27

*/
mtx_columns_collapse( MtxIn, Cids, Cid, RowGoal, Pos, Mtx ) :-
    mtx_header_body( MtxIn, Hdr, Rows ),
    maplist( mtx_header_column_name_pos(Hdr), Cids, _Nms, Cpss ),
    % maplist( mtx_header_column_pos_nest(Hdr), Cids, _Cnms, Cpss ),
    mtx_columns_collapse_rows( Rows, Cpss, RowGoal, Vals, RedRows ),
    arg( Cpss, Hdr, _, RedHdr ),
    mtx_column_add( [RedHdr|RedRows], Pos, [Cid|Vals], Mtx ).

mtx_columns_collapse_rows( [], _Poss, _Goal, [], [] ).
mtx_columns_collapse_rows( [R|Rs], Poss, Goal, [Val|Vals], [RedR|RedRs] ) :-
    arg( Poss, R, RowSelVals, RedR ),
    call( Goal, RowSelVals, Val ),
    mtx_columns_collapse_rows( Rs, Poss, Goal, Vals, RedRs ).
