-module(udpsrv).
-behaviour(gen_server).
-define(SERVER, ?MODULE).
-define(Addr, {224,0,0,251}).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-record(state, {socket}).
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
%    {ok, #state{}}.

    Port = 5000,
    {ok, Socket} = gen_udp:open(Port,[{reuseaddr,true}, {ip,?Addr}, {multicast_ttl,4}, {multicast_loop,true}, binary]),
    inet:setopts(Socket,[{add_membership,{{?Addr,{0,0,0,0}}}}]),

    gen_udp:send(Socket,?Addr,5000,erlang:atom_to_list(node())),
    error_logger:info_msg("Listen in port ~p~n", [Port]),

    net_kernel:monitor_nodes(true, []),
    
    {ok, #state{socket=Socket}}.

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({udp,_Socket,{_A,_B,_C,_D},_Port,String}, State) ->
    error_logger:info_msg("Received via INFO: ~p~n", [String]),
    case net_adm:ping(erlang:binary_to_atom(String, latin1)) of
	pong -> 
		% io:format("~w~n", nodes());
	    error_logger:info_msg("Node ~p has been attached~n", erlang:binary_to_atom(String, latin1));
	_ ->
	    io:format("Oops!~n")
	end,
    {noreply, State};

handle_info({nodedown, Nodename}, State)->
    error_logger:info_msg("Node ~p has gone down", Nodename),
    {noreply, State};

handle_info({nodeup, Nodename}, State)->
    error_logger:info_msg("Node ~p has up", Nodename),
    {noreply, State}.


terminate(_Reason, State) ->

    gen_udp:close(State#state.socket),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
