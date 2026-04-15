-module(rpg2).

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

deal_damage(Myself, Myself = {chr, Id, _}, _Damage) ->
  io:format("~p cannot deal damage to themselves~n", [Id]),
  Myself;
deal_damage(From = {chr, Id1, [_, {level, LevelFrom}, _]}, To = {chr, Id2, [_, {level, LevelTo}, _]}, Damage) when LevelFrom =< LevelTo - 5 ->
  io:format("~p has reduced damage over ~p~n", [Id1, Id2]),
  deal_modified_damage(From, To, Damage * 0.5);
deal_damage(From = {chr, Id1, [_, {level, LevelFrom}, _]}, To = {chr, Id2, [_, {level, LevelTo}, _]}, Damage) when LevelFrom >= LevelTo + 5 ->
  io:format("~p has extra damage bonus over ~p~n", [Id1, Id2]),
  deal_modified_damage(From, To, Damage * 1.5);
deal_damage(From, To, Damage) ->
  deal_modified_damage(From, To, Damage).

deal_modified_damage(_From, {chr, Id, [{health, Health}, {level, Level}, {state, _State}]}, Damage) when Health =< Damage ->
  io:format("deal ~p damage to ~p, killing them~n", [Damage, Id]),
  make_character(Id, 0, Level);
deal_modified_damage(_From, {chr, Id, [{health, Health}, {level, Level}, {state, _State}]}, Damage) ->
  io:format("deal ~p damage to ~p~n", [Damage, Id]),
  make_character(Id, Health - Damage, Level).

heal(Myself, Myself = {chr, Id, [{health, _Health}, {level, Level}, {state, _State = alive}]}) ->
  io:format("heal ~p back to full health (~p)~n", [Id, ?HEALTH]),
  make_character(Id, ?HEALTH, Level);
heal(Myself, Myself = {chr, Id, _}) ->
  io:format("cannot heal ~p since they are not alive~n", [Id]),
  Myself;
heal(_NotMyself, Myself) ->
  io:format("a character can only heal themselves!~n", []),
  Myself.

run() ->
  Raith = make_character(raith, 1000, 6),
  Baddie = make_character(baddie, 1000, 6),
  print_character(Raith),
  print_character(Baddie),

  Baddie2 = deal_damage(Raith, Baddie, 100),
  print_character(Baddie2),
  
  Baddie3 = heal(Raith, Baddie2),
  print_character(Baddie3),
  
  Baddie3b = heal(Baddie3, Baddie3),
  print_character(Baddie3b),
  
  Baddie4 = deal_damage(Raith, Baddie3b, 500),
  print_character(Baddie4),
  
  Baddie5 = deal_damage(Raith, Baddie4, 500),
  print_character(Baddie5),

  Baddie6 = heal(Baddie5, Baddie5),
  print_character(Baddie6),
  
  Raith2 = deal_damage(Raith, Raith, 1000),
  print_character(Raith2),
  
  Giant = make_character(giant, 1000, 11),
  Tiddler = make_character(tiddler, 1000, 1),

  print_character(Giant),
  Giant2 = deal_damage(Raith, Giant, 100),
  print_character(Giant2),
  
  print_character(Tiddler),
  Tiddler2 = deal_damage(Raith, Tiddler, 100),
  print_character(Tiddler2),
  finished.

