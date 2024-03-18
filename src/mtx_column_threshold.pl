
:- lib(compare_multi_ops_list/2).

%% mtx_column_threshold( +Csv, +Clm, +Val, +Dir, -Sel ).
%% mtx_column_threshold( +Csv, +Clm, +Val, +Dir, -Sel, -Rej ).
%% mtx_column_threshold( +Csv, -Sel, +Opts ).
%
%  Cuts rows off Csv by thresholding Clm over or below Val according to Dir.
%  The resulting csv is in Sel.
%  When Dir is < predicate keeps values below the threshold and Dir > keeps values
%  (strictly) above the threshold. Note that the Clm_th value of each row 
%  is also tested for being numeric. This makes sure we dont test against 
%  non-numerics. Rows that have non-numeric Clm_th values are not in Sel.
%  Clm is fed through mtx_header_column_pos/3 and can be an argument of
%  the first term in Csv (the header) or the corresponding number. 
%  Csv and Sel are passed through mtx/2, so the can be list of row terms or csv filenames.
%
%  The Opts version, only fires if the following Option is present:
%  * mtx_cuttoff(Clm,Val,Dir)
%    with the same semantics as the /5 version. (Dir == false, means do not apply threhold.)
%
%  If the option does not exist, the predicate succeeds with =|Sel = Csv|=.
%
%  The predicate assumes Csv is of the form [Hdr|Rows] and includes Hdr to result.
%  If you want to call on non headers Rows then with numeric NumClm you can call:
%  ==
%  ?- mtx_column_threshold( [_|Rows], NumClm, Val, Dir, [_|OutRows] ).
%  ==
%
%  Examples
%  ==
%  ?- assert( csv([row(a,b,c),row(1,2,3),row(1,4,5),row(3,6,7),row('',8,9),row(3,b,10)]) ).
%  ?- csv( Csv ), mtx_column_threshold( Csv, a, 2, <, Out ).
%     Out = [row(a, b, c), row(1, 2, 3), row(1, 4, 5)].
%  ?- csv( Csv ), mtx_column_threshold( Csv, 1, 2, >, Out ).
%     Out = [row(a, b, c), row(3, 6, 7), row(3, b, 10)].
%  ==
%
% @author nicos angelopoulos
% @version 0.1, 2014/1/29
% @tbd was csv_threshold/5
% @tbd fixme: change multi_comparison to stoics_lib:op_compare/3 
%
mtx_column_threshold( CsvIn, Clm, Val, Dir, Out ) :-
	mtx( CsvIn, Csv ),
	Csv = [Hdr|Rows],
	mtx:mtx_header_column_pos( Hdr, Clm, Pos ),
	compare_multi_ops_list( Dir, Dirs ),
	include( row_threshold(Pos,Val,Dirs), Rows, OutRows ),
	mtx( Out, [Hdr|OutRows] ).

mtx_column_threshold( CsvIn, Clm, Val, Dir, Sel, Rej ) :-
	mtx( CsvIn, Csv ),
	Csv = [Hdr|Rows],
	mtx:mtx_header_column_pos( Hdr, Clm, Pos ),
	compare_multi_ops_list( Dir, Dirs ),
	partition( row_threshold(Pos,Val,Dirs), Rows, SelRows, RejRows ),
	mtx( Sel, [Hdr|SelRows] ),
	mtx( Rej, [Hdr|RejRows] ).

mtx_column_threshold( CsvIn, Sel, OptS ) :-
     en_list( OptS, Opts ),
     % fixme: add a way to return the Rej-ected rows
     ( (memberchk(mtx_cutoff(Clm,Val,Dir), Opts), Dir \== false) -> 
          mtx_column_threshold( CsvIn, Clm, Val, Dir, Sel )
          ;
          CsvIn = Sel
     ).

row_threshold( Pos, Val, Dirs, Row ) :-
	arg( Pos, Row, This ),
	number( This ),
	compare( Dir, This, Val ),
	memberchk( Dir, Dirs ).
