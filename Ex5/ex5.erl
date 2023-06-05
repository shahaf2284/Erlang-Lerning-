%%%-----------------------------------------------------------------------------------------------------------------------
%%% Exm
%%% @The creator of the project: Shahaf Zohar
%%%                              205978000
%%% Created : 15. Apr 2023 10:00 PM
%%%-----------------------------------------------------------------------------------------------------------------------
-module(ex5).
-record(message,{idf,counter,numberMessage}).
-record(next,{pidNext,mainPid}).
-record(matrixnode,{right,left,up,down,index,pidMain,listMessage,maxMessage}).
%-export([loop/1,ring_parallel/2,createProcess/1,loopProsse1/2,ring_serial/2,serialRing/1,ring_serial2/2]).
-export([mesh_serial/3,loop/1,ring_parallel/2,createProcess/1,loopProsse1/2,ring_serial/2,ring_serial2/2,serialRing/1,matrixNxN/1,mesh_parallel/3]).

%===================================================================================================================

%task 1 
loop(P)->
    receive
        {ringMessage} ->
                P!{ringMessage},
                loop(P);
        {messageEnd,Number} ->
                P!{messageEnd,Number},
                erlang:exit(P);
        other-> 
            io:format("I dont know what do~n")
    end.

loopProsse1(P2,IDmain)->
    receive
        {endring, M} ->
               %io:format("now all N process create, now we send ~p~n", [M]),
                X=sendM(0,M,P2),
                loopProsse1(X,IDmain); 
        {messageEnd,Number} ->
                    %io:format("receive ~p messages~n", [Number]),
                    IDmain!{receiveAll,Number},
                    erlang:exit(self());
        {ringMessage} ->
               loopProsse1(P2,IDmain); 
        _ -> 
            loopProsse1(P2,IDmain)
    end.

% N = The size of the ring
ring_parallel(N,M) ->
    Tstart = erlang:timestamp(),
    ID=self(),
    spawn(?MODULE, createProcess,[{N,M,ID}]),
    receive
         {receiveAll,Send} ->
            Tend = erlang:timestamp(),
            {timer:now_diff(Tend,Tstart),M,Send}
    end.


createProcess(X) ->
    if
        is_record(X,message)->
                            IDF = X#message.idf,            %id process 1
                            N = X#message.counter,      
                            M = X#message.numberMessage,
                            if 
                                N =:= 0 -> % case that process N create
                                    IDF!{endring,M},
                                    loop(IDF);
                                true ->
                                    Message = #message{idf=IDF,counter=N-1,numberMessage = M},
                                    Next=spawn(?MODULE, createProcess,[Message]),
                                    loop(Next)
                            end;

        is_tuple(X)->                 %case Process 1
                            {N,M,IDmain} = X,
                            Message = #message{idf=self(),counter=N-1,numberMessage = M},
                            P2= spawn(?MODULE, createProcess,[Message]),
                            loopProsse1(P2,IDmain)

        end.
%sendM(_Number,0,P2)-> P2; 
sendM(Number,0,P2)-> 
        P2!{messageEnd,Number};  

sendM(Number,M,P2)->
        P2!{ringMessage},
        sendM(Number+1,M-1,P2).
%===================================================================================================================

%task 2 
ring_serial(V,M) ->
                    Tstart = erlang:timestamp(),         % Start timer 
                              PIDmain = self(),             
                              PIDmain!{1,0},                    % Send to my self message {Send to Process 1, the first message}
                              receiveMsg(PIDmain,Tstart,V,M).

receiveMsg(PIDmain,Tstart,V,M) ->
                              receive
                                  {1,M} -> {timer:now_diff(erlang:timestamp(),Tstart),M,M};                 %{End the send message in process 1}
                                  {VNumumber,MsgNum} when VNumumber =/=V+1 -> PIDmain!{VNumumber+1,MsgNum},     % process 1 send to process 2 {2,0}, process 2 to process 3 {3,0},....process N-1 to process N = V+1 {N,0}
                                                                             receiveMsg(PIDmain,Tstart,V,M);
                                  {VNumumber,MsgNum} when VNumumber=:=V+1 -> PIDmain!{1,MsgNum+1},              % process 1 get from process N and send to process 2 the new message 
                                                                             receiveMsg(PIDmain,Tstart,V,M)
                              end.


%----------------------------------------------------------------------------------------------------------------------

ring_serial2(V,M)->
    Tstart = erlang:timestamp(),
    ListProcess = createNProcess(V,[]),                             % Creat list of all process pid
    P1 =lists:nth(1,ListProcess),                                   
    sendMessage(ListProcess,P1),                                    
    P1!{startTosendM,self(),M},
    receive
         {receiveAll} -> Tend = erlang:timestamp()
    end,
    io:format("runtime = ~p  microseconds~n", [timer:now_diff(Tend,Tstart)]).     % Print and calculate the time


