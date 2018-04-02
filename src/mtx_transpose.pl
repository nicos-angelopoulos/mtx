
:- lib( transpose_args/2 ).

%% csv_transpose( CsvF, OutF ).
%
%  Transpose a csv file.
%
% @author nicos angelopoulos
% @version  0.2 2014/4/24
% @see was csv_transpose
%
mtx_transpose( In, Out ) :-
	mtx( In, Csv ),
     transpose_args( Csv, Trans ),
	mtx( Out, Trans ).
