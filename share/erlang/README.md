# Erlang snippets

## Determine open file limits within Erlang

To verify that an Erlang process is using the correct open file limits 
setting, use this command:

```
erl -setcookie 3a7m3
rpc:call('earl@node07.example.com', os, cmd, ["ulimit -n"]).
```

Don't forget to **CONTROL-D** out of the session.

## Remote Shell

To get a remote Erlang shell on a node, use the following `erl` command:

```bash
erl -remsh earl@node07.example.com -setcookie 3a7m3
```

Note that a few things are different about the remote shell (or remsh):

1. Exit the console with **CONTROL-G q**
2. Lager messages will not be present in a remote shell console
3. The shell can be affected by load and network much as a ssh connection 
   can, and will become unresponsive in such cases
