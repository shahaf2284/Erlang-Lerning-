%%%------------------------------------------------------------------------------------------------------------------------
%%% Exm 9
%%% @The creator of the project: Shahaf Zohar
%%%                              205978000
%%% Created : 13. jun 2023 17:44
%%%-------------------------------------------------------------------------------------------------------------------------

-module(ex9).
-author("ShahafZohar").
%% API
-export([etsBot/0]).
%%%-------------------------------------------------------------------------------------------------------------------------
etsBot()->
  [Type|List_of_lines] = string:split(readlines("etsCommands.txt"),"\n",all),
  %Read all lines from file and put it in list. The first line is Type and the rest is in List_of_lines, every element is line
  Ets = ets:new(elioz,[list_to_atom(Type)]),  %Create Ets
  {_,Output_File} = file:open("etsRes_206116089.ets", [write]),  %Open a file and call it File
  action_on_line(List_of_lines,Ets,list_to_atom(Type)), %send the lines to action_on_line and I will explain there
  ListEts = ets:tab2list(Ets),
  [io:format(Output_File,"~s ~s~n",[Key,Val])|| {Key,Val} <- ListEts],
  file:close(Output_File),
  ets:delete(Ets),
  ok.

action_on_line([],_Ets,_Type)->finish;
action_on_line([Line|List_of_lines],Ets,Type)->
  %Every iteration I take one line and act according the action
  [Action|List] = string:split(Line," ",all),
  %For every line I take the first word, that is the Action and the rest is in List
  case Action of
    "insert" -> my_insert(List,Ets,Type);
    "delete" -> my_delete(List,Ets);
    "lookup" -> my_lookup(List,Ets);
    "update" ->
      if
        Type  =/= bag -> my_update(List,Ets);
        true -> false
      end;
    _->false
  end,
  action_on_line(List_of_lines,Ets,Type). %Send the rest of lines to the function

my_insert([],_Ets,_Type)->finish;
my_insert(List,Ets,Type)->
    %Insert to the Ets. The function run on all of the line
    [Key,Val|T] = List,
    if
      Type  =/= bag -> ets:insert_new(Ets,{list_to_atom(Key),Val});
      true -> ets:insert(Ets,{list_to_atom(Key),Val})
    end,
    my_insert(T,Ets,Type).

my_update([],_Ets)->finish;
my_update(List,Ets)->
  %Update to the Ets. The function run on all of the line
  [Key,Val|T] = List,
  ets:update_element(Ets,list_to_atom(Key),{2,list_to_atom(Val)}),
  my_update(T,Ets).

my_lookup([],_Ets)->finish;
my_lookup(List,Ets)->
  %lookup in the Ets. The function run on all of the line
  [Key|T] = List,
  case ets:member(Ets,list_to_atom(Key)) of
    true->
      %[Val] = ets:lookup(Ets,list_to_atom(Key)),
      Val = ets:lookup_element(Ets,list_to_atom(Key),2),
      io:format("key: ~s val: ~s~n",[Key,Val]);
    false->false
  end,
  my_lookup(T,Ets).

my_delete([],_Ets)->finish;
my_delete(List,Ets)->
  %Delete from the Ets. The function run on all of the line
  [Key|T] = List,
  case ets:member(Ets,list_to_atom(Key)) of
    true->ets:delete(Ets,list_to_atom(Key));
    false->false
  end,
  my_delete(T,Ets).

%%%--------------------------------------------------------------------------------------------------------------------
%General functions
readlines(FileName) ->  %Read all lines from file and return as string/list
  {ok, Device} = file:open(FileName, [read]),
  try get_all_lines(Device)
  after file:close(Device)
  end.

get_all_lines(Device) ->  %function that help to readlines function
  case io:get_line(Device, "") of
    eof  -> [];
    Line -> Line ++ get_all_lines(Device)
  end.