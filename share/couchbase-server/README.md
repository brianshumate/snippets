# Couchbase Server

This is a collection of snippets related to operating Couchbase Server
clusters organized into three areas of usefulness:

* [Command Line](#command-line)
* [REST API](#rest-api)
* [Views](#views)
* [Web Console UI](#web-console-ui)

## Command Line

Some of the following command line examples require utilities like:

* `curl`
* `jq`
* `sqlite`
* `tcpdump`

### Backup Verification with SQLite

The `cbbackup` utility writes Couchbase Server backup data as SQLite database
files. After performing backups with `cbbackup`, you can inspect the files
to do some basic integrity checking and item count verification:

#### Check integrity of cbbackup SQLite file

```shell
sqlite3 <backup_file.cbb>
PRAGMA integrity_check;
```

The expected result is:

```
ok
```

#### Check item count in cbbackup SQLite File

```
sqlite3 <backup_file.cbb>
select count(*) from (select distinct key from cbb_msg);
```

**NOTE**: This is the count of items in a bucket for one node.

#### Check item counts for all buckets in cbbackup SQLite files

This `bash` snippet will emit bucket name and total count for all buckets
in a `cbbackup` target directory:

```
for bucket in $(find . -type d -name 'bucket-*'); do
  BUCKET_NAME="$(basename ${bucket})"
  BUCKET_COUNT="$(find ${bucket} -name '*.cbb' -exec sqlite3 {} 'select key from cbb_msg' \; | wc -l)"
  echo "${BUCKET_NAME} ${BUCKET_COUNT}"
done
```

#### Generate Keylist for Each Bucket from cbbackup SQLite Files

From the top-level `cbbackup` target directory, do:

```
for bucket in $(find . -type d -name 'bucket-*'); do
  BUCKET_NAME="$(basename ${bucket})"
  find ${bucket} -name '*.cbb' -exec sqlite3 {} 'select key from cbb_msg' \; > ${BUCKET_NAME}_keylist.txt
done
```

### Capture Memcached Traffic

```shell
tcpdump -vvXSs src {source IP} and dst {destination IP} and port {11210} -w capture_file.pcap
```

### cbbackupwrapper / cbrestorewrapper

```shell
/opt/couchbase/bin/cbbackupwrapper http://centos-0663-brian.local:8091 -u Administrator -p couchbase -n 100 -v --path /opt/couchbase/bin /opt/couchbase_backups/
```

```shell
/opt/couchbase/bin/cbrestorewrapper -u Administrator -p couchbase --path /opt/couchbase/bin /opt/couchbase_backups/ http://centos-0663-brian.local:8091
```

### Count emfile Errors by Date

```shell
find . -name ns_server.error.log -print  \
-exec sh -c "awk '/YYYY-MM-DDT/,/emfile/' {} | grep emfile | wc -l" \;
```

### Count Error Instances

Example: find and count errors for a date:

Find `exception exit` errors for December 5th:

```
SEARCHDATE="2015-12-05"; for e in cbcollect_info_*/ns_server.error.log; do \
printf "[${SEARCHDATE}] $(echo ${e} | cut -d'@' -f2 | cut -d'_' -f1) "; \
grep -A 7 "${SEARCHDATE}" "${e}" | grep 'exception exit' -A 8 | wc -l; done
```

Example output:

```
[2015-12-05] cbnode0.local      129
[2015-12-05] cbnode1.local      139
[2015-12-05] cbnode2.local      159
[2015-12-05] cbnode3.local     1699
[2015-12-05] cbnode4.local      229
[2015-12-05] cbnode5.local      399
[2015-12-05] cbnode6.local       89
[2015-12-05] cbnode7.local       19
```

Further narrow down to errors specifically about the `dir_size()` function:

```
SEARCHDATE="2015-12-05"; for e in cbcollect_info_*/ns_server.error.log; do \
printf "[${SEARCHDATE}] $(echo ${e} | cut -d'@' -f2 | cut -d'_' -f1) "; \
grep -A 7 "${SEARCHDATE}" "${e}" | grep 'exception exit' -A 8 | \
grep dir_size | wc -l; done
```

Example output:

```
[2015-12-05] cbnode0.local        0
[2015-12-05] cbnode1.local        0
[2015-12-05] cbnode2.local        0
[2015-12-05] cbnode3.local        4
[2015-12-05] cbnode4.local        6
[2015-12-05] cbnode5.local        0
[2015-12-05] cbnode6.local        0
[2015-12-05] cbnode7.local        1
```

### Determine Node and VBucket Information for Item


You can find a key's vBucket or node with the `vbuckettool` command:

```
curl http://<node>:8091/pools/default/buckets/<bucket> \
| /opt/couchbase/bin/tools/vbuckettool - <key>
```

Output looks like:

```
key: demo_key master: <node>:11210
```
### Count vBucket Items per Bucket

Credit: Brent Woodruff

```shell
awk -v bucket=tacos 'BEGIN {v=0; while(v<1024) { command="/opt/couchbase/bin/cbstats localhost:11210 -b " bucket " vbucket-details " v; while( (command | getline o) > 0) {if(o ~ /num_items/) {sub(/:num_items:/, "", o); print o} } close(command); v++ } }'
```

### Detect Data Loss

Some types of data loss during rebalance scenarios can be found with:


```shell
grep -e 'Data has been lost' -e 'Lost data in' diag.log
```

### Detect Stuck vBuckets

Credit: Brent Woodruff

In some 3.x versions, a rebalance operation can hang due to stuck vBuckets.
The following `awk` script can help identify them:

```shell
cd /opt/couchbase/var/lib/couchbase/logs
  for file in $(ls -tr memcached.log.*); do 
  cat "$file"; done | awk -f /path/to/stuck_vbuckets.awk
done
```

You'll need the [stuck_vbuckets.awk](https://raw.githubusercontent.com/brianshumate/snippets/master/share/couchbase-server/stuck_vbuckets.awk) awk
script for the above command.

### Detect Uptime Change

```shell
egrep "^uptime|^\[ns_doctor" ns_server.stats.log
```

### Examine Rebalance Operations

```shell
egrep 'Starting rebalance|Rebalance completed|Rebalance exited' diag.log
```

### Find Bucket Deletion Events

```shell
grep 'for deletion' ns_server.info.log
```

Example output:

```
[user:info,2015-06-10T20:11:01.492Z,ns_1@node1.local:ns_memcached-fnord<0.13992.0>:ns_memcached:terminate:784]Shutting down bucket "fnord" on 'ns_1@node1.local' for deletion
```

### Generate a Keylist with couchdb-dump

```shell
/opt/couchbase/bin/couch_dbdump --no-body "$vbucket_file" | awk '/^     id: / {sub(/     id: /,""); print}' > keylist
```

### List Active vBuckets on Node

```shell
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

```shell
/opt/couchbase/bin/erl -noinput -eval 'case file:read_file("/opt/couchbase/var/lib/couchbase/config/config.dat") of {ok, B}  -> io:format("~p~n", [binary_to_term(B)]) end.' -run init stop
```

### Reset Couchbase Server Configuration

```shell
sudo service couchbase-server stop && \
sudo rm -rf rm /opt/couchbase/var/lib/couchbase/ip* && \
sudo rm -rf /opt/couchbase/var/lib/couchbase/config/config.dat && \
sudo rm -rf /opt/couchbase/var/lib/couchbase/data && \
sudo service couchbase-server start
```

### Run Access Log Scanner Manually

```shell
cbepctl -b <bucket> <node>:11210 set flush_param alog_sleep_time 2
```

### Access buckets with sleep

```shell
for i in {1..3}; do
  sleep `expr $RANDOM % 90` && curl -u Administrator:password http://cb1.local:8091/pools/default/buckets | python -mjson.tool | grep hostname;
done
```

### View Key and Value from tcpdump with tshark

Get K/V from capture on get(opcode=0) request(magic=128):

```shell
tshark -r {capture}.pcap -R "tcp.port==11210 and memcache.opcode==0 and memcache.magic==128" -T fields -E separator=';' -e memcache.key -e memcache.value
```

With tshark => v1.99:

```shell
tshark -r {capture}.pcap -R "tcp.port==11210 and couchbase.opcode==0 and couchbase.magic==128" -T fields -E separator=';' -e couchbase.key -e couchbase.value
```

## REST API

### Change Maximum Buckets Number

```shell
curl -X POST -u Administrator:password http://localhost:8091/internalSettings -d 'maxBucketCount=6'
```

### Directory of Statistics Endpoints

```
http http://cb1.local:8091/pools/default/buckets/default/statsDirectory
```

### Get Cluster Name

This is for Couchbase Server versions => 3.0.0:

```shell
curl -s -u Administrator:password http://localhost:8091/internalSettings/visual | jq -r '.tabName'
```

### Get Documents List

```
curl -u Administrator:password http://localhost:8091/pools/default/buckets/default/docs
```

### Get Random Key

```
curl -v http://localhost:8091/pools/default/buckets/default/localRandomKey
```

### Get Node Logs

```shell
curl -s -u Administrator:password http://localhost:8091/logs | jq '.'
```

### Get Node Statuses

```shell
curl -s -u Administrator:password http://localhost:8091/nodeStatuses | jq '.'
```

### Monitor View Indexing Progress

```shell
curl -s -X GET -u Administrator:password http://localhost:8091/pools/default/tasks | jq  --raw-output '.[] | select(.type=="indexer") | "\(.bucket) \(.designDocument) Completed \(.changesDone) of \(.totalChanges) \(.changesDone/.totalChanges)%" ' | column -t
```

### Diag Eval Endpoint Snippets

Couchbase Server provides a REST API endpoint at `/diag/eval` that 
for advanced node control and configuration. Typically, commands used with
this endpoint involved specialized knowledge of Couchbase Server internals,
and should not be taken lightly or used haphazardly.

#### Identify Cluster Orchestrator Node

```shell
curl -u Administrator:password http://localhost:8091/diag/eval -d 'node(global:whereis_name(ns_orchestrator)).'
```

#### Restart Cluster Manager

```shell
curl -u Administrator:password http://localhost:8091/diag/eval -d "erlang:halt()."
```

#### Restart Erlang Name Service

```shell
curl -u Administrator:password http://hostname:8091/diag/eval -d 'rpc:call(mb_master:master_node(), erlang, apply ,[fun () -> erlang:exit(erlang:whereis(mb_master), kill) end, []]).' 
```

#### Restart View Manager

```shell
curl -X POST -u Administrator:<password> http://<host>:8091/diag/eval -d 'rpc:eval_everywhere(erlang, apply, [fun () -> [exit(whereis(list_to_atom("capi_set_view_manager-" ++ B)), kill) || B <- ns_bucket:get_bucket_names(membase)] end, []]).'
```

#### Set ALE Log Level to Error

This can be set via `/diag/eval` endpoint or in the `static_config` file.

A general performance increase can be had with all logs set to 
error at the expense of less logging detail

FIXME: this needs updating:

```shell
curl -X POST -u Administrator:<password> http://<host>:8091/diag/eval -d 'ale:set_logelevel(ns_server, error).'
```

Edit static file (instead of above):
```
$EDITOR /opt/couchbase/etc/couchbase/static_config
```

Change log level for desired components as appropriate; here are the defaults:

```
{loglevel_default, debug}.
{loglevel_couchdb, info}.
{loglevel_ns_server, debug}.
{loglevel_error_logger, debug}.
{loglevel_user, debug}.
{loglevel_menelaus, debug}.
{loglevel_ns_doctor, debug}.
{loglevel_stats, debug}.
{loglevel_rebalance, debug}.
{loglevel_cluster, debug}.
{loglevel_views, debug}.
{loglevel_mapreduce_errors, debug}.
{loglevel_xdcr, debug}.
{loglevel_xdcr_trace, error}.
{loglevel_access, info}.
```

## Views

### Get Document Sizes

Map function:

```javascript
function(doc, meta) {
    emit(meta.id, JSON.stringify(doc).length);
}
```

Reduce function:

Use the built-in `_stats` reduce function.

Output:

```json
{
    "rows": [{
        "key": null,
        "value": {
            "sum": 2760276,
            "count": 9001,
            "min": 300,
            "max": 308,
            "sumsqr": 846481068
        }
    }]
}
```

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

```shell
cbstats node01.example.com:11210 all
```

This command example is to get stats only for the *fnord* bucket with
password authentication:

```shell
cbstats node01.example.com:11210 all -b fnord -p potrzebie
```
