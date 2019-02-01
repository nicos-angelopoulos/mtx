
mtx_options_select_defaults( [match_generic(true)] ).

/**  mtx_options_select( +InOpts, +Pfx, -MtxOpts, -RemOpts ).
     mtx_options_select( +InOpts, +Pfx, -MtxOpts, -RemOpts, +Opts ).

Helper predicate that separates possibly prefixed and non prefixed 
options that match to mtx/3 options from Opts producing MtxOpts and RemOpts.
RemOpts has anything that did not match.

Default values for mtx/3 are fished out at run-time.

Opts
  * match_generic(Gen=true)
  matches generic version if prefixed version is not there

==
?- mtx_options_select( [convert(false)], in, Ms, Rs, [] ).
Ms = [convert(false)],
Rs = [].

?- mtx_options_select( [in_convert(false)], in, Ms, Rs, [] ).
Ms = [convert(false)],
Rs = [].

?- mtx_options_select( [convert(false)], in, Ms, Rs, [match_generic(false)] ).
Ms = [],
Rs = [convert(false)].

==

This could possibly be folded into mtx/3 with prefix(Pfx) and rem_opts(RemOpts),
however, it is handy to clean the options before the output call. So the current model is:

== 
mtx_lib_pred( MtxIn, MtxOut, Args ) :-
    options_append( mtx_lib_pred, Args, AllOpts ),
    mtx_options_select( AllOpts, in, InMtxOpts, NonInOpts ),
    mtx( MtxIn, Mtx, InMtxOpts ),
    mtx_options_select( NonInOpts, out, OutMtxOpts, Opts ),
    ...
    mtx( MtxOut, MtxForOut, Opts ).
==

@author nicos angelopoulos
@version  0.1 2019/2/1
@see mtx_row_apply/4 for a usage example

*/
mtx_options_select( InOpts, Pfx, MtxOpts, RemOpts ) :-
    mtx_options_select( InOpts, Pfx, MtxOpts, RemOpts, [] ).
    
mtx_options_select( InOpts, Pfx, MtxOpts, RemOpts, Args ) :-
    options_append( mtx_options_select, Args, Opts ),
    mtx_defaults( MtxDefs ),
    options( match_generic(Gen), Opts ),
    mtx_options_select_pfx( MtxDefs, Pfx, Gen, InOpts, MtxOpts, RemOpts ).

mtx_options_select_pfx( [], _Pfx, _Gen, RemOpts, [], RemOpts ).
mtx_options_select_pfx( [DefMtxOpt|DefMtxOpts], Pfx, Gen, InOpts, MtxOpts, RemOpts ) :-
    DefMtxOpt =.. [OptNm|OptArgs],
    length( OptArgs, OptArgsLen ),
    length( OptFreshArgs, OptArgsLen ),
    atomic_list_concat( [Pfx,OptNm], '_', PfxNm ),
    MtxMatchOpt =.. [PfxNm|OptFreshArgs],
    select_all( InOpts, MtxMatchOpt, MtxMatchedOpts, MtxNonMatchedOpts ),
    mtx_options_select_pfx_generic( Gen, OptNm, OptArgsLen, MtxMatchedOpts, MtxNonMatchedOpts, MtxGenNonMatchedOpts, MtxOpts, TMtxOpts ),
    mtx_options_select_pfx( DefMtxOpts, Pfx, Gen, MtxGenNonMatchedOpts, TMtxOpts, RemOpts ).

mtx_options_select_pfx_generic( true, OptNm, Len, MtxMatchedOpts, MtxNonMatchedOpts, GenNonMatchedOpts, MtxOpts, TMtxOpts ) :-
    length( OptFreshArgs, Len ),
    GenMatchOpt =.. [OptNm|OptFreshArgs],
    select_all( MtxNonMatchedOpts, GenMatchOpt, GenMatchedOpts, GenNonMatchedOpts ),
    ( MtxMatchedOpts = [MatchedOpt|_] ->
        MatchedOpt =.. [_PfxOptNm|MatchedArgs],
        RnmMatchedOpt =.. [OptNm|MatchedArgs],
        MtxOpts = [RnmMatchedOpt|TMtxOpts]
        ;
        ( GenMatchedOpts = [MatchedOpt|_] ->
            MtxOpts = [MatchedOpt|TMtxOpts]
            ;
            TMtxOpts = MtxOpts
        )
    ).
mtx_options_select_pfx_generic( false, OptNm, _Len, MtxMatchedOpts, MtxNonMatchedOpts, MtxNonMatchedOpts, MtxOpts, TMtxOpts ) :-
    ( MtxMatchedOpts = [MatchedOpt|_] ->
        MatchedOpt =.. [_PfxOptNm|MatchedArgs],
        RnmMatchedOpt =.. [OptNm|MatchedArgs],
        MtxOpts = [RnmMatchedOpt|TMtxOpts]
        ;
        TMtxOpts = MtxOpts
    ).
