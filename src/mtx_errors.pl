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
