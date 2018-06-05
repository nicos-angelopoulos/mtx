
mtx_row_apply_defaults( [on_header(false)|MtxOpts] ) :-
    mtx_defaults( MtxOpts ).

/**  mtx_row_apply( +Goal, +MtxIn, -MtxOut, +Opts ).

Apply Goal to all rows of MtxIn to produce MtxOut.<br>
If MtxIn and MtxOut are files, the rows are processed on-the-fly with no <br> 
intermediate data structures being created. This reduces memory usage which <br>
which can be prohibitive when using csv_write_file/3.

Opts
  * on_header(OnH=false)
     Do not apply 
==
?- mtx( '../data/mtcars.csv', MtC ), mtx_row_apply( =, MtC, MtA, [] ).
MtC = MtA, MtA = [row(mpg, cyl, disp, hp, drat, wt, qsec, vs, am, gear, carb), row(21.0, 6.0, 160.0, 110.0, 3.9, 2.62, 16.46, 0.0, 1.0, 4.0, 4.0), row(21.0, 6.0, 160.0, 110.0, 3.9, 2.875, 17.02, 0.0, 1.0, 4.0, 4.0), row(22.8, 4.0, 108.0, 93.0, 3.85, 2.32, 18.61, 1.0, 1.0, 4.0, 1.0), row(21.4, 6.0, 258.0, 110.0, 3.08, 3.215, 19.44, 1.0, 0.0, 3.0, 1.0), row(18.7, 8.0, 360.0, 175.0, 3.15, 3.44, 17.02, 0.0, 0.0, 3.0, 2.0), row(18.1, 6.0, 225.0, 105.0, 2.76, 3.46, 20.22, 1.0, 0.0, 3.0, 1.0), row(14.3, 8.0, 360.0, 245.0, 3.21, 3.57, 15.84, 0.0, 0.0, 3.0, 4.0), row(..., ..., ..., ..., ..., ..., ..., ..., ..., ..., ...)|...].

?- tmp_file( mtcars_clone, TmpF ), mtx_row_apply( =, '../data/mtcars.csv', TmpF, [] ).
==

@author nicos angelopoulos
@version  0.1 2018/6/5
@ see mtx_bi_opts/2

*/
mtx_row_apply( Goal, MtxIn, MtxOut, Args ) :-
    mtx_type( MtxIn, on_file(File) ),
    ground( MtxOut ),
    MtxOut \= [_|_],  % fixme: should there be a new type: to_file(File)... ?
    !,
    options_append( mtx_row_apply, Args, Opts ),
    mtx_row_apply_files( Goal, File, MtxOut, Opts ).
mtx_row_apply( Goal, MtxIn, MtxOut, Args ) :-    % the proto implemenation
    options_append( mtx_row_apply, Args, Opts ),
    mtx( MtxIn, Mtx, Opts ),
    options( on_header(OnH), Opts ),
    mtx_row_apply( OnH, Goal, Mtx, MtxForOut, Opts ),
    option_out( out_match, match, Opts, Opts1 ),
    option_out( out_sep, sep, Opts1, Opts2 ),
    mtx( MtxOut, MtxForOut, Opts2 ).

option_out( OptName, RealName, Opts1, Opts2 ) :-
    Opt =.. [OptName,OptArg],
    select( Opt, Opts1, Opts0 ),
    !,
    Rpt =.. [RealName,OptArg],
    Opts2 = [Rpt|Opts0].
option_out( _OptName, _RealName, Opts, Opts ).

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
    csv_write_row( OutStream, New, OutCompOpts ),
    csv_read_row( InStream, Next, InCompOpts ),
    mtx_row_apply_streams( Next, Goal, InStream, InCompOpts, OutStream, OutCompOpts ).

% fixme: this should be in SWI's csv.pl
% 
csv_write_row( Stream, Row, CompOpts ) :-
    phrase(csv:emit_csv([Row], CompOpts), String),
    format(Stream, '~s', [String]).
