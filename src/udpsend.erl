-module(udpsend).
-export([start/0]).
-define (Addr, {224,0,0,251}).
%-define (Myaddr, {10,10,174,118}).
-define (IAddr, {0,0,0,0}).
-define (Port, 5000).

start() ->

{ok, Socket} = gen_udp:open(5000, [binary, {active, false}, {reuseaddr, true},
                                        {ip, ?Addr}, {add_membership, {?Addr, ?IAddr}}]),
    gen_udp:send(Socket,?Addr,5000,erlang:atom_to_list(node())),
    gen_udp:close(Socket).
