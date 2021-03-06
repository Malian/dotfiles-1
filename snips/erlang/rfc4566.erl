%%% Do not modify this file, it is automatically generated by abnfc.
%%% All changes will be lost when it is regenerated.
%%% Generated by abnfc_gen on 2016-12-08 11:50:38

-module(rfc4566).

-export([parse/1, decode/2, proto_version/0, session_description/0]).

-define(Log(A), (fun(P) -> io:format("[~p:~p#~p] ~p~n", [?MODULE, ?FUNCTION_NAME, ?LINE, P]), P end)(A)).
-define(Token(X), fun(<<X, Rest/binary>>) ->
                          {ok, X, Rest};
                     (_Bin) ->
                          {fail, _Bin}
                  end).
parse(Str) ->
  decode(session_description, list_to_binary(Str)).

decode(session_description, Bin) ->
    (session_description())(Bin);

decode(proto_version, Bin) ->
    (proto_version())(Bin);

decode(origin_field, Bin) ->
    (origin_field())(Bin).

session_description() ->
    seq([
         proto_version(),
         origin_field()
        ]).

proto_version() ->
    Fn = seq([
              ?Token($v),
              ?Token($=),
              repeat(1, infinity, digit()),
              crlf()
             ]),
    fun(Bin) ->
            case Fn(Bin) of
                {ok, [$v, $=, Version, _CRLF], Rest} ->
                    {ok, {proto_version, Version}, Rest};
                {fail, _Bin} ->
                    {fail, _Bin}
            end
    end.

origin_field() ->
    Fn = seq([
              ?Token($o),
              ?Token($=),
              username(),
              sp(),
              sess_id(),
              crlf()
             ]),
    fun(Bin) ->
            case Fn(Bin) of
                {ok, [$o, $=, Username, _SP, SessID, _CRLF], Rest} ->
                    {ok, {origin_field, Username, SessID}, Rest};
                {fail, _Bin} ->
                    {fail, _Bin}
            end
    end.

username() -> non_ws_string().

sess_id() ->
    repeat(1, infinity, digit()).

non_ws_string() ->
    repeat(1, infinity, alt([
                             vchar(),
                             fun(<<C, Rest/binary>>) when (C >= 16#80) and (C =< 16#ff) ->
                                     {ok, C, Rest};
                                (_Bin) -> {fail, _Bin}
                             end
                            ])).

vchar() ->
    fun(<<C, Rest/binary>>) when (C >= 16#21) and (C =< 16#7E) ->
            {ok, C, Rest};
       (_Bin) ->
            {fail, _Bin}
    end.

digit() ->
    fun(<<C, Rest/binary>>) when (C >= 16#30) and (C =< 16#39) ->
            {ok, C, Rest};
       (_Bin) ->
            {fail, _Bin}
    end.

crlf() ->
    alt([
         lf(),
         seq([
              cr(),
              lf()
             ]
            )
        ]).

lf() -> ?Token(16#0A).
cr() -> ?Token(16#0D).

sp() -> ?Token(16#20).


alt(Fs) ->
    fun(Bin) ->
            alt(Fs, Bin)
    end.
alt([F | Fs], Bin) ->
    case F(Bin) of
        {ok, _R, _Rest} = Res -> Res;
        {fail, _} -> alt(Fs, Bin)
    end;
alt([], _Bin) -> {fail, _Bin}.

repeat(Min, Max, F) ->
    repeat(Min, Max, F, 0).
repeat(Min, Max, F, Found) ->
    fun(Bin) ->
            repeat(Min, Max, F, Found, Bin)
    end.
repeat(Min, Max, F, Found, Bin) ->
    case F(Bin) of
        {ok, Result1, Rest} when Max == Found + 1 ->
            {ok, [Result1], Rest};
        {ok, Result1, Rest} ->
            case repeat(Min, Max, F, Found + 1, Rest) of
                {ok, Result2, Rest2} ->
                    {ok, [Result1 | Result2], Rest2};
                {fail, _Bin} when Found >= Min ->
                    {ok, [Result1], Rest};
                {fail, _Bin} ->
                    {fail, _Bin}
            end;
        {fail, _} when Found >= Min ->
            {ok, [], Bin};
        {fail, _Bin} ->
            {fail, _Bin}
    end.

seq(Fs) ->
    fun(Bin) ->
            seq(Fs, Bin)
    end.
seq([F | Fs], Bin) ->
    case F(Bin) of
        {ok, Result1, Rest} ->
            case seq(Fs, Rest) of
                {ok, Result2, Rest2} ->
                    {ok, [Result1 | Result2], Rest2};
                {fail, _Bin} ->
                    {fail, _Bin}
            end;
        {fail, _Bin} ->
            {fail, _Bin}
    end;
seq([], Bin) ->
    {ok, [], Bin}.
