%%%---------------------------------------------------------------------------------------------------------------------------------------------------------
%%% @author ShahafZohar
%%%         205978000
%%%
%%% Created : 30. May 2023 12:17 PM
%%%---------------------------------------------------------------------------------------------------------------------------------------------------------
-module(ex8_205978000).
-author("ShahafZohar").
-export([steadyMon/1,startChat/1,call/1,steadyLink/1]).

%%%---------------------------------------------------------------------------------------------------------------------------------------------------------
%% Spawns a process to evaluate function F/0,Links the two processes
%% Terminates after 5 seconds if no exception occurs
%% Returns the PID of spawned process

steadyLink(F) -> PID = spawn_link(F),

  receive
  after
    5000 -> PID
  end.
%%%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%% Spawns a process to evaluate function F/0
%% Monitors the spawned process
%% Returns the PID of spawned process
%%Catches any type of termination of F/0 and prints the corresponding result (string)

steadyMon(F) -> {PID,_} = spawn_monitor(F),
  receive
    {_,_,_,PID,normal} -> io:format("Normal termination of process ~s was detected~n",[pid_to_list(PID) --"<>"]),PID;
    {_,_,_,PID,Reason} -> io:format("An exception in process ~s was detected: ~p~n",[pid_to_list(PID) --"<>",Reason]),PID
  after
    5000 -> exit(PID,kill),PID
  end.

%%%----------------------------------------------------------------------------------------------------------------------------------------------------------
%% A chat tool that sends messages between two hosts. Uses rpc module for sending messages
%% Returns a PID of a local process which is responsible for sending messages to the remote and counting stats of sent/received messages.
%% Spawns a process in remote machine ‘name@IP’ if there is no such process yet only
%% Messages will be then sent by this process to the receiving process in ‘name@IP’
%% Upon a receive of a message, it should be printed to the screen.
%% Upon a receive of a message stats, prints the number of received/sent messages

startChat(callee_init) -> io:fwrite("Start chat and the Pid - ",[]),
  case whereis(callee) of
    		undefined -> PID = spawn(fun() -> slave(0,0) end), 			% the slave go to loop and wait to message from the master	
		 register(callee, PID); 							%we expect to get undefined for first time call of this function because callee isn't registered
    		_ -> void
  		end;

startChat(NodeID) -> put(callee,NodeID), rpc:call(NodeID,ex8_205978000,startChat,[callee_init]),		%The master start the chat and send to the slave function startChat from above 
	  case whereis(caller) of
	    undefined -> PID = spawn(fun()-> master(NodeID,0,0) end), register(caller, PID); %we expect to get undefined for first time call of this function because caller isn't registered
	    Registered_PID -> PID = Registered_PID
	  end,
	  PID.

%%%----------------------------------------------------------------------------------------------------------------------------------------------------------
% wating for message 
%============
% master loop 
%============
master(Callee,Sent,Received) ->
	  receive
	    {rec,stats} -> io:fwrite("Local Stats: sent: ~p received: ~p~n",[Sent,Received+1]),master(Callee,Sent,Received+1); %print stats and recall with updated stats
	    {rec,quit} -> SelfPID = self(),io:fwrite("~p - Successfully closed.~n",[SelfPID]); 						% message to kill self that has been received from callee
	    {rec,Msg} -> io:fwrite("~p~n",[Msg]), master(Callee,Sent,Received+1); 				       %a message was received from callee, print it and recall with updated stats
	    Msg -> rpc:call(Callee,ex8_205978000,call,[{callee,Msg}]),io:fwrite("sent~n",[]), master(Callee,Sent+1,Received) % send message to remote
	  end.

%============
% slave loop 
%============
slave(Sent,Received) ->
	receive
	  stats -> io:fwrite("Remote Stats: sent: ~p received: ~p~n",[Sent,Received+1]),slave(Sent,Received+1);                               % present stats and recall with updated stats
	  {send,quit,Caller} ->SelfPID = self(), io:fwrite("~p - Successfully closed.~n",[SelfPID]),rpc:call(Caller,ex8_205978000,call,[{caller,quit}]); % an instruction to send kill msg to the caller
	  {send,Message,Caller} -> rpc:call(Caller,ex8_205978000,call,[{caller,Message}]), slave(Sent+1,Received);   %an instruction to send a message to the caller and recall with updated stats
	  Message -> io:fwrite("~p~n",[Message]),slave(Sent,Received+1)					         % print message and recall with updated stats
	end.

%%%----------------------------------------------------------------------------------------------------------------------------------------------------------
%% Sending message from remote to local by RPC call

call({callee,NodeID,Msg}) -> callee!{send,Msg,NodeID};					
call({callee,Msg}) -> callee!Msg;
call({caller,Msg}) -> caller!{rec,Msg};
call(Msg) -> N = node(),rpc:call(get(callee),ex8_205978000,call,[{callee,N,Msg}]).  	%instruct callee to send message to caller


%%%----------------------------------------------------------------------------------------------------------------------------------------------------------








