
:- lib( transpose_args/2 ).

%% mtx_transpose( +Mtx, -Trans ).
%
%  Transpose a matrix. Both Mtx and Trans are passed through mtx/2.
%
%
% @author nicos angelopoulos
% @version  0.2 2014/4/24
% @version  0.3 2020/3/17,  docs update
% @see mtx/2
% @see was csv_transpose/2
%
mtx_transpose( In, Out ) :-
    mtx( In, Csv ),
    transpose_args( Csv, Trans ),
    mtx( Out, Trans ).
