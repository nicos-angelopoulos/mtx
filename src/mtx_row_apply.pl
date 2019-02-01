
mtx_row_apply_defaults( Args, Defs ) :-
    mtx_defaults( MtxOpts ),
    ( memberchk(out_is_mtx(false),Args) ->
        DefHdr = false
        ;
        DefHdr = true
    ),
    Defs = [out_is_mtx(true),out_has_header(DefHdr),on_header(false)|MtxOpts].

/**  mtx_row_apply( +Goal, +MtxIn, -Out, +Opts ).

Apply Goal to all rows of MtxIn to produce Out.<br>
If MtxIn and MtxOut are files (ground atoms), the rows are processed on-the-fly with no <br> 
intermediate data structures being created. This reduces memory usage which <br>
which used to be prohibitive when using csv_write_file/3 (that has been fixed,
but it is more memory efficient to use the specialised version).
Goal is called in user by default (use Mod:G, to overwrite this).

Please note that Out would usually be another matrix,
however, the predicate can also produce other outputs. 
You need to set _is_mtx(false)_ in this case, (note thaugh
this will also (a) change the default of _Hdr_ to _false_ and 
(b) by pass calling mtx/2 on the output).

Opts
  * in_MtxOpt(InpMtxOpt)
  any option you want to pass to the input mtx/3 call
   
  * on_header(OnH=false)
  do not apply Call on header row

  * out_has_header(Hdr=true)
  reply has header (default changes to _false_, if _IsMtx=false_)

  * out_is_mtx(IsMtx=true)
  set to false if output is not a matrix

  * out_MtxOpt(MtxOutOpt)
  any option you want to pass to the output mtx/3 call

In addition you can give any option that you want to pass to both mtx/3 calls from those
that are recognised by mtx/3 (see mtx_options_select/5). For example, _convert(true)_
will be passed to both mtx/3 calls, whereas _in_convert(true)_ will only be pased to the 
input call.

==
?- mtx( data('mtcars.csv'), MtC ), mtx_row_apply( =, MtC, MtA, [] ).
MtC = MtA, MtA = [row(mpg, cyl, disp, hp, drat, wt, qsec, vs, am, gear, carb), row('21.0', ...), ... ].

?- mtx( data('mtcars.csv'), MtC ), mtx_row_apply( =, MtC, MtA, out_has_header(false) ).
MtC = [row(mpg, cyl, disp, hp, drat, wt, qsec, vs, am, gear, carb), row(21.0, ...), ... ],
MtA = [row('21.0', '6.0', '160.0', '110.0', '3.9', '2.62', '16.46', '0.0', '1.0', '4.0', '4.0'), ...].

?- assert((sum_args(Term,Sum) :- Term=..[_|Args], sumlist(Args,Sum))).
?- sum_args( a(1,2,3), Sum ).
Sum = 6.
?- mtx_row_apply(sum_args,data('mtcars.csv'),Sums,[convert(true),out_is_mtx(false)]).
Sums = [328.97999999999996, 329.79499999999996, 259.58, ... ].

?- tmp_file( mtcars_clone, TmpF ), mtx_row_apply( =, data('mtcars.csv', TmpF, [] ).
==

On *nix only:
==
?- library(by_unix).
?- tmp_file( mtcars_clone, TmpF ), mtx_row_apply( =, data('mtcars.csv'), TmpF, [] ), @ head( -2, TmpF ).
mpg,cyl,disp,hp,drat,wt,qsec,vs,am,gear,carb
21.0,6.0,160.0,110.0,3.9,2.62,16.46,0.0,1.0,4.0,4.0
TmpF = '/tmp/swipl_mtcars_clone_21824_1'.
===

@author nicos angelopoulos
@version  0.1 2018/6/5
@version  0.2 2019/2/1, added support for non Mtx outputs: out_has_header() and out_is_mtx(). use mtx_otpions_select/5
@see mtx_bi_opts/2, mtx_options_select/5.

*/
mtx_row_apply( Goal, MtxIn, MtxOut, Args ) :-
    mtx_type( MtxIn, on_file(File) ),
    ground( MtxOut ),
    MtxOut \= [_|_],  % fixme: should there be a new type: to_file(File)... ?
    !,
    options_append( mtx_row_apply, Args, Opts ),
    mtx_row_apply_files( Goal, File, MtxOut, Opts ).
