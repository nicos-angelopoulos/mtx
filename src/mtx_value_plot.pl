
:- lib(promise(mlu_frequency_plot/2,mlu)).

mtx_value_plot_defaults( [sort(true),pop_line(false)] ).

/** mtx_value_plot( +Mtx, +Value, +Opts ).

Plot the occurrences of a value in the columns of a matrix via mlu's mlu_frequency_plot/2.

Requires pack(mlu).

Opts 
  * sort(Sort=true)
     overrides default for mlu_frequency_plot/2

==
?- [pack(mtx/examples/ones_plots)].  ones_plots.
% displays 2 frequency plots one with a vertical separator line and
% the other with 3 frequency groups distinguished by colour.
==

@author nicos angelopoulos
@version  0.1 2017/1/13
@see mtx_value_column_frequencies/3
@see mlu_frequency_plot/2

*/
mtx_value_plot( Inx, Value, Args ) :-
    mtx_value_column_frequencies( Inx, Value, CntFreqs ),
    options_append( mtx_value_plot, Args, Opts ),
    % mlu:mlu_frequency_plot( CntFreqs, Opts ).  % "mlu:" for error when pack(mlu) is not loaded/present
    mlu_frequency_plot( CntFreqs, Opts ).  % "mlu:" for error when pack(mlu) is not loaded/present
