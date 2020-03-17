
:- lib(mtx_options_csv/4).
:- lib(onoma/2).
:- lib(stoics_lib:holds/2).
:- lib(stoics_lib:locate/3).
:- lib(stoics_lib:expand_spec/2).

% This is also called from mtx_options_select/5. Be mindfull if it is being changed.
%
mtx_defaults( Defs ) :-
	Defs = [ report(false),
             % convert(false),
             convert(true),
	         csv_read([]),
	         csv_write([]),
		     cache(false),
		     from_cache(true),
             skip_heading(false)
            % sep(0',)  % has no default value
	       ].

%% mtx( +Mtx ).
%
% True iff Mtx is a valid representation of a matrix.
% 
% This is a synonym for =|mtx(Mtx, _Canonical)|=. Cite this predicate for valid input representations of Mtx variables.
%
% Valid representations are (see mtx_type/2):
% * list of lists
%    which is assumed to be a per-column representation (see mtx_lists/2).
%
% * list of terms 
%    such as those read in with csv_read_file/2 but there is no restriction on term name and arity
%    this is the canonical representation and each term is a row of the matrix
% 
% * atomic
%    where the atom corresponds to a predicate name and the predicate with arity N is defined to 
%    succeeds with the returned argument instantiated to a list
% 
% * csv file or its stem
%    as possible to be read by csv_read_file/2
%	 alias paths and normal delimited file extension can be ommited
%
%---+++ Notes for developers.
%
% For examples use:
%== 
% ?- mtx_data( mtcars, Mtcars ).
% M = [row(mpg, cyl, disp, hp, ....
%
% ?- mtx( pack(mtx/data/mtcars), Mtc ).
%
% ?- mtx( data(mtcars), Mtx ).
%==
%
%---++ Variable naming conventions
% * MtxIn  
%   matrix in any acceptable representation (1st arg of mtx/2)
% * Mtx    
%   canonical Mtx  (2nd arg of mtx/2)
% * Hdr
%   header
% * Clm
%   column data
% * Cnm
%   column name
% * Cps
%   column position (also Cpos)
%
% If a predicate definition has both Cnm and Cps define them in that order.
%
%==
% ?- mtx_data( mtcars, Cars ), mtx( Cars ).
%==
%
%@see library(mtx)
%
mtx( Mtx ) :-
	mtx( Mtx, _ ).

/** mtx( +Any, -Canonical ).
    mtx( ?Res, +Canonical ).
    mtx( ?Any, ?Canonical, +Opts ).

Convert to Canonical representation of matrix Any or pass the Canonical representation to output Res.

The canonical representation of a matrix is a list of compounds, the first
of which is the header and the rest are the rows. The term name of the compounds is not strict but header
is often and by convention either _hdr_ or _row_ and rows are usually term named by _row_. 

When Opts is missing, it is set to the empty list (see options/2).

See library(mtx).

Modes

When +Any is ground and -Canonical is unbound, Any is converted from any of the accepted input formats (see mtx_type/2).

When both +Canonical and +Res are ground, Res is taken to be a file to write on.

Under +Canonical and -Res, Res is bound to Canonical (allows non-output).

This predicate is often called from within mtx pack predicates to translate inputs/outputs to canonical matrices,
before and performing the intended operations.

The predicate can be made to look at data directories of packs for input data matrices.<br>
The following three calls are equivalent.

==
?- mtx( data(mtcars), Mtcars, sep(comma) ).
?- mtx( data(mtcars), Mtcars ).
?- mtx( pack('mtx/data/mtcars.csv'), Mtcars).
==
 
Data matrices can be debug-ed via the =dims= and =length= goals in debug_call/3.<br>
==
?- debug(mtx_ex).
?- use_module(library(lib)).
?- lib(debug_call).
?-  mtx( data(mtcars), Mtcars ), debug_call( mtx_ex, dims, mtcars/Mtcars ).
% Dimensions for matrix,  (mtcars) nR: 33, nC: 11.
Mtcars = [row(mpg, cyl, disp, hp, ....)|...]
?- mtx( data(mtcars), Mtcars ), debug_call( mtx_ex, len, mtcars/Mtcars ).
?- mtx( data(mtcars), Mtcars ), debug_call( mtx_ex, length, mtcars/Mtcars ).
% Length for list, mtcars: 33
Mtcars = [row(mpg, cyl, disp, hp, ....)|...]
==

Opts is a term or list of terms from the following:

  * cache(Cache=false)
  if _true_ file is cached as a fact and attempts to reload the same csv file will use
  the cache. Any other value (Handle) than _true_ or _false_ will cache the file
  and in addition to using the cache when reloading the csv file it also allow 
  access to the matrix via Handle, that is =!mtx(Handle,Mtx)!=

  * convert(Conv=false)
  adds convert(Conv) to Wopts and Ropts (the default here, flipts the current convert(true) default in csv_write_file/3 - also for read)
  
  * csv_read(Ropts=[])
  options for csv_read_file/3

  * csv_write(Wopts=[])
  options for csv_write_file/3

  * from_cache(FromCache=true)
  when _true_ reads from cache if it can match Any to a handle or a file

  * input_file(InpFile)
  defines input file for the purposes of creating an output file in conjuction with Psfx

  * match(Match)
  if present adds match_arity(Match) into Wopts and Ropts

  * output_postfix(Psfx)
  the postfix of the output file (added at end of stem of InpFile)

  * output_file(OutF)
  defines output to csv when Any is a var/1 and Canonical is ground/1.

  * report(Rep=false)
  report the read/write and dims of corresponding matrix

  * ret_mtx_input(InpF)
  full path of the input file

  * rows_name(RowsName=_)
  if present the header is left padded with RowsName

  * sep(Sep)
  if present adds separator(SepCode) into Wopts and Ropts, via mtx_sep(Sep,SepCode), mtx_sep/2

  * skip_heading(Skh=false)
  provide prefix (number, seen as code; atom; or list, seen as codes) that removes heading lines

  * type(Type)
  returns the type of input matrix, see mtx_type/2
==

?- mtx( pack(mtx/data/mtcars), Cars ), 
   length( Cars, Length ).
Cars = [row(mpg, cyl, disp, hp, drat, wt, qsec, vs, am, gear, carb), row(21.0, ....],
Length = 33.

?- mtx( What, [hdr(a,b,c),row(1,2,3),row(4,5,6),row(7,8,9)], [output_file(testo)] ).
What = testo.

?- shell( 'more testo' ).
a,b,c
1,2,3
4,5,6
7,8,9
true.

?- mtx( What, [hdr(a,b,c),row(1,2,3),row(4,5,6),row(7,8,9)], [input_file('testo.csv'),output_postfix('_demo')] ).
What = testo_demo.csv.

?- mtx( pack(mtx/data/mtcars), Cars, cache(cars) ).
Cars = [row(mpg, cyl...)|...]
?- debug(mtx(mtx)).
?- mtx( cars, Cars ).
Using cached mtx with handle: cars
Cars = [row(mpg, cyl...)|...]

?- mtx( pack(mtx/data/mtcars), Mtx, cache(mtcars) ), assert(mc(Mtx)), length( Mtx, Len ).
...
Len = 33.
?- mtx( mtcars, Mtcars ), length( Mtcars, Len ).
...
Len = 33.
?- mtx( mc, Mc), length( Mc, Len ).
...
% Len = 33.
==

@version 1:0, 2014/9/22 
@version 1:1, 2016/11/10, added call to mtx_type/2 and predicated matrices
@tbd option read_options(ReadCsvOpts)
@tbd option fill_header(true) then with new_header(HeaderArgsList)
@tbd fill_header(replace) then, replaces header new_header(...) new_header(1..n) by default.
@see library(mtx)

*/
mtx( File, Rows ) :-
	mtx( File, Rows, [] ).

mtx( Mtx, Rows, Args ) :-
	options_append( mtx, Args, Opts ),
	ground( Mtx, GrMtx  ),   % fixme: now these can return partial- unlike old is_ground/2
	ground( Rows, GrRows ),
	mtx_ground_ness( GrMtx/GrRows, Mtx, Rows, Opts ).

mtx_ground_ness( true/true, Mtx, Canon, Opts ) :- !,
	mtx_ground_canonical( Mtx, Canon, Opts ).
mtx_ground_ness( true/_, Mtx, Canon, Opts ) :- !,
	% mtx_canonical( Mtx, Canon, Opts ),
	mtx_type( Mtx, Type ),
	ground( Type ),
	options_return( type(Type), Opts ),
	mtx_type_canonical( Type, Mtx, Canon, Opts ).
mtx_ground_ness( _/true, Mtx, Canon, _Opts ) :- !,  % passes results back to variable instead of writing
	Mtx = Canon.
mtx_ground_ness( _Else, Mtx, Canon, _Opts ) :- !,
	throw( arg_ground_in_one_of([1,2],[Mtx,Canon]), mtx:mtx/2 ).

mtx_type_canonical( by_column, Mtx, Canon, _Opts ) :-
	mtx_lists( Canon, Mtx ).
mtx_type_canonical( by_row, Canon, Canon, _Opts ).
mtx_type_canonical( handled, Handle, Canon, Opts ) :-
	mtx_from_file( Handle, Canon, Opts ).
mtx_type_canonical( on_file(File), _Mtx, Canon, Opts ) :-
	mtx_from_file( File, Canon, Opts ),
	options_return( ret_mtx_input(File), Opts ).
mtx_type_canonical( predicated, Pname/Arity, Canon, _Opts ) :-
	% Goal =.. [Pname,Arg],
	member( Mod, [user,mtx] ),
	functor( Goal, Pname, Arity ),
	predicate_property( Mod:Goal, defined ),
	!,
	Goal =.. [Pname|Args],
	Row =.. [row|Args],
	findall( Row, call(Mod:Goal), Canon ).
mtx_type_canonical( asserted, Pname, Canon, _Opts ) :-
	member( Mod, [user,mtx] ),
	Goal =.. [Pname,Canon],
	predicate_property( Mod:Goal, defined ),
	!,
	once( call(Mod:Goal) ).
	
mtx_type_canonical( predfile, Pname, Canon, Opts ) :-
	member( Mod, [user,mtx] ),
	Goal =.. [Pname,File],
	predicate_property( Mod:Goal, defined ),
	call( Mod:Goal ),
	!,
	mtx_from_file( File, Canon, Opts ),
	options_return( ret_mtx_input(File), Opts ).

mtx_ground_canonical( Mtx, Canon, Opts ) :-
	holds( (mtx:mtx_type(Canon,Type),Type == by_row), ByRow ),
	mtx_ground_canonical_type( ByRow, Type, Mtx, Canon, Opts ).

mtx_ground_canonical_type( true, _Type, Mtx, Canon, Opts ) :-
	mtx_to_file( Canon, Mtx, Opts ).
mtx_ground_canonical_type( false, Type, _Mtx, _Canon, _Opts ) :-
	throw( pack_error(mtx,mtx/3,non_canonical(Type)) ).

/*
mtx( File, Rows, Args ) :-
	options_append( mtx, Args, Opts ),
	maplist( is_ground, [File,Rows], [FileG,RowsG] ),
	( (FileG==true,atomic(File)) -> FileA = true, VarA =false 
	      ; (var(FileG) -> VarA = true; VarA=false), FileA = false ),
	mtx( VarA/FileG/FileA/RowsG, File, Rows, Opts ).

mtx( Instance, File, Rows, Opts ) :-
	mtx_decipher( Instance, File, Rows, Opts ),
	!.
mtx( Instance, Spec, _Rows, Opts ) :-
	throw( pack_error(mtx,mtx/3,unknown_mtx_input(Spec,Instance,Opts)) ). 
	% fixme: use proper error handling
*/

/*
mtx( File, Rows, OptS ) :-
	atomic( File ),
	\+ ground( Rows ),
	!,
	*/
% mtx_decipher( IsAvar/IsAground/IsAatom/IsBground, File, Rows, Opts ) :-
/*
mtx_decipher( false/true/true/false, File, Rows, Opts ) :-
	file_mtx( File, Rows, Opts ),
	ret_option( ret_mtx_input(File), Opts ).
mtx_decipher( false/false/false/true, Mtx, Rows, _Opts ) :-
	Rows = Mtx.
mtx_decipher( false/true/false/false, Mtx, Rows, Opts ) :-
	( Mtx= [_|_] ->
		Rows = Mtx
		;
		file_mtx( Mtx, Rows, Opts ),
		ret_option( ret_mtx_input(Mtx), Opts )
	).
mtx_decipher( true/false/false/false, Path, Rows, Opts ) :-
	once( locate(Path,['',csv,tsv],File) ),
	options( csv_read(ROpts), Opts, en_list(true) ),
	csv_read_file( File, Rows, ROpts ),
	options( report(Rep), Opts ),
	mtx_report( Rep, read, File, Rows ),
	ret_option( ret_mtx_input(File), Opts ).
% mtx( File, Rows, Opts ) :-
	% var( File ),
	% ground( Rows ),
mtx_decipher( true/false/false/true, File, Rows, Opts ) :-
	mtx_file( Rows, File, Opts ),
	ret_option( ret_mtx_input(File), Opts ).
% mtx( Spec, Rows, OptS ) :-
% 	ground( Spec ),
%	ground( Rows ),
mtx_decipher( false/true/false/true, Spec, Rows, Opts ) :-
	mtx_to_file( Rows, Spec, Opts ).
mtx_decipher( false/true/true/true, Spec, Rows, Opts ) :-
	mtx_to_file( Rows, Spec, Opts ).
*/

mtx_file( Rows, OutputF, Opts ) :-   % fixme: document these 2 clauses
	memberchk( input_file(Input), Opts ),
	memberchk( output_postfix(Psfx),Opts ),
	!,
	file_name_extension( Stem, Ext, Input ),
	atom_concat( Stem, Psfx, NewStem ),
	file_name_extension( NewStem, Ext, OutputF ),
	options( csv_write(CWopts), Opts, en_list(true) ),
    mtx_file_csv_options( Opts, CWopts, Wopts ),
	csv_write_file( OutputF, Rows, Wopts ).
mtx_file( Rows, OutputF, Opts ) :-
	memberchk( output_file(OutputF), Opts ),
	!,
	options( csv_write(CWopts), Opts, en_list(true) ),
    mtx_file_csv_options( Opts, CWopts, Wopts ),
	csv_write_file( OutputF, Rows, Wopts ).
mtx_file( Rows, File, _Opts ) :-
	File = Rows.

mtx_to_file( Rows, Spec, Opts ) :-
	expand_spec( Spec, File ),
	options( csv_write(CWOpts), Opts, en_list(true) ),
    mtx_file_csv_options( Opts, CWOpts, WOpts ),
	csv_write_file( File, Rows, WOpts ),
	options( report(Rep), Opts ),
	mtx_report( Rep, wrote, File, Rows ),
	options_return( ret_mtx_input(File), Opts ).
% mtx( Spec, Rows, Opts ) :-

mtx_from_file( Handle, Rows, Opts ) :-
	\+ options(from_cache(false),Opts),
	mtx:mtx_data_handle_file( Handle, _ ),
	!,
	debug( mtx(mtx), 'Using cached mtx with handle: ~w', Handle ),
	mtx_data_from_store( Handle, Rows ).
mtx_from_file( File, Rows, Opts ) :-
	os_term( Filb, File ),
	once( locate(Filb,['',csv,tsv],Fila) ),
	% exists_file( Fila ),
	!,
	mtx_file_abs( Fila, File, Rows, Opts ).
mtx_from_file( File, Rows, Opts ) :-
	( file_name_extension(File,csv,MtxF); file_name_extension(File,tsv,MtxF)),
	exists_file( MtxF ),
	!,
	mtx_file_abs( MtxF, File, Rows, Opts ).
mtx_from_file( File, Rows, Opts ) :-     % for the error message
	csv_read_file( File, Rows, Opts ).

mtx_file_abs( AbsF, _File, Rows, Opts ) :-
	\+ options(from_cache(false),Opts),
	mtx_data_store( AbsF, Rows ),
	!,
	debug( mtx(mtx), 'Using cached mtx with file location: ~p', AbsF ).
mtx_file_abs( AbsF, File, Rows, Opts ) :-
	options( csv_read(CROpts), Opts, en_list(true) ),
    mtx_file_csv_options( Opts, CROpts, ROpts ),
    options( skip_heading(Skh), Opts ),
    mtx_csv_read_file( Skh, AbsF, Rows, ROpts ),
	options( [report(Rep),cache(Cache)], Opts ),
	mtx_report( Rep, read, File, Rows ),
	mtx_data_to_store( Cache, AbsF, Rows ).

mtx_csv_read_file( false, AbsF, Rows, ROpts ) :-
    !,
	csv_read_file( AbsF, Rows, ROpts ).
mtx_csv_read_file( PfxPrv, AbsF, Rows, ROpts ) :-
    ( number(PfxPrv) -> 
        atom_codes( Pfx, [PfxPrv] )
        ;
        ( atom(PfxPrv) ->
            PfxPrv = Pfx
            ;
            atom_codes(Pfx,PfxPrv)
        )
    ),
    mtx_options_csv( [match(false)|ROpts], AbsF, TopOpts, _ ),
    mtx_options_csv( ROpts, AbsF, CsvOpts, OpenOpts ),
    setup_call_cleanup( 
        open(AbsF, read, Stream, OpenOpts),
        ( 
            csv_read_row(Stream, Row0, TopOpts ),
            mtx_read_headings(Row0, Pfx, Stream, Row1, TopOpts),
            mtx_read_stream(Row1, Stream, Rows, CsvOpts)
        ),
            close(Stream) 
    ).
% mtx_csv_read_file( Skh, AbsF, Rows, ROpts ),

mtx_read_headings( Row, Pfx, Stream, RowN, Topts ) :-
    % fixme: deal with end_of_file, rows
    arg( 1, Row, FA ),
    atom_concat( Pfx, _, FA ),
    !,
    csv_read_row( Stream, Row1, Topts ),
    mtx_read_headings( Row1, Pfx, Stream, RowN, Topts ).
mtx_read_headings( Row, _Pfx, _Stream, Row1, _Topts ) :-
    Row = Row1.

mtx_data_to_store( false, _MtxF, _Rows ) :-
	!.
mtx_data_to_store( true, MtxF, Rows ) :-
	once( absolute_file_name(MtxF,AbsF) ),
	% fixme: need to do more checks ?
	retractall(mtx:mtx_data_store(AbsF,_)),
	assert(mtx:mtx_data_store(AbsF,Rows)).
mtx_data_to_store( Handle, MtxF, Rows ) :-
	once( absolute_file_name(MtxF,AbsF) ),
	mtx_data_handle_to_file( Handle, AbsF ),
	retractall(mtx:mtx_data_store(Handle,_)),
	assert(mtx:mtx_data_store(Handle,Rows)),
	assert(mtx:mtx_data_store(AbsF,Rows)).

mtx_data_handle_to_file( Handle, AbsF ) :-
	mtx_data_handle_file( Handle, OthF ),
	OthF \== AbsF,
	!,
	throw( pack_error(mtx,mtx/3,handle_exists(Handle,OthF,AbsF)) ).
mtx_data_handle_to_file( Handle, AbsF ) :-
	retractall( mtx:mtx_data_handle_file(Handle,_) ),  % bit lazy
	assert( mtx:mtx_data_handle_file(Handle,AbsF) ).

mtx_data_from_store( Handle, Rows ) :-
	mtx_data_store( Handle, Rows ),
	!.
mtx_data_from_store( Handle, _Rows ) :-
	throw( pack_error(mtx,mtx/3,handle_inconsistency(Handle)) ).

mtx_file_csv_options( Opts, RoWOpts, CsvOpts ) :-
    % 19.01.30: we should probably give RoWOpts priority for match() and separator() ...
    ( memberchk(sep(MtxSep),Opts) ->
        mtx_sep( MtxSep, CsvSep ),
        SepOpts = [separator(CsvSep)|RoWOpts]
        ;
        SepOpts = RoWOpts
    ),
    ( memberchk(match(Match),Opts) ->
        MatOpts = [match_arity(Match)|SepOpts]
        ;
        MatOpts = SepOpts
    ),
    options( convert(Conv), Opts ),
    append( MatOpts, [convert(Conv)], CsvOpts ).

mtx_report( true, Op, File, Rows ) :-
	onoma( Op, OpOnoma ),
	mtx_rows_dims( Rows, Nrows, Ncols ),
	format( '~a file: ~w with ~d rows and ~d columns \n', [OpOnoma,File,Nrows,Ncols] ).
mtx_report( false, _Op, _File, _Rows ).
