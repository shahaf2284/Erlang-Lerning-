%%%-------------------------------------------------------------------
%%% @author ubuntu
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. May 2021 12:17 PM
%%%-------------------------------------------------------------------
-module(ex8b).
-author("ubuntu").
-export([startChat/1,call/1,steadyLink/1,steadyMon/1]).

steadyLink(F) -> PID = spawn_link(F),
  receive
  after
    5000 -> PID
  end.

steadyMon(F) -> {PID,_} = spawn_monitor(F),
  receive
    {_,_,_,PID,normal} -> io:format("Normal termination of process ~s was detected~n",[pid_to_list(PID) --"<>"]),PID;
    {_,_,_,PID,Reason} -> io:format("An exception in process ~s was detected: ~p~n",[pid_to_list(PID) --"<>",Reason]),PID
  after
    5000 -> exit(PID,kill),PID
  end.

startChat(init_callee) -> io:fwrite("print inside callee~n",[]),
  case whereis(callee) of
    undefined -> PID = spawn(fun() -> callee_messenger(0,0) end), register(callee, PID); %we expect to get undefined for first time call of this function because callee isn't registered
    _ -> void
  end;
startChat(NodeID) -> put(callee,NodeID), rpc:call(NodeID,ex8b,startChat,[init_callee]),
  case whereis(caller) of
    undefined -> PID = spawn(fun()-> caller_messenger(NodeID,0,0) end), register(caller, PID); %we expect to get undefined for first time call of this function because caller isn't registered
    Registered_PID -> PID = Registered_PID
  end,
  PID.

callee_messenger(Sent,Received) ->
  receive
    stats -> io:fwrite("Remote Stats: sent: ~p received: ~p~n",[Sent,Received+1]),callee_messenger(Sent,Received+1); %print stats and recall with updated stats
    {send,quit,Caller} ->SelfPID = self(), io:fwrite("~p - Successfully closed.~n",[SelfPID]),rpc:call(Caller,ex8b,call,[{caller,quit}]); % an instruction to send kill msg to the caller
    {send,Message,Caller} -> rpc:call(Caller,ex8b,call,[{caller,Message}]), callee_messenger(Sent+1,Received);%an instruction to send a msg to the caller and recall with updated stats
    Message -> io:fwrite("~p~n",[Message]),callee_messenger(Sent,Received+1)% print msg and recall with updated stats
  end.

caller_messenger(Callee,Sent,Received) ->
  receive
    {rec,stats} -> io:fwrite("Local Stats: sent: ~p received: ~p~n",[Sent,Received+1]),caller_messenger(Callee,Sent,Received+1); %print stats and recall with updated stats
    {rec,quit} -> SelfPID = self(),io:fwrite("~p - Successfully closed.~n",[SelfPID]); % msg to kill self that has been received from callee
    {rec,Message} -> io:fwrite("~p~n",[Message]), caller_messenger(Callee,Sent,Received+1); %a msg was received from callee, print it and recall with updated stats
    Message -> rpc:call(Callee,ex8b,call,[{callee,Message}]),io:fwrite("sent~n",[]), caller_messenger(Callee,Sent+1,Received) % send message to remote
  end.

call({callee,NodeID,Message}) -> callee!{send,Message,NodeID};
call({callee,Message}) -> callee!Message;
call({caller,Message}) -> caller!{rec,Message};
call(Message) -> N = node(),rpc:call(get(callee),ex8b,call,[{callee,N,Message}]). %instruct callee to send msg to caller


%% API
