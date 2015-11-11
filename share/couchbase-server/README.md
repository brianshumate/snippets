# Couchbase Server

This is a collection of snippets related to operating Couchbase Server
clusters organized into three areas of usefulness:

* Command Line
* REST API
* Web Console UI

## Command Line

Some of the following command line examples require utilities like:

* `curl`
* `jq`

### Backup Verification with SQLite

The `cbbackup` utility writes Couchbase Server backup data as SQLite database
files. After performing backups with `cbbackup`, you can inspect the files
to do some basic integrity checking and item count verification:

#### Check integrity of cbbackup SQLite file

```
sqlite3 <backup_file.cbb>
PRAGMA integrity_check;
```

The expected result is:

```
ok
```

#### Check item count in cbbackup SQLite file

```
sqlite3 <backup_file.cbb>
select count(*) from (select distinct key from cbb_msg);
```

### Capture Memcached Traffic

```
tcpdump -vvXSs src {source IP} and dst {destination IP} and port {11210} -w capture_file.pcap
```

### cbbackupwrapper / cbrestorewrapper

```
/opt/couchbase/bin/cbbackupwrapper http://centos-0663-brian.local:8091 -u Administrator -p couchbase -n 100 -v --path /opt/couchbase/bin /opt/couchbase_backups/
```

```
/opt/couchbase/bin/cbrestorewrapper -u Administrator -p couchbase --path /opt/couchbase/bin /opt/couchbase_backups/ http://centos-0663-brian.local:8091
```

### Count emfile Errors by Date

```
find . -name ns_server.error.log -print -exec sh -c "awk '/YYYY-MM-DDT/,/emfile/' {} | grep emfile | wc -l" \;
```

### Count vBucket Items per Bucket

Credit: Brent Woodruff

```
awk -v bucket=beer-sample 'BEGIN {v=0; while(v<1024) { command="/opt/couchbase/bin/cbstats localhost:11210 -b " bucket " vbucket-details " v; while( (command | getline o) > 0) {if(o ~ /num_items/) {sub(/:num_items:/, "", o); print o} } close(command); v++ } }'
```

### Detect Stuck vBuckets

Credit: Brent Woodruff

In some 3.x versions, a rebalance operation can hang due to stuck vBuckets.
The following `awk` script can help identify them:

```
cd /opt/couchbase/var/lib/couchbase/logs
for file in $(ls -tr memcached.log.*); 
do cat "$file"; done | awk -f /path/to/stuck_vbuckets.awk
```

You'll need [stuck_vbuckets.awk]() for the above command.

### Detect Uptime Change

```
egrep "^uptime|^\[ns_doctor" ns_server.stats.log
```

### Examine Rebalance Operations

```
egrep 'Starting rebalance|Rebalance completed|Rebalance exited' diag.log
```

### Find Bucket Deletion Events

```
grep 'for deletion' ns_server.info.log
```

Example output:

```
[user:info,2015-06-10T20:11:01.492Z,ns_1@node1.local:ns_memcached-fnord<0.13992.0>:ns_memcached:terminate:784]Shutting down bucket "fnord" on 'ns_1@node1.local' for deletion
```

### Generate a Keylist with couchdb-dump

```
/opt/couchbase/bin/couch_dbdump --no-body "$vbucket_file" | awk '/^     id: / {sub(/     id: /,""); print}' > keylist
```

### List Active vBuckets on Node

```
cbstats localhost:11210 -b default vbucket-details | grep active | cut -f1 -d: | cut -f2 -d_ | sort -n
```

### Logs

Use `cbcollect_info` to get a large collection of detailed logging
in a snapshot style. There are also log files in the Couchbase Server log
directory, `/opt/couchbase/var/lib/couchbase/logs` some of which are
human-readable.

### Read config.dat

The node configuration file `config.dat` is a binary formatted file; this
one-liner uses Erlang to print it to standard out in a human-readable format:

```
/opt/couchbase/bin/erl -noinput -eval 'case file:read_file("/opt/couchbase/var/lib/couchbase/config/config.dat") of {ok, B}  -> io:format("~p~n", [binary_to_term(B)]) end.' -run init stop
```

