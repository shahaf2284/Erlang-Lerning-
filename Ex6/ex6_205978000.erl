%%%-----------------------------------------------------------------------------------------------------------------------
%%% Exm 6
%%% @The creator of the project: Shahaf Zohar
%%%                              205978000
%%% Created : 5. May 2023 13:42
%%%-----------------------------------------------------------------------------------------------------------------------
-module(ex6_205978000).
-export([songList/1,songGen/3]).


songList([]) -> empty;                % Case error; get empty list  
songList(Songs)-> G = digraph:new(),  % Creating graph 
        [digraph:add_vertex(G,X)|| X <- Songs],  % Append all songs to the graph as vertex
        completeG(G,Songs,1,length(Songs)),
        io:format("number of edges is:  ~p~n",[length(digraph:edges(G))]), G.

completeG(G,_,Index,N) when Index =:= N+1 -> G;     %stop recursive  function when N = Index 
completeG(G,Sng,Index,N) ->Heads = lists:map(fun(X)-> {hd(X),X} end, Sng -- [lists:nth(Index,Sng)]),   %Creation of a list of all the beginnings of the letters of the songs
        GNew = makeEdge(G,lists:nth(Index,Sng),Heads),  
        completeG(GNew,Sng,Index+1,N).

makeEdge(G,_X,[])-> G;
makeEdge(G,X,[H|T])->{Head,Vertex_i} = H, Y=lists:last(X),
    if                                                             %Creating an arc between vertices that meet the condition 
        Y =:= Head -> digraph:add_edge(G,X,Vertex_i),makeEdge(G,X,T);   %that the letters are equal, the final is equal to the initial    
        true -> makeEdge(G,X,T)
    end.

%=====================================================================================================================
% The songGen/3 function takes the graph created by songList/1 as input along 
%with the starting and ending vertices and returns the shortest path between
%them using the digraph:get_short_path/3 function.
songGen([],_Start,_End)->false;
songGen(G,Start,End)->digraph:get_short_path(G,Start,End).  % Reterning the shortest path in the graph