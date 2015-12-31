# Mac OS X

## Increase Maximum Open Files

The following techniques will persist an increase of maximum open files
to 65536 on Mac OS X systems.

### Version 10.10

Check current open files limit:

```
launchctl limit maxfiles
```

For Mac OS X version 10.10 you must create a property list (.plist) to
increase maximum open files. Create 
`/Library/LaunchDaemons/limit.maxfiles.plist` as root:

```
sudo $EDITOR /Library/LaunchDaemons/limit.maxfiles.plist
```

add this content:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>limit.maxfiles</string>
    <key>ProgramArguments</key>
    <array>
      <string>launchctl</string>
      <string>limit</string>
      <string>maxfiles</string>
      <string>65536</string>
      <string>65536</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>ServiceIPC</key>
    <false/>
  </dict>
</plist>

```

This property list will set maximum open files upon restart, but you can
raise the limits without a restart for the root user as well:

```
sudo launchctl limit maxfiles 65536 65536
```

## Mount Encrypted Disk Image

```
hdiutil attach -stdinpass image_file.dmg
```

## Keychain

Mac OS X provides the `security(1)` command for interfacing with the
underlying security framework and keychains.

### Add Keychain Item

To add a generic password keychain item use a command like this:

```
security -a <account> -s <service> -p <password>
```

To add an internet password keychain item use a command like this:

```
security -v add-internet-password -a <account> -s <server> -w <password>
```

### Unlock Keychain

```
security unlock-keychain
```

## Time Machine Backups

Remove ACLs from manually restored directory of files:

```
sudo chmod -RN <dir>
```

Remove extended attributed from manually restored directory of files:

```
sudo xattr -r -c <dir>
```