createNProcess(0,Acc)-> Acc;
createNProcess(V,Acc)-> Next = #next{},
    createNProcess(V-1,Acc++[spawn(?MODULE, serialRing,[Next])]).


sendMessage([H],P1)-> H!{nextNode, P1};                                           % Only procsse N in the list send to p1 the message   
sendMessage([H|T],P1)-> H!{nextNode, lists:nth(1,T)},
                        sendMessage(T,P1).


serialRing(Next)->
    receive
        {nextNode,Pid} ->
                NewNext = #next{pidNext = Pid, mainPid = 0},
                %io:format("The Next Process is ~p~n",[Pid]),
                serialRing(NewNext);

        {startTosendM,PidMain,M} ->                                                 % Process 1 only 
                Newnext = #next{pidNext = Next#next.pidNext, mainPid = PidMain},
                sendM(M,Next#next.pidNext),
                serialRing(Newnext);
        {ringMessage}->
                Next#next.pidNext!{messageRing},
                serialRing(Next);
        {messageEnd}->
                if
                    Next#next.mainPid =/= 0 -> Next#next.mainPid!{receiveAll};
                    true -> Next#next.pidNext!{messageEnd},serialRing(Next)
                end;
        {receiveAll} ->
                if 
                    Next#next.mainPid =/= 0 -> Next#next.mainPid!{receiveAll};
                    true -> serialRing(Next)
                end;        
            _-> 
                serialRing(Next)
    end.

sendM(0,Pid)->
    Pid!{messageEnd};  

sendM(M,Pid)->
    Pid!{ringMessage},
    sendM(M-1,Pid).

%===================================================================================================================================================
%task 3

mesh_parallel(N,M,C)->
    Tstart = erlang:timestamp(),
    %io:format("~n-----------------------------------~n"),
    ListProcess = createNxN(N*N,[]),                % Creat N process 
    %io:format("~n#####~p#####~n",[ListProcess]),
    creatingAmatrix(ListProcess,1, N, ListProcess,C,M),
    %io:format("~n====<<~p>>===~n",[lists:nth(C,ListProcess)]),
    lists:nth(C,ListProcess)!{kingOfKing,M,self()},            %main send to the king start simulation
        receive
         {receiveAllM} ->
                killAll(ListProcess),
                Tend = erlang:timestamp(),
                {timer:now_diff(Tend,Tstart),M,(N*N-1)*M}
        end.
creatingAmatrix([],_Index,_N,_L,_King,_M) -> none;
creatingAmatrix([H|T],Index,N,L,King,M) ->
    Case1 = ((Index rem N) =/= 0), Case2 = ((Index rem N) =/= 1),Case3= (N < Index), Case4 = (Index =< N*N-N),
    Right = case Case1 of 
            true->  lists:nth(Index+1,L);
            false ->  -1
        end,
    Left = case Case2 of 
            true -> lists:nth(Index-1,L);
            false -> -1
        end,
    Up = case Case3 of  
            true -> lists:nth(Index-N,L);
            false -> -1
        end,
    Down = case Case4 of  
            true ->  lists:nth(Index+N,L); 
            false -> -1
        end,
        
        MAX = (N*N-1)*M,
        Node = #matrixnode{right = Right, left = Left, up = Up, down = Down, index=Index,pidMain=0,listMessage = [],maxMessage = MAX},
        H!{location,Node},
        creatingAmatrix(T,Index+1,N,L,King,M).

         
createNxN(0,Acc)-> Acc;
createNxN(N,Acc)->
        Node = #matrixnode{},
        createNxN(N-1,Acc++[spawn(?MODULE, matrixNxN,[Node])]).

matrixNxN(Node)->
    receive
        {location,NewNode} -> matrixNxN(NewNode);   % init the nodes in the matrix each node know his nighbours 

        {kingOfKing,M, PidM}-> 
            UpdatedNode = Node#matrixnode{pidMain = PidM},   %just case king changes pidMain field 
            %io:format("~nR=~p~nL=~p~nU=~p~nD=~p~nPid=~p~n",[UpdatedNode#matrixnode.right,UpdatedNode#matrixnode.left,UpdatedNode#matrixnode.up,UpdatedNode#matrixnode.down,UpdatedNode#matrixnode.pidMain]),
            sendMatrix(UpdatedNode,M,0),matrixNxN(UpdatedNode);  % Just the king get this message

        {Index,Num}->
            Case1 = ((length(Node#matrixnode.listMessage) =:= Node#matrixnode.maxMessage) and (Node#matrixnode.pidMain =/= 0)),
            case Case1 of
                    true -> Node#matrixnode.pidMain!{receiveAllM},
                            %io:format("~n*********************************************=~n"),
                            erlang:exit(self());
                    false -> none    
            end,
            % case Node#matrixnode.index =:= 2 of
            %     true->io:format("=========================~n"),
            %     io:format("My index:~p Tuple = ~p list=~p %%%%%%%~n", [Node#matrixnode.index,{Index,Num}, Node#matrixnode.listMessage]),
            %     io:format("the resulte is  ~p %%%%%%%~n", [lists:member({Index,Num}, Node#matrixnode.listMessage)]),
            %     io:format("=========================~n");
            %     false->none
            % end,
            case lists:member({Index,Num}, Node#matrixnode.listMessage) of
                true -> %passMessage(Node,{Index,Num}),
                        matrixNxN(Node);
                false -> List = Node#matrixnode.listMessage,
                        %io:format("~n%%%%%%%%%<<~p>>%%%%%%%%~n", [List]),
                        UpdatedNode = Node#matrixnode{listMessage = List ++ [{Index,Num}]},
                        passMessage(UpdatedNode,{Index,Num}),
                        passMessage(UpdatedNode,{Node#matrixnode.index,Num}),
                        matrixNxN(UpdatedNode)
            end;
        {justDie}->
                erlang:exit(self());
        _-> matrixNxN(Node)
    end. 

passMessage(Node,Msg) -> 
            Case1 = (Node#matrixnode.right =/= -1), Case2 = (Node#matrixnode.left =/= -1),
            Case3= (Node#matrixnode.up =/= -1), Case4 = (Node#matrixnode.down =/= -1),
            %io:format("~n==============~n"),
            case Case1 of 
                true ->  Node#matrixnode.right!Msg;
                false -> none
            end,
            case Case2 of 
                true -> Node#matrixnode.left!Msg;
                false -> none
            end,
            case Case3 of  
                true -> Node#matrixnode.up!Msg;
                false -> none
            end,
            case Case4 of  
                true -> Node#matrixnode.down!Msg; 
                false -> none
            end.

sendMatrix(_Node,M,M)-> none; 
sendMatrix(Node,M,Num)->
        Case1 = (Node#matrixnode.right =/= -1), Case2 = (Node#matrixnode.left =/= -1),
        Case3= (Node#matrixnode.up =/= -1), Case4 = (Node#matrixnode.down =/= -1),
        case Case1 of 
            true ->  Node#matrixnode.right!{Node#matrixnode.index,Num};
            false -> none
        end,
        case Case2 of 
            true -> Node#matrixnode.left!{Node#matrixnode.index,Num};
            false -> none
        end,
        case Case3 of  
            true -> Node#matrixnode.up!{Node#matrixnode.index,Num};
            false -> none
        end,
        case Case4 of  
            true -> Node#matrixnode.down!{Node#matrixnode.index,Num}; 
            false -> none
        end,
        %io:format("~n********~p********~n",[Node#matrixnode.index]),
        %io:format("~n********~p********~n",[Num]),
        List=Node#matrixnode.listMessage,
        UpdatedNode = Node#matrixnode{listMessage = List++[{Node#matrixnode.index,Num}]},
        %io:format("~n=======~p======~n",[UpdatedNode#matrixnode.listMessage]),
        sendMatrix(UpdatedNode,M,Num+1).           

killAll([]) ->  none;
killAll([H]) ->  H!{justDie};
killAll([H|T]) ->  H!{justDie},killAll(T).

%===================================================================================================================================================
%task 4

mesh_serial(N,M,C)->
if C rem N /= 0 ->
        R = 1;
    true ->
        R = 0
    end,
    %if has a left node
    if C rem N /= 1 ->
        L = 1;
    true ->
        L = 0
    end,
    %if up a left node
    if C > N ->
        U = 1;
    true ->
        U = 0
    end,
    % %if up a down node
    if C =< N*N - N ->
        D = 1;
    true ->
        D = 0
    end,
    Count = count_nonzero({L,R,U,D}),
    {X,_Y,_Z}=ring_serial(N*N*N*N,M),
    {X,M*Count,N*N*M}.


%counts number of relevant neighbors from the tupple
count_nonzero(Tuple) ->
    count_nonzero(Tuple, tuple_size(Tuple), 0).

count_nonzero(_, 0, Count) ->
    Count;

count_nonzero(Tuple, Index, Count) ->
    case element(Index, Tuple) of
        0 ->
            count_nonzero(Tuple, Index - 1, Count);
        _ ->
            count_nonzero(Tuple, Index - 1, Count + 1)
    end.
