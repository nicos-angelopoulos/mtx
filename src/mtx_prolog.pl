
:- lib(stoics_lib:en_list/2).

mtx_prolog_defaults( [auto_pname(Apname)|_], Defs ) :-
	Defs = [predicate_name(Apname), % out_stem(Astem),
	        header_remove(false),consult(save)
	       ].


/** mtx_prolog( ?Mtx, ?Prolog ).
    mtx_prolog( ?Mtx, ?Prolog, -Opts ).

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

  * out_stem(Fstem=stem(Mtx))
    stem for filename, .pl is added. The default is the stem of Mtx.
    (Was file_stem(Fstem).)

  * out_ext(Fext={csv,pl})
    extension for ouput file. The default depends whether the 
    predicate is writing out to Mtx on to Prolog

  * out_dir(Fdir=dir(InpF))
    output directory, default is '.' or taken from input file if one was given

  * header_remove(Rmv=false)
    whether to ignore the first row, else true, or pname for header fact

  * mtx_opt(MtxOpt)
    option(s) to be passed to mtx/3

  * predicate_name(Pname=stem(basename(Mtx)))
    predicate name for facts
 
  * rows_transform(Rtrans)
    if present the predicate is called on the input rows to transform them
    before they converted to facts. Use Rtrans = maplist(Pred) if you want
    to use maplist on each row for Pred rather than the default of calling
    Pred with RowsIn and RowsOut

Modalities
  * Mtx = os_file(), Prolog = os_file()  
    (write from one existing, and if both exist Mtx -> Prolog
  * Mtx = os_file(), Prolog = var
  * Mtx = var, Prolog = os_file


@author nicos angelopoulos
@version  0.1 2015/3/20
@version  0.2 2018/12/3, added conversion from Prolog to mtx.
@tbd change header_remove(Rmv) to keep_header({true,false,*as_comment*}).
@tbd change allow for header pred names (harmonize with bio_db ?s _info...)
@tbd modalities list
@tbd add examples and test conversion from Prolog to mtx

*/
mtx_prolog( Mtx, Prolog ) :-	
    mtx_prolog( Mtx, Prolog, [] ).

mtx_prolog( Mtx, Prolog, ArgS ) :-
    en_list( ArgS, Args ),
	mtx_pname_stem( Mtx, APname, _AStem ),
	options_append( mtx_prolog, [auto_pname(APname)|Args], Opts ),
	debug( mtx, 'mtx_prolog/3 opts: ~w', [Opts] ),
    mtx_prolog_opts( Mtx, Prolog, Opts ).

mtx_prolog_opts( Mtx, Prolog, Opts ) :-
    ground( Prolog ),
    mtx_prolog_ground_pl( Prolog, Mtx, Opts ),
    !.
mtx_prolog_opts( Mtx, Prolog, Opts ) :-
	mtx( Mtx, MtxRows, [ret_mtx_input(Ret)|Opts] ),
	debug( mtx, 'Read from mtx: ~w', Ret ),
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

mtx_prolog_ground_pl( [Clause|Clauses], Mtx, Opts ) :-
    !,
    ( memberchk(out_ext(DefExt),Opts) -> true; DefExt = csv ),
    ( memberchk(out_dir(DefDir),Opts) -> true; DefDir = '.' ),
    ( memberchk(out_stem(Stem),Opts) ->
        Dir = DefDir, Ext = DefExt
        ;
        ( var(Mtx) ->
            functor(Clause, Stem, _Arity),
            Dir = DefDir, Ext = DefExt
            ;
            % throws error if Mtx is also a list of rows, fixme: throw non-modality error
            absolute_file_name( Mtx, AbsMtxF ),
            os_path( Dir, OsMtxF, AbsMtxF ),
            os_ext( Ext, Stem, OsMtxF )
        )
    ),
    os_dir_stem_ext( Dir, Stem, Ext, OutMtxF ),
    mtx_prolog_write_mtx( OutMtxF, [Clause|Clauses], Opts ).

mtx_prolog_ground_pl( InPlF, MtxGivenF, Opts ) :-
    ( var(MtxGivenF) ->
        absolute_file_name( InPlF, AbsPlF ),
        os_dir_stem_ext( DefDir, DefStem, _InExt, AbsPlF ),
        ( memberchk(out_ext(OutExt),Opts) -> true; OutExt = csv ),
        ( memberchk(out_stem(OutStem),Opts) -> true; OutStem = DefStem ),
        ( memberchk(out_dir(OutDir),Opts) -> true; OutDir = DefDir ),
        os_dir_stem_ext( OutDir, OutStem, OutExt, OutMtxF ),
        MtxGivenF = OutMtxF
        ;
       % throws error if Mtx is also a list of rows, fixme: throw non-modality error
        absolute_file_name( MtxGivenF, OutMtxF )
    ),
    % fixme: move to stoics_lib
    read_clauses( AbsPlF, Clauses ),
    mtx_prolog_write_mtx( OutMtxF, Clauses, Opts ).

mtx_prolog_write_mtx( OutMtxF, [Clause|Clauses], Opts ) :-
    findall( MtxOpt, member(mtx_opt(MtxOpt),Opts), MtxOpts ),
    mtx( OutMtxF, [Clause|Clauses], MtxOpts ).

    % fixme: move to stoics_lib
read_clauses( PlF, Clauses ) :-
    setup_call_cleanup( open(PlF,read,In), 
                            ( read(In,First),
                              read_clauses_stream(First,In,Clauses)
                            ),
                                close(In) ).

read_clauses_stream( end_of_file, _In, Clauses ) :- !, Clauses = [].
read_clauses_stream( Clause, In, [Clause|Clauses] ) :- 
    rea( In, Next ),
    read_clauses_stream( Next, In, Clauses ).
    

mtx_prolog_out_stem( Prolog, _Ret, Fstem, _Opts ) :-
	ground( Prolog ),
	!,
	Fstem = mtx_prolog_out.
mtx_prolog_out_stem( _Prolog, _Ret, Fstem, Opts ) :-
	memberchk( out_stem(Fstem), Opts ),
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
