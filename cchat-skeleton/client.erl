-module(client).
-export([handle/2, initial_state/3]).

% This record defines the structure of the state of a client.
% Add whatever other fields you need.
-record(client_st, {
    gui, % atom of the GUI process
    nick, % nick/username of the client
    server % atom of the chat server
}).

% Return an initial state record. This is called from GUI.
% Do not change the signature of this function.
initial_state(Nick, GUIAtom, ServerAtom) ->
    #client_st{
        gui = GUIAtom,
        nick = Nick,
        server = ServerAtom
    }.

% handle/2 handles each kind of request from GUI
% Parameters:
%   - the current state of the client (St)
%   - request data from GUI
% Must return a tuple {reply, Data, NewState}, where:
%   - Data is what is sent to GUI, either the atom `ok` or a tuple {error, Atom, "Error message"}
%   - NewState is the updated state of the client

% Join channel
handle(St, {join, Channel}) ->
    % TODO: Implement this function

    %{reply, join, St, ok, Channel};
    %{reply, join, St, ok, Channel};
    %fun(St, join) -> {reply, ok, St} end.
    %{reply, {error, not_implemented, "join not implemented"}, St} ;

%    fun(St, {join, Channel}) -> {reply, ok, St} end;

    %fun(Nick, {join, Channel}) -> {reply, ok, St} end;
    %fun(St, {join, Channel}) -> {reply, ok, St} end;
    %fun(St, join, Channel) -> {reply, ok, St} end;

    %fun(St, {join, Channel}) -> {reply, ok, {join, Channel}}end;


    %Works :) Need to add user_already_joined.
    {reply, ok, {join, Channel}};

    %{reply, ok, St} ;
% Leave channel
handle(St, {leave, Channel}) ->
    % TODO: Implement this function
    % {reply, ok, St} ;
    %%{reply, {error, not_implemented, "leave not implemented"}, St} ;

    {reply, ok, {leave, Channel}};

% Sending message (from GUI, to channel)
handle(St, {message_send, Channel, Msg}) ->
%%handle(St = #client_st{nick = Nick}, {message_send, Channel, Msg}) ->
%%handle(St = #client_st{nick = Nick}, {message_send, Channel, Nick, Msg}) ->
    % TODO: Implement this function
    % {reply, ok, St} ;

    %{{message_send, Channel, Msg}, self(), St};

    %fun(St, {message_send}) -> {reply, ok, {message_send, {Channel, Msg}}}end;

    %Shows up in the GUI on the sending actor, not the receiving actor. Fix!
    %%
    %io:format("State is: ~p", [St]),
    %%Crashes
    %[{_, CurrentChannel}] = St,
    %if
    %    CurrentChannel -> {reply, ok, {message_send, Channel, Msg}};
    %    true -> {reply, {error, user_not_joined, "User not joined channel"}, St}
    %end;
    %if currentChannel =:= Channel ->

    io:format("In the message_send method"),
    %[{Usernick,_,_}] = St,
    %io:format("--ST IS--~p~n", [St]),
    %io:format("--NICK IS--", [Nick]),

    %ST IS--{join,"#dev"}
    %io:format("--NICK IS: ", [Nick]),
    %St = Nick,

%{reply, ok, {message_send, Channel, Msg}, St};
{reply, ok, {message_send, Channel, Msg}};





    %%Doesn't work??
    %re:run(Channel, ["#"]) ->

    %{reply, ok, {message_send, Channel, Msg}};


    %{reply, ok, {message_send, Channel, Msg}} |
    %{reply, {error, user_not_joined, "User not joined channel"}, St}



    %%
    %%works, moved upwards to add "user_not_joined".
    %{reply, ok, {message_send, Channel, Msg}};

    %Just for testing to see if it worked.
    %fun(St, {message_send, Channel, Msg}) -> gen_server:call(Channel, {message_send, Channel, Msg}),
     %   {reply, ok, St}end;


    %{reply, {error, not_implemented, "message sending not implemented"}, St} ;

%Added, since it was missing - Receiving message (from channel to GUI)
%Not implemented in gui.erl => can be found below => leave as is?
handle(St, {message_receive, Channel, Msg}) ->
%handle(St = #client_st{gui = GUI}, {message_receive, Channel, Nick, Msg}) ->
%{reply, {error, not_implemented, "join not implemented"}, St} ;
    %%
    %receive {response, {message_receive, Channel, Msg}, St} -> result end.
    io:format("In the message_receiving method"),
    {reply, ok, {message_receive, Channel, Msg}};
    %gen_server:call(GUI, {message_receive, Channel, Nick++"> "++Msg}),
    %{reply, ok, St};

%%
%{reply, ok, {message_receive, Channel, Msg}};




% This case is only relevant for the distinction assignment!
% Change nick (no check, local only)
handle(St, {nick, NewNick}) ->
    {reply, ok, St#client_st{nick = NewNick}} ;

% ---------------------------------------------------------------------------
% The cases below do not need to be changed...
% But you should understand how they work!

% Get current nick
handle(St, whoami) ->
    {reply, St#client_st.nick, St} ;

% Incoming message (from channel, to GUI)
handle(St = #client_st{gui = GUI}, {message_receive, Channel, Nick, Msg}) ->
    gen_server:call(GUI, {message_receive, Channel, Nick++"> "++Msg}),
    {reply, ok, St} ;

% Quit client via GUI
handle(St, quit) ->
    % Any cleanup should happen here, but this is optional
    {reply, ok, St} ;

% Catch-all for any unhandled requests
handle(St, Data) ->
    {reply, {error, not_implemented, "Client does not handle this command"}, St} .
