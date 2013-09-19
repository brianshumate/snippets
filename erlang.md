Riak Snippets
=============

## Determine Open File Limits from Erlang

To verify that Riak is using the correct open file limits setting, use
`riak attach`, and issue the following command:

```
os:cmd("ulimit -n").
```

To check open file limits on a remote node, use this command:

```
rpc:call('riak@node07.example.com', os, cmd, ["ulimit -n"]).
```

Don't forget to **CONTROL-D** out of the `riak attach` session.

## Count Keys in a Node's Bitcask

To count the keys in an individual node's Bitcask backend, use `riak attach`,
and issue the following command:

```
riak_kv_bitcask_backend:key_counts().
```

Don't forget to **CONTROL-D** out of the `riak attach` session.

## Member Status and Ring Status

You can get `riak admin member-status` and `riak-admin ring-status` output
from the console, by using `riak attach` and the following commands:

```
riak_core_console:member_status([]).
riak_core_console:ring_status([]).
```

Don't forget to **CONTROL-D** out of the `riak attach` session.

## Determine Preflist for a Key

From `riak attach`, execute the following code to find the preflist for a key:

```erlang
f(),PList=fun(Bucket,Key) when is_binary(Bucket),is_binary(Key) ->
    {ok,Ring} = riak_core_ring_manager:get_my_ring(),
    DocIdx = riak_core_util:chash_key({Bucket,Key}),
    {ok,C} = riak:local_client(),
    Props = C:get_bucket(Bucket),
    Nval = proplists:get_value(n_val,Props),
    AllPref = riak_core_ring:preflist(DocIdx,Ring),
    {Pref,_} = lists:split(Nval,AllPref),
    Pref
    end.
```

Call the function like so:

```
PList(<<"bucket">>,<<"key">>).
```

Output looks like this:

```
[{298582611803841718934712433883646521460354973696,
  'riak@node07.example.com'},
 {192616659074364247891161938651510223838445679680,
  'riak@node08.example.com'},
 {252003558408573547955522474920030365824602865664,
  'riak@node09.example.com'}]
```

Don't forget to **CONTROL-D** out of the `riak attach` session.

## Remote Shell

To get a remote Erlang shell on a Riak node, use the following `erl` command:

```bash
erl -remsh riak@node07.example.com -setcookie riak
```

Note that a few things are different about the remote shell (or remsh):

1. Exit the console with **CONTROL-G q**
2. Lager messages will not be present in a remote shell console
3. The shell can be affected by load and network much as a ssh connection can, and will become unresponsive in such cases
