%%%-------------------------------------------------------------------
%%% HW-3
%%% @The creator of the project: Shahaf Zohar
%%%                              205978000
%%% Created : 2. Apr 2023 10:00 PM
%%%-------------------------------------------------------------------
-module(ex3).
-export([sortRes/1,sortRes/2, sortResLC/1, sortResPM/1, sortResLM/1, sortBytwo/1, qSort/1, mSort/1, matElemMult/2, filter_g/2, filter_p/2, even/1,fiboR/1, factorial/1, fiboT/1]).
-import(lists,[filter/1, filter/2, sort/1, zip/2, split/2]).
%%%---------------------------------------------------------------------------------------------------------------------------------
%%%Sorts List according to the residue of division by 3
%%Sortres Function
sortRes([])->[].
sortRes(List,lc) -> sortResLC(List);
sortRes(List,pm) -> sortResPM(List);
sortRes(List,lm) -> sortResLM(List).
sortResLC(List) -> sort([X || X <- List, ((X rem 3) =:= 0)]) ++ sort([X || X <- List, ((X rem 3) =:= 1)]) ++ sort([X || X <- List, ((X rem 3) =:= 2)]). %Scans the list, checks if element has remainder of 0, then 1, then 2. Sort and Concatenate the three lists.
sortResPM(List) -> sort(sortResPM(List,[],0)) ++ sort(sortResPM(List,[],1)) ++ sort(sortResPM(List,[],2)).  % Pattern matching 
sortResPM([],A,_N) -> A;
sortResPM([H|T],A,N) when (H rem 3) =:= N -> [H|sortResPM(T,A,N)];   %if H has remainder of N, add to list. Performed total 3 times, each time for different N(0,1,2). Sort and Concatenate the three lists.
sortResPM([_H|T],A,N) -> sortResPM(T,A,N).
sortResLM(List) -> 
    sort(filter(fun(X) -> (X rem 3) =:= 0 end,List)) ++ sort(filter(fun(X) -> (X rem 3) =:= 1 end,List)) ++ sort(filter(fun(X) -> (X rem 3) =:= 2 end,List)). %using lists:filter to filter each time by remainder. Sort and Concatenate the three lists.

%%%----------------------------------------------------------------------------------------------------------------------------------
sortBytwo(L) -> Filtered = filter(fun(X) -> X rem 2 == 0 end, L),
         io:format("Filtered list: ~p.\n", [Filtered]).

%%%----------------------------------------------------------------------------------------------------------------------------------
%%Quick Sort
qSort([]) ->[];                 % Bace on quick sort algoritem
qSort([Pivot|T]) ->
    qSort([X || X <- T, X < Pivot])++ [Pivot] ++ qSort([X || X <- T, X >= Pivot]).

%%%----------------------------------------------------------------------------------------------------------------------------------
%%Marge Sort
mSort([]) -> [];                     %Empty list is already sorted.
mSort([X]) -> [X];                   %List of 1 element is already sorted.
mSort(List) -> {L,R} = split(length(List) div 2, List), merge(mSort(L), mSort(R)).        %Recursively splits the list in the middle until of size 1, then calls merge for each side.
merge(L, R) -> merge(L,R,[]).        %Repeatedly merge sublists to produce new sorted sublists until there is only one sublist remaining
merge([],R,Acc) -> Acc++R;           %Stop condition. Left side is empty, return current list adding right.
merge(L,[],Acc) -> Acc++L;           %Stop condition. Right side is empty, return current list adding left.
merge([HL|TailL], [HR|TailR], Acc) when HR >= HL -> merge(TailL, [HR|TailR], Acc ++ [HL]);      %Adding HL (Hade Left) first because its smaller than HR(Hade Right).
merge([HL|TailL], [HR|TailR], Acc) when HL > HR  -> merge([HL|TailL], TailR, Acc ++ [HR]).      %Adding HL (Hade Left) first because its bigger than HR(Hade Right).

%%%----------------------------------------------------------------------------------------------------------------------------------
%%Matrices Functions
%%Input: Squares matrices MatA,MatB
%%Output: Element by element multiplication result. 
%%Optional, Implement it with list comprehension.
matElemMult([],[]) -> [];
matElemMult(MatA,MatB) -> [multi(A,B,[]) || {A,B} <- zip(MatA,MatB)].
multi([],[], Container) -> Container;
multi([H1|T1],[H2|T2], Container) -> multi(T1,T2,Container ++ [float(H1*H2)]).

%%%----------------------------------------------------------------------------------------------------------------------------------
%%------------------------------------Filter  Functions------------------------------------------------------------------------------
%%If Filter is the atom ‘numbers’ than remove all numbers from list.
%%If Filter is the atom ‘atoms’ than remove all atoms from list.
%%Implement it using Guards.

filter_g(List, Filter) -> filterS(List, Filter =:= numbers).
%%if Filter = numbers 
filterS(List,true) -> [X || X <- List, not is_number(X)];
%%if Filter = atoms 
filterS(List,false) -> [X || X <- List, not is_atom(X)].  

%%Implement the same functionality of filter_g by using pattern matching approach (without guards)
%%Examples (filter_p should do the same)

filter_p([H|T],Filter) -> filter_p(T,Filter =:= atoms,H,is_atom(H)).
%%if Filter = atoms then remove every element which is atom
filter_p([],true,_X,true) -> [];
filter_p([],true,X,false) -> [X];
filter_p([H|T],true,_X,true) -> filter_p(T,true,H,is_atom(H));
filter_p([H|T],true,X,false) -> [X|filter_p(T,true,H,is_atom(H))];

%if Filter != atoms then remove every element which is  not atom (number).
filter_p([],false,_X,false) -> [];
filter_p([],false,X,true) -> [X];
filter_p([H|T],false,_X,false) -> filter_p(T,false,H,is_atom(H));
filter_p([H|T],false,X,true) -> [X|filter_p(T,false,H,is_atom(H))].

%%Factorial - N! = N*(N-1)*...*3*2*1
factorial(1) -> 1;                        %stop condition of the recursion.
factorial(N) -> N*factorial(N-1).

%%%----------------------------------------------------------------------------------------------------------------------------------
%%------------------------------------Even Functions------------------------------------------------------------------------------
%Returns a list of all even members of List, in the same order as appeared in it
%Implement it using a recursion without using reverse()
%Hint: use guards
even(List) -> even(List,[]).
even([],Acc)-> Acc;						%stop condition of the recursion.
even([H|T],Acc) when ((H rem 2) =:= 0) -> [H] ++ even(T,Acc);
even([H|T],Acc) when ((H rem 2) =/= 0) -> even(T,Acc).

%%%----------------------------------------------------------------------------------------------------------------------------------
%%-------------------------------------Fibonacci Functions------------------------------------------------------------------------------
%%Returns the N’th Fibonacci number (1,1,2,3,5,…)
%%Implement it using a recursion
%%1,1,2,3,5,....N
%% 2^N complexity 
fiboR(1) -> 1;
fiboR(2) -> 1;			%stop condition of the recursion.
fiboR(N) -> fiboR(N-1) + fiboR(N-2).

%%Returns the N’th Fibonacci number (1,1,2,3,5,…)
%%Implement it using a tail recursion
%%1,1,2,3,5,....N
fiboT(N) -> fiboTrc(N,0,1).
fiboTrc(1,_,B)-> B;
fiboTrc(N,A,B)-> fiboTrc(N-1,B,B+A).














