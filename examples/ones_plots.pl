
:- use_module( library(mtx) ).

/** ones_plots.

Plots the frequencies of ones in the data(binary.csv) dataset in two plots.
One with a dividing line at frequency 4 and one with 3 colours for 
3 distinct population groups.

@author nicos angelopoulos
@version  0.1 2017/1/17

*/
ones_plots :-
    ones_plot_pop_line(4),
    ones_plot_pop_breaks([2,4]).

ones_plot_pop_line(At) :-
    mtx( pack('mtx/data/binary.csv'), Bin ),
    GT = theme('axis.text.x' = element_text(angle = 45, vjust = 1, hjust=1)),
    MainLbl = 'gene mutation counts',
    Opts = [labels(columns,counts,MainLbl),gg_terms(GT),pop_line(At)],
    % mtx_value_plot( Bin, 1, [output(pdf(+NoMpdf,width=14))|Opts] ),
    mtx_value_plot( Bin, 1, Opts ).

ones_plot_pop_breaks(Brks) :-
    mtx( pack('mtx/data/binary.csv'), Bin ),
    GT = theme('axis.text.x' = element_text(angle = 45, vjust = 1, hjust=1)),
    MainLbl = 'gene mutation counts',
    Opts = [    labels(columns,counts,MainLbl),
                gg_terms(GT),level_colours_title('count_groups'),
                pop_breaks(Brks)
                ],
    % mtx_value_plot( Bin, 1, [output(pdf(+NoMpdf,width=14))|Opts] ),
    mtx_value_plot( Bin, 1, Opts ).
