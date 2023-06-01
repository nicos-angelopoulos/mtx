
:- lib(stoics_lib:en_list/2).

%% compare_multi_ops_list( +Multi, -List ).
%
% Convert multiops to lists of ops. 
%
%==
% ?- compare_multi_ops_list( =<, OpsL ).
% OpsL = [=, <].
%==
%
% @author nicos angelopoulos
% @version  0.1 2014/1/5
% @see  mtx_column_threshold/5
% @tbd  -Multi, +List mode ?
%
compare_multi_ops_list( Op, OpsList ) :-
	current_op( _, _, Op ),  % fixme can we be more specific? should be infix...
	!,
	% term_codes( Op, Codes ),
	term_to_atom( Op, Atom ),
     atom_codes( Atom, Codes ),
	maplist( compare_multi_ops_codes_to_term, Codes, OpsList ).
compare_multi_ops_list( Op, _List ) :-
	throw( fixme(not_an_operator(Op) ) ).

compare_multi_ops_codes_to_term( Code, Term ) :-
     atom_codes( Atom, [Code] ),
     read_term_from_atom( Atom, Term, [] ).