mtx_row_apply( GoalPrv, MtxIn, MtxOut, Args ) :-    % the proto implemenation
    options_append( mtx_row_apply, Args, AllOpts ),
    mtx_options_select( AllOpts, in, InMtxOpts, NonInOpts ),
    mtx( MtxIn, Mtx, InMtxOpts ),
    mtx_options_select( NonInOpts, out, OutMtxOpts, Opts ),
    options( on_header(OnH), Opts ),
    ( GoalPrv = _:_ -> Goal = GoalPrv ; Goal= user:GoalPrv ),
    mtx_row_apply( OnH, Goal, Mtx, MtxForOutPrv, Opts ),
    options( out_has_header(OutHasHdr), Opts ),
    mtx_row_out_header( OutHasHdr, MtxForOutPrv, MtxForOut ),
    options( out_is_mtx(OutIsMtx), Opts ),
    mtx_row_out_mtx( OutIsMtx, MtxOut, MtxForOut, OutMtxOpts ).

mtx_row_out_mtx( true, MtxOut, MtxForOut, Opts ) :-
    mtx( MtxOut, MtxForOut, Opts ).
mtx_row_out_mtx( false, Out, Out, _Opts ).

mtx_row_out_header( true, MtxForOut, MtxForOut ).
mtx_row_out_header( false, [_|MtxForOut], MtxForOut ).

mtx_row_apply( true, Goal, [Hdr|Rows], [NewHdr|NewRows], Opts ) :-
    call( Goal, Hdr, NewHdr ),
    mtx_by_row_apply( Rows, Goal, NewRows, Opts ).
mtx_row_apply( false, Goal, [Hdr|Rows], [Hdr|NewRows], Opts ) :-
    mtx_by_row_apply( Rows, Goal, NewRows, Opts ).

mtx_by_row_apply( [], _Goal, [], _Opts ).
mtx_by_row_apply( [R|Rs], Goal, [N|Ns], Opts ) :-
    call( Goal, R, N ),
    mtx_by_row_apply( Rs, Goal, Ns, Opts ).

mtx_row_apply_files( Goal, Fin, Fou, Opts ) :-
    mtx_bi_opts( Opts, Fin, Fou, InOpts, OuOpts ),
    csv_options( InComp, InOpts ),
    csv_options( OutComp, OuOpts ),
    setup_call_cleanup( 
        ( open(Fin,read,InStream,[]),    % use Opts ?
          open(Fou,write,OutStream,[])
        ),
        ( csv_read_row(InStream, Row0, InComp),
          mtx_row_apply_streams( Row0, Goal, InStream, InComp, OutStream, OutComp )
        ),
        ( close(InStream),
          close(OutStream)
        ) 
    ).


/*
mtx_bi_opts( InOpts, Opts ) :-
    ( select_option(sep(InMtxSep),Opts,_Opts0) ->
            mtx_sep( InMtxSep, InSep ),
            InOpts1 = [separator(InSep)],
            ( select_option(out_sep(OutMtxSep),Opts) ->
                mtx_sep( OutMtxSep, OutSep ),
                OutOpts1 = [separator(OutSep)]
                ;
                OutOpts1 = [separator(InSep)]
            )
            ;
            csv:default_separator( Fin, [], InOpts1 )
            ( 
            csv:default_separator( Fou, [], OutOpts1 )
    ),
    select_option( match(InMatch), Opts, _ ),
    ( memberchk(out_match(OutMatch),Opts) -> true; OutMatch = InMatch ),
    InOpts2 = [match_arity(InMatch)|InOpts1],
    OutOpts2 = [match_arity(OutMatch)|OutOpts1],
    csv_options( InCompOpts, InOpts2 ),
    csv_options( OutCompOpts, OutOpts2 ),
*/

mtx_row_apply_streams( end_of_file, _Goal, _InStream, _InCompOpts, _OutStream, _OutCompOpts ) :- !.
mtx_row_apply_streams( Row, Goal, InStream, InCompOpts, OutStream, OutCompOpts ) :-
    call( Goal, Row, New ),
    csv:csv_write_row( OutStream, OutCompOpts, New ),  % fixeme: should be in interface of library(csv)
    csv_read_row( InStream, Next, InCompOpts ),
    mtx_row_apply_streams( Next, Goal, InStream, InCompOpts, OutStream, OutCompOpts ).
