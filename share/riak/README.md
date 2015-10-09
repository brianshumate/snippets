# Riak snippets

## Search cluster info logs

```bash
grep -E '^[a-zA-Z_]+ *<[0-9]\.[0-9]*\.[0-9]> *.*' cluster_info.txt | sort -k 1,1 -s | less
```

## Grab LevelDB LOG files:

```bash
mkdir leveldb_logs
cd leveldb_logs
for l in `ls -1 /var/lib/riak/leveldb/`; do cp /var/lib/riak/leveldb/$l/LOG ./LOG_$l; done
```

## Find LevelDB compaction errors:

```bash
find </path/to/leveldb> -name LOG -exec grep -l 'Compaction error' {} \;
```

## Ping a node with netcat:

```bash
echo -e "\x00\x00\x00\x01\x01" | nc 127.0.0.1 8087 | hexdump
```

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
