
%% mtx_header_column_name_pos( +Hdr, ?Cid, -Cnm, -Pos ).
%
% N is the nth position of the column identifier Cid that is present in Hdr.
% Only first match is returned.
% Predicate is kept to a minimal implementation, for instance just fails if no Cid is in Hdr.
% Is the column name corresponding to Pos.
% Can be used to enumerate columns (name and position, v0.4)
%
% Here, unlike in the alternative implementation, we first look for Cid in Hdr args
% if that is successful the corresponding position is returned, only then we check
% if Cid is integer before returning it as the requested position.
% We also check Pos in this case is within range.
%jjj
%==
% ?- mtx_mtcars( Mt ), Mt = [Hdr|_Rows], mtx_header_column_name_pos( Hdr, mpg, Cnm, Cpos ).
% Cnm = mpg,
% Cpos = 1.
% 
% ?- mtx_mtcars( Mt ), Mt = [Hdr|_Rows], mtx_header_column_name_pos( Hdr, 3, Cnm, Cpos ).
% Cnm = disp,
% Cpos = 3.
%== 
% @author nicos angelopoulos
% @version  0.2 2014/6/30, this was header_column_id_pos/3,4
% @version  0.3 2015/1/26, changed the /4 name to header_column_name_pos/4
% @version  0.4 2016/6/22, added enumeration for unbound (Cid)
% @version  0.5 2016/12/20, added nth(Cid)
%
mtx_header_column_name_pos( Hdr, Cid, Cnm, Pos ) :-
	var(Cid),
	!,
	arg( Pos, Hdr, Cid ),
	Cnm = Cid.
mtx_header_column_name_pos( Hdr, Cid, Cnm, Pos ) :-
	once( arg(Pos,Hdr,Cid) ),
	!,
	Cnm = Cid.
mtx_header_column_name_pos( Hdr, CidPrv, Cnm, Pos ) :-
	( CidPrv = nth(Cid) ; Cid = CidPrv ),
	number( Cid ),
	Pos is integer( Cid ),
	Pos =:= Cid,
	!,
	Pos > 0,
	functor( Hdr, _, Arity ),
	Pos =< Arity,
	once( arg(Pos,Hdr,Cnm) ).
mtx_header_column_name_pos( Hdr, Cid, _Cnm, _Pos ) :-
	% fixme
	throw( could_not_locate_column_in_header_row(Cid,Hdr) ).
