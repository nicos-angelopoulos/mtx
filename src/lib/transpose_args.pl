%% transpose_args( +List, -Trans ).
%
% Transpose the args of List into Trans.
%
%==
% transpose_args( [x(1,2,3),x(a,b,c)], [x(1,a),x(2,b),x(3,c)] )
%==
%
% @author nicos angelopoulos
% @version  0.1 2014/5/14    added doc at this date.
%
transpose_args( List, Trans ) :-
     List = [H|_T],
     functor( H, Name, Arity ),
     findall( Tr, (between(1,Arity,A),
                    findall(Ta,(member(L,List),arg(A,L,Ta)),Targs),
                    Tr=..[Name|Targs]),
                                             Trans).
