Couchbase Server Snippets
=========================

## All Statistics

Use `cbastats` to get all node statistics for the *default* bucket:

```
cbstats node01.example.com:11210 all
```

This command example is for a the *fnord* bucket with password authentication:

```
cbstats node01.example.com:11210 all -b fnord -p potrzebie
```
