
:- use_module( library(mtx) ).

/** mtx_columns_kv( +Csv, +Cid1, +Cid2, -KVs, -Cnms, -Cpos ).

Create a KV pairs list from mtx/1:Mtx and identifiers for two of its columns:
Cid1 and Cid2. Cnms is Cnm1-Cnm2 and Cpos is Cpos1-Cpos2 as returned by 
mtx_header_column_name_pos/4. KVs have all the pair values of Cid1 and Cid2.

==
 ?- mtx_data( mtcars, Mt ), mtx_columns_kv( Mt, mpg, hp, KVs, _, _ ).
 Mt = [row(mpg, cyl, disp,..)|...],
 KVs = [21.0-110.0, 21.0-110.0, 22.8-93.0, 21.4-110.0, 18.7-175.0, 18.1-105.0, ... - ...|...].
==
 
 @tbd allow for Clm2 to be a list of column ids?

*/

mtx_columns_kv( MtxIn, Cid1, Cid2, KVs, Cnms, Cposs ) :-
	mtx( MtxIn, Mtx ),
	mtx_header_body( Mtx, Hdr, Rows ),
	mtx_header_column_name_pos( Hdr, Cid1, Cnm1, Cpos1 ),
	mtx_header_column_name_pos( Hdr, Cid2, Cnm2, Cpos2 ),
	Cnms  = Cnm1-Cnm2,
	Cposs = Cpos1-Cpos2,
	findall( K-V, (member(Row,Rows),arg(Cpos1,Row,K),arg(Cpos2,Row,V)), KVs ).
