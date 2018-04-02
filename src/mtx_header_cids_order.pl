/** mtx_header_cids_order( +Hdr, +Cids, -Order ).  

    Order is the order set of column positions corresponding to Cids in Hdr.

==
?- mtx_data( mtcars, Mt ), mtx_header( Mt, Hdr ), 
   mtx_header_cids_order( Hdr, [drat,cyl], Order ).
	
Mt = ...,
Hdr = row(mpg, cyl, disp, hp, drat, wt, qsec, vs, am, gear, carb),
Order = [2, 5].

==

*/
mtx_header_cids_order( Hdr, Cids, Order ) :-
	maplist( mtx_header_column_name_pos(Hdr), Cids, _Cnms, Cposs ),
	sort( Cposs, Order ).
