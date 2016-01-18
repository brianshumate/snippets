# Python snippets

## Generate Random MAC Addresses

Uuseful for XEN DomU images:

```bash
python -c 'import random; r=random.randint; print "00:16:3E:%02X:%02X:%02X" % (r(0, 0x7f), r(0, 0xff), r(0, 0xff))'
```

## Get CPU Core Count

```
import multiprocessing
multiprocessing.cpu_count()
```

## Pretty Print and Validate JSON

```
cat blah.json | python -mjson.tool
```

or

```
curl http://example.com/rest/api | python -mjson.tool
```

## Serve Files Over HTTP

The following command will make all files in the present working directory
available via HTTP over TCP port *8080*:

```
python -m SimpleHTTPServer 8080
```
