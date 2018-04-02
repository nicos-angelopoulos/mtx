
mtx_prolog_defaults( [auto_pname(Apname)|_], Defs ) :-
	Defs = [predicate_name(Apname), % file_stem(Astem),
	        header_remove(false),consult(save)
	       ].


/** mtx_prolog( +Mtx, ?Prolog, -Opts ).

Write/convert an Mtx to a prolog file.

Prolog can be given, in which case it is considered to be a full filename.
If Prolog is free, it instantiates to the filename of the file the facts
were dumped on, or the Rows themselves if consult(consult) was in Opts.

In what follows, Stem is the first of: 
   * the stem of filename Mtx (if Mtx is atomic with extension),
   * Mtx if this is atomic
   * Stem = row for Pname, and Stem = mtx for Fstem, else

Opts 
  * consult(Cons=save)
    should the facts be consulted (consult), saved (save) or both ?

  * file_stem(Fstem=stem(Mtx))
    stem for filename, .pl is added. The default is the stem of Mtx.

  * header_remove(Rmv=false)
    whether to ignore the first row, else true, or pname for header fact

  * predicate_name(Pname=stem(basename(Mtx)))
    predicate name for facts
 
  * rows_transform(Rtrans)
    if present the predicate is called on the input rows to transform them
    before they converted to facts. Use Rtrans = maplist(Pred) if you want
    to use maplist on each row for Pred rather than the default of calling
    Pred with RowsIn and RowsOut

@author nicos angelopoulos
@version  0.1 2015/3/20

*/
mtx_prolog( Mtx, Prolog, ArgS ) :-	
	mtx_pname_stem( Mtx, APname, _AStem ),
	en_list( ArgS, Args ),
	debug( _, 'Args: ~w', [Args] ),
	options_append( mtx_prolog, [auto_pname(APname)|Args], Opts ),
	debug( _, 'Opts: ~w', [Opts] ),
	mtx( Mtx, MtxRows, [ret_mtx_input(Ret)|Opts] ),
	debug( _, 'Read from mtx: ~w', Ret ),
	options( header_remove(Hrmv), Opts ),
	header_remove_option( Hrmv, MtxRows, RowsPrv ),
	( memberchk(rows_transform(Rtrans),Opts) ->
		rows_transform( Rtrans, RowsPrv, Rows )
		;
		RowsPrv = Rows
	),
	options( predicate_name(Pname), Opts ),
	maplist( mtx_pname_row(Pname), Rows, Trans ),
	mtx_prolog_out_stem( Prolog, Ret, Fstem, Opts ),

	options( consult(Cons), Opts ),
	options_return( ret_pname(Pname), Opts ),
	mtx_prolog_consult( Cons, Fstem, Trans, Prolog ).


mtx_prolog_out_stem( Prolog, _Ret, Fstem, _Opts ) :-
	ground( Prolog ),
	!,
	Fstem = mtx_prolog_out.
mtx_prolog_out_stem( _Prolog, _Ret, Fstem, Opts ) :-
	memberchk( file_stem(Fstem), Opts ),
	!.
mtx_prolog_out_stem( _Prolog, Ret, Fstem, _Opts ) :-
	ground( Ret ),
	file_name_extension( Fstem, _, Ret ),
	!.
mtx_prolog_out_stem( _Prolog, _Ret, Fstem, _Opts ) :-
	Fstem = mtx_prolog_out.

header_remove_option( false, Rows, Rows ).
header_remove_option( true, [_|Rows], Rows ).

rows_transform( maplist(Rtrans), RowsIn, RowsOut ) :-
	!,
	maplist( Rtrans, RowsIn, RowsOut ).
rows_transform( Rtrans, RowsIn, RowsOut ) :-
	call( Rtrans, RowsIn, RowsOut ).

mtx_pname_row( Pname, Row, New ) :-
	Row =.. [_|Args],
	New =.. [Pname|Args].

mtx_prolog_consult( both, Stem, Out, File ) :-
	mtx_prolog_consult_save( Stem, Out, File ),
	consult( File ).
mtx_prolog_consult( save, Stem, Out, File ) :-
	mtx_prolog_consult_save( Stem, Out, File ).
mtx_prolog_consult( consult, _Stem, Out, Out ) :-
	maplist( assert, Out ).

mtx_prolog_consult_save( _Stem, Out, File ) :-
	ground( File ),
	!,
	mtx_prolog_consult_save_file( File, Out ).
mtx_prolog_consult_save( Stem, Rows, File ) :-
	file_name_extension( Stem, pl, File ),
	mtx_prolog_consult_save_file( File, Rows ).

mtx_prolog_consult_save_file( File, Rows ) :-
	open( File, write, Out ),
     maplist( portray_clause(Out), Rows ),
     close( Out ).

% mtx_prolog_consult_fact( Row ) :-
	% assert( Row ).

mtx_prolog_header( true, [_|Out], Out ) :- !.
mtx_prolog_header( false, Out, Out ) :- !.
mtx_prolog_header( Oth, [H|T], [N|T] ) :-
	H =.. [_|HArgs],
	N =.. [Oth|HArgs].

mtx_pname_stem( Mtx, Pname, Stem ) :-
	atomic( Mtx ),
	!,
	mtx_pname_stem_atomic( Mtx, Pname, Stem ).
mtx_pname_stem( _Mtx, row, mtx ).

mtx_pname_stem_atomic( Mtx, Stem, Stem ) :-
	file_name_extension( Stem, _, Mtx ),
	!.
mtx_pname_stem_atomic( Atom, Atom, Atom ).
