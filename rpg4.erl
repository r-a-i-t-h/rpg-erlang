-module(rpg4).

-compile([export_all, nowarn_export_all]).
-export([run/0]).

-record(chr, {
    name,
    level = 1,
    health = 1000,
    max_health = 1000,
    style = melee,
    factions
}).

range(melee) -> 2;
range(ranged) -> 20;
range(#chr{ style = Style }) when is_atom(Style) -> range(Style).

status(#chr{ health = 0 }) -> dead;
status(#chr{}) -> alive.

make_character(Name, Style) -> 
  #chr{name = Name, style = Style, factions = sets:new()}.
make_character(Name, Style, Health, Level) -> 
  #chr{name = Name, level = Level, health = Health, max_health = Health, style = Style, factions = sets:new()}.

chr_set_health(Chr = #chr{}, Health) ->
  Chr#chr{ health = Health }.

chr_adjust_health(Chr = #chr{ health = Health }, Adjustment) ->
  Chr#chr{ health = max(0, Health + Adjustment) }.

chr_change_style(Chr = #chr{}, Style) ->
  Chr#chr{ style = Style }.

chr_join_faction(Chr = #chr{ name = Name, factions = Factions }, Faction) ->
  io:format("~p joined faction ~p~n", [Name, Faction]),
  Chr#chr{ factions = sets:add_element(Faction, Factions)}.

chr_leave_faction(Chr = #chr{ name = Name, factions = Factions }, Faction) ->
  io:format("~p left faction ~p~n", [Name, Faction]),
  Chr#chr{ factions = sets:del_element(Faction, Factions)}.

are_enemies(#chr{ factions = Factions1 }, #chr{ factions = Factions2 }) -> 
  sets:is_empty(sets:intersection(Factions1, Factions2)).

are_allies(Chr1 = #chr{}, Chr2 = #chr{}) ->
  not are_enemies(Chr1, Chr2).

print_character(Chr) -> 
  io:format("chr: ~p = ~p~n~n", [Chr, status(Chr)]).

deal_damage(From = #chr{}, To = #chr{}, Distance, Damage) ->
  deal_damage(From, To, Distance, Damage, are_enemies(From, To)).

deal_damage(From = #chr{}, To = #chr{}, Distance, Damage, true) ->
  deal_damage_to_enemy(From, To, Distance, Damage);
deal_damage(#chr{ name = NameFrom }, To = #chr{ name = NameTo }, _, _, false) ->
  io:format("~p cannot deal damage to ally ~p~n", [NameFrom, NameTo]),
  To.

deal_damage_to_enemy(From = #chr{}, To = #chr{}, Distance, Damage) ->
  deal_damage_to_enemy(From, To, Distance, Damage, range(From)).

deal_damage_to_enemy(From = #chr{}, To = #chr{}, Distance, Damage, Range) when Range >= Distance ->
  deal_damage_within_range(From, To, Damage);
deal_damage_to_enemy(#chr{ name = NameFrom }, To = #chr{ name = NameTo }, _, _, _) ->
  io:format("~p is out of range of ~p~n", [NameFrom, NameTo]),
  To .

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

heal(From = #chr{}, To = #chr{}) ->
  heal(From, To, are_allies(From, To)).

heal(From = #chr{}, To = #chr{}, true) ->
    heal_ally(From, To);
heal(#chr{ name = NameFrom }, To = #chr{ name = NameTo }, false) ->
  io:format("~p cannot heal enemy ~p~n", [NameFrom, NameTo]),
  To.

heal_ally(#chr{ name = NameFrom }, To = #chr{ name = NameTo, health = Health }) when Health > 0 ->
  io:format("~p heals ally ~p back to full health (~p)~n", [NameFrom, NameTo, To#chr.max_health]),
  chr_set_health(To, To#chr.max_health);
heal_ally(#chr{ name = NameFrom }, To = #chr{ name = NameTo }) ->
  io:format("~p cannot heal ~p since they are not alive~n", [NameFrom, NameTo]),
  To.

run() ->
  Raith = make_character(raith, melee),
  Greeney = make_character(greeney, melee),
  Bluey = make_character(bluey, melee),
  Reddy = make_character(reddy, melee),
  G2 = chr_join_faction(Greeney, green),
  B2 = chr_join_faction(Bluey, blue),
  R2 = chr_join_faction(Reddy, red),
  Raith2 = chr_join_faction(Raith, green),
  Raith3 = chr_join_faction(Raith2, blue),
  Raith4 = chr_join_faction(Raith3, red),
  deal_damage(Raith4, G2, 0, 1),
  deal_damage(Raith4, B2, 0, 1),
  deal_damage(Raith4, R2, 0, 1),
  Raith5 = chr_leave_faction(Raith4, blue),
  Raith6 = chr_leave_faction(Raith5, red),
  deal_damage(Raith6, G2, 0, 1),
  deal_damage(Raith6, B2, 0, 1),
  deal_damage(Raith6, R2, 0, 1),
  G3 = chr_leave_faction(G2, green),
  deal_damage(Raith6, G3, 0, 1),
  deal_damage(Raith6, G3, 10, 1000),
  heal(G3, B2),
  G4 = chr_join_faction(G3, blue),
  heal(G4, B2),
  Solo1 = make_character(solo1, melee),
  Solo2 = make_character(solo2, melee),
  io:format("Two solo characters (not in any faction) are enemies? = ~p~n", [are_enemies(Solo1, Solo2)]),
  heal(Solo1, Solo2),
  finished.
