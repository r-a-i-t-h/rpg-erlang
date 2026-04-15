-module(rpg1).

-compile([export_all, nowarn_export_all]).
-export([run/0]).

-define(HEALTH, 1000).

make_character(Id) -> 
  make_character(Id, ?HEALTH, 1).
make_character(Id, 0, Level) -> 
  {chr, Id, [{health, 0}, {level, Level}, {state, dead}]};
make_character(Id, Health, Level) -> 
  {chr, Id, [{health, Health}, {level, Level}, {state, alive}]}.

print_character(Chr) -> 
  io:format("chr: ~p~n~n", [Chr]).

deal_damage(_From, {chr, Id, [{health, Health}, {level, Level}, {state, _State}]}, Damage) when Health =< Damage ->
  io:format("deal ~p damage to ~p, killing them~n", [Damage, Id]),
  make_character(Id, 0, Level);
deal_damage(_From, {chr, Id, [{health, Health}, {level, Level}, {state, _State}]}, Damage) ->
  io:format("deal ~p damage to ~p~n", [Damage, Id]),
  make_character(Id, Health - Damage, Level).

heal(_From, {chr, Id, [{health, _Health}, {level, Level}, {state, _State = alive}]}) ->
  io:format("heal ~p back to full health (~p)~n", [Id, ?HEALTH]),
  make_character(Id, ?HEALTH, Level);
heal(_From, To = {chr, Id, _}) ->
  io:format("cannot heal ~p since they are not alive~n", [Id]),
  To.

run() ->
  Raith = make_character(raith),
  Baddie = make_character(baddie),
  print_character(Raith),
  print_character(Baddie),

  Baddie2 = deal_damage(Raith, Baddie, 100),
  print_character(Baddie2),
  
  Baddie3 = heal(Raith, Baddie2),
  print_character(Baddie3),
  
  Baddie4 = deal_damage(Raith, Baddie3, 500),
  print_character(Baddie4),
  
  Baddie5 = deal_damage(Raith, Baddie4, 500),
  print_character(Baddie5),

  Baddie6 = heal(Raith, Baddie5),
  print_character(Baddie6),
  finished.

