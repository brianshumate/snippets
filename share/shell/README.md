## shell snippets

### Convert Newline Values to Space Separated

Create this space separated list: `1002 1003 1004 1005 1006 1007` given
these newline separated values as the variable VALUES:

```
1002
1003
1004
1005
1006
1007
```

Using `tr` like this:

```
echo $VALUES tr "\n" " "
```

### Create ISO-8601 Dates

```
date +"%Y-%m-%dT%H:%M:%SZ"
```

or

```
date -u +%Y-%m-%dT%H:%M:%S%z
```

### Extract .deb files in BSDish Systems (including Mac OS X)

```
ar vx <filename>
```

Where `<filename>` is replace with the `.deb` file that you wish to extract.

The `.deb` will extract to a series of files which include either `.tar.gz`
or sometimes `.xz` archives containing all packaged files.

### Extract RPM with cpio

```
rpm2cpio file.rpm | cpio -i -d
```
