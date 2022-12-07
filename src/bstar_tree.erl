-module(bstar_tree).
-export([new/0, insert/2, search/2, delete/2]).

-type bstar_tree() :: #{root => undefined | bstar_node()}.
-type bstar_node() :: #{keys => [key()], children => [bstar_node()]}.
-type key() :: integer().


new() ->
    #{root => undefined}.

insert(Tree, Key) ->
    Tree#{root => insert(maps:get(root,Tree), Key, 3)}.

insert(undefined, Key, _Depth) ->
    #{keys => [Key], children => []};
insert(Node, Key, Depth) ->
    Keys = maps:get(keys, Node),
    case Key >= hd(Keys) of
        true ->
            case Key =:= hd(Keys) of
                true ->
                    Node;
                false ->
                    Index = lists:max([1, lastindex(hd(Keys), Keys) + 1]),
                    insert_at_index(Node, Key, Index, Depth)
            end;
        false ->
            case Key =:= tl(Keys) of
                true ->
                    Node;
                false ->
                    Index = lists:min([length(Keys), lists:firstindex(tl(Keys), Keys)]),
                    insert_at_index(Node, Key, Index, Depth)
            end
    end.

insert_at_index(Node, Key, Index, Depth) ->
    Keys = maps:get(keys, Node),
    Children = maps:get(children, Node),
    %% Original code:
    %% case length(Keys) < (1 bsl Depth) of
    case length(Keys) < Depth of
        true ->
            NewNode = Node#{keys => insert_at_index(Keys, Key, Index)},
            NewNode#{children => insert_at_index(Children, undefined, Index)};
        false ->
            %% Original code:
            %% {LeftKeys, RightKeys} = lists:split(Index - 1, Keys),
            %% {_LeftChildren, RightChildren} = lists:split(Index, Children),
            %% NewNode = Node#{keys => [Key | RightKeys]},
            %% NewNode#{children => [insert(hd(Children), hd(LeftKeys), Depth + 1) | RightChildren]}
            %%
            case {lists:split(Index - 1, Keys), lists:split(Index, Children)} of
                {{[] = _LeftKeys, RightKeys}, {_LeftChildren, RightChildren}} ->
                    NewNode = Node#{keys => [Key | RightKeys]},
                    NewNode#{children => [RightChildren]};
                {{LeftKeys, RightKeys}, {_LeftChildren, RightChildren}} ->
                    NewNode = Node#{keys => [Key | RightKeys]},
                    NewNode#{children => [insert(hd(Children), hd(LeftKeys), Depth + 1) | RightChildren]}
            end
    end.

insert_at_index([], Key, _) ->
    [Key];
insert_at_index(List, Key, Index) when length(List) >= Index ->
    [H | T] = List,
    [H | insert_at_index(T, Key, Index - 1)];
insert_at_index(List, Key, _) ->
    [Key | List].

search(#{root := Tree}, Key) ->
    search(Tree, Key);
search(undefined, _) ->
    false;
search(Node, Key) ->
    Keys = maps:get(keys, Node),
    Children = maps:get(children, Node),
    case lists:member(Key, Keys) of
        true ->
            Node;
        false ->
            case Key >= hd(Keys) of
                true ->
                    case Key =:= hd(Keys) of
                        true ->
                            search(hd(Children), Key);
                        false ->
                            Index = lists:max([1, lastindex(hd(Keys), Keys) + 1]),
                            search(lists:nth(Index, Children), Key)
                    end;
                false ->
                    case Key =:= tl(Keys) of
                        true ->
                            search(lists:nth(length(Children), Children), Key);
                        false ->
                            Index = lists:min([length(Keys), lists:firstindex(tl(Keys), Keys)]),
                            search(lists:nth(Index, Children), Key)
                    end
            end
    end.

delete(Tree, Key) ->
    Tree#{root => delete(maps:get(root, Tree), Key, 1)}.

delete(undefined, _, _) ->
    undefined;
delete(Node, Key, Depth) ->
    Keys = maps:get(keys, Node),
    Children = maps:get(children, Node),
    case Key >= hd(Keys) of
        true ->
            case Key =:= hd(Keys) of
                true ->
                    case length(Keys) == 1 of
                        true ->
                            hd(Children);
                        false ->
                            NewNode = Node#{keys => tl(Keys)},
                            NewNode#{children => tl(Children)}
                    end;
                false ->
                    Index = lists:max([1, lastindex(hd(Keys), Keys) + 1]),
                    NewNode = Node#{keys => replace_at_index(Keys, delete(lists:nth(Index, Children), Key, Depth), Index)},
                    NewNode#{children => replace_at_index(Children, undefined, Index)}
            end;
        false ->
            case Key =:= tl(Keys) of
                true ->
                    case length(Keys) == 1 of
                        true ->
                            lists:nth(length(Children), Children);
                        false ->
                            NewNode = Node#{keys => lists:delete(Key, Keys)},
                            NewNode#{children => lists:delete(undefined, Children)}
                    end;
                false ->
                    Index = lists:min([length(Keys), lists:firstindex(tl(Keys), Keys)]),
                    NewNode = Node#{keys => replace_at_index(Keys, delete(lists:nth(Index, Children), Key, Depth), Index)},
                    NewNode#{children => replace_at_index(Children, undefined, Index)}
            end
    end.

replace_at_index([], _, _) ->
    [];
replace_at_index(List, Element, Index) when length(List) >= Index ->
    [H | T] = List,
    [H | replace_at_index(T, Element, Index - 1)];
replace_at_index(List, Element, _) ->
    [Element | List].


lastindex(Key, List) ->
    lastindex(Key, List, 0, 0).

lastindex(_Key, [], LastPos, _Counter) ->
    LastPos;
lastindex(Key, [Key|Tail], _LastPos, Counter) ->
    lastindex(Key, Tail, Counter, Counter+1);
lastindex(Key, [_|Tail], LastPos, Counter) ->
    lastindex(Key, Tail, LastPos, Counter+1).
