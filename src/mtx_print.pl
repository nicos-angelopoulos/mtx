
mtx_print_defaults([widths([]),pads(' ')]).

/** mtx_print(Mtx, Opts)

Prints a table of the values in Mtx.

Opts
  * pad(Pad=' ')
    pads to use between the N columns. If single atom, it is repeated N-1 times.
  * widths(Widths)
    widths to use for each column. If a single number, is used for all. 
    Default is to use the max codes length from the items in each column

Examples
==
?- 
     Mtx = [ hdr('','Queued','Running'),
             row('Throughput',0,10),
             row(v1_medium72,8,10)
             ],
     assert( p_mtx(Mtx) ).

?- p_mtx(Mtx), mtx_print( Mtx, true ).
            Queued Running
 Throughput      0      10
v1_medium72      8      10

Mtx = [hdr('', 'Queued', 'Running'), row('Throughput', 0, 10), row(v1_medium72, 8, 10)].


?- p_mtx(Mtx), mtx_print( Mtx, widths(10) ).
               Queued    Running
Throughput          0         10
1_medium72          8         10

Mtx = [hdr('', 'Queued', 'Running'), row('Throughput', 0, 10), row(v1_medium72, 8, 10)].
==

@author nicos angelopoulos
@version  0.1 2022/11/06
@see lexi_n/2 (pack(stcoics_lib))

*/

mtx_print( InMtx, Args ) :-
     mtx( InMtx, Mtx ),
     Self = mtx_print,
     options_append( Self, Args, Opts ),
     options( widths(WidOpt), Opts ),
     mtx_print_widths( WidOpt, Mtx, Widths ),
     length( Widths, NoClms ),
     options( pads(PadOpt), Opts ),
     mtx_print_pads( PadOpt, NoClms, Pads ),
     mtx_print( Mtx, NoClms, Widths, Pads ).

mtx_print_pads( [P|Ps], _NoClms, Pads ) :-
     !,
     Pads = [P|Ps].
mtx_print_pads( P, NoClms, Pads ) :-
     NoSpcs is NoClms - 1,
     findall( P, between(1,NoSpcs,_), Pads ).

mtx_print_widths( [], Mtx, Widths ) :-
     !,
     mtx_apply( Mtx, atom_length, LenMtx, has_header(false) ),
     mtx_lists( LenMtx, LenClmsL ),
     maplist( max_list, LenClmsL, Widths ).
mtx_print_widths( [W|Ws], _Mtx, Widths ) :-
     !,
     Widths = [W|Ws].
mtx_print_widths( Width, Mtx, Widths ) :-
     number( Width ),
     !,
     Mtx = [Hdr|_Rows],
     functor( Hdr, _, Ncols ),
     findall( Width, between(1,Ncols,_), Widths ).
mtx_print_widths( Width, _Mtx, _Widths ) :-
     throw( unusable_width_option(Width) ).

mtx_print( [], _, _, _ ).
mtx_print( [R|Rs], NoClms, Lens, Spcs ) :-
     mtx_print_row( NoClms, 1, R, Lens, Spcs ),
     mtx_print( Rs, NoClms, Lens, Spcs ).

mtx_print_row( 1, I, Row, [Len], _ShouldBeEmpty ) :-
     arg( I, Row, Ith ),
     !,
     lexi_n( Ith, Len, 0' , +(Print) ),
     write( Print ), nl.
mtx_print_row( NoCleft, I, Row, [Len|Lens], [Spc|Spcs] ) :-
     Rem is NoCleft - 1,
     arg( I, Row, Ith ),
     lexi_n( Ith, Len, 0' , +(Print) ),
     write( Print ), write( Spc ),
     J is I + 1,
     mtx_print_row( Rem, J, Row, Lens, Spcs ).
