-module(rpg3).

-compile([export_all, nowarn_export_all]).
-export([run/0]).

-record(chr, {
    name,
    level = 1,
    health = 1000,
    max_health = 1000,
    style = melee
}).

range(melee) -> 2;
range(ranged) -> 20;
range(#chr{ style = Style }) when is_atom(Style) -> range(Style).

status(#chr{ health = 0 }) -> dead;
status(#chr{}) -> alive.

make_character(Name, Style) -> 
  #chr{name = Name, style = Style}.
make_character(Name, Style, Health, Level) -> 
  #chr{name = Name, level = Level, health = Health, max_health = Health, style = Style}.

chr_set_health(Chr = #chr{}, Health) ->
  Chr#chr{ health = Health }.

chr_adjust_health(Chr = #chr{ health = Health }, Adjustment) ->
  Chr#chr{ health = max(0, Health + Adjustment) }.

chr_change_style(Chr = #chr{}, Style) ->
  Chr#chr{ style = Style }.

print_character(Chr) -> 
  io:format("chr: ~p = ~p~n~n", [Chr, status(Chr)]).

deal_damage(Myself, Myself = #chr{ name = Name }, _, _) ->
  io:format("~p cannot deal damage to themselves~n", [Name]),
  Myself;
deal_damage(From = #chr{ name = NameFrom }, To = #chr{ name = NameTo }, Distance, Damage) ->
  FromRange = range(From),
  if FromRange >= Distance -> 
    deal_damage_within_range(From, To, Damage);
  true -> 
    io:format("~p is out of range of ~p~n", [NameFrom, NameTo]),
    To 
  end.

deal_damage_within_range(From = #chr{ name = NameFrom, level = LevelFrom }, To = #chr{ name = NameTo, level = LevelTo }, Damage) when LevelFrom =< LevelTo - 5 ->
  io:format("~p has reduced damage over ~p~n", [NameFrom, NameTo]),
  deal_modified_damage(From, To, Damage * 0.5);
deal_damage_within_range(From = #chr{ name = NameFrom, level = LevelFrom }, To = #chr{ name = NameTo, level = LevelTo }, Damage) when LevelFrom >= LevelTo + 5 ->
  io:format("~p has extra damage bonus over ~p~n", [NameFrom, NameTo]),
  deal_modified_damage(From, To, Damage * 1.5);
deal_damage_within_range(From, To, Damage) ->
  deal_modified_damage(From, To, Damage).

deal_modified_damage(#chr{ name = NameFrom }, To = #chr{ name = NameTo, health = Health }, Damage) when Health =< Damage ->
  io:format("~p deals ~p damage to ~p, killing them~n", [NameFrom, Damage, NameTo]),
  chr_set_health(To, 0);
deal_modified_damage(#chr{ name = NameFrom }, To = #chr{ name = NameTo }, Damage) ->
  io:format("~p deals ~p damage to ~p~n", [NameFrom, Damage, NameTo]),
  chr_adjust_health(To, -Damage).

heal(Myself, Myself = #chr{ name = Name, health = Health }) when Health > 0 ->
  io:format("heal ~p back to full health (~p)~n", [Name, Myself#chr.max_health]),
  chr_set_health(Myself, Myself#chr.max_health);
heal(Myself, Myself = #chr{ name = Name }) ->
  io:format("cannot heal ~p since they are not alive~n", [Name]),
  Myself;
heal(_NotMyself, Myself) ->
  io:format("a character can only heal themselves!~n", []),
  Myself.

run() ->
  Raith = make_character(raith, ranged, 1000, 6),
  Baddie = make_character(baddie, melee, 1000, 6),
  print_character(Raith),
  print_character(Baddie),

  Baddie1 = deal_damage(Raith, Baddie, 21, 100),
  print_character(Baddie1),

  Baddie2 = deal_damage(Raith, Baddie1, 10,100),
  print_character(Baddie2),
  
  Baddie3 = heal(Raith, Baddie2),
  print_character(Baddie3),
  
  Baddie3b = heal(Baddie3, Baddie3),
  print_character(Baddie3b),
  
  Baddie4 = deal_damage(Raith, Baddie3b, 10, 500),
  print_character(Baddie4),
  
  Baddie5 = deal_damage(Raith, Baddie4, 10, 500),
  print_character(Baddie5),

  Baddie6 = heal(Baddie5, Baddie5),
  print_character(Baddie6),
  
  Raith2 = deal_damage(Raith, Raith, 0, 1000),
  print_character(Raith2),
  
  Giant = make_character(giant, melee, 1000, 11),
  Tiddler = make_character(tiddler, melee, 1000, 1),

  print_character(Giant),
  Giant2 = deal_damage(Raith, Giant, 10, 100),
  print_character(Giant2),
  
  print_character(Tiddler),
  Tiddler2 = deal_damage(Raith, Tiddler, 10, 100),
  print_character(Tiddler2),

  Tiddler3 = deal_damage(Giant, Tiddler2, 3, 100),
  print_character(Tiddler3),

  Tiddler4 = deal_damage(Giant, Tiddler3, 2, 100),
  print_character(Tiddler4),
  finished.

