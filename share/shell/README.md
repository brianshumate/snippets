## Shell snippets

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

### Random-ish String

Get a pseudorandom alphanumeric string of 32 characters in length like so:

```
LC_ALL=C; cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1
```

### Shenanigans with say

```
while true; \
  do say -v ? | awk '{print $1}' | xargs -J% -n 1 say -v % butts; \
done
```

h/t: Andrei Sambra

```
PHRASES=('please help me' 'i am so alone' 'i am lonely' 'pssssst' 'hello' 'hey, listen.' 'they did this to me' 'i must feed' 'power overwhelming'); while true; do say "${WORDS[$[ $[ RANDOM % ${#WORDS[@]} ]]]}" -v Whisper; sleep 300; done
```

```
osascript -e 'say "Dum dum dum dum dum dum dum he he he ho ho ho fa lah lah lah lah lah lah fa lah full hoo hoo hoo" using "Cellos"'
```

```
osascript -e 'say "Dum dum dee dum dum dum dum dee Dum dum dee dum dum dum dum dee dum dee dum dum dum de dum dum dum dee dum dee dum dum dee dummmmmmmmmmmmmmmmm" using "Hysterical"'

```

### Storage Related

Show top 10 largest directories and files in PWD:

```
du -h . | sort -nr | head
```
