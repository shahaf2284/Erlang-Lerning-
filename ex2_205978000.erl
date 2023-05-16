%%%-------------------------------------------------------------------
%%% HW-2
%%% @The creator of the project: Shahaf Zohar
%%%                              205978000
%%% Created : 31. Mar 2023 11:00 PM
%%%-------------------------------------------------------------------
-module(ex2_205978000).
-export([findKelem/2,reverse/1,factorial/1,deleteKelem/2, addKelem/3, union/2]).
%%reverse/1, reverse/2, factorial/1, deleteKelem/2, remove_element/2, addKelem/3, union/2]).
%%-----------------------------------------------------------------------------------------
%%% Returns the K’th element of List. In case of an error, it should return an atom, notFound
findKelem([],K)-> notFound;               %no elements in an empty list
findKelem([H|_],1) -> H;                  %K=1 returns the head.
findKelem([H|T],K) -> findKelem(T,K-1).   %the list shortens recursively until the K'th element is the head. returns the head.

%%-----------------------------------------------------------------------------------------
%%reverse - Reverse List’s items
reverse([]) -> [];
reverse(List) -> reverse(List,[]).        %original summon of reverse summons a help function with 2 arguments.
reverse([],Rev) -> Rev;                   %stop condition of the recursion.
reverse([H|T],Rev) -> reverse(T,[H|Rev]). %Accumulates the original list, to a reversed list recursively.

%%-----------------------------------------------------------------------------------------
%%Factorial - N! = N*(N-1)*...*3*2*1
factorial(1) -> 1;                        %stop condition of the recursion.
factorial(N) -> N*factorial(N-1).

%%-----------------------------------------------------------------------------------------
%%Remove one element - remove one element from list just if he exists 
deleteKelem([],_) -> [];                            %base case, empty list
deleteKelem([X | T], X) -> deleteKelem(T,X);        %remove the first occurrence of X
deleteKelem([H | T], X) -> [H | deleteKelem(T,X)].  %keep the current element and recursively remove X from the tail of the list
%%another way to solve the problem:
%%deleteKeleM(List,K)->[X||X<-List,X /= K].

%%-----------------------------------------------------------------------------------------
%%Adds Element to List in K’th place. Assume valid input
addKelem(List,1,Elem) -> [Elem|List];               %stop condition of the recursion.    
addKelem([H|T],K,Elem) -> [H | addKelem(T,K-1,Elem)].

%Union - Returns the union of these two lists and removes multiple instances from both lists
union([],[]) -> [];                        %merged empty list
union([],A) -> A;                          %stop condition of the recursion.
union([H|T],A) -> remove_duplicates([H|union(T,A)]). 
remove_duplicates([]) -> [];
remove_duplicates([H|T]) -> [H | [X || X <- remove_duplicates(T), X /= H]]. %Help function.removes multiple



