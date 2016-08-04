-module({{name}}_SUITE).
-export([
         all/0,
         suite/0,
         groups/0,
         init_per_suite/1,
         end_per_suite/1,
         init_per_group/2,
         end_per_group/2,
         init_per_testcase/2,
         end_per_testcase/2
        ]).

-export([
         unit1/1,
         unit2/1,
         err1/1,
         err2/1,
         flush_all/1
        ]).

-include_lib("common_test/include/ct.hrl").
-include("ct_logger.hrl").

suite() ->
    [{timetrap, {seconds, 5}}].

init_per_suite(_Config) ->
    _Config.

end_per_suite(_Config) ->
    ok.

init_per_group(_GroupName, _Config) ->
    _Config.

end_per_group(_GroupName, _Config) ->
    ok.

init_per_testcase(_TestCase, _Config) ->
    _Config.

end_per_testcase(_TestCase, _Config) ->
    ok.

%% parallel: run on separate process
%% shuffle: execute random
%% shuffle, sequence: stop when fail
groups() ->
    [
     {
      success,
      [shuffle, sequence],
      [
       unit1,
       unit2,
       flush_all
      ]
     },
     {
      failure,
      [parallel],
      [
       err1,
       err2
      ]
     }
    ].

all() ->
    [
     {group, success},
     {group, failure}
    ].

unit1(_Config) ->
    unit1 = unit1.

unit2(_Config) ->
    unit1 = unit1.

err1(_Config) ->
    unit1 = unit1.

err2(_Config) ->
    unit1 = unit1.

flush_all(_Config) ->
    ok.
