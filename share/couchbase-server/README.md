# Couchbase Server

This is a collection of snippets related to operating Couchbase Server
clusters organized into three areas of usefulness:

* Command Line
* REST API
* Web Console UI

## Command Line

### Detect Stuck vBuckets

In some 3.x versions, a rebalance operation can hang due to stuck vBuckets.
The following `awk` script can help identify them:

```
cd /opt/couchbase/var/lib/couchbase/logs
for file in $(ls -tr memcached.log.*); 
do cat "$file"; done | awk -f /path/to/stuck_vbuckets.awk
```

You'll need [stuck_vbuckets.awk]() for the above command.

### Logs

Use `cbcollect_info` to get a large collection of detailed logging
in a snapshot style. There are also log files in the Couchbase Server log
directory, `/opt/couchbase/var/lib/couchbase/logs` some of which are
human-readable.

#### Find Bucket Deletion Events

```
grep 'for deletion' ns_server.info.log
```

Example output:

```
[user:info,2015-06-10T20:11:01.492Z,ns_1@node1.local:ns_memcached-fnord<0.13992.0>:ns_memcached:terminate:784]Shutting down bucket "fnord" on 'ns_1@node1.local' for deletion
```

### Read config.dat

The node configuration file `config.dat` is a binary formatted file; this
one-liner uses Erlang to print it to standard out in a human-readable format:

```
/opt/couchbase/bin/erl -noinput -eval 'case file:read_file("/opt/couchbase/var/lib/couchbase/config/config.dat") of {ok, B}  -> io:format("~p~n", [binary_to_term(B)]) end.' -run init stop
```

### Run Access Log Scanner Manually

```
cbepctl -b <bucket> <node>:11210 set flush_param alog_sleep_time 2
```

### Access buckets with sleep

```
for i in {1..3}; do
sleep `expr $RANDOM % 90` && curl -u Administrator:couchbase http://cb1.local:8091/pools/default/buckets | python -mjson.tool | grep hostname;
done
```

### Check item count in cbbackup SQLite files

```
sqlite3 <backup_file.cbb>
select count(*) from (select distinct key from cbb_msg);
```

### cbbackupwrapper / cbrestorewrapper

```
/opt/couchbase/bin/cbbackupwrapper http://centos-0663-brian.local:8091 -u Administrator -p couchbase -n 100 -v --path /opt/couchbase/bin /opt/couchbase_backups/
```

```
/opt/couchbase/bin/cbrestorewrapper -u Administrator -p couchbase --path /opt/couchbase/bin /opt/couchbase_backups/ http://centos-0663-brian.local:8091
```

### Generate a keylist with couchdb-dump

```
/opt/couchbase/bin/couch_dbdump --no-body "$vbucket_file" | awk '/^     id: / {sub(/     id: /,""); print}' > keylist
```

## REST API

### Diag Eval Endpoint Snippets

Couchbase Server provides a REST API endpoint at `/diag/eval` that 
for advanced node control and configuration. Typically, commands used with
this endpoint involved specialized knowledge of Couchbase Server internals,
and should not be taken lightly or used haphazardly.

### Set ALE Log Level to Error

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
