
:- use_module(library(csv)).  % csv:make_csv_options/3, csv:default_separator/3.

/**  mtx_options_csv( +Mopts, +File, -Copts, -Ropts ).

Separate mtx options Mopts to Csv accepted options and everything else (Ropts).

File is needed for guessing a separator value if there is not one given as an option.

==
?- mtx_options_csv( [match(false)], Copts, Ropts ).
==

@author nicos angelopoulos
@version  0.1 2018/11/12

*/

mtx_options_csv( Options, File, Copts, Ropts ) :-
    ( select_option(sep(MtxSep),Options,Options0) ->
                        mtx_sep( MtxSep, CsvSep ),
                        Options1 = [separator(CsvSep)|Options0]
                        ;     
                        csv:default_separator( File, Options, Options1 )
    ),
    select_option( match(MatchPrv), Options1, Options2, _ ),
    ( var(MatchPrv) -> Match = true; Match = MatchPrv ),
    csv:make_csv_options([match_arity(Match)|Options2], Copts, Ropts ).