### Reset Couchbase Server Configuration

```
sudo service couchbase-server stop && \
sudo rm -rf rm /opt/couchbase/var/lib/couchbase/ip* && \
sudo rm -rf /opt/couchbase/var/lib/couchbase/config/config.dat && \
sudo rm -rf /opt/couchbase/var/lib/couchbase/data && \
sudo service couchbase-server start
```

### Run Access Log Scanner Manually

```
cbepctl -b <bucket> <node>:11210 set flush_param alog_sleep_time 2
```

### Access buckets with sleep

```
for i in {1..3}; do
sleep `expr $RANDOM % 90` && curl -u Administrator:password http://cb1.local:8091/pools/default/buckets | python -mjson.tool | grep hostname;
done
```

### View Key and Value from tcpdump with tshark

Get K/V from capture on get(opcode=0) request(magic=128):

```
tshark -r {capture}.pcap -R "tcp.port==11210 and memcache.opcode==0 and memcache.magic==128" -T fields -E separator=';' -e memcache.key -e memcache.value
```

With tshark => v1.99:

```
tshark -r {capture}.pcap -R "tcp.port==11210 and couchbase.opcode==0 and couchbase.magic==128" -T fields -E separator=';' -e couchbase.key -e couchbase.value
```

## REST API

### Change Maximum Buckets Number

```
curl -X POST -u Administrator:password http://localhost:8091/internalSettings -d 'maxBucketCount=6'
```

### Get Cluster Name

This is for Couchbase Server versions => 3.0.0:

```
curl -s -u Administrator:password http://localhost:8091/internalSettings/visual | jq -r '.tabName'
```

### Get Node Logs

```
curl -s -u Administrator:password http://localhost:8091/logs | jq '.'
```

### Get Node Statuses

```
curl -s -u Administrator:password http://localhost:8091/nodeStatuses | jq '.'
```

### Monitor View Indexing Progress

```
curl -s -X GET -u Administrator:password http://localhost:8091/pools/default/tasks | jq  --raw-output '.[] | select(.type=="indexer") | "\(.bucket) \(.designDocument) Completed \(.changesDone) of \(.totalChanges) \(.changesDone/.totalChanges)%" ' | column -t
```

### Diag Eval Endpoint Snippets

Couchbase Server provides a REST API endpoint at `/diag/eval` that 
for advanced node control and configuration. Typically, commands used with
this endpoint involved specialized knowledge of Couchbase Server internals,
and should not be taken lightly or used haphazardly.

#### Identify Cluster Orchestrator Node

```
curl -u Administrator:password http://localhost:8091/diag/eval -d 'node(global:whereis_name(ns_orchestrator)).'
```

#### Restart Cluster Manager

```
curl -u Administrator:password http://localhost:8091/diag/eval -d "erlang:halt()."
```

#### Restart Erlang Name Service

```
curl -u Administrator:password http://hostname:8091/diag/eval -d 'rpc:call(mb_master:master_node(), erlang, apply ,[fun () -> erlang:exit(erlang:whereis(mb_master), kill) end, []]).' 
```

#### Restart View Manager

```
curl -X POST -u Administrator:<password> http://<host>:8091/diag/eval -d 'rpc:eval_everywhere(erlang, apply, [fun () -> [exit(whereis(list_to_atom("capi_set_view_manager-" ++ B)), kill) || B <- ns_bucket:get_bucket_names(membase)] end, []]).'
```

#### Set ALE Log Level to Error

"ale:set_logelevel(ns_server, error)."

Massive general performance increase can be had with this setting at the
expense of less logging detail

## Web Console UI

### Activate Internal Settings

To activate the internal settings menu, you can append this URL fragment to
the web console UI address in your browser:

```
?enableInternalSettings=1
```

For example:

```
http://cb1.example.local:8091/?enableInternalSettings=1
```

## All Statistics

Use `cbstats` to get all node statistics for the *default* bucket:

```
cbstats node01.example.com:11210 all
```

This command example is to get stats only for the *fnord* bucket with
password authentication:

```
cbstats node01.example.com:11210 all -b fnord -p potrzebie
```
