
:- lib(stoics_lib:op_compare/3).
% :- debug( mtx_apply ).

mtx_apply_defaults( Defs ) :-
	Defs = [ij_constraint(>:<),on_mtx(self),mtx_in_goal(false),default_value(undefined),
	        has_header(true), row_start(top) ].

/** mtx_apply( +Mtx, +Goal, -Res, +Opts ).

Opts
  * default_value(DefV=undefined)
    use value(Val)=DefV when you want to set the elements that fail ij_constraint

  * has_header(HasH=true)
    see mtx_header_body/5. Header is removed before application and then added to Res (if exists).

  * ij_constraint(IJc=true)
    alternatives are any operator accepted by op_compare/3 (ground Op), with < meaning operate on (strict) upper matrix and >:< operate on all pairs

  * mtx_in_goal(MinG=false)
    whether to pass scaffold to Goal call. If _true_ call is call(Gname,Scf,I,J,Elem|Gargs,NtxScf), else
    it is call(Gname,Elem|Gargs,OutElem)
  
  * on_mtx(OnMtx=self)
    scaffold matrix for results. _self_ means use Mtx itself

  * row_start(Rst=top)
    set to bottom for upward looking ij_constraints

==
?- Mtx = [row(a,b,c),row(1,2,3),row(4,5,6),row(7,8,9)], assert( a_mtx(Mtx) ).

?- a_mtx( Amtx ), mtx_apply( Amtx, plus(1), Bmtx, true ).
Bmtx = [row(a, b, c), row(2, 3, 4), row(5, 6, 7), row(8, 9, 10)].

?- a_mtx( Amtx ), mtx_apply( Amtx, plus(1), Bmtx, ij_constraint(<) ).
Bmtx = [row(a, b, c), row(1, 3, 4), row(4, 5, 7), row(7, 8, 9)].

?- a_mtx( Amtx ), mtx_apply( Amtx, plus(1), Bmtx, [ij_constraint(=<),default_value(0),row_start(bottom)] ).
Bmtx = [row(a, b, c), row(0, 0, 4), row(0, 6, 7), row(8, 9, 10)].

?- a_mtx( Amtx ), mtx_apply( Amtx, plus(1), Bmtx, [ij_constraint(=<),default_value(0),row_start(top)] ).
Bmtx = [row(a, b, c), row(2, 3, 4), row(0, 6, 7), row(0, 0, 10)].

?- a_mtx( Amtx ), mtx_apply( Amtx, plus(1), Bmtx, [ij_constraint(=<),default_value(0),row_start(top)] ).
Bmtx = [row(a, b, c), row(0, 3, 4), row(0, 0, 7), row(0, 0, 0)].

==

@author nicos angelopoulos
@version  0.1 2016/2/17

*/
mtx_apply( Mtx, Goal, Res, Args ) :-
	options_append( mtx_apply, Args, Opts ),
	mtx_header_body( Mtx, Header, Body, HasH, Opts ),
	options( ij_constraint(IJc), Opts ),
	options( mtx_in_goal(MiG), Opts ),
	mtx_apply_def( Def, Opts ),
	mtx_apply_on( Mtx, OnMtx, Opts ),
	Goal =.. [Gn|Gas],
	mtx_dims( Body, NRs, NCs ),
	options( row_start(Rst), Opts ),
	mtx_apply_row_start( Rst, NRs, I, It ), 
	mtx_apply( I, 1, It, NRs,  NCs, IJc, Body, Gn/Gas/Def, MiG, OnMtx, ResBody ),
	mtx_has_header_add( HasH, Header, ResBody, Res ).

mtx_apply_row_start( top, NRs, 1, it(+,=<,NRs) ).
mtx_apply_row_start( bottom, NRs, NRs, it(-,>,0) ).

mtx_apply( I, J, It, Rs,  NCs, IJc, Mtx, GTerm, MiG, OnMtx, ResBody ) :-
	It = it(IncOp,TermOp,TermVal),
	debug( mtx_apply, 'i: ~w', [I] ),
	% I =< Rs,
	op_compare( TermOp, I, TermVal ),
	!,
	Mtx = [Row|Rows],
	Row =.. [Rn|Rvals],
	mtx_in_goal_row( MiG, OnMtx, ResRow, OnRows, ResRows, ResBody ),
	mtx_apply_row( J, I, NCs, IJc, Rvals, GTerm, MiG, OnMtx, ResRowVals ),
	mtx_apply_row_pack( MiG, ResRowVals, Rn, ResRow ),
	% Iinc is I + 1,
	Expr =.. [IncOp,I, 1],
	call( is, NxtI, Expr ),
	mtx_apply( NxtI, J, It, Rs, NCs, IJc, Rows, GTerm, MiG, OnRows, ResRows ).
