-module(bstar_tree_tests).
-include_lib("eunit/include/eunit.hrl").
-include_lib("quviq/include/eqc.hrl").

insert_test_() ->
    ?FORALL(KeyList, list(pos_integer()),
        Tree = bstar_tree:new(),
        KeyList1 = lists:sort(KeyList),
        lists:foreach(fun(Key) -> bstar_tree:insert(Tree, Key) end, KeyList1),
        lists:foreach(fun(Key) ->
            ?assertEqual({Key, ParentKey}, bstar_tree:search(Tree, Key))
        end, KeyList1))
    .
