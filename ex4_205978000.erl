%%%-----------------------------------------------------------------------------------------------------------------------
%%% Exm 4
%%% @The creator of the project: Shahaf Zohar
%%%                              205978000
%%% Created : 5. May 2023 13:42
%%%-----------------------------------------------------------------------------------------------------------------------

-module(ex4_205978000).
-export([flatten/1,smaller/2,replace/3,mapSub/2]).

%====================================================================================================
%Every call split list to head and tail.
flatten([])->[];                        %Stop conditions, empty list
flatten([H|T])when not is_list(H) -> [H] ++ flatten(T);         % if H not list just append him to list and call again 
flatten([H|T])-> flatten(H) ++ flatten(T).                      % If H is not a list then chain it to the flatten list T,
                                                                % else chain the flatten list H with the flatten list T.

%====================================================================================================
% take a list,Thr return all the element are smaller then this 
smaller(List,Thr) -> lists:map(fun(X)-> X =< Thr end, List).

%====================================================================================================
%Replaces all instances of Old with New in List
replace(List,Old,New) -> helped(List,Old,New). 
helped([],_Old,_New) -> [];
helped([H|T],Old,New) -> if 
                            H =:= Old -> [New] ++ helped(T,Old,New);
                            true -> [H] ++ helped(T,Old,New)
                        end.

%====================================================================================================
mapSub(List1,Arg2)-> helper(List1,Arg2).
helper([],[]) -> [];                    % the basic case tow empty list
helper(List,[]) when is_list(List) -> List;            % case -> the Arg is empty list 
helper(List,[]) when  not is_list(List) -> lenError;
helper([],_List) -> lenError;
helper(List,Arg) when is_number(Arg) and is_list(List) -> lists:map(fun(X) -> X-Arg end, List);
helper(List1,List2) when length(List1) =/= length(List2) -> lenError;
helper(List1,List2) when  (length(List1) =:= length(List2)) -> lists:map(fun({X,Y})-> X-Y end, lists:zip(List1,List2)).





