-module(server).
-export([start/1,stop/1]).

% Start a new server process with the given name
% Do not change the signature of this function.
start(ServerAtom) ->
    % TODO Implement function
    % - Spawn a new process which waits for a message, handles it, then loops infinitely
    % - Register this process to ServerAtom
    % - Return the process ID
    genserver:start(ServerAtom,#{},fun handle/2).

handle(State, {nick, Pid, NewNick}) ->
    Nicks = maps:get(nicks, State, #{}),
    case lists:member(NewNick, maps:values(Nicks)) of
        true ->
            {reply,{error, nick_taken, "nick_taken"}, State};
        false ->
            NewNicks = maps:put(Pid, NewNick, Nicks),
            {reply, ok, State#{nicks => NewNicks}}
    end;

handle(State, {join, Channel, Member}) ->
    Channels = maps:get(channels, State, #{}),
    Members = maps:get(Channel, Channels, []),
    case lists:member(Member, Members) of
        true -> {reply, {error, already_joined, "already_joined"}, State};
        false ->
            NewChannels = maps:put(Channel, [Member|Members], Channels),
            {reply, ok, State#{channels => NewChannels}}
    end.

% Stop the server process registered to the given name,
% together with any other associated processes
stop(ServerAtom) ->
    % TODO Implement function
    % Return ok
    genserver:stop(ServerAtom).
