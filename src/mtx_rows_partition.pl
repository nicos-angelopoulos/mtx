
mtx_rows_partition_defaults( [has_header(true),apply_on(whole)] ).  
    % fixme, use global default for has_header/1 ?

/** mtx_rows_partition( +Mtx, +Goal, -Incl, -Excl, +Opts ).

Partition matrix Mtx by calling Goal on each row of the matrix.

If Mtx, Incl and Excl are ground and non-lists are taken to be files to read/write upon<br>
in which case an optimised version is used, that does not read the whole file<br>
into memory but processes each line as it is read. In this case Incl and Excl 
can be the special atom false which will indicated the specified channel is 
not required.

Opts 
  * has_header(HasH=true)
    If true, first line is removed before partitioning and added to both Incl and Excl

  * apply_on(AppOn=whole)
    which part of row to use: *whole*, _head_ or _body_

==
?- assert( (arg_val(N,Val,Row) :- arg(N,Row,Val)) ).
?- mtx_data( mtcars, Mtcars ),
   mtx_rows_partition( Mtcars, arg_val(1,21.0), Incl, Excl, true ), 
   length( Excl, Nxcl ), maplist( writeln, Incl ), write( xLen:Nxcl ), nl, fail.

row(mpg,cyl,disp,hp,drat,wt,qsec,vs,am,gear,carb)
row(21.0,6.0,160.0,110.0,3.9,2.62,16.46,0.0,1.0,4.0,4.0)
row(21.0,6.0,160.0,110.0,3.9,2.875,17.02,0.0,1.0,4.0,4.0)
xLen:31
==

@author  nicos angelopoulos
@version 0.1 2016/2/16
@version 0.2 2018/3/23,   added optmised version for when all io is on files
@see     mtx_header_body/5  (has_header(HasH))

*/
mtx_rows_partition( MtxIn, Goal, Incl, Excl, Args ) :-
    ground(MtxIn), 
    MtxIn \= [_|_],
    ground( Incl ),
    ground( Excl ),
    !,
    mtx_rows_partition_files( MtxIn, Goal, Incl, Excl, Args ).

mtx_rows_partition( MtxIn, Goal, Incl, Excl, Args ) :-
	options_append( mtx_rows_partition, Args, Opts ),
	mtx_header_body( MtxIn, Header, Mtx, HasH, Opts ),
	options( apply_on(Aon), Opts ),
	partition( mtx_row_call(Aon,Goal), Mtx, IncRows, ExclRows ),
	maplist( mtx_has_header_add(HasH,Header), [IncRows,ExclRows], [Incl,Excl] ).

mtx_row_call( whole, Goal, Row ) :-
	goal_expression( Row, Goal, Call ),
	call( Call ).
mtx_row_call( body, Goal, Row ) :-
	Row =.. [Rn,_|Rargs],
	Red =.. [Rn|Rargs],
	goal_expression( Red, Goal, Call ),
	call( Call ).
mtx_row_call( head, Goal, Row ) :-
	arg( 1, Row, Arg ),
	goal_expression( Arg, Goal, Call ),
	call( Call ).

mtx_rows_partition_files( MtxIn, Goal, Incl, Excl, Args ) :-
    maplist( mtx_rows_partition_file_open, [Incl,Excl], [Io,Eo] ),
    options_append( mtx_rows_partition, Args, Opts ),
    options( [has_header(HasH),apply_on(Aon)], Opts, rem_opts(RemOpts) ),
    csv_options( CsvOpts, RemOpts ),
    setup_call_cleanup(
       open(MtxIn, read, In),
       mtx_rows_partition_streams( HasH, Aon, CsvOpts, RemOpts, In, Goal, Io, Eo ),
       % forall(data(C1,C2,C3), csv_write_stream(Out, [row(C1,C2,C3)], [])),
       (close(In),maplist(mtx_rows_partition_file_close,[Io,Eo])) ).

mtx_rows_partition_streams( true, Aon, Comp, Opts, In, Goal, Io, Eo ) :-
    !,
    csv_read_row( In, Hdr, Comp ),
    mtx_row_partition_csv_write_row( Io, Hdr, Opts ),
    mtx_row_partition_csv_write_row( Eo, Hdr, Opts ),
    csv_read_row( In, Row, Comp ),
    mtx_rows_partition_streams_row( Row, Aon, Comp, Opts, In, Goal, 1, Io, Eo ).

mtx_rows_partition_streams_row( end_of_file, _Aon, _Comp, _Opts, _In, _Goal, _I, _Io, _Eo ) :- !.
mtx_rows_partition_streams_row( Row, Aon, Comp, Opts, In, Goal, I, Io, Eo ) :-
    debug( mtx_rows_partition, 'Read row: ~d', [I] ),
    ( mtx_row_call(Aon,Goal,Row) -> 
        mtx_row_partition_csv_write_row( Io, Row, Opts )
        ;
        mtx_row_partition_csv_write_row( Eo, Row, Opts )
    ),
    csv_read_row( In, Nxt, Comp ),
    J is I + 1,
    mtx_rows_partition_streams_row( Nxt, Aon, Comp, Opts, In, Goal, J, Io, Eo ).


mtx_row_partition_csv_write_row( false, _Row, _CsvOpts ) :- !.
mtx_row_partition_csv_write_row( Stream, Row, CsvOpts ) :-
    csv_write_stream( Stream, [Row], CsvOpts ).

mtx_rows_partition_file_close( false ) :- !.
mtx_rows_partition_file_close( Stream) :- close( Stream ).

mtx_rows_partition_file_open( false, false ) :- !.
mtx_rows_partition_file_open( File, Stream ) :-
    open( File, write, Stream ).
