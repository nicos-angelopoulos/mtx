/**  mtx_read_stream( +Stream, -Data, +CsvOpts ).
     mtx_read_stream( +Row0, +Stream, -Data, CsvOpts ).

Read rows from a stream.

This should really be in library(csv).

CsvOpts are Csv specificially compiled options.

==
?- mtx_read_stream( S, D, O ).
==

@author nicos angelopoulos
@version  0.1 2018/11/12

*/
mtx_read_stream( Stream, Data, Copts ) :-
    csv_read_row( Stream, Row, Copts ),
    mtx_read_stream( Row, Stream, Data, Copts ).

mtx_read_stream( end_of_file, _Stream, Data, _Copts ) :-
    !,
    Data = [].
mtx_read_stream( Row, Stream, Data, Copts ) :-
    csv_read_row( Stream, Row1, Copts ),
    Data = [Row|Data1],
    mtx_read_stream( Row1, Stream, Data1, Copts ).
