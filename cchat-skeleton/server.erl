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


    ChannelPid = case maps:find(Channel, Channels) of
        {ok, Pid} -> Pid;
        error ->
            genserver:start(list_to_atom(Channel),[],fun handle/2)
        end,
    
    Result = genserver:request(ChannelPid, {join_channel, Member}),
    NewChannels = maps:put(Channel, ChannelPid, Channels),
    {reply, Result, State#{channels => NewChannels}};

handle(Members, {join_channel, Member}) ->
    case lists:member(Member, Members) of
        true ->
            {reply, {error, user_already_joined, "Already joined"}, Members};
        false ->
            {reply, ok, [Member | Members]}
    end;   


handle(Members, {leave, Member}) ->
    case lists:member(Member, Members) of
        true ->
            {reply, ok, lists:delete(Member, Members)};
        false ->
            {reply, {error, user_not_joined, "Not joined"}, Members}
    end;


handle(Members, {message_send, Channel, Sender, Nick, Msg}) ->
    case lists:member(Sender, Members) of
        false ->
            {reply, {error, user_not_joined, "Not joined"}, Members};
        true ->
            lists:foreach(
                fun(Member) ->
                    spawn(fun() ->
                        catch genserver:request(
                            Member,
                            {message_receive, Channel, Nick, Msg}
                        )
                    end)
                end,
                lists:delete(Sender, Members)
            ),
            {reply, ok, Members}
    end;


handle(State, get_channels) ->
    Channels = maps:get(channels, State, #{}),
    {reply, maps:values(Channels), State}.





% Stop the server process registered to the given name,
% together with any other associated processes
stop(ServerAtom) ->
    ChannelPids = genserver:request(ServerAtom, get_channels),
    lists:foreach(fun(Pid) -> genserver:stop(Pid) end,ChannelPids),
    genserver:stop(ServerAtom).