mtx_apply( _I, _J, _It, _Rs,  _NCs, _IJc, _Mtx, _GTerm, MiG, OnMtx, ResBody ) :-
	debug( mtx_apply, 'done Is', [] ),
	mtx_apply_row_close( MiG, OnMtx, ResBody ). % body_close, but would be identical anyways

mtx_apply_row( J, I, NCs, IJc, Row, GTerm, MiG, OnMtx, ResRow ) :-
	debug( mtx_apply, 'j: ~w', [J] ),
	J =< NCs,
	op_compare( IJc, I, J ),
	!,
	GTerm = Gn/Gas/_Def,
	Row = [Elem|Tow],
	mtx_apply_goal_term( MiG, Gn, Gas, Elem, OnMtx, I, J, ResRow, NxtMtx, RemRow ),
	Jinc is J + 1,
	mtx_apply_row( Jinc, I, NCs, IJc, Tow, GTerm, MiG, NxtMtx, RemRow ).

mtx_apply_row( J, I, NCs, IJc, Row, GTerm, MiG, OnMtx, ResRow ) :-
	J =< NCs,
	!,  % we are in defaults situation here
	GTerm = _Gn/_Gas/Def,
	Row = [Elem|Tow],
	( Def=='$undefined' -> DefElem = Elem; DefElem = Def ),
	mtx_apply_add_default( MiG, OnMtx, I, J, DefElem, ResRow, NxtMtx, RemRow ),
	Jinc is J + 1,
	mtx_apply_row( Jinc, I, NCs, IJc, Tow, GTerm, MiG, NxtMtx, RemRow ).
mtx_apply_row( _J, _I, _NCs, _IJc, [], _GTerm, MiG, OnMtx, ResRow ) :-
	mtx_apply_row_close( MiG, OnMtx, ResRow ).

mtx_apply_row_pack( true, Res, _Rn, Res ).
mtx_apply_row_pack( false, ResVals, Rn, ResRow ) :-
	ResRow =.. [Rn|ResVals].

mtx_apply_row_close( false, _OnMtx, [] ).
mtx_apply_row_close( true, OnMtx, OnMtx ).

mtx_apply_goal_term( false, Gn, Gas, Elem, OnMtx, _I, _J, ResRow, NxtMtx, RemRow ) :- 
	append( [Elem|Gas], [OutElem], Args ),
	Call =.. [Gn|Args],
	call( Call ),
	ResRow = [OutElem|RemRow], 
	NxtMtx = OnMtx.
mtx_apply_goal_term( true, Gn, Gas, Elem, OnMtx, I, J, ResRow, NxtMtx, RemRow ) :- 
	append( [OnMtx,I,J,Elem|Gas], NxtMtx, Args ),
	Call =.. [Gn|Args],
	call( Call ),
	RemRow = ResRow.

mtx_apply_add_default( false, OnMtx, _I, _J, Val, [Val|RemRow], OnMtx, RemRow ).
mtx_apply_add_default( true, OnMtx, I, J, Val, Mtx, NxtMtx, Mtx ) :-
	mtx_pos_elem( OnMtx, I, J, Val, NxtMtx ).

mtx_in_goal_row( true, _OnMtx, ResRow, ResRow, ResRows, ResRows ).
mtx_in_goal_row( false, OnMtx, ResRow, OnMtx, ResRows, [ResRow|ResRows] ).

mtx_apply_on( Mtx, OnMtx, Opts ) :-
	options( on_mtx(self), Opts ),
	!,
	OnMtx = Mtx.
mtx_apply_on( _Mtx, OnMtx, Opts ) :-
	options( on_mtx(OnMtx), Opts ).

mtx_apply_def( Def, Opts ) :-
	options( default_value(DefT), Opts ),
	mtx_apply_def_value( DefT, Def ).

mtx_apply_def_value( undefined, '$undefined' ) :-
	!.
mtx_apply_def_value( value(Val), Val ) :- !.
mtx_apply_def_value( Val, Val ).
