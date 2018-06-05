
/**  mtx_bi_opts( +BiOpts, +MtxIn, +MtxOut, -InOpts, -OutOpts ).

Standarise options when both an input and output matrices are needed.<br>
If MtxIn or MtxOut map to a file matrix, then default separators are via csv:default_separator/3.

Opts
  * match_in(OutMatch)
     to define match option that is specific to input (overrides match/1)

  * match_out(OutMatch)
     to define match option that is specific to ouput (overrides match/1)

  * sep_in(InSep)
     to define sep option that is input specific (overrides sep/1)

  * sep_out(OutSep)
     to define sep option that is output specific (overrides sep/1)

==
?- mtx_bi_opts( [], true.csv, out.csv, Ins, Outs ).
min([])-sin([])-mou([])-sou([sep(44)])
Ins = [],
Outs = [sep(44)].

==

@author nicos angelopoulos
@version  0.1 2018/6/5

*/
mtx_bi_opts( All, MtxIn, MtxOut, Ipts, Opts ) :-
    % mtx_defaults( Defs ),
    % append( Bpts, Defs, All ),
    ( catch(options(match(MatchOpt),All,rem_opts(All0)),_,fail) -> Match=[match(MatchOpt)]; All0=All, Match=[] ),
    ( catch(options(match_in(MinOpt),All0,rem_opts(All1)),_,fail) -> 
        Min = [match(MinOpt)]
        ;
        All1 = All0,
        Min = Match
    ),
    ( catch(options(match_out(MouOpt),All1,rem_opts(All2)),_,fail) ->
        Mou = [match(MouOpt)]
        ;
        All2 = All1,
        Mou = Match
    ),
    ( catch(options(sep(SepOpt),All2,rem_opts(All3)),_,fail) -> Sep=[sep(SepOpt)] ; All2 = All3, Sep = [] ),
    ( catch(options(sep_in(SinOpt),All3,rem_opts(All4)),_,fail) -> 
        Sin = [sep(SinOpt)]
        ;
        All4 = All3,
        ( ( mtx_type(MtxIn,on_file(FromFile)),csv:default_separator(FromFile,[],DefSepOpts),
                memberchk(separator(SepOpt),DefSepOpts) 
              ) ->
                Sin = [sep(SepOpt)]
                ;
                Sin = Sep
        )
    ),
    ( catch(options(sep_out(SouOpt),All4,rem_opts(All5)),_,fail) -> 
        Sou = [sep(SouOpt)]
        ;
        All5 = All4,
       ( ( ground(MtxOut),csv:default_separator(MtxOut,[],DefOutSepOpts),
                memberchk(separator(SepOpt),DefOutSepOpts)) ->
                % true
                Sou = [sep(SepOpt)]
                ;
                Sou = Sep
        )
    ),
    flatten( [Min,Sin|All5], Ipts ),
    flatten( [Mou,Sou|All5], Opts ).
