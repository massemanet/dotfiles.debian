```erlang
H = fun(C, P, T) -> F = fun(G, W, S) -> G(G, W, W(S)) end, D = fun(S) -> P(Z = C(), S), Z end, W = fun(S) -> receive quit -> exit(normal) after T -> D(S) end end, register(loop, spawn(fun()->F(F,W,undefined) end)) end.
```

```erlang
C = fun() -> [(maps:from_list(case process_info(P) of undefined -> []; L -> L end))#{pid => P} || P <- processes()] end.
```

```erlang
N = fun(M) -> case {maps:get(registered_name, M, undefined), maps:get(initial_call, M, undefined)} of {undefined, {proc_lib,init_p,5}} -> try proc_lib:translate_initial_call(maps:get(pid,M)) catch _:_ -> dead end; {undefined, undefined} -> dead; {undefined,IC}->IC;{Reg, _} -> Reg end end.
```

```erlang
P = fun(_, undefined) -> ok; (S, Z) -> J = lists:foldl(fun(M,O) -> Name = N(M), case maps:get(Name,O,undefined) of undefined -> O#{Name=>1}; _C->O#{Name=>_C+1} end end, #{}, S), io:fwrite("~p~n",[lists:sort(maps:fold(fun(K,V,A)-> case 10<V of true->[{V,K}|A]; false -> A end end, [], J))]) end.
```

```erlang
H(C, P, 2000).
```
