Riak Snippets
=============

`grep` through `cluster_info` logs:

```bash
grep -E '^[a-zA-Z_]+ *<[0-9]\.[0-9]*\.[0-9]> *.*' cluster_info.txt | sort -k 1,1 -s | less
```

Grab LevelDB LOG files:

```bash
mkdir leveldb_logs
cd leveldb_logs
for l in `ls -1 /var/lib/riak/leveldb/`; do cp /var/lib/riak/leveldb/$l/LOG ./LOG_$l; done
```

Find LevelDB compaction errors:

```bash
find </path/to/leveldb> -name LOG -exec grep -l 'Compaction error' {} \;
```

Ping a node with netcat:

```
echo -e "\x00\x00\x00\x01\x01" | nc 127.0.0.1 8087 | hexdump
```
