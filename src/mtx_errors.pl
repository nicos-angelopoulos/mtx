mtx_errors.

:- multifile( pack_errors:message/3 ).

pack_errors:message( non_canonical(Type) ) -->
	['Input matrix in canonical representation expected, found: ~w'-[Type]].
pack_errors:message( unknown_mtx_input(Spec,Instance,Opts) ) -->
	['Cannot convert input : ~w, (having groundness spec:~w) and, \n  options: ~w'-[Instance,Spec,Opts]].
pack_errors:message( handle_inconsistency(Handle) ) -->
	['Cache handle: ~w exists, but data not found for it.'-[Handle]].
pack_errors:message( handle_exists(Handle,OthF,AbsF) ) -->
	['Cache handle: ~w exists but points to: ~p, refusingto repoint to: ~w.'-[Handle,OthF,AbsF]].
pack_errors:message( cannot_decipher_mtx_type_for_input(Mtx) ) -->  
                    % fixme: get a generic way to only show part of input if Mtx is too long ?
     ['Cannot decipher type of ground mtx input: ~w'-[Mtx]].
