-module(bstar_tree_tests).
-include_lib("eunit/include/eunit.hrl").

insert_test_() ->
    Tree = bstar_tree:new(),
    Tree1 = bstar_tree:insert(Tree, 1),
    Tree2 = bstar_tree:insert(Tree1, 2),
    Tree3 = bstar_tree:insert(Tree2, 3),
    ?assertEqual({3, [1, 2]}, bstar_tree:search(Tree3, 3)),
    Tree4 = bstar_tree:insert(Tree3, 4),
    Tree5 = bstar_tree:insert(Tree4, 5),
    Tree6 = bstar_tree:insert(Tree5, 6),
    ?assertEqual({6, [4, 5]}, bstar_tree:search(Tree6, 6)),
    Tree7 = bstar_tree:insert(Tree6, 7),
    Tree8 = bstar_tree:insert(Tree7, 8),
    Tree9 = bstar_tree:insert(Tree8, 9),
    Tree10 = bstar_tree:insert(Tree9, 10),
    ?assertEqual({10, [8, 9]}, bstar_tree:search(Tree10, 10)).
