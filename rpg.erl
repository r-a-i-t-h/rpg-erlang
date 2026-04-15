-module(rpg).

-export([clean/0]).

clean() ->
  [file:delete(File) || File <- filelib:wildcard("*.beam")].
