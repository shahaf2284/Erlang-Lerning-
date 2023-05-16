
%%%-----------------------------------------------------------------------------------------------------------------------
%%% Exm 7
%%% @The creator of the project: Shahaf Zohar
%%%                              205978000
%%% Created : 14. May 2023 14:03
%%%-----------------------------------------------------------------------------------------------------------------------

-module(ex7_205978000).
%%---------------------------------------------API------------------------------------------------------------------------

-export([steady/1, calc/3]).
%-------------------------------------------------------------------------------------------------------------------------
steady(F)->
  {_,File} = file:open("myLog_205978000.elog", [append]),  %Open a file and call it File
  try F() of
    Return -> io:format(File,"~p~n",[{os:system_time(),success,Return}]) %%Success Case, no failure
  catch
    error:Error	-> io:format(File,"~p~n",[{os:system_time(), error, Error}]);  %Case "error" -> failure
    exit:Exit ->   io:format(File,"~p~n",[{os:system_time(),exit, Exit}]);     %Case "exit" -> failure
    throw:Throw->  io:format(File,"~p~n",[{os:system_time(), throw, Throw}])   %Case "throw" -> failure
  end.

%-------------------------------------------------------------------------------------------------------------------------
calc(division,A,B)->
  try A/B of
    Return-> Return                                  % Case that there was no failing, then return the result
  catch
    error:Error -> {os:system_time(), error, Error}  % Case that there was failing, than return
                                                     % tuple that indicate that was error
  end.
