%%%------------------------------------------------------------------------------------------------------------------------
%%% Exm 9
%%% @The creator of the project: Shahaf Zohar
%%%                              205978000
%%% Created : 13. jun 2023 17:44
%%%-------------------------------------------------------------------------------------------------------------------------

-module(ex9_205978000).
-author("ShahafZohar").
%% API
-export([etsBot/0]).
%%%-------------------------------------------------------------------------------------------------------------------------

% To read a file in Erlang, there are different ways to approach it. Here are a few options:
% Use file:open/2 to open the file and io:get_line/1 to read it line by line. This is more memory-efficient and can handle large files.
readlines(FileName) ->
        {ok, Device} = file:open(FileName, [read]),
        try get_all_lines(Device)
        after file:close(Device)
        end.

get_all_lines(Device) ->
       case io:get_line(Device, "") of
           eof  -> [];
           Line -> Line ++ get_all_lines(Device)
       end.

%%%-------------------------------------------------------------------------------------------------------------------------

etsBot()-> 
        [Type|Set_of_command] = string:split(readlines("etsCommands.txt"),"\n",all),
        Ets = ets:new(shahaf,[list_to_atom(Type)]),  %Create Ets
        {_,Output_File} = file:open("etsRes_205978000.ets", [write]),  %Open a file and call it File mode write
        crossing_lines(Set_of_command,Ets,list_to_atom(Type)), %send the the lines and and activate them
        ListEts = ets:tab2list(Ets),
        [io:format(Output_File,"~s ~s~n",[Key,Val])|| {Key,Val} <- ListEts],
        file:close(Output_File),
        ets:delete(Ets),
        ok.

crossing_lines([],_Ets,_Type)->finish;
crossing_lines([Head|Tail],Ets,Type)->
        [Command|List] = string:split(Head," ",all),            % Every iteration I take one line and act according the action
                                                                % For every line I take the first word, that is the Action and the rest is in List
        case Command of
            "insert" -> insertfunc(List,Ets,Type);
            "delete" -> deletefunc(List,Ets);
            "lookup" -> lookupfunc(List,Ets);
            "update" -> updatefunc(List,Ets);
        _ -> false
        end,
        crossing_lines(Tail,Ets,Type). %Send the rest of lines to the function

insertfunc([],_Ets,_Type)-> finish;
insertfunc(List,Ets,Type)-> 
            [Key,Val|Tail] = List,
            ets:insert(Ets,{list_to_atom(Key),Val}),
            insertfunc(Tail,Ets,Type).

deletefunc([],_Ets)-> finish;
deletefunc(List,Ets)->
  %Delete from the Ets. The function run on all of the line
  [Key|Tail] = List,
  case ets:member(Ets,list_to_atom(Key)) of
    true->ets:delete(Ets,list_to_atom(Key));
    false->false
  end,
  deletefunc(Tail,Ets).

lookupfunc([],_Ets)-> finish;
lookupfunc(List,Ets)->
    %Insert to the Ets. The function run on all of the line
    [Key|Tail] = List,
    Val = ets:lookup_element(Ets,list_to_atom(Key),2),
    io:format("key: ~s val: ~s~n",[Key,Val]),
    lookupfunc(Tail,Ets).

updatefunc([],_Ets)-> finish;
updatefunc(List,Ets)->
    [Key,Val|Tail]=List,
    case ets:member(Ets,list_to_atom(Key)) of
        true -> ets:update_element(Ets,list_to_atom(Key),{2,list_to_atom(Val)});
        false -> false
    end,
    updatefunc(Tail,Ets).



























